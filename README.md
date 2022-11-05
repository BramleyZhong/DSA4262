# DSA4262 Proj-genenius Readme

### Required software
- R, version 4.2.1
- RStudio (Optional)

### Required packages
- tidyverse
- xgboost
- jsonlite
- gtools
- pROC
- ROSE
- caret

### Excecution guidelines
- For other groups to validate, please download _dataset3_parsed.csv_ as sample input data, _xgboost_final.rda_ as pre-trained model, and _prediction.R_ and put the three files into the same working directory. The _prediction.R_ will read in _dataset3_parsed.csv_ and _xgboost_final.rda_ to generate prediction and export csv file.  

- For full process usage, please download _data_parsing_train.R_ and _data_parsing_test.R_ to parse json data into training and test data, _Models_xgboost.R_ and releavaent raw json data. Please use _data_parsing_train.R_ and _data_parsing_test.R_ to parse json data into training data first. The _Models_xgboost.R_ contains xgboost model with optimised parameters after parameter tuning, and will take in parsed training data and teat data and use xgboost model to generate pridictions.  

### Files description
#### data_parsing_train.R & data_parsing_test.R
- Input: data.json (for training), data.info (for training), datasetX.json (for testing)
- Output: train_data.csv, test_data.csv
- Parse raw data (json) into dataframe in R for convinient use
- Can be used for both training data and test data
- Long excecution time is expected, please use larger instances to avoid memory issue and save running time
- Details can be found in the comments in Data_parsing_train.R and Data_parsing_test.R

#### models_xgboost.R 
- Include data engineering, model training and predicting
- Use train_data.csv as training data, use test_data.csv for prediction
- Output final csv file for submission 

#### dataset3_parsed.csv
- Sample test data parsed from dataset3.json

#### xgboost_final.rda
- Pre-trained xgboost model, ready to use

#### prediction.R
- File to execute to generate prediction on parsed data and output csv file for submission

