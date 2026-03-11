# 3dfier Benchmark Report (Telemetry Post-Merge)

## Setup
- Date (UTC): 20260311T165254Z
- Branch: perf/telemetry-benchmarking
- Commit: 3cd181a
- Binary: /home/elena/3dfier_doneright/3dfier/build/3dfier
- Config: /home/elena/3dfier_doneright/3dfier/example_data_large/runs/run_20260309T100259Z_d0d36394/03_consolidation/inputs/3dfier_config.yml
- Runs: 5
- Warm-up discarded: 1
- Artifacts: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_20260311T165254Z
- CSV: /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_post_merge_20260311T165254Z/perf.csv

## Run Protocol
- Run benchmark 5 times.
- Discard run 1 (warm-up).
- Compare medians.
- Accept only if OBJ hash is identical to telemetry baseline.

## Correctness Gate
- Baseline hash target: `18019d3e5ae7a2bb14e50b0203ac87ed2ae637ae3a9f236c3c1284643b5837d8`
- OBJ hash (runs 1-5): all identical to baseline hash
- Result: PASS

## Current Medians (warm-up discarded)
- total_runtime_ms: 18090.232
- points_ingest_ms: 7727.137
- points_ingest_feature_insert_ms: 5511.626
- points_ingest_feature_insert_terrain_ms: 4397.316
- point_in_polygon_ms: 3728.245
- adjacent_collection_ms: 2238.664
- stitching_ms: 2607.193
- cdt_ms: 2094.256

## Current Hotspot Share
- points_ingest_feature_insert_terrain_ms: 24.31% of total
- point_in_polygon_ms: 20.61% of total
- stitching_ms: 14.41% of total
- adjacent_collection_ms: 12.37% of total
- cdt_ms: 11.58% of total

## Delta Vs Telemetry Per-Class Baseline
Reference:
- /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/telemetry_perclass_20260311T162408Z/perf.csv

Medians (`current - baseline`):
- total_runtime_ms: `18090.232 - 20449.364 = -2359.132 ms` (`-11.54%`)
- points_ingest_ms: `7727.137 - 9009.609 = -1282.472 ms` (`-14.23%`)
- points_ingest_feature_insert_ms: `5511.626 - 6587.559 = -1075.934 ms` (`-16.33%`)
- points_ingest_feature_insert_terrain_ms: `4397.316 - 5458.304 = -1060.988 ms` (`-19.44%`)
- point_in_polygon_ms: `3728.245 - 4793.213 = -1064.968 ms` (`-22.22%`)
- adjacent_collection_ms: `2238.664 - 2353.936 = -115.272 ms` (`-4.90%`)
- stitching_ms: `2607.193 - 3256.006 = -648.813 ms` (`-19.93%`)
- adjacent_collection_ms + stitching_ms: `4845.857 - 5609.942 = -764.085 ms` (`-13.62%`)
- cdt_ms: `2094.256 - 2082.180 = +12.076 ms` (`+0.58%`)

## Delta Vs exp-six
Reference:
- /home/elena/3dfier_doneright/3dfier/example_data_large/output/benchmarks/exp_six_adjstitch_20260311T164457Z/perf.csv

Medians (`current - exp-six`):
- total_runtime_ms: `18090.232 - 18293.927 = -203.694 ms` (`-1.11%`)
- points_ingest_feature_insert_terrain_ms: `4397.316 - 4472.641 = -75.325 ms` (`-1.68%`)
- point_in_polygon_ms: `3728.245 - 3822.940 = -94.695 ms` (`-2.48%`)
- adjacent_collection_ms + stitching_ms: `4845.857 - 4875.513 = -29.656 ms` (`-0.61%`)

## Notes
- `exp-three` was targeted for telemetry merge but was redundant with newer `exp-six` changes (empty cherry-pick).
- `exp-one` was merged as commit `3cd181a` (within-range check ordering), with strict-equivalence preserved.
