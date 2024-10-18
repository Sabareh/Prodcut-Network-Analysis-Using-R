# **Product Network Analysis Using R and Shiny**

## Demo

Here's a preview of the **Product Network Analysis** app in action:

![Product Analysis Demo](images/demo.png)

## **Overview**

This Shiny web application analyzes product transactions to discover frequently purchased product pairs and visualize the relationships between them. The app uses association rule mining (Apriori algorithm) to identify frequent itemsets, and it applies community detection to find clusters of related products.

## **Features**

- **File Upload**: Upload a CSV file containing transactional data.
- **Frequent Itemsets**: Discover frequently purchased product pairs using the Apriori algorithm.
- **Product Pair Visualization**: Display a table of frequently purchased product pairs with their support counts.
- **Community Detection**: Visualize product clusters based on frequent itemsets using a graph network plot.

## **Requirements**

### **Libraries**
Make sure you have the following R libraries installed before running the app:
- `shiny`
- `arules`
- `igraph`
- `tidyr`
  
You can install them using the following commands:
```r
install.packages("shiny")
install.packages("arules")
install.packages("igraph")
install.packages("tidyr")
```

### **File Format**
The app expects a CSV file with the following columns:
- `order_id`: Identifier for each transaction (or order).
- `product_id`: Identifier for each product in the transaction.

## **Getting Started**

### **1. Clone the Repository**

```bash
git clone https://github.com/your-repository-link.git
```

### **2. Open the Project in RStudio**
Once you've cloned the repository, open the project in RStudio.

### **3. Run the App**
You can run the application using the `runApp()` function:

```r
library(shiny)
runApp('path_to_your_project_folder')
```

Alternatively, open the `app.R` file and click "Run App" in RStudio.

## **Usage**

### **1. Upload Transaction Data**
- Go to the "Transactions" tab.
- Upload a CSV file that contains transactional data (`order_id`, `product_id`).

### **2. Analyze Product Pairs**
- Go to the "Product Pairs" tab.
- View a table displaying frequently purchased product pairs and their support counts.

### **3. Community Detection**
- Go to the "Community Detection" tab.
- See a graph visualization of product clusters, using community detection algorithms to find relationships between items.

## **Project Structure**

```plaintext
.
├── app.R                # Main Shiny app code
├── README.md            # Project documentation
└── data/                # Sample data files (optional)
```

## **Customization**

Feel free to customize the application:
- Modify support or confidence thresholds for frequent itemset generation.
- Adjust the visualization settings in the "Community Detection" tab (e.g., layout, node size).

## **Contributing**

Contributions are welcome! Please submit a pull request or open an issue for any improvements or bug fixes.

## **License**

This project is licensed under the MIT License.
