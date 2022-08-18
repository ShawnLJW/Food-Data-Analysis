library(shiny)
library(tidyverse)
library(scales)

food_balances <- read_csv("food_balances.csv")
areas <- unique(food_balances$Area)
population_table <- food_balances %>%
  select(Area, Year, Population) %>%
  drop_na()
population_table$Year <- ordered(population_table$Year)

ui <- fluidPage(
  titlePanel("Food Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("areaSelected", "Area:",
                  areas)
    ),
    mainPanel(
      plotOutput(outputId = "populationLine")
    )
  )
)

server <- function(input, output) {
  populationPlotData <- reactive({
    filter(population_table, Area == input$areaSelected)
  })
  output$populationLine <- renderPlot({
    ggplot(data=populationPlotData(), aes(x=Year, y=Population, colour="darkblue", group=1)) +
      ggtitle("Population growth") +
      geom_line() +
      scale_color_manual(values = c("Population" = "darkblue")) +
      scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
      theme(
        axis.title=element_blank()
      )
  })
}

shinyApp(ui = ui, server = server)