################################################
# Cancer Risk per million - 
################################################

# Install the necessary packages
# install.packages('dplyr') 
# install.packages('tidyverse')
# install.packages('ggplot2')
# install.packages('rpart')
# install.packages('rpart.plot')
# install.packages('rattle')
# install.packages('RColorBrewer')
# install.packages('skimr')
# install.packages("xlsx")
# install.packages("vioplot")
# install.packages("corrplot")
# install.packages("Hmisc")

# Libraries to current R session
library(dplyr) 
library(tidyverse)
library(ggplot2)
library(rpart)
library(rpart.plot)
library(rattle)
library(RColorBrewer)
library(skimr)
library("readxl")
library(vioplot)
library(Hmisc)
library(corrplot)

## Suppress messages / warnings during package loading
options(warn = -1) 

# Set the working directory
setwd('D:/University/ASDM/Developments/Task 1 - Classification')
# Check for the working directory
getwd()

#######################
# 1. Data Acquisition 
#######################

# Chemical Exposure Analysis
## Importing / Reading the data into "df_cea" data frame 
df_cea_raw <- read_excel("ARM Dataset - 2 states.xlsx", sheet = 1) 

# Check the number of rows and cols
dim(df_cea_raw) # --> 

#Structure 
str(df_cea_raw)
names(df_cea_raw)

##########################
# 2. Data Preparation
##########################

# Using dplyr library here

# State == "CA" | State == "TX"  - check later

# Filter / subset the dataset 
df_cea <- select(filter(df_cea_raw, State == "CA"),c(State, County, Pollutant.Name,
Point..includes.railyards..Cancer.Risk..per.million., 
Airport.Cancer.Risk..per.million.,
OR.Lightduty..includes.refueling..Cancer.Risk..per.million.,
OR.Heavyduty.Cancer.Risk..per.million.,
NR..no.airports..CMV..locomotives..Cancer.Risk..per.million.,
NP.10m.ReleaseHeight.Cancer.Risk..per.million.,
NP.Low.ReleaseHeight.Cancer.Risk..per.million.,
ResidentialWoodCombustion..RWC..Cancer.Risk..per.million.,
NR.CommercialMarineVessel..CMV..Cancer.Risk..per.million.,
Biogenics.Cancer.Risk..per.million.,
Fires..ag..prescribed..and.wild..Cancer.Risk..per.million.,
Secondary.Cancer.Risk..per.million.,
Total.Cancer.Risk..per.million.))

# Renaming the columns - Simplification
# Feature Engineering
names(df_cea)[names(df_cea) == 'State'] <-  'state'
names(df_cea)[names(df_cea) == 'County'] <-  'county'
names(df_cea)[names(df_cea) == 'Pollutant.Name'] <-  'pollutant'
names(df_cea)[names(df_cea) == 'Point..includes.railyards..Cancer.Risk..per.million.'] <-  'railyards_crpm'
names(df_cea)[names(df_cea) == 'Airport.Cancer.Risk..per.million.'] <-  'airport_crpm'
names(df_cea)[names(df_cea) == 'OR.Lightduty..includes.refueling..Cancer.Risk..per.million.'] <-  'lightduty_crpm'
names(df_cea)[names(df_cea) == 'OR.Heavyduty.Cancer.Risk..per.million.'] <-  'heavyduty_crpm'
names(df_cea)[names(df_cea) == 'NR..no.airports..CMV..locomotives..Cancer.Risk..per.million.'] <-  'cmv_loco_crpm'
names(df_cea)[names(df_cea) == 'NP.10m.ReleaseHeight.Cancer.Risk..per.million.'] <-  'np_10m_releaseheight_crpm'
names(df_cea)[names(df_cea) == 'NP.Low.ReleaseHeight.Cancer.Risk..per.million.'] <-  'np_low_releaseheight_crpm'
names(df_cea)[names(df_cea) == 'ResidentialWoodCombustion..RWC..Cancer.Risk..per.million.'] <-  'rwc_crpm'
names(df_cea)[names(df_cea) == 'NR.CommercialMarineVessel..CMV..Cancer.Risk..per.million.'] <-  'cmv_crpm'
names(df_cea)[names(df_cea) == 'Biogenics.Cancer.Risk..per.million.'] <-  'biogenics_crpm'
names(df_cea)[names(df_cea) == 'Fires..ag..prescribed..and.wild..Cancer.Risk..per.million.'] <-  'fires_crpm'
names(df_cea)[names(df_cea) == 'Secondary.Cancer.Risk..per.million.'] <-  'secondary_crpm'
names(df_cea)[names(df_cea) == 'Total.Cancer.Risk..per.million.'] <-  'total_crpm'

# Describing the data subset 
head(df_cea)
tail(df_cea)
names(df_cea)
str(df_cea)
summary(df_cea)

# Check the number of Rows & Columns in the data subset
nrow(df_cea) 
ncol(df_cea) 
dim(df_cea)   # --> ~30 features & ~12051 rows

skim(df_cea)

# Histogram - Total CRPM
hist(df_cea$total_crpm, xlab="Total Cancer Risk per Million", main = "Distribution of Total Cancer Risk per million")

# Boxplot - Total CRPM by County
boxplot(total_crpm~county,data=df_cea, main="Total Cancer risk per Million",xlab="Cancer Risk per Million", ylab="County")

# Boxplot - Total CRPM by Pollutant
boxplot(total_crpm~pollutant,data=df_cea, main="Total Cancer risk per Million",xlab="Cancer Risk per Million", ylab="Pollutant")

# Violin Plots
x1 <- df_cea$total_crpm[df_cea$pollutant=="1,3-BUTADIENE"]
x2 <- df_cea$total_crpm[df_cea$pollutant=="ACETALDEHYDE"]
x3 <- df_cea$total_crpm[df_cea$pollutant=="BENZENE"]
x4 <- df_cea$total_crpm[df_cea$pollutant=="CYANIDE COMPOUNDS"]
x5 <- df_cea$total_crpm[df_cea$pollutant=="DIESEL PM"]
x6 <- df_cea$total_crpm[df_cea$pollutant=="TOLUENE"]
vioplot(x1, x2, x3, x4, x5, x6, names=c("1,3-BUTADIENE","ACETALDEHYDE", "BENZENE", "CYANIDE COMPOUNDS" , "DIESEL PM", "TOLUENE" ),
col="gold", xlab="Pollutant Name", ylab="Total Cancer risk per million")
title("Violin Plot - Total Cancer Risk per million by Pollutants")


# Use single color
ggplot(df_cea, aes(x=county, y=total_crpm)) +
  geom_violin(trim=FALSE, fill='#A4A4A4', color="darkred")+
  geom_boxplot(width=0.1) + theme_minimal()
# Change violin plot colors by groups
p<-ggplot(df_cea, aes(x=county, y=total_crpm, fill=county)) +
  geom_violin(trim=FALSE)
p

df_cea_corvar <- df_cea[, c(4:16)]
df_cea_cor <- cor(df_cea_corvar)
round(df_cea_cor,2)

# ++++++++++++++++++++++++++++
# flattenCorrMatrix
# ++++++++++++++++++++++++++++
# cormat : matrix of the correlation coefficients
# pmat : matrix of the correlation p-values
flattenCorrMatrix <- function(cormat, pmat) {
  ut <- upper.tri(cormat)
  data.frame(
    row = rownames(cormat)[row(cormat)[ut]],
    column = rownames(cormat)[col(cormat)[ut]],
    cor  =(cormat)[ut],
    p = pmat[ut]
  )
}


res2<-rcorr(as.matrix(df_cea[, c(4:16)]))
flattenCorrMatrix(res2$r, res2$P)

# Get some colors - Understand Heatmap / Correlation matrix
col<- colorRampPalette(c("blue", "white", "red"))(20)
heatmap(x = df_cea_cor, col = col, symm = TRUE)

# Correlogram
corrplot(df_cea_cor, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)

# df_cea$level_of_threat <- cut(df_cea$total_crpm, 4, labels = c('L0', 'L1', 'L2', 'L3')) 

df_cea$level_of_threat <- ifelse(df_cea$total_crpm <= 0.5, 'L0',
                                 ifelse(df_cea$total_crpm <= 5, 'L1',
                                        ifelse(df_cea$total_crpm <= 10, 'L2', 'L3')))

# Check frequency
as.data.frame(table(df_cea$level_of_threat)) 

str(df_cea$level_of_threat)

# Violin Plot - Level of Threat
# Use single color
ggplot(df_cea, aes(x=level_of_threat, y=total_crpm)) +
  geom_violin(trim=FALSE, fill='#A4A4A4', color="darkred")+
  geom_boxplot(width=0.1) + theme_minimal()
# Change violin plot colors by groups
p<-ggplot(df_cea, aes(x=level_of_threat, y=total_crpm, fill=level_of_threat)) + geom_violin(trim=FALSE) +scale_fill_brewer(palette="Dark2")
p


#5 imp variables - heavyduty, lightduty, cmv, np_releaseheight 1 and 2

##########################
# 3. Data Preprocessing
##########################

# Random number generator
set.seed(1241) 

# sample function can be used to return a random permutation of a vector.
cea_split <- sample(2, nrow(df_cea),replace=TRUE, prob=c(0.8,0.2))
head(cea_split)

# ML datasets
train_cea <- df_cea[cea_split==1,] 
test_cea <- df_cea[cea_split==2,] 

# Check the ML datasets
# To check how many observations are in train and test data sets .
dim(train_cea) # Retrieve the dimension of the train data set 
dim(test_cea) # Retrieve the dimension of the validate data set


##########################
# 4. Data Wrangling
##########################
## XXXXXXX - To work on this later

##########################
# 5. Model Training
##########################
# Decision Trees - Implement with "party" package
# Ignore installation if "party" package was already installed. You can run library() to find out this. 

# install.packages("party") 
library("party")

names(df_cea)
cea_tree_1_cmv <- ctree(level_of_threat ~   cmv_loco_crpm, data = train_cea)

print(cea_tree_1_cmv) # Draw the tree

# Plotting the Decision Tree
plot(cea_tree_1_cmv)

cea_tree_1_ld_hd <- ctree(level_of_threat ~  lightduty_crpm + heavyduty_crpm , data = train_cea)

print(cea_tree_1_ld_hd) # Draw the tree

# Plotting the Decision Tree
plot(cea_tree_1_ld_hd)

cea_tree <- cea_tree_1_ld_hd

#Predictive Analysis - Accuracy check using Confusion Matrix
train_predict <- table( train_cea$level_of_threat , predict(cea_tree)) 
print(train_predict)
plot(train_predict[,1:3], xlab = 'Level of Threat', ylab = 'Prediction')

spineplot(t(train_predict)) # New item

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
test_predict <- table(predict(cea_tree, newdata= test_cea), test_cea$level_of_threat) 
print(test_predict)
plot(test_predict[,1:3], xlab = 'Smoking Status', ylab = 'Prediction')

# Accuracy %
sum(diag(test_predict))/sum(test_predict)
# Error Rate %
1 - sum(diag(test_predict))/sum(test_predict)

# Another method for classification - Decision trees
# https://online.datasciencedojo.com/blogs/a-comprehensive-tutorial-on-classification-using-decision-trees



