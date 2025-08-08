This repository contains analysis and plotting scripts to replicate Figures 4 and 5 from our eLife paper.

Overview
Data source: Available from Dryad: https://doi.org/10.7554/elife.92088.2
There are three experiments, each experiment has it's own raw data file and analysis script.

Analysis scripts: Process raw data to calculate percent change from baseline for each TMS protocol, block, condition, and subject.


Plotting scripts: Use the processed .csv files to reproduce Figures 4 and 5 as presented in the paper.

Software Requirements
Python
Python version: 3.8.8

Required packages:

bash
Copy
Edit
pandas==1.2.4  
numpy==1.20.1  
matplotlib==3.3.4  
scipy==1.6.2
Install all required packages via pip:

bash
Copy
Edit
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

Calculate percent change from baseline for each:

TMS protocol 

Block

Condition

Subject

Save the output as .csv files for each experiment

Example (MATLAB):

matlab
Copy
Edit
% From the 'analysis' directory
run('process_experiment1.m')
run('process_experiment2.m')

Output:
mep_percent_change_Exp1.csv
mep_percent_change_Exp2.csv
mep_percent_change_Exp3.csv

These will be saved in the data/processed/ directory.

Step 3 — Generate Figures 4 and 5
Run the Python script to load the .csv files and generate the figures.

Example (Python):

bash
Copy
Edit
python plotting/Reproduce_eLife_Figures4_5.py
This will:

Load the processed .csv files
Average across blocks for each subject for each condition and TMS protocol 

Generate Figure 4 and Figure 5

Save them as .png and .pdf in the figures/ directory

Repository Structure
bash
Copy
Edit
├── analysis/                # MATLAB scripts to process raw data
│   ├── process_experiment1.m
│   ├── process_experiment2.m
├── plotting/
│   ├── make_figures_4_5.py  # Python script to generate figures
├── data/
│   ├── raw/                 # Place Dryad raw data here
│   ├── processed/           # Processed .csv output files
├── figures/                 # Generated figures (output)
└── README.md
Citation
If you use this code, please cite our paper:

[Authors], Title, eLife, Year, DOI: [link]

