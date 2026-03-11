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

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$OUT_ROOT/${TAG}_${STAMP}"
mkdir -p "$RUN_DIR"
PERF_CSV="$RUN_DIR/perf.csv"

CONFIG_DIR="$(cd "$(dirname "$CONFIG")" && pwd)"
CONFIG_FILE="$(basename "$CONFIG")"

BASELINE_HASH=""
for i in $(seq 1 "$RUNS"); do
  OBJ_OUT="$RUN_DIR/run_${i}.obj"
  LOG_OUT="$RUN_DIR/run_${i}.log"

  (
    cd "$CONFIG_DIR"
    "$BINARY" "$CONFIG_FILE" --OBJ "$OBJ_OUT" --perf-csv "$PERF_CSV"
  ) >"$LOG_OUT" 2>&1

  HASH="$(sha256sum "$OBJ_OUT" | awk '{print $1}')"
  if [[ -z "$BASELINE_HASH" ]]; then
    BASELINE_HASH="$HASH"
    if [[ -n "$EXPECTED_HASH" && "$HASH" != "$EXPECTED_HASH" ]]; then
      echo "ERROR: baseline hash mismatch. expected=$EXPECTED_HASH got=$HASH" >&2
      exit 1
    fi
  elif [[ "$HASH" != "$BASELINE_HASH" ]]; then
    echo "ERROR: run_${i} OBJ hash mismatch. baseline=$BASELINE_HASH got=$HASH" >&2
    exit 1
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

## Correctness Gate
- OBJ hash (all runs): \`$BASELINE_HASH\`
- Hash consistency: PASS

## Median Metrics (warm-up discarded)
- total_runtime_ms: $MED_TOTAL
- points_ingest_ms: $MED_INGEST
- points_ingest_feature_insert_ms: $MED_INSERT
- cdt_ms: $MED_CDT

## Notes
- CSV source: $PERF_CSV
- Policy: accept future optimizations only if OBJ hash stays identical (unless explicitly non-equivalent) and runtime tradeoff is documented.
REPORT

echo "Benchmark complete"
echo "Run dir: $RUN_DIR"
echo "Perf CSV: $PERF_CSV"
echo "Report: $REPORT_OUT"
echo "Baseline hash: $BASELINE_HASH"
