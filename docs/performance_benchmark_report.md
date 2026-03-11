# 3dfier Benchmark Report (exp-six: adjacency + stitching)

## Setup
- Date (UTC): 20260311T164457Z
- Branch: perf/exp-five
- Commit: 80ff32a
- Binary: /home/elena/3dfier_doneright/3dfier/build/3dfier
- Config: /home/elena/3dfier_doneright/3dfier/example_data_large/runs/run_20260309T100259Z_d0d36394/03_consolidation/inputs/3dfier_config.yml
- Runs: 5
- Warm-up discarded: 1
- Artifacts: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/exp_six_adjstitch_20260311T164457Z

## Correctness Gate
- OBJ hash (all runs): `18019d3e5ae7a2bb14e50b0203ac87ed2ae637ae3a9f236c3c1284643b5837d8`
- Hash consistency: PASS

## Median Metrics (warm-up discarded)
- total_runtime_ms: 18293.927
- points_ingest_ms: 7928.633
- points_ingest_feature_insert_ms: 5560.967
- cdt_ms: 2134.191

## Notes
- CSV source: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/exp_six_adjstitch_20260311T164457Z/perf.csv
- Policy: accept future optimizations only if OBJ hash stays identical (unless explicitly non-equivalent) and runtime tradeoff is documented.

## Experiment Note
- Comparison baseline: `/home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/exp_five_20260311T163215Z/perf.csv`
- Protocol: 5 runs total, discard run 1, compare medians.
- Correctness: OBJ hash unchanged (`18019d3e5ae7a2bb14e50b0203ac87ed2ae637ae3a9f236c3c1284643b5837d8`).

Median deltas (`exp-six` minus `exp-five`):
- `adjacent_collection_ms`: `2248.226 - 2384.148 = -135.922 ms` (`-5.70%`)
- `stitching_ms`: `2627.287 - 3116.435 = -489.148 ms` (`-15.70%`)
- `adjacent_collection_ms + stitching_ms`: `4875.513 - 5500.583 = -625.070 ms` (`-11.36%`)
- `total_runtime_ms`: `18293.927 - 19739.030 = -1445.103 ms` (`-7.32%`)
