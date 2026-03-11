#!/usr/bin/env bash
set -euo pipefail

RUNS=5
WARMUP=1
TAG="baseline"
BINARY="${BINARY:-/home/elena/3dfier_doneright/3dfier/build/3dfier}"
CONFIG="${CONFIG:-/home/elena/3dfier_doneright/3dfier/example_data_large/runs/run_20260309T100259Z_d0d36394/03_consolidation/inputs/3dfier_config.yml}"
OUT_ROOT="${OUT_ROOT:-/home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks}"
REPORT_OUT="${REPORT_OUT:-/home/elena/3dfier_doneright/3dfier/docs/performance_benchmark_report.md}"
EXPECTED_HASH="${EXPECTED_HASH:-}"
EQUIV_OBJ="${EQUIV_OBJ:-}"
EQUIV_TOL="${EQUIV_TOL:-1e-4}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --runs) RUNS="$2"; shift 2 ;;
    --warmup) WARMUP="$2"; shift 2 ;;
    --tag) TAG="$2"; shift 2 ;;
    --binary) BINARY="$2"; shift 2 ;;
    --config) CONFIG="$2"; shift 2 ;;
    --out-root) OUT_ROOT="$2"; shift 2 ;;
    --report-out) REPORT_OUT="$2"; shift 2 ;;
    --expected-hash) EXPECTED_HASH="$2"; shift 2 ;;
    --equiv-obj) EQUIV_OBJ="$2"; shift 2 ;;
    --equiv-tol) EQUIV_TOL="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -x "$BINARY" ]]; then
  echo "Binary is missing or not executable: $BINARY" >&2
  exit 1
fi
if [[ ! -f "$CONFIG" ]]; then
  echo "Config file is missing: $CONFIG" >&2
  exit 1
fi
if (( WARMUP < 0 || WARMUP >= RUNS )); then
  echo "Invalid warmup value. Require 0 <= warmup < runs" >&2
  exit 1
fi
if [[ -n "$EQUIV_OBJ" && ! -f "$EQUIV_OBJ" ]]; then
  echo "Equivalence baseline OBJ is missing: $EQUIV_OBJ" >&2
  exit 1
fi
if [[ -n "$EQUIV_OBJ" && -n "$EXPECTED_HASH" ]]; then
  echo "Do not combine --equiv-obj with --expected-hash; pick one correctness mode." >&2
  exit 1
fi
if [[ -n "$EQUIV_OBJ" ]] && ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for --equiv-obj checks." >&2
  exit 1
fi

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$OUT_ROOT/${TAG}_${STAMP}"
mkdir -p "$RUN_DIR"
PERF_CSV="$RUN_DIR/perf.csv"

CONFIG_DIR="$(cd "$(dirname "$CONFIG")" && pwd)"
CONFIG_FILE="$(basename "$CONFIG")"

compare_obj_numeric_equivalence() {
  local baseline_obj="$1"
  local candidate_obj="$2"
  local tol="$3"
  python3 - "$baseline_obj" "$candidate_obj" "$tol" <<'PY'
import sys

baseline_path, candidate_path, tol_arg = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    tol = float(tol_arg)
except ValueError:
    print(f"Invalid tolerance value: {tol_arg}", file=sys.stderr)
    sys.exit(2)

if tol < 0:
    print(f"Tolerance must be >= 0. Got: {tol}", file=sys.stderr)
    sys.exit(2)

def parse_obj(path):
    vertices = []
    faces = []
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        for lineno, line in enumerate(f, 1):
            if line.startswith("v "):
                parts = line.split()
                if len(parts) < 4:
                    print(f"{path}:{lineno}: malformed vertex line", file=sys.stderr)
                    sys.exit(2)
                try:
                    vertices.append((float(parts[1]), float(parts[2]), float(parts[3])))
                except ValueError:
                    print(f"{path}:{lineno}: invalid vertex coordinate", file=sys.stderr)
                    sys.exit(2)
            elif line.startswith("f "):
                faces.append(line.strip())
    return vertices, faces

b_vertices, b_faces = parse_obj(baseline_path)
c_vertices, c_faces = parse_obj(candidate_path)

if len(b_vertices) != len(c_vertices):
    print(
        f"Vertex count mismatch: baseline={len(b_vertices)} candidate={len(c_vertices)}",
        file=sys.stderr,
    )
    sys.exit(1)

if len(b_faces) != len(c_faces):
    print(
        f"Face count mismatch: baseline={len(b_faces)} candidate={len(c_faces)}",
        file=sys.stderr,
    )
    sys.exit(1)

for idx, (bf, cf) in enumerate(zip(b_faces, c_faces), 1):
    if bf != cf:
        print(f"Face order/content mismatch at face index {idx}", file=sys.stderr)
        sys.exit(1)

max_diff = 0.0
max_idx = 0
max_axis = ""
for idx, (bv, cv) in enumerate(zip(b_vertices, c_vertices), 1):
    diffs = [abs(bv[0] - cv[0]), abs(bv[1] - cv[1]), abs(bv[2] - cv[2])]
    local_max = max(diffs)
    if local_max > max_diff:
        max_diff = local_max
        max_idx = idx
        max_axis = ("x", "y", "z")[diffs.index(local_max)]
    if local_max > tol:
        print(
            f"Vertex tolerance mismatch at index {idx}: max axis diff={local_max:.12g} (tol={tol:.12g})",
            file=sys.stderr,
        )
        sys.exit(1)

print(
    f"PASS numeric-equivalence: vertices={len(b_vertices)} faces={len(b_faces)} max_abs_diff={max_diff:.12g} axis={max_axis or 'n/a'} index={max_idx or 0}",
    file=sys.stderr,
)
PY
}

BASELINE_HASH=""
CORRECTNESS_MODE="hash"
CORRECTNESS_SUMMARY="PASS"
for i in $(seq 1 "$RUNS"); do
  OBJ_OUT="$RUN_DIR/run_${i}.obj"
  LOG_OUT="$RUN_DIR/run_${i}.log"

  (
    cd "$CONFIG_DIR"
    "$BINARY" "$CONFIG_FILE" --OBJ "$OBJ_OUT" --perf-csv "$PERF_CSV"
  ) >"$LOG_OUT" 2>&1

  if [[ -n "$EQUIV_OBJ" ]]; then
    CORRECTNESS_MODE="numeric-equivalence"
    if ! compare_obj_numeric_equivalence "$EQUIV_OBJ" "$OBJ_OUT" "$EQUIV_TOL"; then
      CORRECTNESS_SUMMARY="FAIL"
      echo "ERROR: run_${i} failed numeric-equivalence check against baseline OBJ: $EQUIV_OBJ" >&2
      exit 1
    fi
  else
    HASH="$(sha256sum "$OBJ_OUT" | awk '{print $1}')"
    if [[ -z "$BASELINE_HASH" ]]; then
      BASELINE_HASH="$HASH"
      if [[ -n "$EXPECTED_HASH" && "$HASH" != "$EXPECTED_HASH" ]]; then
        CORRECTNESS_SUMMARY="FAIL"
        echo "ERROR: baseline hash mismatch. expected=$EXPECTED_HASH got=$HASH" >&2
        exit 1
      fi
    elif [[ "$HASH" != "$BASELINE_HASH" ]]; then
      CORRECTNESS_SUMMARY="FAIL"
      echo "ERROR: run_${i} OBJ hash mismatch. baseline=$BASELINE_HASH got=$HASH" >&2
      exit 1
    fi
  fi

done

median_from_col() {
  local col_idx="$1"
  local start_line="$((WARMUP + 2))"
  mapfile -t values < <(tail -n +"$start_line" "$PERF_CSV" | awk -F, -v c="$col_idx" '{print $c}' | sort -n)
  local n="${#values[@]}"
  if (( n == 0 )); then
    echo "0"
    return
  fi
  if (( n % 2 == 1 )); then
    echo "${values[$((n/2))]}"
  else
    awk -v a="${values[$((n/2 - 1))]}" -v b="${values[$((n/2))]}" 'BEGIN{printf "%.3f", (a+b)/2.0}'
  fi
}

header="$(head -n 1 "$PERF_CSV")"
idx_for() {
  local name="$1"
  awk -v h="$header" -v n="$name" 'BEGIN{split(h,a,","); for(i=1;i<=length(a);i++) if(a[i]==n){print i; exit}}'
}

IDX_TOTAL="$(idx_for total_runtime_ms)"
IDX_INGEST="$(idx_for points_ingest_ms)"
IDX_INSERT="$(idx_for points_ingest_feature_insert_ms)"
IDX_CDT="$(idx_for cdt_ms)"

MED_TOTAL="$(median_from_col "$IDX_TOTAL")"
MED_INGEST="$(median_from_col "$IDX_INGEST")"
MED_INSERT="$(median_from_col "$IDX_INSERT")"
MED_CDT="$(median_from_col "$IDX_CDT")"

if [[ -n "$EQUIV_OBJ" ]]; then
  CORRECTNESS_SECTION=$(
    cat <<EOF
## Correctness Gate
- Mode: numeric equivalence
- Baseline OBJ: \`$EQUIV_OBJ\`
- Vertex tolerance (abs): \`$EQUIV_TOL\`
- Face count/order: exact match required
- Result: $CORRECTNESS_SUMMARY
EOF
  )
  POLICY_LINE="- Policy: accept optimizations when numeric equivalence to baseline OBJ passes (vertex abs diff <= $EQUIV_TOL, face order/count unchanged) and runtime tradeoff is documented."
else
  CORRECTNESS_SECTION=$(
    cat <<EOF
## Correctness Gate
- Mode: hash
- OBJ hash (all runs): \`$BASELINE_HASH\`
- Hash consistency: PASS
EOF
  )
  POLICY_LINE="- Policy: accept future optimizations only if OBJ hash stays identical (unless explicitly non-equivalent) and runtime tradeoff is documented."
fi

mkdir -p "$(dirname "$REPORT_OUT")"
cat > "$REPORT_OUT" <<REPORT
# 3dfier Benchmark Report (Telemetry Baseline)

## Setup
- Date (UTC): $STAMP
- Branch: $(git rev-parse --abbrev-ref HEAD)
- Commit: $(git rev-parse --short HEAD)
- Binary: $BINARY
- Config: $CONFIG
- Runs: $RUNS
- Warm-up discarded: $WARMUP
- Artifacts: $RUN_DIR
- CSV: $PERF_CSV

$CORRECTNESS_SECTION

## Median Metrics (warm-up discarded)
- total_runtime_ms: $MED_TOTAL
- points_ingest_ms: $MED_INGEST
- points_ingest_feature_insert_ms: $MED_INSERT
- cdt_ms: $MED_CDT

## Notes
- CSV source: $PERF_CSV
$POLICY_LINE
REPORT

echo "Benchmark complete"
echo "Run dir: $RUN_DIR"
echo "Perf CSV: $PERF_CSV"
echo "Report: $REPORT_OUT"
if [[ -n "$EQUIV_OBJ" ]]; then
  echo "Correctness mode: numeric-equivalence"
  echo "Baseline OBJ: $EQUIV_OBJ"
  echo "Vertex tolerance: $EQUIV_TOL"
else
  echo "Baseline hash: $BASELINE_HASH"
fi
