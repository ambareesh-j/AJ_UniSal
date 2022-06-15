#################################
# Sentiment Analysis
#################################

# Step 0 - Problem Definition 
# To identify various burger joints among the given tourist accommodations and analyze the sentiment by restaurant

# Step 1 - Environmental Setup
# 1.1 - Install the required packages/libraries from R
# install.packages('dplyr')
# install.packages('tidyverse')
# install.packages('skimr')
# install.packages("tm")  # for text mining
# install.packages("SnowballC") # for text stemming
# install.packages("wordcloud") # word-cloud generator
# install.packages("RColorBrewer") # color palettes
# install.packages("syuzhet") # for sentiment analysis
# install.packages("ggplot2") # for plotting graphs
# install.packages('syuzhet') # For sentiment scores, emotion classification

# 1.2 - Load the libraries
library(dplyr) 
library(tidyverse)
library(ggplot2)
library(RColorBrewer)
library(skimr)
library(tm) 
library(wordcloud) 
library(SnowballC)
library(syuzhet)

# 1.3 - Setup Working directory
fpath = "D:/University/ASDM/Developments/Task 4 - Text Mining"
setwd(fpath)   # Set the WD
getwd()        # Validate the new WD

# Step 2 - Data Acquisition
# 2.1 - Setup Lexicon for Sentiment Analysis 
p_lex <- read.csv("Sentiment Analysis Data/positive-lexicon.txt")
n_lex <- read.csv("Sentiment Analysis Data/negative-lexicon.txt")

# 2.2 - Inspect lexicon
head(p_lex)     
tail(p_lex)

head(n_lex)
tail(n_lex)

# 2.3 - Import the Tourist Accommodation reviews file into R 
df_revs_raw <- read.csv("tourist_accommodation_reviews.csv", header= TRUE)

# 2.4 - Inspect the acquired data
names(df_revs_raw)    
head(df_revs_raw)
tail(df_revs_raw)
summary(df_revs_raw)
str(df_revs_raw)
dim(df_revs_raw)

# Step 3 - Data Preprocessing
# 3.1 Duplicate (to lowercase) the "review" column - to transform it later
df_revs_raw$Review_TRF <- tolower(df_revs_raw$Review)

# 3.2 Identify the "burger joints" & Filter them out as a subset
df_revs_raw$Is_Burg_Joint <- grepl(c("burg"), df_revs_raw$Review_TRF)
df_burg <- subset(df_revs_raw, Is_Burg_Joint==TRUE)

# 3.3 - Inspect the new subset
names(df_burg)    
head(df_burg)
tail(df_burg)
summary(df_burg)
str(df_burg)
dim(df_burg)

# 3.4 - Inspect the review column to validate the search
head(df_burg$Review)


# 3.5 - Creating a function for sentimental analysis
f_sentiment_burg <- function(stem_corpus)
{
  # 3.5.1 - Variable initialization
  tot_pos_cnt <- 0
  tot_neg_cnt <- 0
  pos_cnt_vec <- c()
  neg_cnt_vec <- c()
  size <- length(stem_corpus)
  
  # 3.5.2 - Loop to identify positive and negative lexicon
  for(i in 1:size)
  {
    # List the words by splitting them by spaces
    corpus_words <- list(strsplit(stem_corpus[[i]]$content, split = " "))
    
    # Segregate Positive and Negative Counts based on Lexicon
    pos_cnt <-length(intersect(unlist(corpus_words), unlist(p_lex)))
    neg_cnt <-length(intersect(unlist(corpus_words), unlist(n_lex)))
    
    # Overall positive & negative counts
    tot_pos_cnt <- tot_pos_cnt + pos_cnt 
    tot_neg_cnt <- tot_neg_cnt + neg_cnt 
  }
  
  # 3.5.3 - Total Count is the sum of positive & negative counts
  tot_pos_cnt 
  tot_neg_cnt 
  tot_cnt <- tot_pos_cnt + tot_neg_cnt
  
  # 3.5.4 - Formulate the Overall Positive % & Overall Negative % 
  overall_pos_percent <- (tot_pos_cnt*100)/tot_cnt
  overall_neg_percent <- (tot_neg_cnt*100)/tot_cnt
  
  overall_pos_percent  # Inspect
  
  # 3.5.5 - Create a data frame to be utilized at a later stage
  df<-data.frame(Positive=num(tot_pos_cnt),
                 Negative=num(tot_neg_cnt),
                 Total = num(tot_cnt),
                 Overall_Rating = overall_pos_percent)
  return(df) 
}

# 3.6 - Creating a function for Word Cloud
f_wc <- function(stem_corpus, v_jt)
{
print(v_jt)
wordcloud(stem_corpus,
          min.freq = 3,
          colors=brewer.pal(8, "Dark2"),
          random.color = TRUE,
          max.words = 100)
}
  
# Step 4 - Data Preparation & Cleanup 
# 4.1 - Identify the unique burger joints and sort them by alphabetical order.
v_burgJoints <- sort(unique(df_burg$Hotel.Restaurant.name))
v_burgJoints

# 4.2 - Variable Initialization
df_final = data.frame( burg_joint=rep(0, 10), Positive=rep(0,10), Negative=rep(0,10), Total=rep(0,10), Overall_Rating=rep(0,10))

iter = 0 # Loop counter variable

# 4.3 - Loop using Burger Sentiment function ("f_sentiment_burg()")
for (burg_joint in v_burgJoints) {
  
  # 4.3.1 - Loop counter variable 
  iter = iter+1
  
  # 4.3.2 - Create text vectors
  vec_burg_reviews <- subset(df_burg$Review_TRF,df_burg$Hotel.Restaurant.name==burg_joint) 
  
  # gsub() function replaces all matches of a string
  
  # 4.3.3 - Remove hyperlinks from the reviews (if any)
  vec_burg_reviews <- gsub("http\\S+\\s*", "", vec_burg_reviews)
  
  # 4.3.4 - Remove punctuation from the reviews
  vec_burg_reviews <- gsub("[[:punct:]]", "", vec_burg_reviews)
  
  # 4.3.5 - Remove numerical values from the reviews
  vec_burg_reviews <- gsub("[[:digit:]]", "", vec_burg_reviews)
  
  # 4.3.6 - Remove leading blank spaces at the beginning from the reviews
  vec_burg_reviews <- gsub("^ ", "", vec_burg_reviews)
  
  # 4.3.7 - Remove blank spaces at the end from the reviews
  vec_burg_reviews <- gsub(" $", "", vec_burg_reviews)
  
  # 4.3.8 - Replace "\n" word with a space from the reviews
  vec_burg_reviews <- gsub("\n", " ", vec_burg_reviews)

  # 4.3.9 - Converting the text vectors to corpus
  corpus_burg_revs <- Corpus(VectorSource(vec_burg_reviews))
  
  # 4.3.10 - Clean up corpus by removing stop words and Whitespace
  corpus_burg_revs <- tm_map(corpus_burg_revs, removeWords,stopwords("english"))
  corpus_burg_revs <- tm_map(corpus_burg_revs, stripWhitespace)

  # 4.3.11 - Stem the words to their root of all reviews present in the corpus
  stem_corpus_burg_revs <- tm_map(corpus_burg_revs, stemDocument)
  
  # 4.3.12 - Utilize the sentiment analysis function for the stemmed corpus and append it to a dataframe
  df_final[iter,] <- c(burg_joint, f_sentiment_burg(stem_corpus_burg_revs))
}

# 4.4 - Inspect the outcomes for each restaurant
head(df_final)
tail(df_final)
names(df_final)

# 4.5 - Sort by total reviews & pick top 30 restaurants with highest total reviews
df_final <- df_final[order(-df_final$Total),]
df_pop30 <- df_final[1:30,]
head(df_pop30)

# 4.6 - Setup rownames as Restaurant names
rownames(df_pop30) <- df_pop30$burg_joint

# 4.7 - Pivot the Positive & Negative reviews for comparative analysis
df_pop30_comp <- df_pop30[,1:3] %>% 
  pivot_longer(
    cols = ends_with("tive"), 
    names_to = "Review Type", 
    values_to = "Review Count",
    values_drop_na = TRUE
  )
head(df_pop30_comp)
tail(df_pop30_comp)
names(df_pop30_comp)

# 4.8 - Subset & sort top 30 reviews for Word cloud
# Subset
df_pop30_revs <- df_burg %>% filter(Hotel.Restaurant.name %in% df_pop30$burg_joint)
dim(df_pop30_revs)
# Sort
v_top30_burg_jts <- sort(unique(df_pop30_revs$Hotel.Restaurant.name))
v_top30_burg_jts

# 4.9 - Loop for Word Clouds (top 30 only)
for (burg_joint in v_top30_burg_jts) {
  
  # 4.3.2 - Create text vectors
  vec_burg_reviews <- subset(df_burg$Review_TRF,df_burg$Hotel.Restaurant.name==burg_joint) 
  
  # gsub() function replaces all matches of a string
  
  # 4.3.3 - Remove hyperlinks from the reviews (if any)
  vec_burg_reviews <- gsub("http\\S+\\s*", "", vec_burg_reviews)
  
  # 4.3.4 - Remove punctuation from the reviews
  vec_burg_reviews <- gsub("[[:punct:]]", "", vec_burg_reviews)
  
  # 4.3.5 - Remove numerical values from the reviews
  vec_burg_reviews <- gsub("[[:digit:]]", "", vec_burg_reviews)
  
  # 4.3.6 - Remove leading blank spaces at the beginning from the reviews
  vec_burg_reviews <- gsub("^ ", "", vec_burg_reviews)
  
  # 4.3.7 - Remove blank spaces at the end from the reviews
  vec_burg_reviews <- gsub(" $", "", vec_burg_reviews)
  
  # 4.3.8 - Replace "\n" word with a space from the reviews
  vec_burg_reviews <- gsub("\n", " ", vec_burg_reviews)
  
  # 4.3.9 - Converting the text vectors to corpus
  corpus_burg_revs <- Corpus(VectorSource(vec_burg_reviews))
  
  # 4.3.10 - Clean up corpus by removing stop words and Whitespace
  corpus_burg_revs <- tm_map(corpus_burg_revs, removeWords,stopwords("english"))
  corpus_burg_revs <- tm_map(corpus_burg_revs, stripWhitespace)
  
  # 4.3.11 - Stem the words to their root of all reviews present in the corpus
  stem_corpus_burg_revs <- tm_map(corpus_burg_revs, stemDocument)
  
  f_wc(stem_corpus_burg_revs, burg_joint)
}

# Step 5 - Data Analysis

# 5.1 - Highest Overall Ratings 
options(digits=2)
df_pop30 %>% mutate(burg_joint = fct_reorder(burg_joint, desc(Overall_Rating))) %>%
  ggplot(aes(burg_joint,Overall_Rating))+
  geom_col() +
  labs(title="Top 30 Burger Joints by Highest Overall Positive Ratings (%)")+
  theme(plot.title = element_text(hjust = 0.5, size = 18, face = 'bold'))+
  xlab("Name of the Restaurant")+ 
  ylab("Overall Positive Rating in %")+
  theme(axis.title.x = element_text(size=14, face = 'bold'))+
  theme(axis.title.y = element_text(size=14, face = 'bold'))+ 
  geom_text(aes(label = signif(Overall_Rating, digits = 3)), nudge_y = 4, size = 3)+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

# 5.2 - Comparative analysis (Positive vs. Negative reviews)
# using 100% stacked bar graph
ggplot(df_pop30_comp, 
       aes(fill=df_pop30_comp$`Review Type`, 
           y=df_pop30_comp$`Review Count`, 
           x=df_pop30_comp$burg_joint)) + 
  geom_bar(position="fill", stat="identity") +
  xlab("Name of the Restaurant")+ 
  ylab("Positive vs. Negative reviews")+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  ggtitle("Top 30 Burger joints in Thailand by Positive & Negative Reviews") +
  theme(axis.title.x = element_text(size=14, face = 'bold'))+
  theme(axis.title.y = element_text(size=14, face = 'bold'))+ 
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = 'bold'))+
  guides(fill=guide_legend(title="Review Type"))


# However, these overall positive ratings may not fully justify our cause, since the number of ratings also need to be checked first

# 5.3 - Total Reviews 

# 5.3.1 - Custom Bar plot (ability to rotate labels)
# Arguments - data - dataframe ; col - column to plot ; lab_vec - Labels vector, aor - Angle of Rotation
custom_x <- function(data, col, lab_vec, aor, title, ylabs) {
  plt <- barplot(data[[col]], main = title, ylab = ylabs, col='goldenrod1', xaxt="n")
  text(plt, par("usr")[3], labels = lab_vec, srt = aor, adj = c(1.1,1.1), xpd = TRUE, cex=0.6) 
}

# 5.3.2 - Plotting the top 30 burger joints using number of reviews
custom_x(df_pop30, 'Total', row.names(df_pop30), 45, "Top 30 Burger Joints in Thailand by total number of reviews", "Total number of reviews")

# 5.4 - Comparative analysis using simple Stacked bar graph
ggplot(df_pop30_comp, aes(fill=df_pop30_comp$`Review Type`, 
                          y=df_pop30_comp$`Review Count`, 
                          x=df_pop30_comp$burg_joint)) + 
  geom_bar(position="stack", stat="identity")+
  xlab("Name of the Restaurant")+ 
  ylab("Positive vs. Negative reviews")+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  ggtitle("Top 30 Burger joints in Thailand by Positive & Negative Reviews") +
  theme(axis.title.x = element_text(size=14, face = 'bold'))+
  theme(axis.title.y = element_text(size=14, face = 'bold'))+ 
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = 'bold'))+
  guides(fill=guide_legend(title="Review Type"))


# 5.5 - Using Combo chart (Bar+Line graph) 
ggplot(df_pop30) + 
  geom_col(aes(x = burg_joint, y = Total), 
           size = 1, color = "white", fill = "steelblue") +
  geom_line(aes(x = burg_joint, y = Overall_Rating), 
            size = 1, color="red", group = 1) +
  xlab("Name of the Restaurant")+ 
  ylab("Number of Reviews")+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  ggtitle("Top 30 Burger joints in Thailand by Positive & Negative Reviews") +
  theme(axis.title.x = element_text(size=14, face = 'bold'))+
  theme(axis.title.y = element_text(size=14, face = 'bold'))+ 
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = 'bold'))+ geom_hline(yintercept=90, linetype="dashed", color = "red")
  

# Step 6 - Overall Sentiment Scores & Emotion Classification

# 6.1 - Use various methods (scales) to create vectors
# 6.1.1 - Syuzhet
burg_syuzhet <- get_sentiment(df_burg$Review, method="syuzhet")
head(burg_syuzhet)
summary(burg_syuzhet)

# 6.1.2 - Bing
burg_bing <- get_sentiment(df_burg$Review, method="bing")
head(burg_bing)
summary(burg_bing)

# 6.1.3 - Affin
burg_afinn <- get_sentiment(df_burg$Review, method="afinn")
head(burg_afinn)
summary(burg_afinn)

# 6.2 - NRC Sentiment Analysis 
# anger, anticipation, disgust, fear, joy, sadness, surprise, trust 
burg_nrc <- get_nrc_sentiment(df_burg$Review)
head(burg_nrc)
dim(burg_nrc)

# 6.3 - Data Transformation for Emotions
# 6.3.1 - Transpose
burg_nrc_t <- data.frame(t(burg_nrc))

# 6.3.2 - Grouping using Sum
burg_nrc_g <- data.frame(rowSums(burg_nrc_t[1:1454]))

# 6.3.3 - Cleanup
names(burg_nrc_g)[1] <- "count"
burg_nrc_g <- cbind("sentiment" = rownames(burg_nrc_g), burg_nrc_g)
rownames(burg_nrc_g) <- NULL
burg_nrc_final<-burg_nrc_g[1:8,]

# 6.3.4 - Plot using quickplot
#Plot One - count of words associated with each sentiment
quickplot(sentiment, data=burg_nrc_final, weight=count, geom="bar", fill=sentiment, ylab="count")+
  ggtitle("Survey sentiments")+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
  theme(axis.title.x = element_text(size=14, face = 'bold'))+
  theme(axis.title.y = element_text(size=14, face = 'bold'))+ 
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = 'bold'))

# 6.3.4 - Plot to identify strong vs weak emotions
barplot(
  sort(colSums(prop.table(burg_nrc[, 1:8]))), 
  horiz = TRUE, 
  cex.names = 0.7, 
  col='steelblue',
  las = 1, 
  main = "Emotions in Reviews", xlab="Percentage"
)

