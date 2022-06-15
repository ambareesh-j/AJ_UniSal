#################################
# Association rules mining - Market basket analysis
#################################

# install.packages()
# install.packages("arules")
# install.packages("arulesViz")
# install.packages("plotly")
# library(plotly)
library(arulesViz) # activate “arules” package
library(arules) # activate “arules” package

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

mypath = "D:/University/ASDM/Developments/Task 2 - Association Rules Mining"
# you need to change the string to your directory
setwd(mypath)
# set working directory
getwd()
# check if the working directory has changed correctly

## Importing / Reading the data into "df_cea" data frame 
df_cea_raw <- read_excel("ARM Dataset - Hazard Indices.xlsx", sheet = 1) 
names(df_cea_raw)

# Check the number of rows and cols
dim(df_cea_raw) # --> 

#Structure 
str(df_cea_raw)
names(df_cea_raw)

##########################
# 2. Data Preparation
##########################

# Using dplyr library here

# Filter / subset the dataset 
df_cea <- select(filter(df_cea_raw ),c(State, County, Pollutant.Name,Total.Respiratory.HI, Total.Neurological.HI, Total.Liver.HI, Total.Developmental.HI, Total.Reproductive.HI, Total.Kidney.HI, Total.Ocular.HI, Total.Endocrine.HI, Total.Hematological.HI, Total.Immunological.HI, Total.Skeletal.HI, Total.Spleen.HI, Total.Thyroid.HI, Total.Wholebody.HI ))

# Renaming the columns - Simplification
# Feature Engineering
names(df_cea)[names(df_cea) == 'State'] <-  'state'
names(df_cea)[names(df_cea) == 'County'] <-  'county'
names(df_cea)[names(df_cea) == 'Pollutant.Name'] <-  'pollutant'
names(df_cea)[names(df_cea) == 'Total.Respiratory.HI'] <-  'resp_hi'
names(df_cea)[names(df_cea) == 'Total.Neurological.HI'] <-  'neuro_hi'
names(df_cea)[names(df_cea) == 'Total.Liver.HI'] <-  'liver_hi'
names(df_cea)[names(df_cea) == 'Total.Developmental.HI'] <-  'dvpt_hi'
names(df_cea)[names(df_cea) == 'Total.Reproductive.HI'] <-  'repro_hi'
names(df_cea)[names(df_cea) == 'Total.Kidney.HI'] <-  'kidney_hi'
names(df_cea)[names(df_cea) == 'Total.Ocular.HI'] <-  'ocular_hi'
names(df_cea)[names(df_cea) == 'Total.Endocrine.HI'] <-  'endo_hi'
names(df_cea)[names(df_cea) == 'Total.Hematological.HI'] <-  'hemato_hi'
names(df_cea)[names(df_cea) == 'Total.Immunological.HI'] <-  'immuno_hi'
names(df_cea)[names(df_cea) == 'Total.Skeletal.HI'] <-  'skele_hi'
names(df_cea)[names(df_cea) == 'Total.Spleen.HI'] <-  'spleen_hi'
names(df_cea)[names(df_cea) == 'Total.Thyroid.HI'] <-  'thyro_hi'
names(df_cea)[names(df_cea) == 'Total.Wholebody.HI'] <-  'overall_hi'

# Describing the data subset 
head(df_cea)
tail(df_cea)
names(df_cea)
str(df_cea)
summary(df_cea)

# Check the number of Rows & Columns in the data subset
nrow(df_cea) 
ncol(df_cea) 
dim(df_cea)   # --> 

skim(df_cea)

# Try to write a function here later - simplification process

# Convert continuous values into dichotomous variables (Y/N)
df_cea <- df_cea %>% mutate(resp_hi = factor(ifelse(resp_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(neuro_hi = factor(ifelse(neuro_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(liver_hi = factor(ifelse(liver_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(dvpt_hi = factor(ifelse(dvpt_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(repro_hi = factor(ifelse(repro_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(kidney_hi = factor(ifelse(kidney_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(ocular_hi = factor(ifelse(ocular_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(endo_hi = factor(ifelse(endo_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(hemato_hi = factor(ifelse(hemato_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(immuno_hi = factor(ifelse(immuno_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(skele_hi = factor(ifelse(skele_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(spleen_hi = factor(ifelse(spleen_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(thyro_hi = factor(ifelse(thyro_hi > 0, "Y", "N")))
df_cea <- df_cea %>% mutate(overall_hi = factor(ifelse(overall_hi > 0, "Y", "N")))

names(df_cea)
head(df_cea)
str(df_cea)
summary(df_cea)


dim(df_cea)

# Hazard_Index 
#colSums() function computes the sums of columns.
yes <- colSums(df_cea[,4:17] == "Y")
yes

no <- colSums(df_cea[,4:17] == "N")
no

harard_index <- rbind(yes,no)
harard_index

barplot(harard_index,legend=rownames(harard_index)) #Plot 1

barplot(harard_index, beside=T,legend=rownames(harard_index))# Plot 2

# Subsetting to minimize the overload

# Hazard_Index 
#colSums() function computes the sums of columns.
yes <- colSums(df_cea[,c(4, 5, 8, 13, 16)] == "Y")
yes

no <- colSums(df_cea[,c(4, 5, 8, 13, 16)] == "N")
no

harard_index <- rbind(yes,no)
harard_index

barplot(harard_index,legend=rownames(harard_index)) #Plot 1

barplot(harard_index, beside=T,legend=rownames(harard_index))# Plot 2

# use arules library here
# apriori() function to be used - by default it executes all the iterations at once

# Exclude No values

# 95 % conf = 3 rules
rules <- apriori(df_cea[,4:17],
                 parameter  = list(minlen=2, maxlen=3,conf = 0.95), 
                 appearance = list(rhs=c("resp_hi=Y"),default="lhs"))

summary(rules)
inspect(rules)

# 90% conf = 17 rules
rules <- apriori(df_mb,
parameter  = list(minlen=2, maxlen=3,conf = 0.90), 
appearance = list(rhs=c("food=Y"),default="lhs"))

summary(rules)
inspect(rules)


# arulesViz - plots

plot(rules)
plot(rules, method="grouped")

plot(rules@quality)

# Interactive plots - plotly_arules() function - doesn't work

rules3 <- apriori(df_mb,
parameter = list(minlen=2,maxlen=3, conf = 0.90),
appearance = list(rhs=c("food=Y","drinks=Y"), lhs = c("home=Y", "fresh=Y", "beauty=Y", "health=Y", "baby=Y", "pets=Y") , default="none"))

inspect(rules3)

(rules3)

ruleExplorer(rules3)


rules_ex <-apriori(df_mb,
                   parameter =list(minlen=2,maxlen=3,conf=0.95))

ruleExplorer(rules_ex)



















