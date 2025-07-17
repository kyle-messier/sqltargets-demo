-- !preview conn=DBI::dbConnect(duckdb::duckdb(), "myspatial.duckdb", read_only = TRUE)

with spatial_data as (
  select * from Spatial_Simulation
),
filtered as (
  select *
  from spatial_data
  where x < {{ params.x_threshold }} and y > {{ params.y_threshold }}
)
select * from filtered;
