# Telemetry Benchmark Workflow

## Branching Model
- Long-lived baseline branch: `perf/telemetry-benchmarking`
- Per enhancement: create `perf/exp-<short-name>` from `perf/telemetry-benchmarking`
- Do not stack experiments on top of other experiment branches

## Required Gates
- Correctness gate: OBJ numeric-equivalence must pass against the chosen baseline OBJ
- Numeric-equivalence rule: same face count/order and per-vertex absolute diff `<= 1e-4`
- Performance gate: run 5 times, discard first run, compare medians
- Key metrics: `total_runtime_ms`, `points_ingest_ms`, `points_ingest_feature_insert_ms`, `cdt_ms`

## Standard Benchmark Command
```bash
scripts/benchmark_large_example.sh \
  --runs 5 \
  --warmup 1 \
  --tag telemetry_baseline \
  --equiv-obj /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_reverted_20260311T182031Z/run_1.obj \
  --equiv-tol 1e-4
```

## Current Baseline
- Baseline artifacts: `/home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_reverted_20260311T182031Z`
- Baseline CSV: `/home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_reverted_20260311T182031Z/perf.csv`
- Baseline OBJ for equivalence: `/home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_reverted_20260311T182031Z/run_1.obj`

## Artifact Policy
- Raw artifacts (OBJ/CSV/log) stay untracked under `example_data_large/output/benchmarks/`
- Commit only concise markdown summaries in `docs/`

## Suggested Commit Sequence
1. `perf: add runtime telemetry stats and csv export`
2. `bench: add repeatable large-example benchmark runner and summary template`
3. `docs: add telemetry benchmarking protocol and baseline results`
