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

captcha <- c(one = 1, two = 2, three = 3, four = 4, five = 5,
             six = 6, seven = 7, eight = 8, nine = 9)
