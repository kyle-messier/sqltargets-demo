-- !preview conn=DBI::dbConnect(duckdb::duckdb(), "database.duckdb", read_only = TRUE)

with spatial_data as (
  select * from Spatial_Simulation
),
filtered as (
  select *
  from spatial_data
  where x < 0.1 and y > 0.9
)
select * from filtered;
