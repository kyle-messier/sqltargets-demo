-- !preview conn=DBI::dbConnect(duckdb::duckdb(), read_only = TRUE)

with
parquet1 as (
  select * from read_parquet('_targets/objects/spatial_sim_base')
),
parquet2 as (
  select * from read_parquet('_targets/objects/spatial_sim_01')
),
combined as (
  select * from parquet1
  union all
  select * from parquet2
)
select * from combined;
