# 3dfier Benchmark Report (Telemetry Baseline, Numeric Gate)

## Setup
- Date (UTC): 20260311T182031Z
- Branch: perf/telemetry-benchmarking
- Commit: a3c8733
- Binary: /home/elena/3dfier_doneright/3dfier/build/3dfier
- Config: /home/elena/3dfier_doneright/3dfier/example_data_large/runs/run_20260309T100259Z_d0d36394/03_consolidation/inputs/3dfier_config.yml
- Runs: 5
- Warm-up discarded: 1
- Artifacts (new baseline): /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_reverted_20260311T182031Z
- CSV (new baseline): /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_reverted_20260311T182031Z/perf.csv

## Correctness Gate
- Mode: numeric equivalence
- Baseline OBJ (for future runs): `/home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_reverted_20260311T182031Z/run_1.obj`
- Vertex tolerance (abs): `1e-4`
- Face count/order: exact match required
- Result: PASS

## Median Metrics (warm-up discarded)
- total_runtime_ms: 18792.851
- points_ingest_ms: 8204.069
- points_ingest_feature_insert_ms: 5811.477
- cdt_ms: 2149.753

## Notes
- CSV source: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_reverted_20260311T182031Z/perf.csv
- Policy: accept optimizations when numeric equivalence to baseline OBJ passes (vertex abs diff <= 1e-4, face order/count unchanged) and runtime tradeoff is documented.
- Promotion note: this run is adopted as the new benchmark baseline.
