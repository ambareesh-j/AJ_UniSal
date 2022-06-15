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
df_cea_raw <- read_excel("ARM Dataset.xlsx", sheet = 1) 

df_cea <- select(filter(df_cea_raw, State == "CA"),c(State, County,
                                                     # Pollutant.Name,
                                                     Point..includes.railyards..Cancer.Risk..per.million.,Airport.Cancer.Risk..per.million., OR.Lightduty..includes.refueling..Cancer.Risk..per.million., OR.Heavyduty.Cancer.Risk..per.million., NR..no.airports..CMV..locomotives..Cancer.Risk..per.million., NP.10m.ReleaseHeight.Cancer.Risk..per.million., NP.Low.ReleaseHeight.Cancer.Risk..per.million., ResidentialWoodCombustion..RWC..Cancer.Risk..per.million., NR.CommercialMarineVessel..CMV..Cancer.Risk..per.million., Biogenics.Cancer.Risk..per.million., Fires..ag..prescribed..and.wild..Cancer.Risk..per.million., Secondary.Cancer.Risk..per.million.,
Total.Cancer.Risk..per.million.))

# Renaming the columns - Simplification
# Feature Engineering
names(df_cea)[names(df_cea) == 'State'] <-  'state'
names(df_cea)[names(df_cea) == 'County'] <-  'county'
# names(df_cea)[names(df_cea) == 'Pollutant.Name'] <-  'pollutant'
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
dim(df_cea)   # --> ~ 48781 rows and 16 columns

skim(df_cea)

# Aggregates using means - Group by - Dplyr
df_cea_agg <- df_cea %>%
              group_by(state, county) %>%
              summarise_at(vars(c(1:13)), list(avg = mean))

df_cea_agg

# Describing the data subset 
head(df_cea_agg)
tail(df_cea_agg)
names(df_cea_agg)
str(df_cea_agg)
summary(df_cea_agg)

# Check the number of Rows & Columns in the data subset
nrow(df_cea_agg) 
ncol(df_cea_agg) 
dim(df_cea_agg)   # --> ~ 48781 rows and 16 columns

skim(df_cea_agg)

# Pairs plot - Correlation plot
df_cea_agg$state <- as.factor(df_cea_agg$state)
df_cea_agg$county <- as.factor(df_cea_agg$county)
pairs(df_cea_agg)

# Total CRPM avg vs. Light duty CRPM avg  
plot(total_crpm_avg ~ lightduty_crpm_avg, data = df_cea_agg)
with(df_cea_agg,text(total_crpm_avg ~ lightduty_crpm_avg, labels= county))

# Remove the overlap
plot(total_crpm_avg ~ lightduty_crpm_avg, data = df_cea_agg)
with(df_cea_agg,text(total_crpm_avg ~ lightduty_crpm_avg, labels= county,pos=4,cex=.6))

# Total CRPM avg vs. Heavy duty CRPM avg  
plot(total_crpm_avg ~ heavyduty_crpm_avg, data = df_cea_agg)
with(df_cea_agg,text(total_crpm_avg ~ heavyduty_crpm_avg, labels= county))

# Remove the overlap
plot(total_crpm_avg ~ heavyduty_crpm_avg, data = df_cea_agg)
with(df_cea_agg,text(total_crpm_avg ~ heavyduty_crpm_avg, labels= county,pos=4,cex=.6))


#normalise function
normalise <- function(df)
{
  return(((df- min(df)) /(max(df)-min(df))*(1-0))+0)
}

head(df_cea_agg)

#Normalise the dataset using above normalise function 
county<-df_cea_agg[,2]
county

df_cea_agg_n<-df_cea_agg[,3:15] #remove categ columns
df_cea_agg_n
df_cea_agg_n <- as.data.frame(lapply(df_cea_agg_n,normalise)) 
df_cea_agg_n$county<-county #add company column after normalise

dim(df_cea_agg_n)
str(df_cea_agg_n)
names(df_cea_agg_n)
head(df_cea_agg_n)

df_cea_agg_n<-df_cea_agg_n[,c(14,1,2,3,4,5,6,7,8,9,10,11,12,13)] #rearrange the columns in the dataset

#Choosing Euclidean distance method and creating distance matrix

distance <- dist(df_cea_agg_n,method = "euclidean",)
distance

print(distance)
print(distance,digits=3)


# install.packages('factoextra') # install "factoextra" package
library(factoextra) # activate "factoextra" package

dev.off()
fviz_dist(distance)

#Choosing Euclidean distance method and creating distance matrix with required name

county_names <- as.character(df_cea_agg_n$county)
county_names

rownames(df_cea_agg_n) <- as.character(df_cea_agg_n$county)
head(df_cea_agg_n)

# df_cea_agg_n$county<-NULL

distance <- dist(df_cea_agg_n,method = "euclidean")
distance

fviz_dist(distance)

#Hierarchical clustering

df_cea_agg.hclust <- hclust(distance)
df_cea_agg.hclust

plot(df_cea_agg.hclust)
plot(df_cea_agg.hclust,hang=-1)

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
rownames(df_cea_agg_n)<-df_cea_agg_n$county

names(df_cea_agg_n)
str(df_cea_agg_n)

scaled_df <- scale(df_cea_agg_n)
kclus <- kmeans(scaled_df, 3)$cluster
clusplot(scaled_df, kclus)
clusplot(scaled_df, kclus, color = TRUE, shade = TRUE, labels = 2, lines = 0)


# state.x77
# 
# scaled_df <- scale(state.x77)
# clus <- kmeans(scaled_df, 3)$cluster
# clusplot(scaled_df, clus)
# clusplot(scaled_df, clus, color = TRUE, shade = TRUE, labels = 2, lines = 0)
