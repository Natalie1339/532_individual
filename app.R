library(shiny)
library(bslib)
library(tidyverse)
library(DT)

# Constants
BEHAVIOUR_COLS  <- c("running", "chasing", "climbing", "eating", "foraging")
BEHAVIOUR_COLOUR <- "#6A9E6F"

FUR_COLOURS <- c("Gray" = "#808080", "Cinnamon" = "#A66A3F", "Black" = "#4a4a4a")
FUR_ORDER   <- c("Gray", "Cinnamon", "Black")
SHIFT_ORDER <- c("AM", "PM")

# Paths
APP_DIR   <- dirname(rstudioapi::getSourceEditorContext()$path)
DATA_PATH <- file.path(APP_DIR, "data", "processed", "squirrels.csv")

# Load data once at startup
initial <- read_csv(DATA_PATH)

all_shift <- SHIFT_ORDER
all_age   <- sort(unique(initial$age))

# UI --------------------------------------------------------------------------
ui <- fluidPage(
  
  # Header banner
  tags$div(
    style = paste(
      "position: relative; height: 100px; margin-bottom: 10px; border-radius: 10px;",
      "overflow: hidden; background-image:",
      "linear-gradient(to right, rgba(0,0,0,0.65), rgba(0,0,0,0.28)),",
      "url('squirrels_image.png');",
      "background-size: cover; background-position: center;"
    ),
    tags$div(
      style = paste(
        "position: absolute; left: 18px; bottom: 14px; color: #ffffff;",
        "text-shadow: 0 1px 4px rgba(0,0,0,0.55);"
      ),
      tags$h2("NYC Central Park Squirrels", style = "margin: 0;"),
      tags$p(
        tags$a("Image Source",
               href   = "https://www.centralparknyc.org/articles/getting-to-know-central-parks-squirrels",
               target = "_blank",
               style  = "color: #e6f4ff;"
        ),
        " // ",
        tags$a("Data Source",
               href   = "https://data.cityofnewyork.us/Environment/2018-Central-Park-Squirrel-Census-Squirrel-Data/vfnx-vebw",
               target = "_blank",
               style  = "color: #e6f4ff;"
        ),
        style = "margin: 6px 0 0 0; font-size: 0.95rem;"
      )
    )
  ),
  
  # Sidebar layout
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("shift", "Shift",
                         choices  = all_shift,
                         selected = all_shift
      ),
      checkboxGroupInput("age", "Age",
                         choices  = all_age,
                         selected = all_age
      )
    ),
    mainPanel(
      textOutput("squirrel_count"),
      tags$style("#squirrel_count { font-size: 0.95rem; color: #555; margin-bottom: 8px; }"),
      fluidRow(
        column(6,
               card(
                 card_header("Fur Color Counts"),
                 plotOutput("fur_color_hist", height = "260px"),
                 full_screen = TRUE
               )
        ),
        column(6,
               card(
                 card_header("Top 5 Behaviours"),
                 plotOutput("behaviour_hist", height = "260px"),
                 full_screen = TRUE
               )
        )
      ),
      fluidRow(
        column(12,
               card(
                 card_header("Filtered Data Table"),
                 DT::dataTableOutput("table_view"),
                 full_screen = TRUE
               )
        )
      )
    )
  )
)

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Reactive: load data
  df <- reactive({
    read_csv(DATA_PATH)
  })
  
  # Reactive: filtered data
  filtered_df <- reactive({
    dat <- df()
    selected_shift <- if (length(input$shift) > 0) input$shift else character(0)
    selected_age   <- if (length(input$age)   > 0) input$age   else character(0)
    
    dat |>
      filter(shift %in% selected_shift, age %in% selected_age)
  })
  
  # Squirrel count
  output$squirrel_count <- renderText({
    paste0("Showing ", format(nrow(filtered_df()), big.mark = ","), " squirrels")
  })
  
  # Fur color bar chart
  output$fur_color_hist <- renderPlot({
    dat <- filtered_df()
    if (nrow(dat) == 0) return(NULL)
    
    counts <- dat |>
      filter(!is.na(primary_fur_color)) |>
      count(primary_fur_color) |>
      mutate(primary_fur_color = factor(primary_fur_color, levels = FUR_ORDER))
    
    ggplot(counts, aes(x = primary_fur_color, y = n, fill = primary_fur_color)) +
      geom_col() +
      scale_fill_manual(values = FUR_COLOURS, drop = FALSE) +
      scale_x_discrete(limits = FUR_ORDER) +
      labs(x = NULL, y = "Sightings") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Behaviour bar chart
  output$behaviour_hist <- renderPlot({
    dat <- filtered_df()
    if (nrow(dat) == 0) return(NULL)
    
    cols <- intersect(BEHAVIOUR_COLS, names(dat))
    if (length(cols) == 0) return(NULL)
    
    counts <- dat |>
      select(all_of(cols)) |>
      summarise(across(everything(), ~ sum(. == TRUE, na.rm = TRUE))) |>
      pivot_longer(everything(), names_to = "behaviour", values_to = "count") |>
      slice_max(count, n = 5) |>
      mutate(behaviour = tools::toTitleCase(gsub("_", " ", behaviour)),
             behaviour = reorder(behaviour, -count))
    
    ggplot(counts, aes(x = behaviour, y = count)) +
      geom_col(fill = BEHAVIOUR_COLOUR) +
      labs(x = NULL, y = "Sightings") +
      theme_minimal()
  })
  
  # Data table
  output$table_view <- DT::renderDataTable({
    dat <- filtered_df()
    if (nrow(dat) == 0) {
      return(data.frame(message = "No rows for current filters"))
    }
    
    cols      <- c("unique_squirrel_id", "date", "shift", "age", "primary_fur_color", "hectare")
    available <- intersect(cols, names(dat))
    table_df  <- dat[, available]
    names(table_df) <- c("ID", "Date", "Shift", "Age", "Fur Color", "Hectare")[
      match(names(table_df), cols)
    ]
    table_df
  },
  filter  = "top",
  options = list(scrollY = "470px", paging = FALSE)
  )
}

# Run -------------------------------------------------------------------------
shinyApp(ui = ui, server = server)