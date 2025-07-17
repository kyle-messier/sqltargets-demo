ingest_data <- function(source_file, duckdb_file, table_name) {
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)
  on.exit(DBI::dbDisconnect(con))

  df <- readr::read_csv(
    source_file,
    col_types = readr::cols(
      .default = readr::col_character()
    ),
  ) |>
    janitor::clean_names()

  DBI::dbWriteTable(con, table_name, df, overwrite = TRUE)

  hash <- dplyr::tbl(con, table_name) |>
    dplyr::collect() |>
    digest::digest()
}

handle_inputs <- function(schema, table, query) {
  if (missing(query) && (missing(schema) || missing(table))) {
    stop(
      glue::glue_collapse(
        "Either 'schema' and 'table' must be provided together or ",
        "just 'query' should be provided."
      )
    )
  }
}

get_table_checksum <- function(
  schema = NULL,
  table = NULL,
  query = NULL,
  con = NULL
) {
  handle_inputs(schema, table, query)
  if (!missing(table)) {
    logger::log_info("Fetching checksum from {schema}.{table}")
    checksum_query <- glue::glue(
      "SELECT md5(array_agg(t.*)::text) AS checksum FROM {schema}.{table} t"
    )
  } else {
    checksum_query <- glue::glue(
      "SELECT md5(array_agg(t.*)::text) AS checksum FROM ({query}) t"
    )
  }

  checksum <- DBI::dbGetQuery(con, statement = checksum_query)$checksum

  msg <- ifelse(is.null(table), "query", glue::glue("{schema}.{table}"))
  logger::log_info("Checksum for {msg} is {checksum}")

  return(checksum)
}
