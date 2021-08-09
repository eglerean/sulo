#!/usr/bin/env Rscript

## Item Response Theory (IRT) - Partial Credit Model (PCM)
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


# In this script we fit the PCM for polytomous data as implemented
# by the R packages eRm
# We report
# 1. summary statistics for the fitted model
# 2. Item Characteristic Curves (ICC) for each item
# 3. Wright map
# 4. Item fit summary statistics and item map
# 5. Person fit summary statistics and person fit map
# 6. test for the unidimensionality of the data
# 7. test for local dependence of items


# We use the eRm package
library("eRm")


dfA <- read.table("../results/scores/scores_sorted.csv",header=TRUE, sep=',', colClasses = "integer")
dfA <- dfA + 1 # We have values from 0 to 2 as required by eRM packages with polytomous data


# 1. model fitting and summary statistics for the fitted model
PC_model <- PCM(df)
summary(PC_model)
th <- thresholds(PC_model)
th


# 2. Item Characteristic Curves (ICC) for each item
#    TODO: legends and title could be improved
lab <- labels(df)[[2]]
for(n in lab){
  print(paste("Plotting item ",n))
  # figures are stored in ../results/figures/
  pdf(paste('../results/figures/',n,'-ICC.pdf',sep=""))
  plotICC(PC_model,item.subset=n)
  dev.off()
}

# 3. Person-Item map (Wright map)
pdf('../results/figures/PImap.pdf')
plotPImap(PC_model)
dev.off()
pdf('../results/figures/PImap_C1.pdf')
plotPImap(PC_model,item.subset = c(1,2,3,4,5,6,7,8,9,10,11,12))
dev.off()
pdf('../results/figures/PImap_C2.pdf')
plotPImap(PC_model,item.subset = c(13,14,15,16,17,18,19,20,21,22))
dev.off()
pdf('../results/figures/PImap_C3.pdf')
plotPImap(PC_model,item.subset = c(23,24,25,26,27,28,29,30,31,32,33,34))
dev.off()
pdf('../results/figures/PImap_C4.pdf')
plotPImap(PC_model,item.subset = c(35,36,37,38,39,40))
dev.off()

# 4. Item fit summary statistics and item fit map
pres <- person.parameter(PC_model)
itfi <- itemfit(pres)
itfi
pdf('../results/figures/PW_itemMap.pdf')
plotPWmap(PC_model)
dev.off()

# 5. Person fit summary statistics and person fit map
pefi <- personfit(pres)
pdf('../results/figures/PW_personsMap.pdf')
plotPWmap(PC_model,pmap=TRUE, imap=FALSE)
dev.off()


# 6. test for the unidimensionality of the data
utest <- MLoef(PC_model)
utest

# 7. test for local dependence of items
res <- residuals(pres)
Q3 <- cor(res,method="pearson")
diag(Q3)<-NA
Q3star=Q3 - mean(Q3, na.rm = TRUE)
ii = which(abs(Q3star) > 0.2)
m = 40
for(ind in ii){
  rid = ((ind-1) %% m) + 1
  cid = floor((ind-1) / m) + 1
  print(paste(labels(df)[[2]][rid],labels(df)[[2]][cid],Q3star[rid,cid],sep=" "))
}

