library(targets)
library(tarchetypes)
library(sqltargets)
library(tidyverse)

tar_option_set(
  packages = c(
    "DBI",
    "duckdb"
  ),
  format = "rds"
)

tar_source()

sqltargets_option_set("sqltargets.template_engine", "jinjar")

list(
  tar_target(
    name = spatial_sim_base,
    command = simulate_spatial_data(10000)
  ),
  tar_target(
    # Shows we can create a DuckDB database file from a target
    # https://github.com/philiporlando/docker-duckdb-r/blob/main/R/setup_duckdb.R #nolint
    name = duckdb_file,
    command = setup_duckdb("myspatial.duckdb")
  ),
  tar_target(
    # This target shows we can open/close a DuckDB connection
    # and write a target to it
    name = add_sim_data,
    command = {
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)
      on.exit(DBI::dbDisconnect(con))
      table <- as_tibble(spatial_sim_base)
      dbWriteTable(
        con,
        "Spatial_Simulation",
        table,
        overwrite = TRUE,
        row.names = FALSE
      )
    }
  ),
  tar_target(
    params,
    command = {
      # add_sim_data # To chain the pipeline together
      list(x_threshold = 0.051, y_threshold = 0.09)
    }
  ),
  tar_sql(
    # We can use the DuckDB connection to run SQL queries
    # and return the results as a target (e.g., a data frame)
    sim_filter_1,
    "queries/spatial_filter_1.sql",
    params = params
  ),
  tar_target(
    name = spatial_sim_01,
    command = simulate_spatial_data(100)
  ),
  tar_target(
    # This target shows we can open/close a DuckDB connection
    # and write a target to it
    name = append_data,
    command = {
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)
      on.exit(DBI::dbDisconnect(con))
      table <- as_tibble(spatial_sim_01)
      dbWriteTable(
        con,
        "Spatial_Simulation_01",
        table,
        append = FALSE,
        row.names = FALSE
      )
    }
  ),
  tar_sql(
    sim_closest_mean,
    "queries/closest_mean.sql"
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
