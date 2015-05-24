# Run_analysis.R
# Created by Dave Vandervort, May 2015
# For the class project for Coursera.org/getdata-014
# Aka Getting and Cleaning Data 
# (The 3rd course in the Data Science Specialization)
# see local Readme.md for assumptions and setup for running this script.

# Required libraries
library(data.table)
library(dplyr)

# the read_data function reads the data for the supplied
#  file into a data frame and returns same
read_file <- function(filename){
    # check that the file exists locally
    if (file.exists(filename)) {
        # open and read
        as.data.table(read.table(filename, quote="\"", stringsAsFactors=FALSE))
        
    } else {
        stop(paste("File", filename, "not found. Halting execution"))
    }
}

combine <- function(x, y, subject){
    x[,y:= y$V1]
    x[,subject:= subject$V1]
    x
}

# **********************************************
# BEGIN putting it together
# **********************************************

# get and combine test files
x_test <- read_file("X_test.txt")
y_test <- read_file("y_test.txt")
sub_test <- read_file("subject_test.txt")
test <- combine(x_test, y_test, sub_test)

# now do the same thing for train files
x_train <- read_file("x_train.txt")
y_train <- read_file("y_train.txt")
sub_train <- read_file("subject_train.txt")
train <- combine(x_train, y_train, sub_train)

# NOW combine these into the final data set for analysis
# Because these are identically shaped data sets
# rather than use merge on them, the smaller will 
# simply be prepended to the larger
data <- rbind(train, test)

# *************************************************************
# END of step 1 of the assignment: 
#   Merge the training and test sets to create one data set
# *************************************************************

# Adding in column names (step 4) now, because it will make step 2 easier
f <- read_file("features.txt")
setnames(data, 1:561, f$V2)

# now I can match column names to get mean and std
# Interestingly, default seems to be case insenstive
data2 <- select(data, matches('(mean)|(std)'))

# *************************************************************
# END steps 2 and 4 of the assignment
# Because I did step 4: Adding descriptive Variable names
# In order to do step 2: Extract only the measurements on 
#           mean and standard deviation
# *************************************************************
#
# For those of us who have to be reminded:
# "It is easiest to think of the data frame as a rectangle of data 
# where the rows are the observations and the columns are the variables."
#   Above quote came from http://www.ats.ucla.edu/stat/r/modules/subsetting.htm
# *************************************************************

# Now I have to add descriptive activity names.
# I'm going to build them from those last 2 columns of D,
# The subject and the Y column (activities). BUT, since 
# there are only six activities, I'll hard code them in order
# rather than reading the file in.
# NOTE THAT I've made a tweak to "WALKING", renaming it WALKING_NORMAL
# So that in step 5, when I try to filter on activity labels, 
# WALKING will not also pull WALKING_UPSTAIRS and WALKING_DOWNSTAIRS
activities <- c("WALKING_NORMAL", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")

# build a vector of labels to insert as rownames.
len <- length(data$y)
labels <- vector(length=len)
for (i in 1:len){    
    new_label <- paste("subject", "_", data$subject[i], "_", activities[data$y[i]] , "_", i, sep="")
    # The label will look like this: subject_1_STANDING_1
    # The trailing number is an index intended to ensure no duplicate labels
    labels[i] <- new_label
}
rownames(data2) <- labels


# *********************************************************
# END of part 4: Appropriately label the data set 
#                 with descriptive variable names.
# *********************************************************
# We're going to start step 5 with a sanity check,
# to make sure all the subjects are represented in the data set
# Note: This check is for my own peace of mind, not yours.
# In: rownames for the dataset
# Out: TRUE if they are all found. If not, the program will stop.
verify_subjects <- function(dsr){
    for (i in 1:30){
        # Note that the trailing _ is needed
        # to ensure that searches for subject_3 (for example)
        # don't match subject_30. And so on.
        search_term <- paste("subject", "_", i, "_", sep="")
        res <- grep(search_term, dsr)
        if (length(res) == 0){
            stop(paste("Error! Subject", i, "Missing from the next-to-final dataset!"))
        }
    }
}

verify_subjects(labels)

# Okay, if we made it to this point, we're good!
# Now to build the dataset for step 5 one bit at a time.
# starting with the column names.
new_colnames <- vector()
old_colnames <- colnames(data2)
l2 <- length(old_colnames)
for (i in 1:l2){
    name <- paste("MEAN_OF_", old_colnames[i], sep="")
    new_colnames[i] <- name
}

new_rownames <- vector()
final <- vector()
for (user in 1:30){
    for (activity in activities) {
        # construct enough of the label to filter on
        user_activity_search <- paste("subject", user, activity, sep="_")
        
        # get the rows that will be averaged to make this new row
        target <- filter(data2, grepl(user_activity_search, rownames(data2)))
        
        # now average each column and add to the output table
        row <- colMeans(target)
        
        # build the result up one row at a time
        final <- rbind(final, row)
        
        # store the name for this row
        new_rownames <- c(new_rownames, paste("Subject", user, activity, "means", sep="_"))
    }
}

# After all this, final is a mere matrix. Fix that
final <- as.data.table(final)

# set the names and call it done
setnames(final, new_colnames)
rownames(final) <- new_rownames

#output!
write.table(final, "data.txt", row.name=FALSE)

