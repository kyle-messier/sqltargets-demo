library(targets)
library(tarchetypes)
library(sqltargets)
library(tidyverse)
library(sf)
library(terra)
library(qs2)
library(arrow)
library(crew)
library(dplyr)

tar_option_set(
  packages = c(
    "DBI",
    "duckdb",
    "sf",
    "tarchetypes",
    "sqltargets",
    "qs2",
    "arrow",
    "crew",
    "dplyr",
    "terra",
    "tidyverse"
  )
)

tar_source()

sqltargets_option_set("sqltargets.template_engine", "jinjar")

list(
  tar_target(
    params,
    command = {
      # add sim_combined target to the list to chain the pipeline together
      list(parquet_path = "_targets/objects/sim_combined", x_threshold = 0.051, y_threshold = 0.09, sim_combined)
    }
  ),
  tar_target(
    name = MC_iteration,
    command = sample(c(1000, 5000, 10000), size = 10, replace = TRUE)
  ),
  tar_target(
    name = spatial_sim,
    command = simulate_spatial_data(MC_iteration),
    format = "parquet",
    resources = targets::tar_resources(
      parquet = targets::tar_resources_parquet(compression = "lz4")
    ),
    pattern = map(MC_iteration),
    iteration = "list"
  ),
  tar_target(
    name = file_paths,
    command = {
      spatial_sim
      list(parquet_paths = list.files("_targets/objects/", pattern = "spatial_sim", full.names = TRUE))
    }
  ),
  tar_sql(
    sim_combined,
    "queries/combine_parquet.sql",
    params = file_paths,
    format = "parquet",
    resources = targets::tar_resources(
      parquet = targets::tar_resources_parquet(compression = "lz4")
    )
  ),
  tar_sql(
    # We can use the DuckDB connection to run SQL queries
    # and return the results as a target (e.g., a data frame)
    sim_filter_1,
    "queries/spatial_filter_1.sql",
    params = params
  ),
  tar_target(
    sf_pred_calc_split,
    qs_read("beethoven_files/sf_pred_calc_split"),
    iteration = "vector"
  ),
  tar_target(
    df_pred_calc_gridcoords,
    qs_read("beethoven_files/df_pred_calc_gridcoords")
  ),
  targets::tar_target(
    list_pred_calc_grid,
    command = {
      grid_unit <- sf::st_bbox(sf_pred_calc_split)
      sf::st_as_sf(
        df_pred_calc_gridcoords |>
          dplyr::filter(
            (lon <= grid_unit[3] & lon >= grid_unit[1]) &
              (lat <= grid_unit[4] & lat >= grid_unit[2])
          ),
        coords = c("lon", "lat"),
        crs = 4326,
        remove = FALSE
      )
    },
    iteration = "list",
    pattern = map(sf_pred_calc_split),
    resources = targets::tar_resources(
      parquet = targets::tar_resources_parquet(compression = "lz4")
    )
  )
)

# To Do:
# 1) Add rows to current DuckDB table
# - Result 1: hard coded target with DBI append works
# - Wakey ordering of targets
# 2) Add a new table to the DuckDB database
# Result: Works easy!
# 3) Add new columns to the existing table
# 4) Add a new query to the DuckDB database
# 5) Query that involves multiple tables
# 6) Try {sf} based queries with {duckspatial}

# If updating the DDB does not work, try tracking with hashing approach
# with an ingest+hash function

# If this works and is fast - think about how
# DuckDB can be used to store/access all of the major data
# in Beethoven
