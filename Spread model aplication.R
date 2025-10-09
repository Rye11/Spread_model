library(shiny)
library(deSolve)
library(ggplot2)
library(dplyr)
library(scales)
library(tidyr)
library(bslib)
library(shinydashboard)

termite_model <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    
    is_forage_time <- (floor(time) %% forage_interval) == 0 & time > 0
    new_Iw_forage <- 0  
    
    if (is_forage_time) {
      susceptible_w <- Sw  
      susceptible_w_ratio <- susceptible_w / 0.7 
      new_Iw_forage <- susceptible_w * (forage_infect_rate / 100) * susceptible_w_ratio
      new_Iw_forage <- min(new_Iw_forage, susceptible_w)  
    }
    
    
    dSw <- -Sw * beta_w * Iw + mu_w * Iw - new_Iw_forage  
    dIw <- Sw * beta_w * Iw - Iw * (gamma_w + mu_w) + new_Iw_forage  
    dDw <- Iw * gamma_w 
    
    
    dSr <- -Sr * beta_r * Iw + mu_r * Er
    dEr <- Sr * beta_r * Iw - Er * (mu_r + gamma_r)
    dDr <- Er * gamma_r  
    
    
    dSy <- -Sy * beta_y * (Iw + Iy + In) + mu_y * Iy
    dIy <- Sy * beta_y * (Iw + Iy + In) - Iy * (mu_y + gamma_y)
    dDy <- Iy * gamma_y 
    
    
    dSs <- -Ss * beta_s * (Iw + In) + mu_s * Es
    dEs <- Ss * beta_s * (Iw + In) - Es * (mu_s + gamma_s)
    dDs <- Es * gamma_s  
    
    
    dSn <- -Sn * beta_n * Iw + mu_n * In
    dIn <- Sn * beta_n * Iw - In * (mu_n + gamma_n)
    dDn <- In * gamma_n  
    
    return(list(c(dSw, dIw, dDw,
                  dSr, dEr, dDr,
                  dSy, dIy, dDy,
                  dSs, dEs, dDs,
                  dSn, dIn, dDn)))
  })
}

ui <- dashboardPage(
  dashboardHeader(
    title = div("Spread Model", 
                style = "color: #fff; font-size: 20px; font-weight: bold;"),
    titleWidth = 350
  ),
  
  dashboardSidebar(
    width = 350,
    sidebarUserPanel("Global Settings", image = NULL),
    
    
    tags$div(class = "shiny-input-container",
             h4("Worker Forage Settings", style = "color: #fff; margin-bottom: 10px;"),
             helpText("Workers get infected when foraging; new infections affect the whole population.", 
                      style = "color: #aaa; font-size: 12px;"),
             sliderInput("forage_interval", "Forage interval (days):", 
                         min = 1, max = 10, value = 2, step = 1),  
             sliderInput("forage_infect_rate", "Infection rate when foraging (%):", 
                         min = 1, max = 100, value = 70, step = 1)   
    ),
    
    
    tags$div(class = "shiny-input-container",
             h4("Initial Infection Settings", style = "color: #fff; margin-bottom: 10px;"),
             helpText("All termites are susceptible initially except infected individuals.", 
                      style = "color: #aaa; font-size: 12px;"),
             sliderInput("init_Iw", "Initial infected workers proportion:", 
                         min = 0, max = 0.7, value = 0.05, step = 0.01),
             sliderInput("init_Iy", "Initial infected young proportion:", 
                         min = 0, max = 0.09, value = 0.00, step = 0.01),
             sliderInput("init_In", "Initial infected nymphs proportion:", 
                         min = 0, max = 0.1, value = 0.00, step = 0.01)
    ),
    
    
    tags$div(class = "shiny-input-container",
             h4("Simulation Days", style = "color: #fff; margin-bottom: 10px;"),
             sliderInput("days", "Simulation days:", 
                         min = 30, max = 180, value = 60, step = 10)
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        *{
          overflow: visible !important;  
        }
        html {
          overflow-y: auto !important;  
        }
        body, .wrapper, .content-wrapper, .main-panel, .sidebar {
          height: auto !important;       
          min-height: 0 !important;      
          max-height: none !important;  
        }
        .sidebar {
          position: relative !important;  
          float: left !important;         
          clear: none !important;         
        }
        .content-wrapper {
          margin-left: 350px !important;  
          float: left !important;         
          width: calc(100% - 350px) !important; 
        }
        .wrapper::after {
          content: '';
          display: table;
          clear: both;
        }
        .small-box .icon-large {
          position: absolute;
          top: auto;
          bottom: 5px;
          right: 5px;
          font-size: 70px;
          color: rgba(0, 0, 0, 0.15);
        }
        .navbar-nav > .messages-menu > .dropdown-menu > li .menu > li > a > .glyphicon,
        .navbar-nav > .messages-menu > .dropdown-menu > li .menu > li > a > .fa {
          float: left; font-size: 30px; width: 50px; text-align: center; margin-right: 5px; color: #000;
        }
        section.sidebar .user-panel {min-height: 65px; padding: 15px; background-color: #222d32;}
        section.sidebar .shiny-input-container {
          padding: 12px 15px 0px 15px; white-space: normal; background-color: #222d32; margin-bottom: 10px;
        }
        div.box-body .shiny-input-container {width: auto; padding: 0; background-color: transparent;}
        .sidebar {color: #fff; background-color: #222d32;}
        .sidebar .irs-min, .sidebar .irs-max {color: #aaa;}
        a > .info-box {color: #333;}
        .shiny-server-account {z-index: 2000;}
        .main-header .sidebar-toggle {font-family: fontAwesome, 'Font Awesome 5 Free'; font-weight: 900;}
        .tab-content {padding: 20px;}
        .box {margin-bottom: 20px; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.1);}
        .box-header {background-color: #f4f4f4; border-bottom: 1px solid #ddd;}
        .box-title {font-size: 16px; font-weight: bold; color: #333;}
      "))
    ),
    
    
    tabsetPanel(
      id = "main_tabs",
      tabPanel("Overview", value = "overview",
               box(title = "Termite Population Trends", status = "primary", solidHeader = TRUE,
                   plotOutput("sum_pop_plot", height = "400px")),
               box(title = "Termite Population Status (All Castes Combined)", status = "primary", solidHeader = TRUE,
                   plotOutput("total_pop_plot", height = "400px")),
               box(title = "Key Metrics Summary", status = "info", solidHeader = TRUE, 
                   tableOutput("summary_table")),
      ),
      
      tabPanel("Workers", value = "workers",
               fluidRow(
                 column(6,
                        box(title = "Worker Parameters", status = "info", solidHeader = TRUE, width = 12,
                            sliderInput("beta_w", "Transmission rate (β_w):", min = 0, max = 1, value = 0.05, step = 0.01),
                            sliderInput("gamma_w", "Mortality rate (γ_w):", min = 0, max = 1, value = 0.3, step = 0.01),
                            sliderInput("mu_w", "Recovery rate (μ_w):", min = 0, max = 1, value = 0.01, step = 0.01),
                            h4("Worker Equations (With Forage Infection)", style = "margin-top: 20px;"),
                            withMathJax(
                              helpText("
                              $$\\begin{cases}
                              \\frac{dS_w}{dt} = -S_w \\cdot \\beta_w \\cdot Iw + \\mu_w \\cdot Iw - \\Delta Iw_{forage} \\\\
                              \\frac{dI_w}{dt} = S_w \\cdot \\beta_w \\cdot Iw - Iw \\cdot (\\gamma_w + \\mu_w) + \\Delta Iw_{forage} \\\\
                              \\frac{dD_w}{dt} = Iw \\cdot \\gamma_w \\\\
                              \\Delta Iw_{forage} = S_w \\cdot \\frac{a%}{100} \\cdot \\frac{S_w}{0.7} \\quad (\\text{when } t \\mod T = 0)
                              \\end{cases}$$")
                            )
                        )
                 ),
                 
                 column(6,
                        box(title = "Worker Population Dynamics", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("worker_states_plot", height = "250px")),
                        box(title = "Worker Cumulative Deaths", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("worker_deaths_plot", height = "250px"))
                 )
               )
      ),
      tabPanel("Reproductives", value = "reproductives",
               fluidRow(
                 column(6,
                        box(title = "Reproductive Parameters", status = "info", solidHeader = TRUE, width = 12,
                            sliderInput("beta_r", "Transmission rate (β_r):", min = 0, max = 1, value = 0.04, step = 0.01),
                            sliderInput("gamma_r", "Mortality rate (γ_r):", min = 0, max = 1, value = 0.2, step = 0.01),
                            sliderInput("mu_r", "Recovery rate (μ_r):", min = 0, max = 1, value = 0.05, step = 0.01),
                            h4("Reproductive Equations", style = "margin-top: 20px;"),
                            withMathJax(helpText("
                              $$\\begin{cases}
                              \\frac{dS_r}{dt} = -S_r \\cdot \\beta_r \\cdot Iw + \\mu_r \\cdot Er \\\\
                              \\frac{dE_r}{dt} = S_r \\cdot \\beta_r \\cdot Iw - Er \\cdot (\\mu_r + \\gamma_r) \\\\
                              \\frac{dD_r}{dt} = Er \\cdot \\gamma_r
                              \\end{cases}$$"))
                        )
                 ),
                 column(6,
                        box(title = "Reproductive Population Dynamics", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("reproductive_states_plot", height = "250px")),
                        box(title = "Reproductive Cumulative Deaths", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("reproductive_deaths_plot", height = "250px"))
                 )
               )
      ),
      
      tabPanel("Young", value = "young",
               fluidRow(
                 column(6,
                        box(title = "Young Parameters", status = "info", solidHeader = TRUE, width = 12,
                            sliderInput("beta_y", "Transmission rate (β_y):", min = 0, max = 1, value = 0.06, step = 0.01),
                            sliderInput("gamma_y", "Mortality rate (γ_y):", min = 0, max = 1, value = 0.35, step = 0.01),
                            sliderInput("mu_y", "Recovery rate (μ_y):", min = 0, max = 1, value = 0.02, step = 0.01),
                            h4("Young Equations", style = "margin-top: 20px;"),
                            withMathJax(helpText("
                              $$\\begin{cases}
                              \\frac{dS_y}{dt} = -S_y \\cdot \\beta_y \\cdot (Iw + Iy + In) + \\mu_y \\cdot Iy \\\\
                              \\frac{dI_y}{dt} = S_y \\cdot \\beta_y \\cdot (Iw + Iy + In) - Iy \\cdot (\\mu_y + \\gamma_y) \\\\
                              \\frac{dD_y}{dt} = Iy \\cdot \\gamma_y
                              \\end{cases}$$"))
                        )
                 ),
                 column(6,
                        box(title = "Young Population Dynamics", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("young_states_plot", height = "250px")),
                        box(title = "Young Cumulative Deaths", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("young_deaths_plot", height = "250px"))
                 )
               )
      ),
      
      tabPanel("Soldiers", value = "soldiers",
               fluidRow(
                 column(6,
                        box(title = "Soldier Parameters", status = "info", solidHeader = TRUE, width = 12,
                            sliderInput("beta_s", "Transmission rate (β_s):", min = 0, max = 1, value = 0.04, step = 0.01),
                            sliderInput("gamma_s", "Mortality rate (γ_s):", min = 0, max = 1, value = 0.28, step = 0.01),
                            sliderInput("mu_s", "Recovery rate (μ_s):", min = 0, max = 1, value = 0.04, step = 0.01),
                            h4("Soldier Equations", style = "margin-top: 20px;"),
                            withMathJax(helpText("
                              $$\\begin{cases}
                              \\frac{dS_s}{dt} = -S_s \\cdot \\beta_s \\cdot (Iw + In) + \\mu_s \\cdot Es \\\\
                              \\frac{dE_s}{dt} = S_s \\cdot \\beta_s \\cdot (Iw + In) - Es \\cdot (\\mu_s + \\gamma_s) \\\\
                              \\frac{dD_s}{dt} = Es \\cdot \\gamma_s
                              \\end{cases}$$"))
                        )
                 ),
                 column(6,
                        box(title = "Soldier Population Dynamics", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("soldier_states_plot", height = "250px")),
                        box(title = "Soldier Cumulative Deaths", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("soldier_deaths_plot", height = "250px"))
                 )
               )
      ),
      
      tabPanel("Nymphs", value = "nymphs",
               fluidRow(
                 column(6,
                        box(title = "Nymph Parameters", status = "info", solidHeader = TRUE, width = 12,
                            sliderInput("beta_n", "Transmission rate (β_n):", min = 0, max = 1, value = 0.05, step = 0.01),
                            sliderInput("gamma_n", "Mortality rate (γ_n):", min = 0, max = 1, value = 0.32, step = 0.01),
                            sliderInput("mu_n", "Recovery rate (μ_n):", min = 0, max = 1, value = 0.02, step = 0.01),
                            h4("Nymph Equations", style = "margin-top: 20px;"),
                            withMathJax(helpText("
                              $$\\begin{cases}
                              \\frac{dS_n}{dt} = -S_n \\cdot \\beta_n \\cdot Iw + \\mu_n \\cdot In \\\\
                              \\frac{dI_n}{dt} = S_n \\cdot \\beta_n \\cdot Iw - In \\cdot (\\mu_n + \\gamma_n) \\\\
                              \\frac{dD_n}{dt} = In \\cdot \\gamma_n
                              \\end{cases}$$"))
                        )
                 ),
                 column(6,
                        box(title = "Nymph Population Dynamics", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("nymph_states_plot", height = "250px")),
                        box(title = "Nymph Cumulative Deaths", status = "primary", solidHeader = TRUE, width = 12,
                            plotOutput("nymph_deaths_plot", height = "250px"))
                 )
               )
      )
    )
  )
)

server <- function(input, output, session) {
  model_output <- reactive({
    parameters <- c(
      beta_w = ifelse(is.null(input$beta_w), 0.05, input$beta_w),
      gamma_w = ifelse(is.null(input$gamma_w), 0.3, input$gamma_w),
      mu_w = ifelse(is.null(input$mu_w), 0.01, input$mu_w),
      beta_r = ifelse(is.null(input$beta_r), 0.04, input$beta_r),
      gamma_r = ifelse(is.null(input$gamma_r), 0.2, input$gamma_r),
      mu_r = ifelse(is.null(input$mu_r), 0.05, input$mu_r),
      beta_y = ifelse(is.null(input$beta_y), 0.06, input$beta_y),
      gamma_y = ifelse(is.null(input$gamma_y), 0.35, input$gamma_y),
      mu_y = ifelse(is.null(input$mu_y), 0.02, input$mu_y),
      beta_s = ifelse(is.null(input$beta_s), 0.04, input$beta_s),
      gamma_s = ifelse(is.null(input$gamma_s), 0.28, input$gamma_s),
      mu_s = ifelse(is.null(input$mu_s), 0.04, input$mu_s),
      beta_n = ifelse(is.null(input$beta_n), 0.05, input$beta_n),
      gamma_n = ifelse(is.null(input$gamma_n), 0.32, input$gamma_n),
      mu_n = ifelse(is.null(input$mu_n), 0.02, input$mu_n),
      forage_interval = input$forage_interval,
      forage_infect_rate = input$forage_infect_rate
    )
    
    initial_state <- c(
      Sw = max(0, 0.7 - input$init_Iw),  
      Iw = min(input$init_Iw, 0.7),
      Dw = 0,
      Sr = max(0, 0.01),            
      Er = 0,
      Dr = 0,
      Sy = max(0, 0.09 - input$init_Iy),  
      Iy = min(input$init_Iy, 0.09),
      Dy = 0,
      Ss = max(0, 0.1),            
      Es = 0,
      Ds = 0,
      Sn = max(0, 0.1 - input$init_In),  
      In = min(input$init_In, 0.1),
      Dn = 0
    )
    
    times <- seq(0, input$days, by = 1)
    output <- ode(y = initial_state, times = times, func = termite_model, parms = parameters)
    as.data.frame(output)
  })
  plot_ant_states <- function(df, caste_name, state_names, color_values) {
    df_long <- df %>%
      select(time, all_of(state_names)) %>%
      pivot_longer(cols = -time, names_to = "compartment", values_to = "proportion")
    
    ggplot(df_long, aes(x = time, y = proportion, color = compartment)) +
      geom_line(size = 1) +
      scale_color_manual(values = color_values) +
      labs(
        x = "Time (days)",
        y = "Population proportion",
        title = paste(caste_name, "Population Dynamics"),
        color = "State"
      ) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "bottom",
            plot.title = element_text(size = 14, face = "bold", color = "#333"))
  }
  
  plot_ant_deaths <- function(df, death_col) {
    df %>%
      ggplot(aes(x = time, y = .data[[death_col]])) +
      geom_line(size = 1, color = "#3c8dbc") +
      labs(
        x = "Time (days)",
        y = "Cumulative deaths proportion",
        title = "Cumulative Deaths"
      ) +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(size = 14, face = "bold", color = "#333"))
  }
  
  output$worker_states_plot <- renderPlot({
    plot_ant_states(model_output(), "Workers", c("Sw", "Iw", "Dw"), 
                    c("Sw" = "#3c8dbc", "Iw" = "#e74c3c", "Dw" = "#7f8c8d"))
  })
  
  output$worker_deaths_plot <- renderPlot({
    plot_ant_deaths(model_output(), "Dw")
  })
  
  output$reproductive_states_plot <- renderPlot({
    plot_ant_states(model_output(), "Reproductives", c("Sr", "Er", "Dr"), 
                    c("Sr" = "#3c8dbc", "Er" = "#f39c12", "Dr" = "#7f8c8d"))
  })
  
  output$reproductive_deaths_plot <- renderPlot({
    plot_ant_deaths(model_output(), "Dr")
  })
  
  output$young_states_plot <- renderPlot({
    plot_ant_states(model_output(), "Young", c("Sy", "Iy", "Dy"), 
                    c("Sy" = "#3c8dbc", "Iy" = "#e74c3c", "Dy" = "#7f8c8d"))
  })
  
  output$young_deaths_plot <- renderPlot({
    plot_ant_deaths(model_output(), "Dy")
  })
  
  output$soldier_states_plot <- renderPlot({
    plot_ant_states(model_output(), "Soldiers", c("Ss", "Es", "Ds"), 
                    c("Ss" = "#3c8dbc", "Es" = "#f39c12", "Ds" = "#7f8c8d"))
  })
  
  output$soldier_deaths_plot <- renderPlot({
    plot_ant_deaths(model_output(), "Ds")
  })
  
  output$nymph_states_plot <- renderPlot({
    plot_ant_states(model_output(), "Nymphs", c("Sn", "In", "Dn"), 
                    c("Sn" = "#3c8dbc", "In" = "#e74c3c", "Dn" = "#7f8c8d"))
  })
  
  output$nymph_deaths_plot <- renderPlot({
    plot_ant_deaths(model_output(), "Dn")
  })
  
  output$sum_pop_plot <- renderPlot({
    df <- model_output() %>%
      mutate(
        Total = Sw + Iw + Dw + Sr + Er + Dr + Sy + Iy + Dy + Ss + Es + Ds + Sn + In + Dn,
        Alive = Total - (Dw + Dr + Dy + Ds + Dn)
      )
    
    ggplot(df, aes(x = time)) +
      geom_line(aes(y = Total, color = "Total Population"), size = 1.2) +
      geom_line(aes(y = Alive, color = "Alive Population"), size = 1.2) +
      scale_color_manual(values = c("Total Population" = "#3c8dbc", "Alive Population" = "#27ae60")) +
      labs(
        x = "Time (days)",
        y = "Population",
        title = "Termite Population Trends",
        color = ""
      ) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "bottom",
            plot.title = element_text(size = 14, face = "bold", color = "#333"))
  })
  
  output$total_pop_plot <- renderPlot({
    df <- model_output() %>%
      mutate(
        Susceptible = Sw + Sr + Sy + Ss + Sn,
        Infected = Iw + Er + Iy + Es + In,
        Dead = Dw + Dr + Dy + Ds + Dn
      ) %>%
      select(time, Susceptible, Infected, Dead) %>%
      pivot_longer(cols = -time, names_to = "Status", values_to = "Population")
    
    ggplot(df, aes(x = time, y = Population, color = Status)) +
      geom_line(size = 1.2) +
      scale_color_manual(values = c("Susceptible" = "#3c8dbc", "Infected" = "#e74c3c", "Dead" = "#7f8c8d")) +
      labs(
        x = "Time (days)",
        y = "Population",
        title = "Termite Population Status (All Castes Combined)",
        color = ""
      ) +
      theme_minimal(base_size = 12) +
      theme(legend.position = "bottom",
            plot.title = element_text(size = 14, face = "bold", color = "#333"))
  })
  
  output$summary_table <- renderTable({
    df <- model_output()
    metrics <- data.frame(
      Caste = c("Workers", "Reproductives", "Young", "Soldiers", "Nymphs"),
      Final_Deaths = percent(c(
        tail(df$Dw, 1),
        tail(df$Dr, 1),
        tail(df$Dy, 1),
        tail(df$Ds, 1),
        tail(df$Dn, 1)
      ))
    )
    metrics
  }, align = "lc", digits = 2)
}

shinyApp(ui = ui, server = server)
