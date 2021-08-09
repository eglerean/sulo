## Descriptive statistics for questionnaire data
# Copyright 2021 Enrico Glerean
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.             


# Data description
#   filetype: CSV, first row list of column names with format C[1-4]_Q[1-40]
#   40 items (Q*) arranged in columns, divided in 4 subscales (C*)
# The four subscales:   
# C1_Q1, C1_Q5, C1_Q9, C1_Q11, C1_Q13, C1_Q16, C1_Q19, C1_Q25, C1_Q27, C1_Q29, C1_Q31, C1_Q35, 
# C2_Q4, C2_Q6, C2_Q8, C2_Q10, C2_Q14, C2_Q21, C2_Q22, C2_Q23, C2_Q30, C2_Q34, 
# C3_Q3, C3_Q12, C3_Q17, C3_Q20, C3_Q24, C3_Q26, C3_Q28, C3_Q32, C3_Q33, C3_Q37, C3_Q38, C3_Q39, 
# C4_Q2, C4_Q7, C4_Q15, C4_Q18, C4_Q36, C4_Q40 
#
#   each row contains the scored answer of a participant:
#     -1: the participant answered wrongly
#     0: the participant answered "I am unsure"
#     1: the participant answered correctly
# Missing values were replaced with median (see python code for preprocessing)

# In this script we report classical descriptive summaries for the dataset
# The script should be run from the terminal prompt as an R-script
#   - without input argument: descriptive statistics for the whole scale
#   - with input argument 1,2,3,4: descriptive statistics for one of the 4 subscales

# We use the descriptive function from the ltm package
library("ltm")


dfA <- read.table("../results/scores/scores_sorted.csv",header=TRUE, sep=',', colClasses = "integer")
dfA <- dfA + 1 # We have values from 0 to 2 as required in other R packages with polytomous data


#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)



if (length(args)==0) {
  print("Running for all items")
  plotlabel="allItems.pdf"
  df <- dfA
} else if (length(args)==1) {
  if (args==1){
    itemssub <- c(1,2,3,4,5,6,7,8,9,10,11,12);
    df <- subset(dfA, select = c("C1_Q1", "C1_Q5", "C1_Q9", "C1_Q11", "C1_Q13", "C1_Q16", "C1_Q19", "C1_Q25", "C1_Q27", "C1_Q29", "C1_Q31", "C1_Q35"));
    plotlabel="Subscale1.pdf";
    print("Running for Subscale 1")
  }
  if (args==2){
    itemssub <- c(13,14,15,16,17,18,19,20,21,22);
    df <- subset(dfA, select = c(C2_Q4, C2_Q6, C2_Q8, C2_Q10, C2_Q14, C2_Q21, C2_Q22, C2_Q23, C2_Q30, C2_Q34));
    plotlabel="Subscale2.pdf";
    print("Running for Subscale 2")
  }
  if (args==3){
    itemssub <- c(23,24,25,26,27,28,29,30,31,32,33,34)
    df <- subset(dfA, select = c(C3_Q3, C3_Q12, C3_Q17, C3_Q20, C3_Q24, C3_Q26, C3_Q28, C3_Q32, C3_Q33, C3_Q37, C3_Q38, C3_Q39));
    plotlabel="Subscale3.pdf"
  }
  if (args==4){
    itemssub <- c(35,36,37,38,39,40)
    df <- subset(dfA, select = c(C4_Q2, C4_Q7, C4_Q15, C4_Q18, C4_Q36, C4_Q40))
    plotlabel="Subscale4.pdf"
  }
}



d <- descript(df)
d


## Item Response Theory equivalent of reliability
#   - Item Separation Reliability (ISR)
#   - Person Separation Reliability (PSR)
# IMPORTANT NOTE:
#  ISR and PSR can also be computed from the standard error of the model fit
#  See for example implementation in package eRm. 
#  Here we follow the formulas from Chapter 18 of:
#   Wright, B. D., & Stone, M. (1999). Measurement Essentials, Wide Range. INC. Wilmington, Delaware.
#  https://www.rasch.org/measess/met-18.pdf

# item separation reliability code from https://bookdown.org/chua/new_rasch_demo2/PC-model.html
# Based on formulas from https://www.rasch.org/measess/met-18.pdf
# Get Item scores
ItemScores <- colSums(df)
# Get Item SD
ItemSD <- apply(df,2,sd)
# Calculate the se of the Item
ItemSE <- ItemSD/sqrt(length(ItemSD))
# compute the Observed Variance (also known as Total Person Variability or Squared Standard Deviation)
SSD.ItemScores <- var(ItemScores)
# compute the Mean Square Measurement error (also known as Model Error variance)
Item.MSE <- sum((ItemSE)^2) / length(ItemSE)
# compute the Item Separation Reliability
item.separation.reliability <- (SSD.ItemScores-Item.MSE) / SSD.ItemScores

print("Item separation reliability: ")
item.separation.reliability


# person separation reliability code from https://bookdown.org/chua/new_rasch_demo2/PC-model.html
# Based on formulas from https://www.rasch.org/measess/met-18.pdf
# Get Person scores
PersonScores <- rowSums(df)
# Get Person SD
PersonSD <- apply(df,1,sd)
# Calculate the se of the Person
PersonSE <- PersonSD/sqrt(length(PersonSD))
# compute the Observed Variance (also known as Total Person Variability or Squared Standard Deviation)
SSD.PersonScores <- var(PersonScores)
# compute the Mean Square Measurement error (also known as Model Error variance)
Person.MSE <- sum((PersonSE)^2) / length(PersonSE)
# compute the Person Separation Reliability
person.separation.reliability <- (SSD.PersonScores-Person.MSE) / SSD.PersonScores


print("Person separation reliability: ")
person.separation.reliability

