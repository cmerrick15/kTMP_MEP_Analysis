This repository contains analysis and plotting scripts to replicate Figures 4 and 5 from our eLife paper.
Here is a link to the paper: https://doi.org/10.7554/eLife.92088.2

Overview
Data source: Available from Dryad: https://doi.org/10.7554/elife.92088.2
There are three experiments, each experiment has it's own raw data file and analysis script. The data files can be found at Dryad and the analysis script can be found here on github. 

Analysis scripts: Process raw data to calculate percent change from baseline for each TMS protocol, block, condition, and subject.

Plotting scripts: Use the processed .csv files to reproduce Figures 4 and 5 as presented in the paper.

**Software Requirements**  
PYTHON 
Python version: 3.8.8

Required packages:

pandas==1.2.4  
numpy==1.20.1  
matplotlib==3.3.4  
scipy==1.6.2

Install all required packages via pip:
pip install pandas==1.2.4 numpy==1.20.1 matplotlib==3.3.4 scipy==1.6.2

MATLAB
Version: R2018a

Required to run the data preprocessing scripts for each experiment

Step 1 — Download the Data
Download the raw dataset from Dryad: https://doi.org/10.7554/elife.92088.2

Extract the contents into a folder called data/raw within this repository.

Step 2 — Run the Analysis Scripts
The analysis scripts will:

Load the raw Dryad data
* You will need to change the CD to the folder containing Dryad data files*

Repository Structure

├── data/ │  ├── processed/ │  └── raw/ ├── analysis/ │  ├── experiment1.m │  ├── experiment2.m │  └── experiment3.m  ├── figures/ │  ├── figure4.py │  └── figure5.py  └── README.md


Calculate percent change from baseline for each:

TMS protocol 

Block

Condition

Subject

Save the output as .csv files for each experiment

Output:
mep_percent_change_Exp1.csv
mep_percent_change_Exp2.csv
mep_percent_change_Exp3.csv

These will be saved in the .../data/processed/ directory.

Step 3 — Generate Figures 4 and 5
Run the Python script to load the .csv files and generate the figures.

Example (Python):

Reproduce_eLife_Figures4_5.py
This will:

Load the processed .csv files
Average across blocks for each subject for each condition and TMS protocol 

Generate Figure 4 and Figure 5

Save them as .png and .pdf in the figures/ directory



Citation
If you use this code, please cite our paper:

Labruna Ludovica, Merrick Christina, Peterchev Angel V, Inglis Ben, Ivry Richard B, Sheltraw Daniel (2024) Kilohertz Transcranial Magnetic Perturbation (kTMP): A New Non-invasive Method to Modulate Cortical Excitability eLife 13:RP92088

https://doi.org/10.7554/eLife.92088.2

