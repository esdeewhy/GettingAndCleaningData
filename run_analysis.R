# Setting the current working directory to the one containing all the files that need to be merged:
setwd("Coursera")
# We are supposing that the data for the project are downloaded and extracted in the working directory "Coursera", under the name "UCI HAR Dataset"

# Library used
library(dplyr)
library(data.table)

# Read of Data (featuresNames and activityLabels)
featuresNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
# Read of training and data set
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTrain <- read.table("UCI HAR Dataset/train/x_train.txt", header = FALSE)

subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTest <- read.table("UCI HAR Dataset/test/x_test.txt", header = FALSE)

#1- Merging the training and the test sets to create one data set and naming the columns
datsubject <- rbind(subjectTrain, subjectTest)
datctivity <- rbind(activityTrain, activityTest)
datfeatures <- rbind(featuresTrain, featuresTest)
colnames(datsubject)<- c("Subject")
colnames(datctivity)<- c("Activity")
names(datfeatures)<- featuresNames$V2

# Merging subject, activity and features
MergedData<- cbind(datfeatures, datctivity, datsubject)
dim(MergedData)
# [1] 10299    563

#2-Extracts only the measurements on the mean and standard deviation for each measurement
# We are reading features.txt and extracting columns indiced by etheir mean or std
datfeaturesextract<- featuresNames$V2[grep("mean\\(\\)|std\\(\\)", featuresNames$V2)]
#selectedNames<- union(c("Subject", "Activity"), selectedNames)
selectedNames<- c(as.character(datfeaturesextract), "Subject", "Activity" )
extractedData<- subset(MergedData, select=selectedNames)
dim(extractedData)
# [1] 10299    68

#3 Using descriptive activity names to name the activities in the data set
# The activity's names are extracted from activity_labels.txt. We will read activity_labels.txt, and factorize variable Activity in the data frame MergedData
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
extractedData$Activity <- as.character(extractedData$Activity)
for (i in 1:6){
  extractedData$Activity[extractedData$Activity == i] <- as.character(activityLabels[i,2])
}
extractedData$Activity <- as.factor(extractedData$Activity)

#4 Appropriately labels the data set with descriptive variable names
# Looking at the MergedData, we can see that:
        # . Acc can be replaced with Accelerometer

        #. Gyro can be replaced with Gyroscope
        
        #. BodyBody can be replaced with Body
        
        #. Mag can be replaced with Magnitude
        
        #. Character f can be replaced with Frequency
        
        #. Character t can be replaced with Time
names(extractedData)<-gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData)<-gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData)<-gsub("BodyBody", "Body", names(extractedData))
names(extractedData)<-gsub("Mag", "Magnitude", names(extractedData))
names(extractedData)<-gsub("^t", "Time", names(extractedData))
names(extractedData)<-gsub("^f", "Frequency", names(extractedData))
names(extractedData)<-gsub("tBody", "TimeBody", names(extractedData))
names(extractedData)<-gsub("-mean()", "Mean", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-std()", "STD", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-freq()", "Frequency", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("angle", "Angle", names(extractedData))
names(extractedData)<-gsub("gravity", "Gravity", names(extractedData))

#5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

extractedData$Subject <- as.factor(extractedData$Subject)
extractedData <- data.table(extractedData)
tidyData <- aggregate(. ~Subject + Activity, extractedData, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
write.table(tidyData, file = "Tidydata.txt", row.names = FALSE)




