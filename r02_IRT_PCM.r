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
# 8. Item/person separation reliability


# We use the eRm package
library("eRm")
citation("eRm")
library("iarm")
citation("iarm")


dfA <- read.table("../results/scores/scores_sorted.csv",header=TRUE, sep=',', colClasses = "integer")
dfA <- dfA + 1 # We have values from 0 to 2 as required by eRM packages with polytomous data

# we use the script as Rscript from the command line
# with input parameter (integer from 1 to4) to run the analysis
# only for a subcategory, or without parameters to run the analysis
# for all items in the scale
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  print("Running for all items")
  outlabel="ALL"
  df <- dfA
} else if (length(args)==1) {
  if (args==1){
    itemssub <- c(1,2,3,4,5,6,7,8,9,10,11,12);
    df <- subset(dfA, select = c("C1_Q1", "C1_Q5", "C1_Q9", "C1_Q11", "C1_Q13", "C1_Q16", "C1_Q19", "C1_Q25", "C1_Q27", "C1_Q29", "C1_Q31", "C1_Q35"));
    outlabel="C1";
    print("Running for Subscale 1")
  }
  if (args==2){
    itemssub <- c(13,14,15,16,17,18,19,20,21,22);
    df <- subset(dfA, select = c(C2_Q4, C2_Q6, C2_Q8, C2_Q10, C2_Q14, C2_Q21, C2_Q22, C2_Q23, C2_Q30, C2_Q34));
    outlabel="C2";
    print("Running for Subscale 2")
  }
  if (args==3){
    itemssub <- c(23,24,25,26,27,28,29,30,31,32,33,34)
    df <- subset(dfA, select = c(C3_Q3, C3_Q12, C3_Q17, C3_Q20, C3_Q24, C3_Q26, C3_Q28, C3_Q32, C3_Q33, C3_Q37, C3_Q38, C3_Q39));
    outlabel="C3"
  }
  if (args==4){
    itemssub <- c(35,36,37,38,39,40)
    df <- subset(dfA, select = c(C4_Q2, C4_Q7, C4_Q15, C4_Q18, C4_Q36, C4_Q40))
    df <- subset(dfA, select = c( C4_Q15, C4_Q18, C4_Q36, C4_Q40))
    outlabel="C4"
  }
}

#df <- subset(dfA, select = c(C1_Q1, C1_Q5, C1_Q9, C1_Q11, C1_Q13, C1_Q16, C1_Q19, C1_Q25, C1_Q27, C1_Q29, C1_Q31, C1_Q35, C2_Q4, C2_Q6, C2_Q8, C2_Q10, C2_Q14, C2_Q21, C2_Q22, C2_Q23, C2_Q30, C2_Q34,C3_Q3, C3_Q12, C3_Q17, C3_Q20, C3_Q24, C3_Q26, C3_Q28, C3_Q32, C3_Q33, C3_Q37, C3_Q38, C3_Q39));
# 0. Some descriptive statistics
lab <- labels(df)[[2]]
perc <- matrix(ncol=3, nrow=length(lab), dimnames = list(lab,c("Wrong","Skipped","Right")))
for(n in lab){
  a <- table(df[n])
  perc[n,] <- data.frame(a)$Freq/dim(df)[1]
}
write.csv(perc,paste('../results/IRT_PCM/descript-',outlabel,'.csv',sep=""))



# 1. model fitting and summary statistics for the fitted model
PC_model <- PCM(df)
summary(PC_model)
th <- thresholds(PC_model)
th
write.csv(th$threshtable$`1`,paste('../results/IRT_PCM/thresholds-',outlabel,'.csv',sep=""))
print("Percentiles of item locations")
round(quantile(th$threshtable$`1`[,1],c(0,.25,.50,.75,1)),2)

# 2. Item Characteristic Curves (ICC) for each item
#    TODO: legends and title could be improved
lab <- labels(df)[[2]]
for(n in lab){
  print(paste("Plotting item ",n))
  # figures are stored in ../results/figures/
  pdf(paste('../results/figures/',n,'-ICC-',outlabel,'.pdf',sep=""))
  plotICC(PC_model,item.subset=n)
  dev.off()
}

# 3. Person-Item map (Wright map)
pdf(paste('../results/figures/PImap-',outlabel,'.pdf',sep=""))
plotPImap(PC_model)
dev.off()
if(length(args)==0){
  pdf('../results/figures/PImap-ALL_C1.pdf')
  plotPImap(PC_model,item.subset = c(1,2,3,4,5,6,7,8,9,10,11,12))
  dev.off()
  pdf('../results/figures/PImap-ALL_C2.pdf')
  plotPImap(PC_model,item.subset = c(13,14,15,16,17,18,19,20,21,22))
  dev.off()
  pdf('../results/figures/PImap-ALL_C3.pdf')
  plotPImap(PC_model,item.subset = c(23,24,25,26,27,28,29,30,31,32,33,34))
  dev.off()
  pdf('../results/figures/PImap-ALL_C4.pdf')
  plotPImap(PC_model,item.subset = c(35,36,37,38,39,40))
  dev.off()
}

# 4. Item fit summary statistics and item fit map

# first with eRm
pres <- person.parameter(PC_model)
itfi <- itemfit(pres)
itfi
pdf(paste('../results/figures/PW_itemMap-',outlabel,'.pdf',sep=""))
plotPWmap(PC_model)
dev.off()
# we do it with iarm to compute conditional infit/outfit as
# explained in https://bmcmedresmethodol.biomedcentral.com/articles/10.1186/1471-2288-8-33

# Bootstrap version, not needed if we use In/outFit conditional statistics
#iofit <- boot_fit(PC_model,200,p.adj = "bonferroni")
#iofit
# fixing issue https://github.com/muellermarianne/iarm/issues/1
# bootdata <- iofit[1][[1]]

iofit2 <- out_infit(PC_model, se=TRUE, p.adj = "bonferroni")
iofit2

#iofit_all <- cbind(Outfit=iofit2$Outfit,OutfitSE=iofit2$Outfit.se,OutfitParamP=iofit2$out.pvalue,OutfitQ=iofit2$out.pvalue.bonferroni,Outfitbootpvalue=bootdata[,2],Outfitbootpadj=bootdata[,3],Infit=iofit2$Infit,InfitSE=iofit2$Infit.se,InfitParamP=iofit2$in.pvalue,InfitQ=iofit2$in.pvalue.bonferroni,Infitbootpvalue=bootdata[,5],Infitbootpadj=bootdata[,6])
iofit_all <- cbind(Outfit=iofit2$Outfit,OutfitSE=iofit2$Outfit.se,OutfitParamP=iofit2$out.pvalue,OutfitQ=iofit2$out.pvalue.bonferroni,Infit=iofit2$Infit,InfitSE=iofit2$Infit.se,InfitParamP=iofit2$in.pvalue,InfitQ=iofit2$in.pvalue.bonferroni)
iofit_all
print("Percentiles of item infit")
round(quantile(iofit2$Infit,c(0,.25,.50,.75,1)),2)
write.csv(iofit_all,paste('../results/IRT_PCM/out_infit-',outlabel,'.csv',sep=""))


# 5. Person fit summary statistics and person fit map
pefi <- personfit(pres)
pdf(paste('../results/figures/PW_personsMap-',args,'.pdf',sep=""))
plotPWmap(PC_model,pmap=TRUE, imap=FALSE)
dev.off()
write.csv(pefi$p.outfitZ,paste('../results/IRT_PCM/PERSONoutfitZ-',outlabel,'.csv',sep=""))
write.csv(pefi$p.infitZ,paste('../results/IRT_PCM/PERSONinfitZ-',outlabel,'.csv',sep=""))
write.csv(pefi$p.outfitMSQ,paste('../results/IRT_PCM/PERSONoutfitMSQ-',outlabel,'.csv',sep=""))
write.csv(pefi$p.infitMSQ,paste('../results/IRT_PCM/PERSONinfitMSQ-',outlabel,'.csv',sep=""))

# Calculate percentage of misfits
perc_misfit <- sum(sign((pefi$p.outfitZ > 2) + (pefi$p.outfitZ < -2) + (pefi$p.infitZ > 2) + (pefi$p.infitZ < -2)))/length(pefi$p.infitZ)

print('Percentage of misift participants according to doi: 10.1080/16501970600632594')
perc_misfit

# with package iarm (just as exploration, not used)
pers_iarm <- person_estimates(PC_model, properties=TRUE, allperson=TRUE)
pers_iarm_properties <- test_prop(PC_model)

# 6. test for the unidimensionality of the data
# if non significant then it is unidimensional
if (length(args)==0 || args!=4)
{
utest <- MLoef(PC_model, splitcr = 'median')
utest
}

# utestNP <- NPtest(PC_model$X01)
res <- residuals(pres)
# this is the implementation of the test of unidimensionality
# that looks at the PCA of the residuals

# the covariance/correlation matrix for PCA were inspected using
# Pearson, Spearman, Kendall. Due to some extreme values in the residuals
# matrix for Item 23, Pearson was too sensitive to these outlier
# Kendall and Spearman did not suffer with the outlier and they produced
# similar correlation matrices
matr <- cor(res, method = "kendall") 
eig <- eigen(matr)
eigen.values <- eig$values
variance.total <- sum(eig$values) # variance to explain
variance.proportion <- eig$values/sum(eig$values) # Proportion of Variance explained
loadings <- eig$vectors # loadings
variance.proportion[1]

# 7. test for local dependence of items
res <- residuals(pres)
Q3 <- cor(res,method="pearson")
diag(Q3)<-NA
Q3star=Q3 - mean(Q3, na.rm = TRUE)
# let's save the Q3star matrix as csv, this is the IRT equivalent of 
# item-to-item correlation
write.csv(Q3star,paste('../results/IRT_PCM/Q3star-',outlabel,'.csv',sep=""))
ii = which(abs(Q3star) > 0.2)
m = ncol(df)
if (length(ii)>0)
{
  for(ind in ii){
    rid = ((ind-1) %% m) + 1
    cid = floor((ind-1) / m) + 1
    if (rid < cid)
    {print(paste(labels(df)[[2]][rid],labels(df)[[2]][cid],Q3star[rid,cid],sep=" "))
  
    }
  }
} else {
  print('Test for local dependence: No items are affected ') 
}


# 8. compute person separation reliability
pers_reli <- SepRel(pres)
print('Person separation reliability')
pers_reli

# 9. Item separation reliability (not reported)
# Formula from https://www.rasch.org/measess/met-18.pdf
item_reli <- 1 - (sum((PC_model$se.beta)^2)/length(PC_model$se.beta))/var(PC_model$betapar)
print('Item reliability')
item_reli

# 10. Wright Map
library("RColorBrewer")
citation("RColorBrewer")
library("WrightMap")
citation("WrightMap")
sco <- rowSums(df)
for(s in 1:length(sco)){
  id = which(pres$pred.list$`1`$x==sco[s])
  sco[s] <- pres$pred.list$`1`$y[id]
}
NT=2
plotTh <- th$threshtable$`1`[,2:3]
plotLoc <- th$threshtable$`1`[,1]

#colors <- brewer.pal(4, "Set1")
colors <- brewer.pal(6,"Greys")

C1col <- matrix(rep(c(colors[6],colors[4]),12), byrow = TRUE, ncol = NT)
C2col <- matrix(rep(c(colors[6],colors[4]),10), byrow = TRUE, ncol = NT)
C3col <- matrix(rep(c(colors[6],colors[4]),12), byrow = TRUE, ncol = NT)
C4col <- matrix(rep(c(colors[6],colors[4]),6), byrow = TRUE, ncol = NT)


itemlevelcolors <- rbind(C1col,C2col,C3col,C4col)
itemdimsymbols <- matrix(c(rep(16, NT*12), rep(17, NT*10), rep(18, NT*12),rep(15, NT*6))
                         , byrow = TRUE, ncol = NT)
lab <- labels(df)[[2]]
lab <- stringr::str_replace(lab, "C[1-4]_", "")
itemlabels <- matrix(rep(lab,2),ncol=NT)
if(NT>1)
{
for(n in 1:length(lab)){
  if(plotTh[n,1] < plotTh[n,2])
    itemlabels[n,2]=" "
  else
    itemlabels[n,1]=" "
  
}
}

# reorder
oo <- order(plotLoc)
plotTh=plotTh[oo,]
itemlevelcolors=itemlevelcolors[oo,]
itemdimsymbols=itemdimsymbols[oo,]
itemlabels=itemlabels[oo,]

WrightMap::wrightMap(sco,plotTh,thr.sym.col.fg=itemlevelcolors, yRange = c(-4,4),
                     thr.sym.col.bg=itemlevelcolors,  thr.sym.pch = itemdimsymbols, 
                     thr.sym.cex = 1, label.items ="",  thr.lab.text =itemlabels, 
                     thr.lab.cex=0.5,  thr.lab.pos = rep(c(1,3),20), label.items.ticks = FALSE, 
                     show.axis.logits = "R")

# Single thresholds
NT=1
if(NT>1)
  colnames(plotTh) <- c(" " ," ")

C1col <- matrix(rep(c(colors[6]),12), byrow = TRUE, ncol = NT)
C2col <- matrix(rep(c(colors[5]),10), byrow = TRUE, ncol = NT)
C3col <- matrix(rep(c(colors[4]),12), byrow = TRUE, ncol = NT)
C4col <- matrix(rep(c(colors[3]),6), byrow = TRUE, ncol = NT)


itemlevelcolors <- rbind(C1col,C2col,C3col,C4col)
itemdimsymbols <- matrix(c(rep(16, NT*12), rep(17, NT*10), rep(18, NT*12),rep(15, NT*6))
                         , byrow = TRUE, ncol = NT)
lab <- labels(df)[[2]]
lab <- stringr::str_replace(lab, "C[1-4]_", "")
itemlabels <- matrix(rep(lab,2),ncol=NT)





devtools::load_all(path = "external/wrightmap/", TRUE)
# next command to use locations
WrightMapEglerean::wrightMap(sco, plotLoc, item.side = itemClassic,
                             item.labels=lab, yRange = c(-5,5),show.axis.logits = "R",
                             oma = c(0,0,0,0))

WrightMapEglerean::itemClassic(plotLoc,
                               item.labels=itemlabels, yRange = c(-4,4),show.axis.logits = "L",
                               oma = c(0,2,0,2))

