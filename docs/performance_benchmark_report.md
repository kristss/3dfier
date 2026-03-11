# 3dfier Benchmark Report (exp-five)

## Setup
- Date (UTC): 20260311T163215Z
- Branch: perf/exp-five
- Commit: e1efb6a
- Binary: /home/elena/3dfier_doneright/3dfier/build/3dfier
- Config: /home/elena/3dfier_doneright/3dfier/example_data_large/runs/run_20260309T100259Z_d0d36394/03_consolidation/inputs/3dfier_config.yml
- Runs: 5
- Warm-up discarded: 1
- Artifacts: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/exp_five_20260311T163215Z

## Correctness Gate
- OBJ hash (all runs): `18019d3e5ae7a2bb14e50b0203ac87ed2ae637ae3a9f236c3c1284643b5837d8`
- Hash consistency: PASS

## Median Metrics (warm-up discarded)
- total_runtime_ms: 19739.030
- points_ingest_ms: 8255.664
- points_ingest_feature_insert_ms: 5771.020
- cdt_ms: 2097.064

## Notes
- CSV source: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/exp_five_20260311T163215Z/perf.csv
- Policy: accept future optimizations only if OBJ hash stays identical (unless explicitly non-equivalent) and runtime tradeoff is documented.

## Experiment Note (Strict-Equivalent Terrain Patch)
- Baseline for comparison (matching telemetry schema): `/home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_perclass_20260311T162408Z/perf.csv`
- Protocol: 5 runs total, drop run 1, compare medians.
- Correctness: OBJ hash identical to baseline (`18019d3e5ae7a2bb14e50b0203ac87ed2ae637ae3a9f236c3c1284643b5837d8`).

Median deltas (`exp-five` minus baseline):
- `total_runtime_ms`: `19739.030 - 20449.364 = -710.334 ms` (`-3.47%`)
- `points_ingest_ms`: `8255.664 - 9009.609 = -753.945 ms` (`-8.37%`)
- `points_ingest_feature_insert_ms`: `5771.020 - 6587.559 = -816.539 ms` (`-12.40%`)
- `points_ingest_feature_insert_terrain_ms`: `4623.269 - 5458.304 = -835.035 ms` (`-15.30%`)
- `point_in_polygon_ms`: `3924.762 - 4793.213 = -868.451 ms` (`-18.12%`)
