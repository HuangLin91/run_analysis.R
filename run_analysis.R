#The purpose of this project is to demonstrate your ability to collect, 
#work with, and clean a data set. The goal is to prepare tidy data that 
#can be used for later analysis. You will be graded by your peers on a 
#series of yes/no questions related to the project. 

#You will be required to submit:

# 1) a tidy data set as described below, 
# 2) a link to a Github repository with your script for performing the 
#    analysis, and 
# 3) a code book that describes the variables, the data, and any 
#    transformations or work that you performed to clean up the data 
#    called CodeBook.md. You should also include a README.md in the repo 
#    with your scripts. This repo explains how all of the scripts work 
#    and how they are connected.  

#One of the most exciting areas in all of data science right now is 
#wearable computing - see for example this article . Companies like Fitbit, 
#Nike, and Jawbone Up are racing to develop the most advanced algorithms 
#to attract new users. The data linked to from the course website represent 
#data collected from the accelerometers from the Samsung Galaxy S smartphone. 
#A full description is available at the site where the data was obtained:

#http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones  

#Here are the data for the project: 
#https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  

#You should create one R script called run_analysis.R that does the following: 
# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation 
#    for each measurement. 
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive activity names. 
# 5.Creates a second, independent tidy data set with the average of 
#    each variable for each activity and each subject. 

#-------------------------- Assignment Starts Here ----------------------------#
library(data.table)
library(reshape2)

#Step 1: Load data 
#1a: Loda raw data
subject_test <- read.table("./test/subject_test.txt", quote="\"")
X_test <- read.table("./test/X_test.txt", quote="\"")
y_test <- read.table("./test/y_test.txt", quote="\"")
subject_train <- read.table("./train/subject_train.txt", quote="\"")
X_train <- read.table("./train/X_train.txt", quote="\"")
y_train <- read.table("./train/y_train.txt", quote="\"")
features <- read.table("features.txt", quote="\"")
activity_labels <- read.table("activity_labels.txt", quote="\"")

head(subject_test);head(X_test);head(y_test);head(subject_train)
head(X_train);head(y_train);head(features);head(activity_labels) 

#1b: load the name column from the following 2 files
feature_names <- features[,2]
activity_names <- activity_labels[,2]

head(feature_names);head(activity_names)

#Step 2: Extracts only the measurements on the mean and standard deviation 
#        for each measurement. (point 2)
#2a: Label the test and train data sets
names(X_test)<-feature_names
names(X_train)<-feature_names

#2b: Extracts only the measurements on the mean and standard deviation
X_test<-X_test[,grepl("mean|std", feature_names)]
X_train<-X_train[,grepl("mean|std", feature_names)]

#Step 3: Describe data. (points 3 and 4)
#3a: bind the test and train data sets
data<-rbind(X_test, X_train)

#3b: add a column with the activities description and bind the 2 sets
y_test[,2]<-activity_names[y_test[,1]]
y_train[,2]<-activity_names[y_train[,1]]
activities<-rbind(y_test, y_train)

head(y_test);head(y_train);head(activities)

#3c: label the columns
names(activities)<-c("ActivityID", "ActivityLabel")

#3d: bind and label the subject names from the test and train files
subject<-rbind(subject_test, subject_train)
colnames(subject)<-"SubjectNumber"

head(subject)

#Step 4: Combine all three tables. (point 1)
alldata<-cbind(as.data.table(subject), activities, data)
head(alldata)

#Step 5: Creates a second, independent tidy data set with the average of each 
#        variable for each activity and each subject. (point 5)

#5a: Calculate average of each variable for each activity and each subject
id_labels<-c("SubjectNumber", "ActivityID", "ActivityLabel")
data_labels<-setdiff(colnames(alldata), id_labels)
predata<-melt(alldata, id = id_labels, measure.vars = data_labels)
head(predata)
result<-dcast(predata, SubjectNumber + ActivityLabel ~ variable, mean)
head(result)

#5b: write the tidy dataset to a file
write.table(result, "tidydataset.txt",sep="/")
