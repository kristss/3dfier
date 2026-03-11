# 3dfier Benchmark Report (Telemetry Baseline)

## Setup
- Date (UTC): 20260311T142956Z
- Branch: perf/telemetry-benchmarking
- Commit: 6208ac1
- Binary: /home/elena/3dfier_doneright/3dfier/build/3dfier
- Config: /home/elena/3dfier_doneright/3dfier/example_data_large/runs/run_20260309T100259Z_d0d36394/03_consolidation/inputs/3dfier_config.yml
- Runs: 5
- Warm-up discarded: 1
- Artifacts: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_baseline_20260311T142956Z

## Correctness Gate
- OBJ hash (all runs): `18019d3e5ae7a2bb14e50b0203ac87ed2ae637ae3a9f236c3c1284643b5837d8`
- Hash consistency: PASS

## Median Metrics (warm-up discarded)
- total_runtime_ms: 24876.677
- points_ingest_ms: 7634.387
- points_ingest_feature_insert_ms: 5329.647
- cdt_ms: 2187.348

## Notes
- CSV source: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_baseline_20260311T142956Z/perf.csv
- Policy: accept future optimizations only if OBJ hash stays identical (unless explicitly non-equivalent) and runtime tradeoff is documented.
