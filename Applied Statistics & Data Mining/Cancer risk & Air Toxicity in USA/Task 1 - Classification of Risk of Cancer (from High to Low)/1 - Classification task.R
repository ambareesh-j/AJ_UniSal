################################################
# Smoking Prediction using Decision Trees
################################################

# Install the necessary packages
# install.packages('dplyr') 
# install.packages('tidyverse')
# install.packages('ggplot2')
# install.packages('rpart')
# install.packages('rpart.plot')
# install.packages('rattle')
# install.packages('RColorBrewer')
install.packages('skimr')

# Libraries to current R session
library(dplyr) 
library(tidyverse)
library(ggplot2)
library(rpart)
library(rpart.plot)
library(rattle)
library(RColorBrewer)
library(skimr)

## Suppress messages / warnings during package loading
options(warn = -1) 

# Set the working directory
setwd('D:/University/ASDM/Developments/Task 1 - Classification')
# Check for the working directory
getwd()

#######################
# 1. Data Acquisition
#######################

## Importing / Reading the data into "df_sdd" data frame 
df_sdd <- read.csv("sdd.csv") 

# Check the number of rows and cols
dim(df_sdd) # --> 718 features & 12051 rows

#Structure 
str(df_sdd)

##########################
# 2. Data Preparation
##########################

# Using dplyr library here

# Filter out unknown outcomes & subset the dataset to only 30 important features
df_smok <- select(filter(df_sdd , dcgstg3 != -9, dcgstg3 != -8),c(dcgstg3, age1115, ethnicgpr, truantdv, cg7tot, sdwkcigg, dcgage, dcgfam, famsmok, dcgppfr, dcgppfam, dsmfhome, stopsmk, trystop, cgstopb, cgstopwb, cglongg, dcggupad, dcggupfa, dcggupni, dcggupgp, dcgguphe, dcggupst, dcggupno, dcgoft, dcgopen, cgdiffg, dlifwell1, dlifdiff1, ddwbscore))

# Describing the data subset 
head(df_smok)
tail(df_smok)
names(df_smok)
str(df_smok)
summary(df_smok)

# Check the number of Rows & Columns in the data subset
nrow(df_smok) 
ncol(df_smok) 
dim(df_smok)   # --> ~30 features & ~12051 rows

skim(df_smok)

# Feature selection using Variable importance
library(caret)
set.seed(100)
rPartMod <- train(dcgstg3 ~ ., data=df_smok, method="rpart")
rpartImp <- varImp(rPartMod)
print(rpartImp)

plot(rpartImp, top = 7, main='Variable Importance')

# Response Variable -
# 1. dcgstg3 - Cigarette smoking status ( 1 - Regular, 2 - )

# Predictor Variables -
# 1. cg7tot - Cigarettes smoked last week
# 2. stopsmk - Like to give up smoking altogether
# 3. cgstopwb - Ease could stop smoking for a week
# 4. trystop - Try to/like to give up smoking
# 5. dcgoft - Smoking status for giving up smoking
# 6. cgstopb - Ease could stop smoking altogether
# 7. cglongg - Length of time as a regular smoker

# Feature Engineering

# Rename the selected variables 
names(df_smok)[names(df_smok) == 'dcgstg3'] <-  'smok.status'
names(df_smok)[names(df_smok) == 'cg7tot'] <-   'no.of.cigs.smoked.last.wk'
names(df_smok)[names(df_smok) == 'stopsmk'] <-  'likes.to.quit.permanently'
names(df_smok)[names(df_smok) == 'cgstopwb'] <- 'restraint.in.a.week'
names(df_smok)[names(df_smok) == 'trystop'] <-  'likes.to.quit'
names(df_smok)[names(df_smok) == 'dcgoft'] <-   'smok.status.for.giving.up'
names(df_smok)[names(df_smok) == 'cgstopb'] <-  'restraint.overall'
names(df_smok)[names(df_smok) == 'cglongg'] <-  'reg.smoker.since'

# Subset the data to only selected features
df_smok <- select(filter(df_smok),c('smok.status','no.of.cigs.smoked.last.wk','likes.to.quit.permanently','restraint.in.a.week','likes.to.quit', 'smok.status.for.giving.up','restraint.overall', 'reg.smoker.since' ))
str(df_smok) 

# Change the data types

# Response variable - Smoking Status - factor
# Convert the continuous variable into categorical variable
df_smok$smok.status <- as.factor(df_smok$smok.status)
df_smok <- df_smok %>% mutate(smok.status=factor(ifelse(smok.status == 1, "Regular", levels(smok.status)[smok.status])))
df_smok <- df_smok %>% mutate(smok.status=factor(ifelse(smok.status == 2, "Occasional", levels(smok.status)[smok.status])))
df_smok <- df_smok %>% mutate(smok.status=factor(ifelse(smok.status == 3, "Non-smoker", levels(smok.status)[smok.status])))
# Check frequency
as.data.frame(table(df_smok$smok.status)) 


# Predictor variables
# 1. 'no.of.cigs.smoked.last.wk' - num : -8 = Don't Know , -9 = Not answered
as.data.frame(table(df_smok$no.of.cigs.smoked.last.wk))

# 2. 'likes.to.quit.permanently' - factor : -1 , -8 , -9 = Not sure
df_smok$likes.to.quit.permanently <- as.factor(df_smok$likes.to.quit.permanently)
df_smok <- df_smok %>% mutate(likes.to.quit.permanently=factor(ifelse(likes.to.quit.permanently == 1, "Yes", levels(likes.to.quit.permanently)[likes.to.quit.permanently])))
df_smok <- df_smok %>% mutate(likes.to.quit.permanently=factor(ifelse(likes.to.quit.permanently == 2, "No", levels(likes.to.quit.permanently)[likes.to.quit.permanently])))
df_smok <- df_smok %>% mutate(likes.to.quit.permanently=factor(ifelse(likes.to.quit.permanently == -1, "NA", levels(likes.to.quit.permanently)[likes.to.quit.permanently])))
df_smok <- df_smok %>% mutate(likes.to.quit.permanently=factor(ifelse(likes.to.quit.permanently == -8, "Don't know", levels(likes.to.quit.permanently)[likes.to.quit.permanently])))
df_smok <- df_smok %>% mutate(likes.to.quit.permanently=factor(ifelse(likes.to.quit.permanently == -9, "Unanswered", levels(likes.to.quit.permanently)[likes.to.quit.permanently])))
# Check frequency
as.data.frame(table(df_smok$likes.to.quit.permanently)) 


# 3. 'restraint.in.a.week' - factor 
df_smok$restraint.in.a.week <- as.factor(df_smok$restraint.in.a.week)
df_smok <- df_smok %>% mutate(restraint.in.a.week=factor(ifelse(restraint.in.a.week == 1, "Difficult", levels(restraint.in.a.week)[restraint.in.a.week])))
df_smok <- df_smok %>% mutate(restraint.in.a.week=factor(ifelse(restraint.in.a.week == 2, "Easy", levels(restraint.in.a.week)[restraint.in.a.week])))
df_smok <- df_smok %>% mutate(restraint.in.a.week=factor(ifelse(restraint.in.a.week == -1, "NA", levels(restraint.in.a.week)[restraint.in.a.week])))
df_smok <- df_smok %>% mutate(restraint.in.a.week=factor(ifelse(restraint.in.a.week == -9, "Unanswered", levels(restraint.in.a.week)[restraint.in.a.week])))
# Check frequency
as.data.frame(table(df_smok$restraint.in.a.week)) 

# 4. 'likes.to.quit' - factor 
df_smok$likes.to.quit <- as.factor(df_smok$likes.to.quit)
df_smok <- df_smok %>% mutate(likes.to.quit=factor(ifelse(likes.to.quit == 1, "Tried to give up, would still like to", levels(likes.to.quit)[likes.to.quit])))
df_smok <- df_smok %>% mutate(likes.to.quit=factor(ifelse(likes.to.quit == 2, "Not tried but would like to give up", levels(likes.to.quit)[likes.to.quit])))
df_smok <- df_smok %>% mutate(likes.to.quit=factor(ifelse(likes.to.quit == 3, "Tried to give up, would not like to", levels(likes.to.quit)[likes.to.quit])))
df_smok <- df_smok %>% mutate(likes.to.quit=factor(ifelse(likes.to.quit == 4, "Not tried, would not like to give up", levels(likes.to.quit)[likes.to.quit])))
df_smok <- df_smok %>% mutate(likes.to.quit=factor(ifelse(likes.to.quit == -1, "NA", levels(likes.to.quit)[likes.to.quit])))
df_smok <- df_smok %>% mutate(likes.to.quit=factor(ifelse(likes.to.quit == -8, "Don't know", levels(likes.to.quit)[likes.to.quit])))
df_smok <- df_smok %>% mutate(likes.to.quit=factor(ifelse(likes.to.quit == -9, "Unanswered", levels(likes.to.quit)[likes.to.quit])))

# Check frequency
as.data.frame(table(df_smok$likes.to.quit)) 


# 5. smok.status.for.giving.up - factor 
df_smok$smok.status.for.giving.up <- as.factor(df_smok$smok.status.for.giving.up)
df_smok <- df_smok %>% mutate(smok.status.for.giving.up=factor(ifelse(smok.status.for.giving.up == 1, "Tried smoking", levels(smok.status.for.giving.up)[smok.status.for.giving.up])))
df_smok <- df_smok %>% mutate(smok.status.for.giving.up=factor(ifelse(smok.status.for.giving.up == 2, "Used to smoke", levels(smok.status.for.giving.up)[smok.status.for.giving.up])))
df_smok <- df_smok %>% mutate(smok.status.for.giving.up=factor(ifelse(smok.status.for.giving.up == 3, "Current smoker", levels(smok.status.for.giving.up)[smok.status.for.giving.up])))
df_smok <- df_smok %>% mutate(smok.status.for.giving.up=factor(ifelse(smok.status.for.giving.up == 99, "NA", levels(smok.status.for.giving.up)[smok.status.for.giving.up])))

# Check frequency
as.data.frame(table(df_smok$smok.status.for.giving.up)) 

# 6. restraint.overall - factor
df_smok$restraint.overall <- as.factor(df_smok$restraint.overall)
df_smok <- df_smok %>% mutate(restraint.overall=factor(ifelse(restraint.overall == 1, "Difficult", levels(restraint.overall)[restraint.overall])))
df_smok <- df_smok %>% mutate(restraint.overall=factor(ifelse(restraint.overall == 2, "Easy", levels(restraint.overall)[restraint.overall])))
df_smok <- df_smok %>% mutate(restraint.overall=factor(ifelse(restraint.overall == -1, "NA", levels(restraint.overall)[restraint.overall])))
df_smok <- df_smok %>% mutate(restraint.overall=factor(ifelse(restraint.overall == -9, "Unanswered", levels(restraint.overall)[restraint.overall])))
# Check frequency
as.data.frame(table(df_smok$restraint.overall))  


# 7. reg.smoker.since - factor
df_smok$reg.smoker.since <- as.factor(df_smok$reg.smoker.since)
df_smok <- df_smok %>% mutate(reg.smoker.since=factor(ifelse(reg.smoker.since == 1, "1 year or less", levels(reg.smoker.since)[reg.smoker.since])))
df_smok <- df_smok %>% mutate(reg.smoker.since=factor(ifelse(reg.smoker.since == 2, "More than one year", levels(reg.smoker.since)[reg.smoker.since])))
df_smok <- df_smok %>% mutate(reg.smoker.since=factor(ifelse(reg.smoker.since == -1, "NA", levels(reg.smoker.since)[reg.smoker.since])))
df_smok <- df_smok %>% mutate(reg.smoker.since=factor(ifelse(reg.smoker.since == -9, "Unanswered", levels(reg.smoker.since)[reg.smoker.since])))
# Check frequency
as.data.frame(table(df_smok$reg.smoker.since))  

# Final structure after assigning data dictionary
str(df_smok)


##########################
# 3. Data Preprocessing
##########################

# Random number generator
set.seed(1241) 

# sample function can be used to return a random permutation of a vector.
smoke_split <- sample(2, nrow(df_smok),replace=TRUE, prob=c(0.8,0.2))
head(smoke_split)

# ML datasets
train_smok <- df_smok[smoke_split==1,] 
test_smok <- df_smok[smoke_split==2,] 

# Check the ML datasets
# To check how many observations are in train and test data sets .
dim(train_smok) # Retrieve the dimension of the train data set 
dim(test_smok) # Retrieve the dimension of the validate data set


##########################
# 4. Data Wrangling
##########################
## XXXXXXX - To work on this later

##########################
# 5. Model Training
##########################
# Decision Trees - Implement with "party" package
# Ignore installation if "party" package was already installed. You can run library() to find out this. 

install.packages("party") 
library("party")

smok_tree <- ctree(smok.status ~ no.of.cigs.smoked.last.wk + likes.to.quit.permanently + restraint.in.a.week + likes.to.quit + smok.status.for.giving.up + restraint.overall + reg.smoker.since, data = train_smok)

print(smok_tree) # Draw the tree

# Plotting the Decision Tree
plot(smok_tree)

#Predictive Analysis - Accuracy check using Confusion Matrix
train_predict <- table( train_smok$smok.status , predict(smok_tree)) 
print(train_predict)
plot(train_predict[,1:3], xlab = 'Smoking Status', ylab = 'Prediction')
     

# # calculate the confusion matrix - apply in Logistic Regression
# ctable <- as.table(matrix(train$dcgstg3, nrow = 2, byrow = TRUE))
# fourfoldplot(ctable, color = c("#CC6666", "#99CC99"),
#              conf.level = 0, margin = 1, main = "Confusion Matrix")

# Accuracy %
sum(diag(train_predict))/sum(train_predict)
# Error Rate %
1 - sum(diag(train_predict))/sum(train_predict)


##########################
# 6. Model Testing
##########################

#Predictive Analysis - Accuracy check using Confusion Matrix
test_predict <- table(predict(smok_tree, newdata= test_smok), test$smok.status) 
print(test_predict)
plot(test_predict[,1:3], xlab = 'Smoking Status', ylab = 'Prediction')

# Accuracy %
sum(diag(test_predict))/sum(test_predict)
# Error Rate %
1 - sum(diag(test_predict))/sum(test_predict)


# Another method for classification - Decision trees
# https://online.datasciencedojo.com/blogs/a-comprehensive-tutorial-on-classification-using-decision-trees


