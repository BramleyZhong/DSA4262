library(tidyverse)
library(xgboost)
library(gtools)
library(caret)
library(pROC)
library(ROSE)

# read in trained model
model = readRDS("D:/Year4/DSA4262/proj2/xgboost_final.rda")

# create a reference list for all possible permutations of sequence
ref <- permutations(n=4,r=5,v=c("A","T","G","C"),repeats.allowed=T)
ref <- as.data.frame(ref)
ref$seq <- str_c(ref$V1,ref$V2,ref$V3,ref$V4, ref$V5)
ref$seq_id <- 1:1024 # total 4^5=1024 different permutations
ref <- select(ref,seq,seq_id)


# read in test1 data
test1 <- read.csv("proj2_df_new_test3.csv") # need to change the path
colnames(test1) <- c("index", "tid", "pid", "seq", "info1", "info2", "info3")
test1$position <- test1$pid
test1$position <- ifelse((test1$index%%3)==1, -1, test1$position)
test1$position <- ifelse((test1$index%%3)==2, 0, test1$position)
test1$position <- ifelse((test1$index%%3)==0, 1, test1$position)
test1$pid <- as.factor(test1$pid)
test1$position <- as.factor(test1$position)
test1$seq <- as.character(test1$seq)
# add reference information of sequence
test1 <- left_join(test1, ref, by='seq')
test_df <- test1

# XGBoost model
X_test = data.matrix(test_df[,c(5,6,7,8,9)]) # independent variables for test

# convert the train and test data into XGBoost matrix
xgboost_test = xgb.DMatrix(data=X_test)


# predict
pred_test = predict(model, xgboost_test) # give probability for each line (row)
output_df_test <- cbind(test_df, pred_test) # add probability to dataframe
# use mean(average) probability of -1, 0, 1 position as final probability
unique_rows <- nrow(test_df)/3 # total rows/3 (3 positions)
group_id <- rep(1:unique_rows, each = 3) # create a auxiliary grouping ID 
output_df_test <- cbind(output_df_test, group_id) 
output_df_test_ref <- select(output_df_test, tid, group_id)
output_df_test$pid <- as.character(output_df_test$pid)
output_df_test$pid <- as.numeric(output_df_test$pid)
output_df_test <- group_by(output_df_test, group_id) %>% 
  summarise(pid = mean(pid), prob = mean(pred_test)) # group by position and group_id, then apply mean to have average probability of -1, 0, 1 position
output_df_test <- unique(inner_join(output_df_test_ref, output_df_test, by="group_id"))

output_df_test <- cbind(output_df_test$tid, output_df_test$pid, output_df_test$prob)
colnames(output_df_test) <- c("transcript_id", "transcript_position", "score")

#export csv file for submission
write.csv(output_df_test, "D:/Year4/DSA4262/proj2/projgenenius_dataset3_2.csv", row.names=FALSE) # need to change the output path
