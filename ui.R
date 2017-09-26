

# Define UI for application that draws a histogram
shinyUI(dashboardPage(
  skin = "green",
  
  dashboardHeader(title = "User App"),
  
  dashboardSidebar(
    sidebarMenuOutput("menu_main"),
    sidebarMenuOutput("menu_profile"),
    uiOutput("login_ui"),
    uiOutput("logout_ui")
  ),
  
  dashboardBody(
    # Start tabitems -----
    tabItems(
      tabItem(
        tabName = "home",
        uiOutput("home_ui")
      ),
      tabItem(
        tabName = "create_account",
        uiOutput("create_account_ui")
      ),
      tabItem(
        tabName = "profile",
        uiOutput("profile_ui")
      )
    ),
    # Footer -----
    div(style = "width:100%; height:50px; background-color:#232323; position:fixed; bottom:0;
         right:0; color:#ececec; text-align:center;")
  )
))
