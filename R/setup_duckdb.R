setup_duckdb <- function(db_path = "data/database.duckdb") {
    duckdb_file <- db_path

    if (!file.exists(duckdb_file)) {
        con <- DBI::dbConnect(
            duckdb::duckdb(),
            dbdir = duckdb_file,
            read_only = FALSE
        )
        DBI::dbDisconnect(con, shutdown = TRUE)
    }

    return(duckdb_file)
}
