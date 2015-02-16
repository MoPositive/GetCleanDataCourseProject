## Run analysis will perform the following:
## 1. Merges the training and the test sets to create 
##  one data set.
## 2. Extracts only the measurements on the mean and 
##  standard deviation for each measurement. 
## 3. Uses descriptive activity names to name the 
##  activities in the data set
## 4. Appropriately labels the data set with descriptive 
##  variable names. 
## 5. From the data set in step 4, creates a second, 
##  independent tidy data set with the average of each 
##  variable for each activity and each subject.

## 1. Merges the training and the test sets to create 
##  one data set.

## Load the train and test datasets, from their respective directories
## Script assumes the data is downloaded and unzipped and we are 
## working from the "UCI HAR Dataset" directory

## Data
xTrain <- read.table("train/X_train.txt")
xTest <- read.table("test/X_test.txt")

## Activities (labels)
yTrain <- read.table("train/Y_train.txt")
yTest <- read.table("test/Y_test.txt")

## Merge test and train sets
y <- rbind(yTrain, yTest)
x <- rbind(xTrain, xTest)

## 2. Extracts only the measurements on the mean gand 
##  standard deviation for each measurement.

## Load the list of feature names
features <- read.table("features.txt")

## get the rows of features that have mean or std
meanStd <- grep("mean\\(|std\\(",features[,2])

## 3. Uses descriptive activity names to name the 
##  activities in the data set

## get the activity labels
a_labels <- read.table("activity_labels.txt")

## give the data a meaningful column name
colnames(y) <- "activity"

## get activity names for y
yName <- sapply(y,function(x) {a_labels[x,2]})

## get the subject data and merge
sTrain <- read.table("train/subject_train.txt")
sTest <- read.table("test/subject_test.txt")
s <- rbind(sTrain, sTest)

## give the data a meaningful column name
colnames(s) <- "subject"

## merge the activity & subject data with mean/std dev data
data_set <- cbind(yName,s,x[,meanStd])

## rename the columns with descriptive values
colnames(data_set) <- 
  c(colnames(y),colnames(s),as.character(features[meanStd,2]))

## 5. From the data set in step 4, creates a second, 
##  independent tidy data set with the average of each 
##  variable for each activity and each subject.

## use ddply to group the data by activity and subject,
## calculate the mean for the columns (using numcolwise)
## and put the data frame back together
new_data <- ddply(data_set,.(activity,subject),numcolwise(mean,na.rm = TRUE))

## Update the column names to note values are now averaged
colnames(new_data)[c(-1,-2)] <- 
  sapply(colnames(new_data)[c(-1,-2)], function(x){paste("avg",x,sep="-")})

## write new data set to a text file for submission
write.table(new_data, "new_data.txt", row.name=FALSE)