

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

  # MENUS -----
  
  # main menu
  output$menu_main <- renderMenu({
    if(is.null(rv_user$user_id)) { # When not logged in
      sidebarMenu(
        id = "tab_main", 
        menuItem("Main",
                 menuSubItem("Home", tabName = "home"),
                 menuSubItem("Create Account", tabName = "create_account"))
      )
    } else { # When logged in
      sidebarMenu(
        id = "tab_main", 
        menuItem("Main",
                 menuSubItem("Home", tabName = "home"))
      )
    }
  })
  
  # profile menu
  output$menu_profile <- renderMenu({
    if(!is.null(rv_user$user_id)) {
      sidebarMenu(
        id = "tab_profile", 
        menuItem("Profile",
                 menuSubItem("Board", tabName = "profile"))
      )
    } else { NULL }
  })
  
  # USER -----
  
  # User - like cookies
  rv_user <- reactiveValues(
    user_id   = NULL,
    user_name = NULL
  )
  
  # Message when logged in
  output$welcome_msg <- renderText({
    if(!is.null(rv_user$user_name)) {
      paste("You are logged in as ", rv_user$user_name)
    } else { NULL }
  })
  
  # UI for login in 
  output$login_ui <- renderUI({
    if(is.null(rv_user$user_id)) {
      list(
        hr(),
        textInput("user_name", "User name or email"),
        passwordInput("user_pw", "Password"),
        actionButton("user_login", "Login", class = "btn-primary"),
        div(style = "padding:10px;", p("or")),
        actionButton("create_account_1", "Create Account", class = "btn-primary")
      )
    } else { NULL }
  })
  
  # UI for login out
  output$logout_ui <- renderUI({
    if(is.null(rv_user$user_id)) {
      NULL
    } else {
      list(
        hr(),
        div(style = "padding:10px;", textOutput("welcome_msg")),
        actionButton("user_logout", "Logout", class = "btn-primary")
      )
    }
  })
  
  # If name or password is not filled disable the login button
  observe({
    if(!is.null(input$user_name)) {
    if(input$user_pw == "" | input$user_name == "") {
      disable("user_login")
    } else {
      enable("user_login")
    }
  }
  })
  
  # Trying to login
  observeEvent(input$user_login, {

    user_ <- pool %>% 
      tbl("user") %>%
      filter(user_name == input$user_name | email == input$user_name) %>% 
      collect()
    
    if(nrow(user_) == 1) {
      # If the password is correct then login
      if(paste(as.character(hash(charToRaw(input$user_pw))), collapse = "") == user_$pw_hash) {
        # Set reactive values of currently logged in person
        rv_user$user_id   <- user_$user_id
        rv_user$user_name <- user_$user_name
        
        updateTabItems(session, "tab_profile", "profile_general")
        
      } else {
        # Reset pw field
        reset("user_name")
        reset("user_pw")
        stop("Wrong username password combination.")
      }
    } else {
      # Reset pw field
      reset("user_name")
      reset("user_pw")
      stop("Wrong username password combination.")
    }
  })
  
  # Logout
  observeEvent(input$user_logout, {
    rv_user$user_id   <- NULL
    rv_user$user_name <- NULL
    
    Sys.sleep(0.5)
    
    updateTabItems(session, "tab_main", "home")
  })
  
  # If create_account button is clicked go to create account tab
  observeEvent(input$create_account_1, {
    updateTabItems(session, "tab_main", "create_account")
  })
  observeEvent(input$create_account_2, {
    updateTabItems(session, "tab_main", "create_account")
  })
  
  
  # PAGE - HOME -----
  
  output$home_ui <- renderUI({
    ui <-  list(p("Welcome to this App"))
    
    ui
  })
  
  
  # CREATE ACCOUNT: MAIN UI PAGE -----
  
  # UI for the page 
  output$create_account_ui <- renderUI({
    ui <- NULL
    if(!is.null(isolate(rv_user$user_id))) {
      ui <- p("Please log out first.")
    } else {
      ui <- list(
        div(
          style = "background-color:white; border:solid 1px #232323; width:80%; 
          max-width:700px; margin:10px auto; padding:15px;",
          div(style = "text-align:center;", h3("Account details")),
          fluidRow(
            column(width = 4, p(id = "input_text", "* User name")),
            column(width = 8, textInput("create_account_name", NULL, value = ""))
          ),
          fluidRow(
            column(width = 4, p(id = "input_text", "Email")),
            column(width = 8, textInput("create_account_email", NULL, value = ""))
          ),
          fluidRow(
            column(width = 4, p(id = "input_text", "* Password")),
            column(width = 8,  passwordInput("create_account_password1", NULL))
          ),
          fluidRow(
            column(width = 4, p(id = "input_text", "* Retype Password")),
            column(width = 8, passwordInput("create_account_password2", NULL))
          ),
          checkboxInput("input_form_disclaimer", "Terms and Conditions: I click therefore I am."),
          actionButton("create_account_button", "Create Account",
                       style = "color: #232323; background-color: #65ff00; border-color: #434343;")
        ),
        div(style = "height:200px")
      )
    }
    ui
  }) 
  
  # CREATE ACCOUNT: CREATE THE ACCOUNT -----
  
  observeEvent(input$create_account_button, {
  
    user_ <- pool %>% 
      tbl("user") %>%
      collect()
    
    # Check if a user name was entered
    if(input$create_account_name == "") {
      showModal(modalDialog(
        title = "User name error",
        "Please enter a user name.",
        easyClose = TRUE, footer = NULL
      ))
      return()
    }
    # Check if user name contains'@'
    if(grepl("@", input$create_account_name)) {
      showModal(modalDialog(
        title = "User name error",
        "User name can't contain '@'",
        easyClose = TRUE, footer = NULL
      ))
      return()
    }
    # Check if account name is unique
    if(input$create_account_name %in% user_$user_name) {
      showModal(modalDialog(
        title = "User name error",
        "User name already taken",
        easyClose = TRUE, footer = NULL
      ))
      return()
    }
    # If email is filled in, check if email address is valid
    if(input$create_account_email != "" & !isValidEmail(input$create_account_email)) {
      showModal(modalDialog(
        title = "Email error",
        "Invalid email address",
        easyClose = TRUE, footer = NULL
      ))
      return()
    }
    # Check if email address is unique 
    if(input$create_account_email %in% user_$email) {
      showModal(modalDialog(
        title = "Email error",
        "Email address already in use",
        easyClose = TRUE, footer = NULL
      ))
      return()
    }
    # Check if password was filled in
    if(input$create_account_password1 == "") {
      showModal(modalDialog(
        title = "Password error",
        "Please enter a password",
        easyClose = TRUE, footer = NULL
      ))
      return()
    }
    # Check if passwords are the same
    if(input$create_account_password1 != input$create_account_password2) {
      showModal(modalDialog(
        title = "Password error",
        "Passwords are not equal",
        easyClose = TRUE, footer = NULL
      ))
      return()
    }
    # Check if passwords are the same
    if(!input$input_form_disclaimer) {
      showModal(modalDialog(
        title = "Terms and Conditions",
        "You have to agree with the terms and conditions to continue",
        easyClose = TRUE, footer = NULL
      ))
      return()
    }
    
    
    # Add new user to user database
    new_user <- tibble(
      user_id     = max(user_$user_id) + 1,
      user_name   = input$create_account_name,
      email       = input$create_account_email,
      pw_hash     = input$create_account_password1 %>% 
        charToRaw() %>% 
        hash() %>% 
        as.character() %>% 
        paste(collapse = ""),
      date_joined = date()
    )
    
    # Add to database
    db_insert_into(pool, "user", new_user)
    
    # Login
    rv_user$user_id   <- new_user$user_id
    rv_user$user_name <- new_user$user_name
    
    # Go to page 2
    updateTabItems(session, "tab_profile", "profile_general")
  })
  
  # PAGE - PROFILE GENERAL -----
  
  output$profile_ui <- renderUI({
    ui <- NULL
    
    if(!is.null(rv_user$user_id)) {
      ui <- p("Welcome to your profile")
    }
    
    ui
  })
  
}) # End server function
