-- !preview conn=DBI::dbConnect(duckdb::duckdb(), "myspatial.duckdb", read_only = TRUE)

with sim1 as (
  select id as id1, x as x1, y as y1
  from Spatial_Simulation_01
),
sim as (
  select id as id2, x as x2, y as y2, z
  from Spatial_Simulation
),
distances as (
  select
    sim1.id1,
    sim1.x1,
    sim1.y1,
    sim.z,
    sqrt(power(sim1.x1 - sim.x2, 2) + power(sim1.y1 - sim.y2, 2)) as distance
  from sim1
  cross join sim
),
ranked as (
  select *,
    row_number() over (partition by id1 order by distance) as rnk
  from distances
),
top5 as (
  select *
  from ranked
  where rnk <= 5
),
mean_z as (
  select id1, x1, y1, avg(z) as mean_z
  from top5
  group by id1, x1, y1
)
select * from mean_z;
