# I. Data Pre-processing

# 1. Primary pre-processing steps

# Drop Date % ID column
str(SmartFresh_Retail)
SmartFresh_Retail.df <- SmartFresh_Retail[,-c(1,4,8)]
str(SmartFresh_Retail.df)

# Replace Null values with the median
SmartFresh_Retail.df$Annual_Income[is.na(SmartFresh_Retail.df$Annual_Income)] <- median(SmartFresh_Retail.df$ Annual_Income, na.rm = TRUE)

# Encoding Education_Level column
SmartFresh_Retail.df$Education_Level <- factor(SmartFresh_Retail.df$Education_Level, 
                                               levels = c("Graduation", "PhD", "Master", "Basic", "2n Cycle"), 
                                               labels = c(0, 2, 1, 0, 1))
# Assign encoded columns as numeric
SmartFresh_Retail.df$Education_Level <- as.numeric(SmartFresh_Retail.df$Education_Level)

# Convert Year_Birth into Age
SmartFresh_Retail.df$Age <- 2025 - SmartFresh_Retail.df$Year_Birth  # Assuming current year is 2025

# Remove the original Year_Birth column
SmartFresh_Retail.df$Year_Birth <- NULL

# Create a new column 'Num_Dependents' by summing 'Kidhome' and 'Teenhome'
SmartFresh_Retail.df$Num_Dependents <- SmartFresh_Retail.df$Kidhome + SmartFresh_Retail.df$Teenhome

# Check the new column
table(SmartFresh_Retail.df$Num_Dependents)

# Remove the original columns as they are no longer needed
SmartFresh_Retail.df$Kidhome <- NULL
SmartFresh_Retail.df$Teenhome <- NULL

# Handling outliers
# Load necessary library
library(dplyr)
# Function to cap outliers using the 1st and 99th percentiles
cap_outliers <- function(x) {
  if (is.numeric(x)) {
    lower_cap <- quantile(x, 0.01, na.rm = TRUE)  # 1st percentile
    upper_cap <- quantile(x, 0.99, na.rm = TRUE)  # 99th percentile
    x <- ifelse(x < lower_cap, lower_cap, ifelse(x > upper_cap, upper_cap, x))
  }
  return(x)
}
# Apply capping to all numeric variables in the dataset
SmartFresh_Retail.df <-SmartFresh_Retail.df %>%
  mutate(across(where(is.numeric), cap_outliers))

View(SmartFresh_Retail.df)

# II. t-test

# Levenve test on variance equality
# Load necessary libraries
library(car)
# Convert offer acceptance variables to factors
offer_vars <- c("Accepted_Offer1", "Accepted_Offer2", "Accepted_Offer3", "Accepted_Offer4", "Accepted_Offer5","Response_Latest")
SmartFresh_Retail.df[, offer_vars] <- lapply(SmartFresh_Retail.df[, offer_vars], as.factor)
# Define spending and shopping variables
spending_vars <- c("Spend_Wine", "Spend_OrganicFood", "Spend_Meat", "Spend_Treats", "Spend_LuxuryGoods")
shopping_vars <- c("Purchases_Online", "Purchases_Catalog", "Purchases_Store", "Visits_OnlineLastMonth")
# Ensure spending and shopping variables are numeric
test_vars <- c(spending_vars, shopping_vars)
SmartFresh_Retail.df[, test_vars] <- lapply(SmartFresh_Retail.df[, test_vars], function(x) as.numeric(as.character(x)))
# Create an empty matrix to store p-values
levene_matrix <- matrix(NA, nrow = length(test_vars), ncol = length(offer_vars),
                        dimnames = list(test_vars, offer_vars))
# Loop through each spending/shopping variable and offer variable
for (spend_var in test_vars) {
  for (offer_var in offer_vars) {
    # Check if variable has enough unique values
    if (length(unique(SmartFresh_Retail.df[[spend_var]])) > 1 & length(unique(SmartFresh_Retail.df[[offer_var]])) > 1) {
      formula <- as.formula(paste(spend_var, "~", offer_var))
      
      # Run Levene’s test, handle errors if any
      test_result <- tryCatch({
        leveneTest(formula, data = SmartFresh_Retail.df, center = "median")$"Pr(>F)"[1]  # Extract p-value
      }, error = function(e) NA)  
      
      # Store the result in the matrix
      levene_matrix[spend_var, offer_var] <- test_result
    }
  }
}
# Convert matrix to dataframe
levene_df <- as.data.frame(levene_matrix)

 

# III. Principle Components Analysis (PCA)

# Standardize numeric columns
numeric_cols <- sapply(SmartFresh_Retail.df, is.numeric)
SF_Standardized.df <- SmartFresh_Retail.df  # Create a copy of the original dataset
SF_Standardized.df[numeric_cols] <- lapply(SF_Standardized.df[numeric_cols], scale)
summary(SF_Standardized.df)

# Select qualified variances from t-test results for PCA
numeric_vars <- c("Annual_Income", "Spend_Wine",
                  "Spend_Meat" ,"Spend_LuxuryGoods", "Promo_Purchases", "Purchases_Online",
                  "Purchases_Catalog", "Purchases_Store","Num_Dependents")

df_pca <- SF_Standardized.df[numeric_vars]

# 1. Perform PCA

pca_result <- prcomp(df_pca, center = TRUE, scale = TRUE)
summary(pca_result)

print(pca_result$rotation)

# 2. Visualize PCA results
library(ggplot2)
library(factoextra)
# Scree plot to visualize explained variance
# Example PCA results
explained_variance <- c(50.8, 17.4, 8.0, 6.1, 5.1, 4.4, 3.4, 2.8, 2.0)
# Calculate cumulative variance
cumulative_variance <- cumsum(explained_variance)
# Determine the number of PCs needed to exceed 80%
pc_threshold <- min(which(cumulative_variance >= 80))
# Create a dataframe for plotting
pca_df <- data.frame(
  PC = 1:length(explained_variance),
  Variance = explained_variance,
  Cumulative = cumulative_variance
)
# Generate the scree plot
ggplot(pca_df, aes(x = PC)) +
  geom_bar(aes(y = Variance), stat = "identity", fill = "steelblue", alpha = 0.8) +  # Variance bars
  geom_line(aes(y = Cumulative), color = "black", size = 1) +  # Cumulative variance line
  geom_point(aes(y = Cumulative), color = "black", size = 2) +  # Points on the cumulative line
  geom_hline(yintercept = 80, linetype = "dashed", color = "red", size = 1) +  # Horizontal reference line at 80%
  geom_vline(xintercept = pc_threshold, linetype = "dashed", color = "blue", size = 1) +  # Vertical reference line
  geom_text(aes(y = Variance, label = paste0(Variance, "%")), vjust = -0.5, size = 4) +  # Variance labels
  geom_text(aes(y = Cumulative, label = paste0(round(Cumulative, 1), "%")), vjust = -0.5, size = 4, color = "black") +  # Cumulative variance labels
  scale_x_continuous(breaks = 1:10) +  # Ensure x-axis displays 1,2,3,...,10
  labs(title = "Scree Plot with Cumulative Variance and 80% Threshold",
       x = "Principal Components",
       y = "Percentage of Explained Variance") +
  theme_minimal()
# Contribution of variables to principal components
fviz_pca_var(pca_result, col.var = "contrib",
             gradient.cols = c("blue", "yellow", "red"))

# IV. k-mean clustering

# Select the first 4 principal components for clustering
df_pca_kmeans <- pca_result$x[, 1:4]  # Extract PC1 to PC4


# Load necessary libraries
library(cluster)  # For silhouette score
library(ggplot2)  # For plotting

# Set max number of clusters
max_k <- 10  

# Initialize vectors to store WSS and Silhouette Scores
wss <- numeric(max_k)
silhouette_scores <- numeric(max_k)

# Run K-means clustering for k = 1 to max_k
for (k in 1:max_k) {
  set.seed(123)  # For reproducibility
  
  # Perform k-means clustering
  kmeans_result <- kmeans(df_pca_kmeans, centers = k, nstart = 5, iter.max = 50)
  
  # Store WSS
  wss[k] <- kmeans_result$tot.withinss
  
  # Compute Silhouette Score (Only for K >= 2 since Silhouette does not work for K=1)
  if (k > 1) {
    silhouette_result <- silhouette(kmeans_result$cluster, dist(df_pca_kmeans))
    silhouette_scores[k] <- mean(silhouette_result[, 3])  # Average silhouette width
  } else {
    silhouette_scores[k] <- NA  # No silhouette score for K=1
  }
}

# Create a dataframe for plotting
plot_df <- data.frame(K = 1:max_k, WSS = wss, Silhouette_Score = silhouette_scores)

# Plot both metrics on the same graph
ggplot(plot_df, aes(x = K)) +
  geom_line(aes(y = WSS, color = "WSS (Elbow Method)"), size = 1.2) + 
  geom_point(aes(y = WSS, color = "WSS (Elbow Method)"), size = 3) +
  geom_line(aes(y = Silhouette_Score * max(wss, na.rm = TRUE) / max(silhouette_scores, na.rm = TRUE), 
                color = "Silhouette Score"), size = 1.2, linetype = "dashed") +
  geom_point(aes(y = Silhouette_Score * max(wss, na.rm = TRUE) / max(silhouette_scores, na.rm = TRUE), 
                 color = "Silhouette Score"), size = 3) +
  scale_color_manual(values = c("WSS (Elbow Method)" = "darkblue", "Silhouette Score" = "lightblue")) +
  scale_y_continuous(sec.axis = sec_axis(~ . * max(silhouette_scores, na.rm = TRUE) / max(wss, na.rm = TRUE), 
                                         name = "Silhouette Score")) +
  scale_x_continuous(breaks = 1:max_k) +  # Ensure all K values are shown
  theme_minimal() +
  theme(panel.grid.major.x = element_line(color = "gray80"),  # Gridlines only at K values
        panel.grid.minor.x = element_blank()) +  # Remove minor gridlines
  labs(title = "Evaluation on k-means clustering performance for k from 1 to 10",
       x = "Number of Clusters (K)",
       y = "Total Within-Cluster Sum of Squares (WSS)",
       color = "Metric")

kmeans_result <- kmeans(df_pca_kmeans, centers = 3, nstart = 50)



# View the number of customers in each cluster
table(kmeans_result$cluster)

# View the center in each cluster corresponding to principle components
SF_clusters <- kmeans(df_pca_kmeans,3)
SF_clusters$centers

# Clusters visualization
# Convert K-Means results to a dataframe
df_pca_kmeans_clustered <- as.data.frame(df_pca_kmeans)
df_pca_kmeans_clustered$Cluster <- as.factor(kmeans_result$cluster)

# Convert cluster column to numeric for visualization
df_pca_kmeans$Cluster <- as.numeric(kmeans_result$cluster)

# Convert to a data frame
df_pca_kmeans <- as.data.frame(df_pca_kmeans)

# Load required library
library(plotly)

# Create an interactive 3D scatter plot
fig <- plot_ly(df_pca_kmeans_clustered,
               x = ~PC1,
               y = ~PC2,
               z = ~PC3,
               color = ~Cluster,
               colors = c("darkblue", "blue", "lightblue")) %>%
  
  add_markers() %>%
  
  layout(title = list(text = "3D K-Means Clustering on PC1, PC2, PC3"),
         scene = list(xaxis = list(title = "PC1"),
                      yaxis = list(title = "PC2"),
                      zaxis = list(title = "PC3")))

# Show the plot
fig

# Load necessary library
install.packages("GGally")

# Load necessary library
library(GGally)
library(RColorBrewer)  # For improved color selection

# Ensure Cluster is a factor
df_pca_kmeans_clustered$Cluster <- as.factor(df_pca_kmeans_clustered$Cluster)

# Get correct column indices for PC1 to PC4
pc_columns <- which(colnames(df_pca_kmeans_clustered) %in% c("PC1", "PC2", "PC3", "PC4"))

# Define a more visible color palette
num_clusters <- length(unique(df_pca_kmeans_clustered$Cluster))
color_palette <- brewer.pal(min(num_clusters, 8), "Dark2")  # Use "Dark2" for distinct colors

# Parallel coordinate plot with improved visibility
ggparcoord(df_pca_kmeans_clustered, 
           columns = pc_columns,  
           groupColumn = which(colnames(df_pca_kmeans_clustered) == "Cluster"),  
           scale = "std",  
           alphaLines = 0.7,   # Adjust transparency for better visibility
           showPoints = TRUE) +  
  scale_color_manual(values = color_palette) +  # Apply color scheme
  labs(title = "Parallel Coordinate Plot of Clusters",
       x = "Principal Components", 
       y = "Standardized Values", 
       color = "Cluster Group") +  # Improve legend title
  theme_minimal() +
  theme(legend.position = "right",  # Move legend to the right for better readability
        panel.grid.major = element_line(color = "gray80"))  # Improve grid visibility





































