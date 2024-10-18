# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/

library(shiny)
library(arules)
library(igraph, quietly = TRUE)
library(tidyr)
library(visNetwork)

server <- function(input, output) {
  # Reactive for transaction object
  trans.obj <- reactive({
    data <- input$datafile
    if (is.null(data)) {
      return(NULL)
    }
    transactions.obj <- read.transactions(file = data$datapath, format = "single", sep = ",", cols = c(1, 2))
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
    
    support <- 0.015
    
    parameters <- list(
      support = support, 
      confidence = 0.5, 
      minlen = 2, 
      maxlen  = 2,
      target = "frequent itemsets"
    )
    
    freq.items <- apriori(transactions.obj, parameter = parameters)
    
    # Check if freq.items has content
    if (length(freq.items) == 0) {
      return(NULL)  # Return NULL if no itemsets are found
    }
    
    freq.items.df <- data.frame(item_set = labels(freq.items),
                                support = quality(freq.items)$support)
    
    # Clean up for item pairs
    freq.items.df <- separate(freq.items.df, item_set, into = c("item1", "item2"), sep = ",")
    freq.items.df[] <- lapply(freq.items.df, gsub, pattern = "\\{", replacement = "")
    freq.items.df[] <- lapply(freq.items.df, gsub, pattern = "\\}", replacement = "")
    
    # Prepare data for graph
    network.data <- freq.items.df[, c("item1", "item2", "support")]
    names(network.data) <- c("from", "to", "weight")
    
    return(network.data)
  })
  
  # Render data table for transactions
  output$transactions <- renderDataTable({ trans.df() })
  
  # Render data table for product pairs
  output$ppairs <- renderDataTable({ network.data() })
  
  # Render community detection plot using visNetwork
  output$community <- renderVisNetwork({
    network.data <- network.data()
    if (is.null(network.data)) return(NULL)
    
    my.graph <- graph_from_data_frame(network.data)
    random.cluster <- walktrap.community(my.graph)
    
    # Convert to visNetwork format
    nodes <- data.frame(id = V(my.graph)$name, label = V(my.graph)$name, group = random.cluster$membership)
    edges <- data.frame(from = as.character(as.vector(get.edgelist(my.graph)[,1])),
                        to = as.character(as.vector(get.edgelist(my.graph)[,2])),
                        weight = E(my.graph)$weight)
    
    # Create the visNetwork plot
    visNetwork(nodes, edges) %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
      visLayout(randomSeed = 123) %>%
      visEdges(arrows = 'to') %>%
      visNodes(size = 20, font = list(size = 20)) %>%
      visLegend(useGroups = TRUE)
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
                      visNetworkOutput("community", height = "800px")  # Use visNetwork output
             )
  )
)

# Run the application 
shinyApp(ui = ui, server = server)
