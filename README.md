# Course Project #
## Coursera Getting and Cleaning data ##
## Setup and analysis instructions ##

This file describes how to use the associated script (run_analysis.R) to produce results needed for the class project due Week 3 of the Coursera Getting and Cleaning Data class (May 2015 session).

## Environment ##

The code was written and tested with the following system specifications:

- Windows v 8.1 64 but
- Intel processor with 6 GB of RAM
- RStudio 0.98.1102 (64 bit)
- R version 3.1.2 (2014-10-31)
- Dependent packages
	- data.table
	- dplyr

Please install the required R packages before attempting to run the script. On some systems there may be warnings that the packages were built under a different version of R. These are only warnings and have not (yet) been shown to degrade performance.

Included files

The files included in this set and their uses are as follows:

- **README.md** This file. It explains how to use the included script to obtain the desired analysis.
- **Codebook.txt** A file that lists the variables and observations and their principles, so that data may be interpreted by the user.
- **run_analysis.R** The analysis script.
- **data.txt** An example of the results of the analysis. This is the output of run_analysis.R. It can be read into R for validation of results with the command: fin2 <- read.table("data.txt", stringsAsFactors=FALSE, header=TRUE )   

## Obtaining data ##

The script summarizes data developed from measurements of volunteers using The Samsung Galaxy S Smartphone. Per the project instructions ([https://class.coursera.org/getdata-014/human_grading/view/courses/973501/assessments/3/submissions](https://class.coursera.org/getdata-014/human_grading/view/courses/973501/assessments/3/submissions)) the original data can be obtained from here: [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones ](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones )

NOTE: This is not the data analyzed by this script. 

**The data needed for this script to run correctly are here**: [https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip )

### Preparing the data for analysis ###

The script assumes that the data files needed for the analysis exist *in the same folder *as the script itself. Therefore, perform the following setup steps:

- Download the zip data from the above address
- Unzip the data files. 
- Locate or create a folder that will be the home of the analysis (example: /home/users/me/tidiness). This will be called the working folder from here on. 
- Copy the following files into the working folder (paths shown are relative to the root folder where files were unzipped).
	-  features.txt
	-  test/X_test.txt
	-  test/y_test.txt
	-  test/subject_test.txt
	-  train/X_train.txt
	-  train/y_train.txt
	-  train/subject_train.txt
-  Also copy the file run_analysis.R into the same folder.

My apologies for not including a script to do this setup auotmatically. Maybe next time.

## Process ##

**To run:**
From within R or Rstudio or other suitable environment, go to the working folder and run the program.
Example:

setwd("/home/users/me/tidiness")
source("run_analysis.R")

The program will first read in the two sets of train and test files. These files have the same structure but different data. The files will be read in as CSV and stored in data tables. The subject_train and subject_test files contain the numbers of the human subjects associated with each row of observations and will be appended as another column in the data.

Likewise, the y_train and y_test files contain the numbers of activities being performed by the test subjects at the time of observation. These, also, are appended as another column (for later use). These extra columns will not persist in the final data set but will be used to construct meaningful row names.

After reading in the data, the test and train data sets will be joined into one. 

The features.txt file contains the names of variables observed. These are imported and applied to the columns of the dataset as descriptive names.

In the next pass the program will extract the columns associated with Means and standard deviations of the variables into a new data table. The columns for users and activities will then be used to build meaningful row names (observations) for this data set.

Finally, the program will segment the observational rows and calculate the mean for each combination of test subject and activity for each variable. The row and column names are adjusted to reflect these changes to the data.

## Tidy Data Detail ##

The data the script outputs is considered "tidy" for the following reasons:

- Each variable measured is in one column. There are 180 columns, each associated with a different measuring device or movement of the test subjects. 
	- Note that the columns generated in interim data sets for test subject numbers and activity numbers are removed from the final data set.
- Each different observation is in one row.
	- In the pre-analysis data, there are many rows for each user and usually many rows for each activity a user performs, as well. In the final data set, these have been condensed so that there is only one row per user/activity.
- There should be one table for each "kind" of variable
	- All variables included in this data set are of the same kind: Motion sensor reading summaries.
- Multiple tables should have a key column allowing them to be linked.
	- There is only one table, so no need for a linkage.
- Also, variable names are clearly listed at the top of the data file and again in the codebook.
- And finally, the program clearly labels both each variable and each observation (though the project instructions cause the row names to be discarded when the data are saved to file. A shame really. I workde so hard on them!)