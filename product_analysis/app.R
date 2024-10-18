#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


library(shiny)
library(arules)
library(igraph)
library(tidyr)

server <- function(input, output) {
  # Reactive for transaction object
  trans.obj <- reactive({
    data <- input$datafile
    if (is.null(data)) {
      return(NULL)
    }
    transactions.obj <- read.transactions(file = data$datapath, format = "single", sep = ",", cols = c("order_id", "product_id"))
    return(transactions.obj)
  })
  
  # Reactive for data frame from CSV
  trans.df <- reactive({
    data <- input$datafile 
    if (is.null(data)) {
      return(NULL)
    }
    trans.df <- read.csv(data$datapath, sep = ",", quote = "", skip = 0, encoding = "unknown")
    return(trans.df)
  })
  
  # Reactive for network data
  network.data <- reactive({
    transactions.obj <- trans.obj()
    if (is.null(transactions.obj)) {
      return(NULL)
    }
    
    support <- 0.015
    parameters <- list(
      support = support, 
      confidence = 0.5, 
      minlen = 2, 
      maxlen  = 2,
      target = "frequent itemsets"
    )
    
    freq.items <- apriori(transactions.obj, parameter = parameters)
    
    freq.items.df <- data.frame(
      item_set = labels(freq.items),
      support = freq.items@quality
    )
    
    freq.items.df$item_set <- as.character(freq.items.df$item_set)
    
    # Clean up for item pairs
    freq.items.df <- separate(freq.items.df, item_set, col = item_set, into = c("item1", "item2"), sep = ",")
    freq.items.df[] <- lapply(freq.items.df, gsub, pattern = "\\{", replacement = "")
    freq.items.df[] <- lapply(freq.items.df, gsub, pattern = "\\}", replacement = "")
    
    # Prepare data for graph
    network.data <- freq.items.df[, c("item1", "item2", "support.count")]
    names(network.data) <- c("from", "to", "weight")
    return(network.data)
  })
  
  # Render data table for transactions
  output$transactions <- renderDataTable({ trans.df() })
  
  # Render data table for product pairs
  output$ppairs <- renderDataTable({ network.data() })
  
  # Render community detection plot
  output$community <- renderPlot({
    network.data <- network.data()
    if (is.null(network.data)) return(NULL)
    
    my.graph <- graph_from_data_frame(network.data)
    random.cluster <- walktrap.community(my.graph)
    plot(random.cluster, my.graph, layout = layout.fruchterman.reingold, 
         vertex.label.cex = 5, edge.arrow.size = .1, height = 1200, width = 1200)
  })
}

# Define UI for the application
ui <- fluidPage(
  titlePanel("Product Analysis"),
  navbarPage("Product Pairs",
             tabPanel('Transactions', 
                      fileInput("datafile", "Choose CSV file", 
                                accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')
                      ),
                      dataTableOutput("transactions")
             ),
             tabPanel('Product Pairs',
                      dataTableOutput("ppairs")
             ),
             tabPanel('Community Detection',
                      plotOutput("community")
             )
  )
)

# Run the application 
shinyApp(ui = ui, server = server)
