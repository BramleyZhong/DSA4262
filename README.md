# DSA4262-Proj-genenius Readme

### Required software
- R, version 4.2.1

### Required packages
- tidyverse
- jsonlite
- xgboost
- gtools
- caret
- pROC
- ROSE




### Installation guidelines



### Excecution guidelines
#### Data_parsing.R
- Input: data.json, data.info
- Output: train_data.csv, test_data.csv
- Parse raw data (json) into dataframe in R for convinient use
- Can be used for both training data and test data
- Long excecution time is expected, please use larger instances to avoid memory issue and save running time
- Details can be found in the comments in Data_parsing.R

#### Models.R
- Include data engineering, model training and predicting
- Use train_data.csv as training data, use test_data.csv for prediction
- Output final csv file for submission 
