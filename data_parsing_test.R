library(jsonlite)
library(tidyverse)


# read in raw data
# please put raw data (data.json etc.) into the working directory
# if need to parse multiple test datasets, please change the raw data source in line 8 and run this data_parsing_test.R for each data source (dataset1, dataset2, etc.)
all_lines <- readLines("dataset1.json") # read in raw test data without label from json
json_list <- lapply(all_lines, fromJSON) # convert json format into list

# convert (nested) list into dataframe
df <- data.frame(matrix(ncol = 12))


for (i in 1:length(json_list)){# for each line (row) in the raw test data
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
  df <- rbind(df,tmp) # append the dataframe of each read into the test dataframe
}

df <- na.omit(df)
colnames(df) <- c("tid", "pid", "seq", "info1", "info2", "info3","info4","info5","info6","info7","info8","info9")
df$pid <- as.numeric(df$pid)


# separate the test dataframe into 3 to differentiate (-1, 0, +1) position
df1 <- df %>% select(tid, pid, seq, info1, info2, info3) %>% mutate(pid = pid-1, seq = substr(seq, 1, 5))
df2 <- df %>% select(tid, pid, seq, info4, info5, info6) %>% mutate(seq = substr(seq, 2, 6))
df3 <- df %>% select(tid, pid, seq, info7, info8, info9) %>% mutate(pid = pid+1, seq = substr(seq, 3,7))
colnames(df2) <- c("tid", "pid", "seq", "info1", "info2", "info3")
colnames(df3) <- c("tid", "pid", "seq", "info1", "info2", "info3")


# recombine the 3 dataframe into 1
df_new <- rbind(df1, df2, df3)
df_new$info1 <- as.numeric(df_new$info1)
df_new$info2 <- as.numeric(df_new$info2)
df_new$info3 <- as.numeric(df_new$info3)


# use mean(average) value as input for different reads
df_new <- df_new %>% group_by(tid, pid, seq) %>% summarise(info1 = mean(info1), info2 = mean(info2), info3 = mean(info3))

# export the test dataframe as csv file
write.csv(df_new, "D:/Year4/DSA4262/proj2/proj2_df_new_test1.csv") # need to change the output path






