library(shiny)
library(shinyjs)
library(shinydashboard)
library(tidyverse)
library(sodium)
library(RSQLite)
library(DBI)
library(pool)

source("R/functions.R")

pool <- dbPool(RSQLite::SQLite(), dbname = "input/database.sqlite")

