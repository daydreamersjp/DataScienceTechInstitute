# Statistical Analysis of Massive and High Dimensional Data

[The RStudio Lab Teacher Created in the Class](https://github.com/daydreamersjp/DataScienceTechInstitute/blob/master/MassiveAndHighDimensionalData/Final_Class_Lab.html)

[The Exam #2 I Submitted for Final Assessment](https://github.com/daydreamersjp/DataScienceTechInstitute/blob/master/MassiveAndHighDimensionalData/Statistical%20Analysis%20of%20Massive%20and%20High%20Dimensional%20Data_Exam2.nb.html)

## Contents of In-class Lab

- Descriptive analysis of iris data

- k-means using swiss data

- Hierarchical clustering using swiss data

- Gaussian Mixture Model (GMM) by EM algorithm using swiss data

- PCA using swiss data

- Multi-dimensional Scaling (MDS) using swiss data

- Curse of dimensionality

- High Dimensional Data Clustering (HDDC) using usps358 data

- Fisher EM using usps358 data

<br><hr><br>

## Contents of Exam #2

- 1 Exercise 1: general questions

  - 1. Describe the general setup of resampling techniques and explain how it can be used for parameter tuning.
  
  - 2. Describe some techniques allowing to select the number of clusters with k-means and the hierarchical clustering.

<br>

- 2 Exercise 2: the Vélib data

The objective of this study is to analyze a data set coming from the Vélib system in Paris (a bike sharing system). The data are loading profiles of the bike stations over one week. The data were collected every hour during the period Sunday 1st Sept. - Sunday 7th Sept., 2014.

  - 2.1 Loading the data The data can be loaded within R as follows:

```
load(’path/to/the/data/velib.Rdata’)
```

<br>

  - 2.2 Pretreatment et descriptive analysis

We consider the 1189 Vélib stations as the individuals of this study. First, do all required pretreatments and the usual descriptive analysis of the data. A selection of the most useful data will be
probably necessary at first.

<br>

  - 2.3 Data visualization

Use PCA to visualize the data. Choose the number of PCA axes to retain for the visualization and interpret the results. In particular, the PCA axes should be explained regarding the original variables.

<br>

  - 2.4 Clustering 

    - 2.4.1 Hierarchical clustering

Apply the hierarchical clustering with appropriate distance, choose the right number of cluster and comment the results. A map of the results may be obtained using the GPS coordinates of the stations, thanks to the leaflet package:


```
palette = colorFactor("RdYlBu", domain = NULL)
leaflet(X) %>% addTiles() %>%
addCircleMarkers(radius = 3,
color = palette(clusters),
stroke = FALSE, fillOpacity = 0.9)
```

<br>

  -
    - 2.4.2 k-means
    
Apply now the k-means clustering on the same data. Choose also the right number of clusters using the appropriate technique. Comment and compare with the result obtained with the hierarchical clustering.

<br>

  - 2.5 Summary 
  
  It is expected a final summary of all information extracted during the analysis.
  
<br>
