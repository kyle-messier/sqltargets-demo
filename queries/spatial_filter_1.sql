-- !preview conn=DBI::dbConnect(duckdb::duckdb(), read_only = TRUE)

with spatial_data as (
  select * from read_parquet('{{ params.parquet_path }}')
),
filtered as (
  select *
  from spatial_data
  where x < {{ params.x_threshold }} and y > {{ params.y_threshold }}
)
select * from filtered;
