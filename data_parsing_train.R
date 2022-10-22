library(jsonlite)
library(tidyverse)


# read in raw data
# please put raw data (data.json etc.) into the working directory
all_lines <- readLines("data.json") # read in raw training data without label from json
raw_label <- read.csv("data.info") # read in training label data 
json_list <- lapply(all_lines, fromJSON) # convert json format into list


# convert (nested) list into dataframe
df <- data.frame(matrix(ncol = 12)) # create empty dataframe for training data 
for (i in 1:length(json_list)){ # for each line (row) in the raw training data
  tid <- names(json_list[[i]]) # get transcript id 
  pid <- names(json_list[[i]][[1]]) # get position
  seq <- names(json_list[[i]][[1]][[1]]) # get sequence
  
  tmp <- data.frame(matrix(ncol = 12)) # create temp dataframe for each read 
  
  for (j in 1:nrow(json_list[[i]][[1]][[1]][[1]])) { # for each read within the line (row)
    tmp[j,] <- c(tid,pid,seq,
                 json_list[[i]][[1]][[1]][[1]][j,1],
                 json_list[[i]][[1]][[1]][[1]][j,2],
                 json_list[[i]][[1]][[1]][[1]][j,3],
                 json_list[[i]][[1]][[1]][[1]][j,4],
                 json_list[[i]][[1]][[1]][[1]][j,5],
                 json_list[[i]][[1]][[1]][[1]][j,6],
                 json_list[[i]][[1]][[1]][[1]][j,7],
                 json_list[[i]][[1]][[1]][[1]][j,8],
                 json_list[[i]][[1]][[1]][[1]][j,9])
  } # create dataframe for each read with transcript id, position, sequence, and 9 numerical inputs (std, mean, length)
  df <- rbind(df,tmp) # append the dataframe of each read into the training dataframe
}

df <- na.omit(df)
colnames(df) <- c("tid", "pid", "seq", "info1", "info2", "info3","info4","info5","info6","info7","info8","info9") 


# add label into the training data
df$pid <- as.numeric(df$pid)
raw_label$transcript_position <- as.numeric(raw_label$transcript_position)
df <- df %>% left_join(raw_label, by=c("tid"="transcript_id","pid"="transcript_position" )) 


# separate the training dataframe into 3 to differentiate (-1, 0, +1) position
df1 <- df %>% select(tid, pid, seq, info1, info2, info3, label) %>% mutate(pid = pid-1, seq = substr(seq, 1, 5)) # tailor the position and sequence information based on relative position (-1,0,+1)
df2 <- df %>% select(tid, pid, seq, info4, info5, info6, label) %>% mutate(seq = substr(seq, 2, 6)) # tailor the position and sequence information based on relative position (-1,0,+1)
df3 <- df %>% select(tid, pid, seq, info7, info8, info9, label) %>% mutate(pid = pid+1, seq = substr(seq, 3,7)) # tailor the position and sequence information based on relative position (-1,0,+1)
colnames(df2) <- c("tid", "pid", "seq", "info1", "info2", "info3", "label")
colnames(df3) <- c("tid", "pid", "seq", "info1", "info2", "info3", "label")


# recombine the 3 dataframe into 1
df_new <- rbind(df1, df2, df3)
df_new$info1 <- as.numeric(df_new$info1)
df_new$info2 <- as.numeric(df_new$info2)
df_new$info3 <- as.numeric(df_new$info3)


# use mean(average) value as input for different reads
df_new <- df_new %>% group_by(tid, pid, seq, label) %>% summarise(info1 = mean(info1), info2 = mean(info2), info3 = mean(info3))


# export the training dataframe as csv file
write.csv(df_new, "D:/Year4/DSA4262/proj2_df_new.csv") # need to change the output path 
