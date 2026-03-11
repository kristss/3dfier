# 3dfier Benchmark Report (Telemetry Baseline)

## Setup
- Date (UTC): 20260311T154501Z
- Branch: perf/telemetry-benchmarking
- Commit: fe04f56
- Binary: /home/elena/3dfier_doneright/3dfier/build/3dfier
- Config: /home/elena/3dfier_doneright/3dfier/example_data_large/runs/run_20260309T100259Z_d0d36394/03_consolidation/inputs/3dfier_config.yml
- Runs: 5
- Warm-up discarded: 1
- Artifacts: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_baseline_post_exp_two_20260311T154501Z

## Correctness Gate
- OBJ hash (all runs): `18019d3e5ae7a2bb14e50b0203ac87ed2ae637ae3a9f236c3c1284643b5837d8`
- Hash consistency: PASS

## Median Metrics (warm-up discarded)
- total_runtime_ms: 19525.046
- points_ingest_ms: 8150.613
- points_ingest_feature_insert_ms: 5920.658
- cdt_ms: 2099.574

## Notes
- CSV source: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_baseline_post_exp_two_20260311T154501Z/perf.csv
- Policy: accept future optimizations only if OBJ hash stays identical (unless explicitly non-equivalent) and runtime tradeoff is documented.
