# Import the "Cardiotocographic.csv"data file and create a data frame

mypath = "D:/University/ASDM/Workshops/W5"
setwd(mypath)

cardio_data <- read.csv("Cardiotocographic.csv", header= TRUE)

# Inspect the dataset in R

names(cardio_data) 
head(cardio_data) 
tail(cardio_data) 
summary(cardio_data) 
str(cardio_data)

# Check the dimension and number of points of the "cardio_data" dataset

nrow(cardio_data) 
ncol(cardio_data) 
dim(cardio_data) 

# Since we need categorical (Factor) data to class variable for prediction, hence we should 
# convert the NSP variable to categorical form by running the following command.

# as.factor function convert a column into a factor column.

cardio_data$NSPF <- as.factor(cardio_data$NSP)
str(cardio_data) 

# Now we will be specifying our train and validate(test) data from our data. Take small number 
# of observations to test the model. Now we will divide our sample into 80% Training and 20% Validation parts for implementing 
# our trees.

# set.seed() function in R is used to reproduce results i.e. it produces the same sample again and again.
# Random number generator
set.seed(1234) 

# sample function can be used to return a random permutation of a vector.
pd <- sample(2, nrow(cardio_data),replace=TRUE, prob=c(0.8,0.2))
pd

# ML datasets
train <- cardio_data[pd==1,] 
validate <- cardio_data[pd==2,] 

# Check the ML datasets
# To check how many observations are in train and validate data sets .
dim(train) # Retrieve the dimension of the train data set 
dim(validate) # Retrieve the dimension of the validate data set

# Decision Trees - Implement with "party" package
# Ignore instalation if "party" package was already installed. You can run library() to find out this. 

install.packages("party") 
library("party")

# Train the tree using ctree() function in party package. 
# Note :for simplicity, we only use four variables, BPM, APC, FMPS and UCPS, to predict the NSP value.

# ctree(formula, data, subset)
# Arguments 
#   formula : a symbolic description of the model to be fit. 
#   data : a data frame containing the variables in the model. 
#   Subset : an optional vector specifying a subset of observations to be used in the fitting process.

cardio_tree <- ctree(NSPF ~ BPM + APC + FMPS + UCPS ,data = train) 
cardio_tree 

print(cardio_tree) # Draw the tree
plot(cardio_tree)

plot(cardio_tree, type="simple")

## PREDICTION 
predict(cardio_tree)

tab <- table(predict(cardio_tree), train$NSPF) 
print(tab) # Here you see a confusion matrix

# Calculate Classification accuracy and error on train data itself
# diag() function extracts the diagonal of a matrix

sum(diag(tab))/sum(tab)   # 83% is accurate

1 - sum(diag(tab))/sum(tab) # that means classification error is 17.89% 

## Now we test the TEST data as part of ML modeling

test_predict <- table(predict(cardio_tree, newdata= validate), validate$NSPF) 
print(test_predict)  # Another confusion matrix received

## Accuracy and Error 
sum(diag(test_predict))/sum(test_predict)   # 80% accurate

#so 20% error 

# Other packages - rpart, tree, maptree, partykit, evtree, randomForest, varSelRF

# You can do a variety of practice on other variables as you wish. 
# Eg 1: Use BPM, DLPS, SDPS and PDPS to predict the NSP value. 
# Eg 2: Use all the variables to predict the NSP value. 



