# Declare global variables to avoid check notes
# - alternatively could use .data pronoun from rlang package
#   - .data$cat_type, .data$category, etc
if (getRversion() >= "4.0.0") {
  utils::globalVariables(
    c(
      # Column names used by data frame(s)
      "cat_type", 
      "category", 
      "subcategory", 
      "fy_qtr",
      "fyr", 
      "qtr", 
      "cyr", 
      "cqtr", 
      "end_qtr_dt",
      "season",
      "cat_type_short",
      "category_short",
      "subcategory_short",
      
      # The pipe dot (if using magrittr)
      "."
    )
  )
}