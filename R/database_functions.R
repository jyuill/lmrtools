# functions to access the LMR database

#' Establish a connection to the LMR database
#' @return A DBI connection object to the LMR database (technically Fig4)
#' @importFrom DBI dbConnect
#' @export
get_con <- function() {
  DBI::dbConnect(
    RPostgres::Postgres(),
    dbname   = Sys.getenv("FIG4_DB_NAME"),
    host     = Sys.getenv("FIG4_DB_HOST_ENDPT"),
    user     = Sys.getenv("FIG4_DB_USER"),
    password = Sys.getenv("FIG4_DB_PWD"),
    port     = as.numeric(Sys.getenv("FIG4_DB_PORT"))
  )
}

#' List the tables in the LMR database
#' @return A character vector of table names
#' @importFrom DBI dbListTables dbDisconnect
#' @export
list_tables <- function() {
  con <- get_con() ## use connection function
  tables <- DBI::dbListTables(con) # check connection by getting list of tables
  ## always disconnect when done
  DBI::dbDisconnect(con)
  return(tables)
}

#' fetch any lmr (fig4)table data - uses new dbx_get_con function for ease of use
#' defaults to main data table
#' use for: quick fetch any raw table
#' for lmr data with filters: use fetch_LMR_filtered
#' @return A data frame of the requested table data
#' @param db_tbl Character string of the table name to fetch (default: "public
#' @export
fetch_db_basic <- function(db_tbl="public.lmr_data") {
  con <- get_con()
  # query - get all data
  data_db <- DBI::dbGetQuery(con, glue::glue("SELECT * FROM {db_tbl};"))
  ## always disconnect when done
  DBI::dbDisconnect(con)
  # pass back data
  return(data_db)
}

#' fetch lmr data with optional filters
#' @return A data frame of the requested table data
#' @param cat_type Character string of category type (default: NULL)
#' @param category Character string of category (default: NULL)
#' @param subcategory Character string of subcategory (default: NULL)
#' @param min_qtr Character string of min qtr as FY20XXQX (default: NULL)
#' @param max_qtr Character string of max qtr as FY20XXQX (default: NULL)
#' @export
fetch_lmr_filter <- function(cat_type=NULL, category=NULL, subcategory=NULL, 
                              min_qtr=NULL, max_qtr=NULL) {
  # set target values for query
  target_cat_type <- ifelse(is.null(cat_type), NA, cat_type)
  target_category <- ifelse(is.null(category), NA, category)
  target_subcategory <- ifelse(is.null(subcategory), NA, subcategory)
  target_min_qtr <- ifelse(is.null(min_qtr), NA, min_qtr)
  target_max_qtr <- ifelse(is.null(max_qtr), NA, max_qtr)
  # make connection
  con <- get_con()
  # query - will apply filters if set, otherwise will return all records
  data_db <- DBI::dbGetQuery(con, "SELECT * FROM public.lmr_data
                                  WHERE 
                                  (cat_type=$1 OR $1 IS NULL) AND 
                                  (category=$2 OR $2 IS NULL) AND 
                                  (subcategory=$3 OR $3 IS NULL) AND
                                  (fy_qtr>= $4 OR $4 IS NULL) AND 
                                  (fy_qtr<= $5 OR $5 IS NULL);",
                                params = list(
                                  target_cat_type,
                                  target_category,
                                  target_subcategory,
                                  target_min_qtr,
                                  target_max_qtr
                                ))
  ## disconnect when done
  DBI::dbDisconnect(con)
  # pass back data
  return(data_db)
}

#' fetch complete lmr data with optional filters
#' includes quarter info and short names; optionally, short names can replace originals
#' @return A data frame of the requested table data
#' @param replace Logical - replace original category names with short names
#' @param cat_type Character string of category type (default: NULL)
#' @param category Character string of category (default: NULL)
#' @param subcategory Character string of subcategory (default: NULL)
#' @param min_end_qtr_dt date YYYY-MM-DD (default: NULL)
#' @param max_end_qtr_dt date YYYY-MM-DD (default: NULL)
#' @importFrom dplyr mutate filter select
#' @export
fetch_lmr_complete_filter <- function(replace=FALSE,
                                cat_type=NULL, category=NULL, subcategory=NULL, 
                                min_end_qtr_dt=NULL, 
                                max_end_qtr_dt=NULL) {
  # set target values for filters (optional)
  target_cat_type <- ifelse(is.null(cat_type), NA, cat_type)
  target_category <- ifelse(is.null(category), NA, category)
  target_subcategory <- ifelse(is.null(subcategory), NA, subcategory)
  target_min_qtr <- ifelse(is.null(min_end_qtr_dt), NA, min_end_qtr_dt)
  target_max_qtr <- ifelse(is.null(max_end_qtr_dt), NA, max_end_qtr_dt)
  # set up query
  query <- "SELECT lmr.*
                          , qtr.fyr
                          , qtr.qtr
                          , qtr.end_qtr
                          , qtr.end_qtr_dt
                          , qtr.cyr
                          , qtr.season
                          , qtr.cqtr
                          , l_cat_type.cat_type_short 
                          , l_cat.category_short
                          , l_subcat.subcategory_short
                          FROM public.lmr_data lmr 
                          LEFT JOIN public.lmr_quarters qtr 
                            ON lmr.fy_qtr = qtr.fy_qtr
                          LEFT JOIN public.lmr_shortname_cat_type l_cat_type
                            ON lmr.cat_type = l_cat_type.cat_type
                          LEFT JOIN public.lmr_shortname_category l_cat 
                            ON lmr.category = l_cat.category
                          LEFT JOIN public.lmr_shortname_subcategory l_subcat 
                            ON lmr.subcategory = l_subcat.subcategory
                          WHERE 
                            (cat_type_short=$1 OR $1 IS NULL) AND 
                            (category_short=$2 OR $2 IS NULL) AND 
                            (subcategory_short=$3 OR $3 IS NULL) AND
                            (end_qtr_dt>= $4 OR $4 IS NULL) AND 
                            (end_qtr_dt<= $5 OR $5 IS NULL);"
  con <- get_con()
  lmr_data_db <- DBI::dbGetQuery(con, query,
                           params = list(
                             target_cat_type,
                             target_category,
                             target_subcategory,
                             target_min_qtr,
                             target_max_qtr
                           ))
  # disconnect when done
  DBI::dbDisconnect(con)
  # replace original names with short names
    if(replace==TRUE){
      lmr_data_db <- lmr_data_db |> dplyr::mutate(
        cat_type = cat_type_short,
        category = category_short,
        subcategory = subcategory_short
      ) |> 
        dplyr::select(-cat_type_short, -category_short, -subcategory_short)
    }
  # pass back data
  return(lmr_data_db)
}