
# Check if an email address is valid
isValidEmail <- function(x) {
  grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", 
        as.character(x), 
        ignore.case = TRUE)
}