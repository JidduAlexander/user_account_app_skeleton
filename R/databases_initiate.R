library(tibble)
library(purrr)
library(sodium)
library(RSQLite)

# User database

db_user <- tibble(
  user_id     = c(1),
  user_name   = c("Admin"),
  email       = c("admin@website.com"),
  pw_hash     = map_chr(c("pw"), function(x) paste(as.character(hash(charToRaw(x))), collapse = "")),
  date_joined = date()
)

con <- dbConnect(SQLite(), "input/database.sqlite")

dbWriteTable(con, name="user", value= db_user, row.names=FALSE, append=TRUE)

dbDisconnect(con)

