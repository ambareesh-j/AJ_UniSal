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

mypath = "D:/University/ASDM/Developments/Task 2 - Association Rules Mining"
# you need to change the string to your directory
setwd(mypath)
# set working directory
getwd()
# check if the working directory has changed correctly

#colClasses option is used to convert to factor
mb_raw <-read.csv("orders_with_categories_FMCG.csv",header=T)
# colClasses="factor")

names(mb_raw)

# Check for no duplicates in order column

# Filter and clean dataset
df_mb <- select(filter(mb_raw, !is.null(mb_raw$order)),c(Food. , Fresh. , Drinks. , Home. , Beauty. , Health. , Baby. , Pets.))

names(df_mb)[names(df_mb) == 'Food.']   <-  'food'
names(df_mb)[names(df_mb) == 'Fresh.']  <-  'fresh'
names(df_mb)[names(df_mb) == 'Drinks.'] <-  'drinks'
names(df_mb)[names(df_mb) == 'Home.']   <-  'home'
names(df_mb)[names(df_mb) == 'Beauty.'] <-  'beauty'
names(df_mb)[names(df_mb) == 'Health.'] <-  'health'
names(df_mb)[names(df_mb) == 'Baby.']   <-  'baby'
names(df_mb)[names(df_mb) == 'Pets.']   <-  'pets'

names(df_mb)
head(df_mb)
str(df_mb)

# Try to write a function here later - simplification process

# Convert continuous values into dichotomous variables (Y/N)
df_mb <- df_mb %>% mutate(food = ifelse(food > 0, "Y", "N"))
# Convert to factor
df_mb$food <- as.factor(df_mb$food)
# Check frequency
as.data.frame(table(df_mb$food)) 

# Convert continuous values into dichotomous variables (Y/N)
df_mb <- df_mb %>% mutate(fresh = ifelse(fresh > 0, "Y", "N"))
# Convert to factor
df_mb$fresh <- as.factor(df_mb$fresh)
# Check frequency
as.data.frame(table(df_mb$fresh)) 

# Convert continuous values into dichotomous variables (Y/N)
df_mb <- df_mb %>% mutate(drinks = ifelse(drinks > 0, "Y", "N"))
# Convert to factor
df_mb$drinks <- as.factor(df_mb$drinks)
# Check frequency
as.data.frame(table(df_mb$drinks)) 

# Convert continuous values into dichotomous variables (Y/N)
df_mb <- df_mb %>% mutate(home = ifelse(home > 0, "Y", "N"))
# Convert to factor
df_mb$home <- as.factor(df_mb$home)
# Check frequency
as.data.frame(table(df_mb$home)) 

# Convert continuous values into dichotomous variables (Y/N)
df_mb <- df_mb %>% mutate(beauty = ifelse(beauty > 0, "Y", "N"))
# Convert to factor
df_mb$beauty <- as.factor(df_mb$beauty)
# Check frequency
as.data.frame(table(df_mb$beauty)) 

# Convert continuous values into dichotomous variables (Y/N)
df_mb <- df_mb %>% mutate(health = ifelse(health > 0, "Y", "N"))
# Convert to factor
df_mb$health <- as.factor(df_mb$health)
# Check frequency
as.data.frame(table(df_mb$health)) 

# Convert continuous values into dichotomous variables (Y/N)
df_mb <- df_mb %>% mutate(baby = ifelse(baby > 0, "Y", "N"))
# Convert to factor
df_mb$baby <- as.factor(df_mb$baby)
# Check frequency
as.data.frame(table(df_mb$baby)) 

# Convert continuous values into dichotomous variables (Y/N)
df_mb <- df_mb %>% mutate(pets = ifelse(pets > 0, "Y", "N"))
# Convert to factor
df_mb$pets <- as.factor(df_mb$pets)
# Check frequency
as.data.frame(table(df_mb$pets)) 


names(df_mb)
head(df_mb)
str(df_mb)
summary(df_mb)


dim(df_mb)

# Purchased Items
#colSums() function computes the sums of columns.
yes <- colSums(df_mb == "Y")
yes

no <- colSums(df_mb == "N")
no

purchased <- rbind(yes,no)
purchased


barplot(purchased,legend=rownames(purchased)) #Plot 1

barplot(purchased, beside=T,legend=rownames(purchased))# Plot 2


# use arules library here
# apriori() function to be used - by default it executes all the iterations at once

rules <- apriori(df_mb)

summary(rules)

inspect(rules)

# too many rules - # set min len = 2, max len = 3, CI = 95%


rules <- apriori(df_mb,
parameter =list(minlen=2,maxlen=3, conf = 0.90, supp= 0.50))

summary(rules)
inspect(rules)

# Exclude No values

# 95 % conf = 3 rules
rules <- apriori(df_mb,
                 parameter  = list(minlen=2, maxlen=3,conf = 0.90, supp=0.55), 
                 appearance = list(rhs=c("food=Y"),default="lhs"))

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



















