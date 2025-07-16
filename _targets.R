library(targets)
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
  tar_target(payment_methods, get_payment_methods()),
  tar_sql(customers_report, "queries/get_customers.sql"),
  tar_sql(
    payments_report,
    "queries/get_payments.sql",
    params = payment_methods
  ),
  tar_target(
    name = spatial_sim,
    command = {
      # Number of points to simulate
      n <- 10000

      # Simulate n random (x, y) points in the unit square [0,1] x [0,1]
      points <- data.frame(
        x = runif(n, min = 0, max = 1),
        y = runif(n, min = 0, max = 1)
      )

      # Define polynomial coefficients
      beta <- c(
        beta0 = 1,
        beta1 = 2,
        beta2 = -1.5,
        beta3 = 0.5,
        beta4 = 0.75,
        beta5 = -1
      )

      # Simulate z using a 3D polynomial of x and y + random noise
      points$z <- with(
        points,
        beta["beta0"] +
          beta["beta1"] * x +
          beta["beta2"] * y +
          beta["beta3"] * x^2 +
          beta["beta4"] * y^2 +
          beta["beta5"] * x * y +
          rnorm(n, sd = 0.2) # Gaussian noise
      )
      return(points)
    }
  ),
  tar_target(
    name = duckdb_file,
    command = setup_duckdb("database.duckdb")
  ),
  tar_target(
    name = add_sim_data,
    command = {
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)
      on.exit(DBI::dbDisconnect(con))
      table <- as_tibble(spatial_sim)
      dbWriteTable(con, "Spatial_Simulation", table)
    }
  ),
  tar_sql(sim_filter_1, "queries/spatial_filter_1.sql")
)
