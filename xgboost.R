library(tidyverse)
library(xgboost)
library(gtools)
library(caret)
library(pROC)
library(ROSE)


# create a reference list for all possible permutations of sequence
ref <- permutations(n=4,r=5,v=c("A","T","G","C"),repeats.allowed=T)
ref <- as.data.frame(ref)
ref$seq <- str_c(ref$V1,ref$V2,ref$V3,ref$V4, ref$V5)
ref$seq_id <- 1:1024 # total 4^5=1024 different permutations
ref <- select(ref,seq,seq_id)


# read in training data
df <- read.csv("proj2_df_new.csv")
# mutate position into -1, 0, 1
df$position <- df$pid
df$position <- ifelse((df$index%%3)==1, -1, df$position)
df$position <- ifelse((df$index%%3)==2, 0, df$position)
df$position <- ifelse((df$index%%3)==0, 1, df$position)
df$pid <- as.factor(df$pid)
df$position <- as.factor(df$position)
df$label <- as.numeric(df$label)
df$seq <- as.character(df$seq)
# add reference information of sequence
df <- left_join(df, ref, by='seq')


# read in test1 data
test1 <- read.csv("proj2_df_new_test1.csv")
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


# read in test2 data
test2 <- read.csv("proj2_df_new_test2.csv")
colnames(test2) <- c("index", "tid", "pid", "seq", "info1", "info2", "info3")
test2$position <- test2$pid
test2$position <- ifelse((test2$index%%3)==1, -1, test2$position)
test2$position <- ifelse((test2$index%%3)==2, 0, test2$position)
test2$position <- ifelse((test2$index%%3)==0, 1, test2$position)
test2$pid <- as.factor(test2$pid)
test2$position <- as.factor(test2$position)
test2$seq <- as.character(test2$seq)
# add reference information of sequence
test2 <- left_join(test2, ref, by='seq')


# oversampling to have more entries with label 0 
n_legit <- table(df$label)[[1]] # number of 1s in training data
new_frac_legit <- 0.50 # oversampling ratio to have 1:1 numbers of 0 and 1
new_n_total <- n_legit/new_frac_legit 
oversampling_result <- ovun.sample(label ~ .,data = df,method = "over",N = new_n_total,seed = 42) # oversampling
df <- oversampling_result$data
#df <- arrange(df, tid)
train_df <- df
test_df <- test1


# XGBoost model
X_train = data.matrix(train_df[,c(6,7,8,9,10)]) # independent variables for train
y_train = train_df[,5] # dependent variables for train

X_test = data.matrix(test_df[,c(5,6,7,8,9)]) # independent variables for test
y_test = test_df[,5] # dependent variables for test

# convert the train and test data into XGBoost matrix
xgboost_train = xgb.DMatrix(data=X_train, label=y_train)
xgboost_test = xgb.DMatrix(data=X_test, label=y_test)

# train 
model <- xgboost(data = xgboost_train, max.depth=8, eta=0.4,
                 nrounds=100, objective = "binary:logistic")  
xgb.pred = predict(model, xgboost_train)
output_df_train <- cbind(train_df, xgb.pred)
xgb.pred <- as.numeric(xgb.pred > 0.5)


# Confusion matrix
conf_mat_train = confusionMatrix(as.factor(y_train), as.factor(xgb.pred))
print(conf_mat_train)


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


# export csv file for final submission
write.csv(output_df_test,"D:/Year4/DSA4262/proj2/output_df_test2.csv", row.names=FALSE) # need to change the output path








