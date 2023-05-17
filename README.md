# SULO
Code for SULO tool: consistency, internal validity, and Rasch analysis

# How to cite

If you find the code in this repository useful for your studies, you can cite it by citing:

> Glerean, N., Talman, K., Glerean, E., Hupli, M., Haavisto, E. (2023) "Development and Psychometric Testing of the Perception of Nursing Profession Instrument (PNPI)" Journal of Advanced Nursing.


# Dependencies

The code in this repository uses
- Python: pandas, numpy, os, scipy, seaborn, matplotlib, xlrd, re
- R: eRm, iarm, wrightmap, ltm

A modified version of WrightMap is also used. It can be downloaded from https://github.com/eglerean/wrightmap .

# Raw data description

The data is not included in the repository as it contains personal data that can be linked to an individual. Participants were not asked about the permission to share or open these data. The data is structures so that for each school, an XLS file was provided including the following columns:

Add here the columns with description.

Values stored in the data are positive integers. Missing values are stored as empty cells in the XLS files. Some schools were part of an intervention, those datasets have two extra columns and this is accounted for in the preprocessing code.


# Step-by-step overview of analysis and code in the repository

## 1. Loading raw data and consolidating it

Script: `p01_preprocessing.ipynb`
Description: This jupyter notebook loads the xls data and performs the following steps:
1. load the raw data from the xlsx files
2. convert empty values to NaN
3. keep only the rows with column 1 ('LUPA KÄYTTÄÄ') == 1
4. save the preprocessed data as `DATA_filename.csv` with NaN -> -1
5. save the background factor data as `BF_filename.csv` with NaN -> -1

This script also calculates the total number of participants in the raw data, and those who gave permission to use their answers for research purposes.

## 2. Scoring the answers and reporting some descriptive statistics

Script: `p02_scoring_descriptive.ipynb`
Descrption: This jupyter notabook loads the preprocessed data and performs the following steps:
1. load each results/preprocessed/DATA** file
2. Normalize the data
3. Compute total scores
4. Sort by subscales
5. Plot heatmap for item-to-item correlations

This scripts also outputs the table to report participants characteristics (Table 1 in the manuscript)

## 3. Descriptive statistics

Script: `r01_descriptive.r`
Description: In this script we report classical descriptive summaries for the dataset
The script should be run from the terminal prompt as an R-script
 - without input argument: descriptive statistics for the whole scale
 - with input argument 1,2,3,4: descriptive statistics for one of the 4 subscales

We use the descriptive function from the ltm package
Data description
    filetype: CSV, first row list of column names with format `C[1-4]_Q[1-40]`
    40 items (Q**) arranged in columns, divided in 4 subscales (C**)
The four subscales:   
- C1_Q1, C1_Q5, C1_Q9, C1_Q11, C1_Q13, C1_Q16, C1_Q19, C1_Q25, C1_Q27, C1_Q29, C1_Q31, C1_Q35, 
- C2_Q4, C2_Q6, C2_Q8, C2_Q10, C2_Q14, C2_Q21, C2_Q22, C2_Q23, C2_Q30, C2_Q34, 
- C3_Q3, C3_Q12, C3_Q17, C3_Q20, C3_Q24, C3_Q26, C3_Q28, C3_Q32, C3_Q33, C3_Q37, C3_Q38, C3_Q39, 
- C4_Q2, C4_Q7, C4_Q15, C4_Q18, C4_Q36, C4_Q40 

each row contains the scored answer of a participant:
- -1: the participant answered wrongly
-  0: the participant answered "I am unsure"
-  1: the participant answered correctly

Missing values were replaced with median (see python code for preprocessing)

## 4. Item Reponse Theory analysis using the Partial Credit Model

Script: `r02_IRT_PCM.r`
Description: In this script we fit the PCM for polytomous data as implemented
by the R packages eRm

We report:
1. summary statistics for the fitted model
2. Item Characteristic Curves (ICC) for each item
3. Wright map
4. Item fit summary statistics and item map
5. Person fit summary statistics and person fit map
6. test for the unidimensionality of the data
7. test for local dependence of items
8. Classical Wright map plot

## Improvements

The following improvements to the tool can be made

1. Add a synthetic data file for testing the script
2. Improving code readability
3. Removing hard-coded paths for reusability

If you can suggest further improvements, please do not hesitate to open a github issue or email enrico *dot* glerean *at* aalto *dot* fi.

