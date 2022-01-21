# Using R, Python, and Apache Airflow to build Data Pipelines 

This repository uses Apache Airflow with R and Python to schedule data analysis tasks. The main purpose of this repository is to document my journey learning about Data pipelines with the focus on how to use data pipelines to make routine data analysis simpler, faster and more repeatable.

To keep the learning engaging, I picked a [real-world data set](https://doi.org/10.7910/DVN/H8SFD2), and used a series of modular scripts to analyze this data and to create visualizations. Special gratitude to [Laura Calcagni](https://lcalcagni.medium.com/running-r-scripts-in-airflow-using-airflow-bashoperators-6d827f5da5b1) for the inspiration to learn about [**Apache Airflow**](https://airflow.apache.org/), and to [John Graves](https://github.com/graveja0/health-care-markets) for teaching me everything I know about R and programming.

### About the Data

As in my [other work](https://github.com/LNshuti/LNSHUTI.github.io), I use the Atlas of Economic Complexity from the Growth Lab at Harvard University. The reasons I love this data source are fourfold:

It is detailed down to the product level that each country in the World trades from 1962 to 2019. 

The data is standardized to simplify the process of building time series to track changes over time. 

It is a regularly used and highly cited source with over fifty thousand downloads. 

It is publicly available and can be downloaded [**here**](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/H8SFD2)


```

```




### References
1. Csárdi, G., Nepusz, T. and Airoldi, E.M., 2016. Statistical network analysis with igraph.
         https://sites.fas.harvard.edu/~airoldi/pub/books/BookDraft-CsardiNepuszAiroldi2016.pdf
         
         
2. Introduction to ggraph: Edges. Data Imaginist. 
         https://www.data-imaginist.com/2017/ggraph-introduction-edges/
         
         
3. John Graves. Defining Markets for Health Care Services.
         https://github.com/graveja0/health-care-markets
