#################################
# Clustering
#################################

# install.packages()
# install.packages("arules")
# install.packages("arulesViz")
# install.packages("plotly")
# library(plotly)

#cluster package is a powerful tool for cluster analysis
# install.packages("cluster") # install “cluster” package 
library(cluster) # activate “cluster” package


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

mypath = "D:/University/ASDM/Developments/Task 3 - Clustering"
# you need to change the string to your directory
setwd(mypath)
# set working directory
getwd()
# check if the working directory has changed correctly

## Importing / Reading the data into "df_cea" data frame 
cost_data <- read.csv("costpercompany.csv", header= TRUE)

names(cost_data) 
head(cost_data) 
tail(cost_data) 
summary(cost_data) 
str(cost_data)

nrow(cost_data) 
ncol(cost_data) 
dim(cost_data)

# Pairs plot - Correlation plot
cost_data$Company <- as.factor(cost_data$Company)
pairs(cost_data)

# Sales & Fuel cost 
plot(Fcost ~ Sales, data = cost_data)
with(cost_data,text(Fcost ~ Sales, labels= Company))

# Remove the overlap
plot(Fcost~ Sales, data = cost_data)
with(cost_data,text(Fcost ~ Sales, labels= Company,pos=4,cex=.6))

#normalise function
normalise <- function(df)
{
  return(((df- min(df)) /(max(df)-min(df))*(1-0))+0)
}

head(cost_data)

#Normalise the dataset using above normalise function 
company<-cost_data[,1]

cost_data_n<-cost_data[,2:9] #remove company column 
cost_data_n
cost_data_n <- as.data.frame(lapply(cost_data_n,normalise)) 
cost_data_n$company<-company #add company column after normalise

dim(cost_data_n)
str(cost_data_n)

cost_data_n<-cost_data_n[,c(9,1,2,3,4,5,6,7,8)] #rearrange the columns in the dataset

#Choosing Euclidean distance method and creating distance matrix

distance <- dist(cost_data_n,method = "euclidean",)
distance

print(distance)
print(distance,digits=3)


# install.packages('factoextra') # install "factoextra" package
library(factoextra) # activate "factoextra" package


fviz_dist(distance)

#Choosing Euclidean distance method and creating distance matrix with required name
rownames(cost_data_n)<-cost_data_n$Company
head(cost_data_n)

cost_data_n$Company<-NULL

distance <- dist(cost_data_n,method = "euclidean")
distance

fviz_dist(distance)

#Hierarchical clustering

cost_data.hclust <- hclust(distance)
cost_data.hclust

plot(cost_data.hclust)
plot(cost_data.hclust,hang=-1)

rect.hclust(cost_data.hclust, 4)

#Hierarchical clustering using average linkage

hclust.average <- hclust(distance, method = "average")
plot(hclust.average)
rect.hclust(hclust.average, 4)

#Hierarchical clustering using single linkage

hclust.single <- hclust(distance, method = "single")
plot(hclust.single,hang = -1)
rect.hclust(hclust.single, 4)

#Hierarchical clustering using centroid linkage

hclust.centroid <- hclust(distance, method = "centroid")
plot(hclust.centroid,hang = -1)
rect.hclust(hclust.centroid, 4)

#Hierarchical clustering using complete linkage

hclust.complete <- hclust(distance, method = "complete")
plot(hclust.complete,hang = -1)
rect.hclust(hclust.complete, 4)

#Members of dendrogram

member.centroid <- cutree(hclust.centroid,4) 
member.centroid
member.complete <- cutree(hclust.complete,4)
member.complete

table(member.centroid,member.complete)

#-----------------------------------------------------------------------

#K-means clustering

KC <- kmeans(cost_data[,-1],3)
KC


clusplot(cost_data, KC$cluster, color=TRUE, shade=TRUE, lines = 0)
