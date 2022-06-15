#################################
# Text Mining 
#################################

# install.packages()
# install.packages("arules")
# install.packages("arulesViz")
# install.packages("plotly")
# library(plotly)

#tm package provides a framework for text mining applications
# install.packages("tm")
# install.packages("wordcloud") #install "wordcloud"
# Activate tm library
library(tm)
library(wordcloud) #load "wordcloud"

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

mypath = "D:/University/ASDM/Developments/Task 4 - Text Mining"
# you need to change the string to your directory
setwd(mypath)
# set working directory
getwd()
# check if the working directory has changed correctly

dataset<- readLines("TMwithR.txt")
dataset

names(dataset)
head(dataset)
tail(dataset)
summary(dataset)
str(dataset)

#converting the text file to corpus
#Corpus is collections of documents containing (natural language) text. Corpus is the main structure that tm uses for storing and manipulating text documents.
mycorpus <- Corpus(VectorSource(dataset))
mycorpus

inspect(mycorpus[1])
inspect(mycorpus[2])
inspect(mycorpus[3])

inspect(mycorpus[8])
mycorpus[8]

#tm_map function can be used as interface to apply transformation functions to corpus. (to lower case)
mycorpus <- tm_map(mycorpus,tolower)
inspect(mycorpus[8])

# Use getTransformations() function to retrieve the list of predefined transformations (mappings) which can be used with tm_map function
getTransformations()

# Remove punctuations
mycorpus <-tm_map(mycorpus,removePunctuation)
inspect(mycorpus[8])

# Remove numbers
mycorpus <- tm_map(mycorpus,removeNumbers)

# Stop words
stopwords("en")

# Remove stop words
dataclean <-tm_map(mycorpus,removeWords,stopwords("english"))
inspect(dataclean[8])

# Strip whitespaces
dataclean <- tm_map(dataclean,stripWhitespace)
inspect(dataclean[8])

# The next step is to create a Document-Term Matrix (DTM). DTM is a matrix that lists all occurrences of words in the corpus. In DTM, documents are represented by rows and the terms (or words) by columns. If a word occurs in a particular document n times, then the matrix entry for corresponding to that row and column is n, if it doesn’t occur at all, the entry is 0.
# Use the following line of code to create the term document matrix 

dtm <- TermDocumentMatrix(dataclean,
                          control = list(minWordLength=c(1,Inf))
)
dtm

#findFreqTerms function can be used to find frequent terms in a document-term or term-document matrix.
findFreqTerms(dtm,lowfreq = 2)

# See words with frequency
termFrequency <- rowSums(as.matrix(dtm))
termFrequency

# See words greater than 15 
termFrequency <- subset(termFrequency,termFrequency>=15)
termFrequency

# Plotting
barplot(termFrequency,las=2,col=rainbow(20))

wordfreq <-sort(termFrequency,decreasing = TRUE)
wordfreq

# Variation 1
wordcloud(words = names(wordfreq), freq=wordfreq,max.words=100, min.freq = 5, random.order = F)

# Variation 2
wordcloud(words = names(wordfreq), freq=wordfreq,max.words=100, min.freq = 5, random.order = F, colors = rainbow(20))

# Variation 3
wordcloud(words = names(wordfreq), freq=wordfreq,max.words=100, min.freq = 5, random.order = F, colors = brewer.pal(6,"Dark2"))

# Variation 4
wordcloud(words = names(wordfreq), scale = c(6,.05), freq=wordfreq,max.words=100, min.freq = 5, random.order = F, colors = brewer.pal(6,"Dark2"))

# Variation 5
wordcloud(words = names(wordfreq), rot.per=0.50, scale = c(6,.05), freq=wordfreq, max.words=100, min.freq = 5, random.order = F, colors = brewer.pal(6,"Dark2"))


#We now see the distribution of the 50 most frequent words in a barplot.
#We now see the distribution of the 50 most frequent words in a barplot. 
barplot(wordfreq[1:50], xlab = "term", ylab = "frequency", las=2, col=heat.colors(50))


###########
# Level 2 
#############
## Twitter Data set 

#Read the data file
bbchealth <- read.csv("Health_Tweets_Data/bbchealth.csv", header= TRUE)
cnnhealth <- read.csv("Health_Tweets_Data/cnnhealth.csv", header= TRUE)
foxhealth <- read.csv("Health_Tweets_Data/foxnewshealth.csv", header= TRUE)
#Inspect the dataset
head(bbchealth)
head(cnnhealth)
head(foxhealth)

#Inspect the tweet column in the datasets
head(bbchealth$tweet)
head(cnnhealth$tweet)
head(foxhealth$tweet)

#create text vectors
bbchealth_tweet<- bbchealth$tweet
cnnhealth_tweet<- cnnhealth$tweet
foxhealth_tweet<- foxhealth$tweet

#convert all text to lower case
bbchealth_tweet<- tolower(bbchealth_tweet)
cnnhealth_tweet<- tolower(cnnhealth_tweet)
foxhealth_tweet<- tolower(foxhealth_tweet)

#gsub() function replaces all matches of a string, if the parameter is a string vector, returns a string vector of the same length and with the same attributes (after possible coercion to character). Elements of string vectors which are not substituted will be returned unchanged (including any declared encoding). gsub() function can use regular expressions as search string.


# Reg Exp 
# https://rstudio-pubs-static.s3.amazonaws.com/74603_76cd14d5983f47408fdf0b323550b846.html
# • http://biostat.mc.vanderbilt.edu/wiki/pub/Main/SvetlanaEdenRFiles/regExprTalk.pdf

#Replace blank space (“rt”)
bbchealth_tweet <- gsub("rt", "", bbchealth_tweet)
cnnhealth_tweet <- gsub("rt", "", cnnhealth_tweet)
foxhealth_tweet <- gsub("rt", "", foxhealth_tweet)
#Replace tweeter @UserName
bbchealth_tweet <- gsub("@\\w+", "", bbchealth_tweet)
cnnhealth_tweet <- gsub("@\\w+", "", cnnhealth_tweet)
foxhealth_tweet <- gsub("@\\w+", "", foxhealth_tweet)

#Replace links in the tweets
bbchealth_tweet <- gsub("http\\S+\\s*", "", bbchealth_tweet)
cnnhealth_tweet <- gsub("http\\S+\\s*", "", cnnhealth_tweet)
foxhealth_tweet <- gsub("http\\S+\\s*", "", foxhealth_tweet)
#Remove punctuation
bbchealth_tweet <- gsub("[[:punct:]]", "", bbchealth_tweet)
cnnhealth_tweet <- gsub("[[:punct:]]", "", cnnhealth_tweet)
foxhealth_tweet <- gsub("[[:punct:]]", "", foxhealth_tweet)


#Remove tabs
bbchealth_tweet <- gsub("[ |\t]{2,}", "", bbchealth_tweet)
cnnhealth_tweet <- gsub("[ |\t]{2,}", "", cnnhealth_tweet)
foxhealth_tweet <- gsub("[ |\t]{2,}", "", foxhealth_tweet)

#Remove "video" word in the tweets
bbchealth_tweet <- gsub("video", "", bbchealth_tweet)
cnnhealth_tweet <- gsub("video", "", cnnhealth_tweet)
foxhealth_tweet <- gsub("video", "", foxhealth_tweet)

#Remove blank spaces at the beginning
bbchealth_tweet <- gsub("^ ", "", bbchealth_tweet)
cnnhealth_tweet <- gsub("^ ", "", cnnhealth_tweet)
foxhealth_tweet <- gsub("^ ", "", foxhealth_tweet)

#Remove blank spaces at the end
bbchealth_tweet <- gsub(" $", "", bbchealth_tweet)
cnnhealth_tweet <- gsub(" $", "", cnnhealth_tweet)
foxhealth_tweet <- gsub(" $", "", foxhealth_tweet)

#Inspect the vectors after cleaning
head(bbchealth_tweet)
head(cnnhealth_tweet)
head(foxhealth_tweet)


library(tm) #load tm package
#converting the text vectors to corpus
bbchealth_corpus <- Corpus(VectorSource(bbchealth_tweet))
bbchealth_corpus

cnnhealth_corpus <- Corpus(VectorSource(cnnhealth_tweet))
cnnhealth_corpus
foxhealth_corpus <- Corpus(VectorSource(foxhealth_tweet))
foxhealth_corpus

#clean up corpus by removing stop words, number and Whitespace
bbchealth_corpus <- tm_map(bbchealth_corpus, removeWords,stopwords("english"))
bbchealth_corpus <- tm_map(bbchealth_corpus,removeNumbers)
bbchealth_corpus <- tm_map(bbchealth_corpus,stripWhitespace)
inspect(bbchealth_corpus )
cnnhealth_corpus <- tm_map(cnnhealth_corpus, removeWords,stopwords("english"))
cnnhealth_corpus <- tm_map(cnnhealth_corpus, removeNumbers)
cnnhealth_corpus <- tm_map(cnnhealth_corpus, stripWhitespace)
inspect(cnnhealth_corpus )
foxhealth_corpus <- tm_map(foxhealth_corpus , removeWords,stopwords("english"))
foxhealth_corpus <- tm_map(foxhealth_corpus , removeNumbers)
foxhealth_corpus <- tm_map(foxhealth_corpus , stripWhitespace)
inspect(foxhealth_corpus )


library("wordcloud") #load wordcloud package
#generate wordclouds
wordcloud(bbchealth_corpus,
          min.freq = 10,
          colors=brewer.pal(8, "Dark2"),
          random.color = TRUE,
          max.words = 100)

wordcloud(cnnhealth_corpus,
          min.freq = 10,
          colors=brewer.pal(8, "Dark2"),
          random.color = TRUE,
          max.words = 100)


wordcloud(foxhealth_corpus,
          min.freq = 10,
          colors=brewer.pal(8, "Dark2"),
          random.color = TRUE,
          max.words = 100)


#Create document-term matrix
bbchealth_dtm <- DocumentTermMatrix(
  bbchealth_corpus,
  control = list(minWordLength=c(3,Inf),
                 bounds = list(global = c(40, Inf)))
)
cnnhealth_dtm <- DocumentTermMatrix(
  cnnhealth_corpus,
  control = list(minWordLength=c(3,Inf),
                 bounds = list(global = c(40, Inf)))
)
foxhealth_dtm <- DocumentTermMatrix(
  foxhealth_corpus,
  control = list(minWordLength=c(3,Inf),
                 bounds = list(global = c(40, Inf)))
)
bbchealth_dtm
cnnhealth_dtm
foxhealth_dtm


bbchealth_dtm2 <- as.matrix(bbchealth_dtm)
cnnhealth_dtm2 <- as.matrix(cnnhealth_dtm)
foxhealth_dtm2 <- as.matrix(foxhealth_dtm)

#K-means clustering
library(cluster) #load cluster package
library(factoextra) #load factoextra package

head(bbchealth_dtm2)
bbc_dist <- dist(t(bbchealth_dtm2), method="euclidian")
kfit <- kmeans(bbc_dist, 3)
bbc_dist
kfit
fviz_cluster(kfit,bbc_dist)


head(cnnhealth_dtm2)
cnn_dist <- dist(t(cnnhealth_dtm2), method="euclidian")
kfit <- kmeans(cnn_dist, 3)
cnn_dist
kfit
fviz_cluster(kfit,cnn_dist)

head(foxhealth_dtm2)
fox_dist <- dist(t(foxhealth_dtm2), method="euclidian")
kfit <- kmeans(fox_dist, 3)
fox_dist
kfit
fviz_cluster(kfit,fox_dist)