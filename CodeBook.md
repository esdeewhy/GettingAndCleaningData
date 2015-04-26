Introduction

This file describes the variables and the approach used to clean up the data.

Description of the data
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope.
- A 561-feature vector with time and frequency domain variables.
- Its activity label.
- An identifier of the subject who carried out the experiment.

The dataset includes the following files:

  - 'features_info.txt': Shows information about the variables used on the feature vector.
  - 'features.txt': List of all features.
  - 'activity_labels.txt': Links the class labels with their activity name.
  - 'train/X_train.txt': Training set.
  - 'train/y_train.txt': Training labels.
  - 'test/X_test.txt': Test set.
  - 'test/y_test.txt': Test labels.
  In the train and test data, there are the following files:
  - 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.
  - 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis.
  - 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration.
  - 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second.
  
The Variables

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz.

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals).

These signals were used to estimate variables of the feature vector for each pattern:
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

The Work Procedure

The working directory were the downloaded data is saved is setted.
The url given is downloaded and the unziped data is stored in UCI HAR Dataset directory.

The library used are:
library(dplyr)
library(data.table)

The "read.table" function  is used to load the activities and the subject of both test and training datasets to R environment.
The feature and activities are loaded into variables featuresNames and activityLabels.
featuresNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
# Read of training and test data set
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTrain <- read.table("UCI HAR Dataset/train/x_train.txt", header = FALSE)

subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTest <- read.table("UCI HAR Dataset/test/x_test.txt", header = FALSE)

Part #1- Merging the training and the test sets to create one data set and naming the columns

We are using row binding (rbing) to concatenate the tables data by row. Both Activity and Subject files will merge the train and data.

datsubject <- rbind(subjectTrain, subjectTest)
datctivity <- rbind(activityTrain, activityTest)
datfeatures <- rbind(featuresTrain, featuresTest)
colnames(datsubject)<- c("Subject")
colnames(datctivity)<- c("Activity")
names(datfeatures)<- featuresNames$V2

# Merging subject, activity and features to get the data frame MergedData
MergedData<- cbind(datfeatures, datctivity, datsubject)
dim(MergedData)
# [1] 10299    563

Part #2-Extracts only the measurements on the mean and standard deviation for each measurement

# We are reading features.txt and extracting columns indiced by etheir "mean()" or "std()". The data frame obtained after extraction is calle "extractedData"
datfeaturesextract<- featuresNames$V2[grep("mean\\(\\)|std\\(\\)", featuresNames$V2)]
#selectedNames<- union(c("Subject", "Activity"), selectedNames)
selectedNames<- c(as.character(datfeaturesextract), "Subject", "Activity" )
extractedData<- subset(MergedData, select=selectedNames)
dim(extractedData)
# [1] 10299    68

Part #3 Using descriptive activity names to name the activities in the data set

# The activity's names are extracted from activity_labels.txt. We will read activity_labels.txt, and factorize variable Activity in the data frame extractedData using descriptive activity name.
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
extractedData$Activity <- as.character(extractedData$Activity)
for (i in 1:6){
  extractedData$Activity[extractedData$Activity == i] <- as.character(activityLabels[i,2])
}
extractedData$Activity <- as.factor(extractedData$Activity)


Part #4 Appropriately labels the data set with descriptive variable names

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

Part #5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

The new data table is saved under the name Tidydata.txt in the working directory.
extractedData$Subject <- as.factor(extractedData$Subject)
extractedData <- data.table(extractedData)
tidyData <- aggregate(. ~Subject + Activity, extractedData, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
write.table(tidyData, file = "Tidydata.txt", row.names = FALSE)
