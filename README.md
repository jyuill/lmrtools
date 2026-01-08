# lmrtools

An R package for working with Figure 4 LMR database. The main purpose is for **standardized queries to the database for purposes of reporting and analysis** in different contexts.

## Installation

\``devtools::install_github("jyuill/lmrtools")`\`

> will need to reinstall any time there are updates.

## Getting credentials

To access the LMR database, you need to obtain credentials:

-   db name
-   host endpoint
-   username
-   password
-   port number

These are available from the **local version of package repo** (NOT Github) or some other repos related to LMR work. Once you have these assembled:

-   `usethis::edit_r_environ(scope="user")`
    -   "user" scope means will be available for any project on the computer
    -   "project" in case just want to apply to individual project for some reason
-   paste into **.Renviron** file that pops up (or may have to type if copy/paste doesn't work)
-   *ENSURE to add .Renviron to .gitignore*

## Usage

Once installed, refer to `lmrtools::` to see available functions.

Notable ones so far:

-   `list_tables()` : all the tables for LMR, indeed everything in the Figure 4 database

-   `fetch_db_basic()` : query any table in the database; defaults to lmr_data

-   `fetch_lmr_complete_filter()` : most flexible option for retrieving LMR data, since it queries raw lmr_data table joined with additional quarter info and short versions of category type, category, and subcategory names. PLUS, can filter by category type, category, subcategory or date range (end of quarter date).

    -   using parameter replace=TRUE in the function results in short names for category type, category, subcategory replacing original names

## Updating

It is expected the package will evolve. Main steps in updating (as far as I understand) are:

1.  **database_functions.R**: add or edit functions as desired.
2.  follow existing examples with use of \#' comments, @return, @parameters, @export, @import, etc.
3.  use package names in functions: `DBI::dbConnect`
4.  `devtools::use_package('<pkg name>')` if new packages are needed
5.  `devtools::load_all()` to test locally.
6.  `devtools::document()` to update documentation.
7.  `devtools::check()` to run diagnostics -\> address issues as needed.
8.  `devtools::install()` to prepare for release.
9.  Push to Github repo
10. install updates in projects with `devtools::install_github('jyuill/lmrtools')`

## Documentation

Documentation is created for the package by using `#'` comments.

-   Run `devtools::document()` to update documentation
    -   will add/edit files to `/man` folder -\> do not make manual changes; manage through `#'` comments in package code
-   DESCRIPTION file can be manually edited.

Documentation can be accessed by users via:

-   **The Help Query:** Type `?get_lmr_data` or `help("fetch_db_basic")` in the console.

-   **The Index:** Type `help(package = "lmrtools")` to see a list of every documented function in your library.

    -   provides access to the DESCRIPTION file

-   **Autocomplete:** In Positron, when you start typing your function name, a hover-box will appear showing the title and parameters you wrote in your Roxygen comments.