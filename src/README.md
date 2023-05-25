
## Pre Processing
The file pre_processing.py contains three classes:

    OpenData: Provides methods for reading and manipulating CSV data.

    WrdsData: Interacts with the WRDS (Wharton Research Data Services) database to retrieve information about libraries and tables.

    Monitor: Measures and displays the running time of a code segment


## Simulation

The file simulated_datasets.py contains a Python implementation of the simulation code for generating datasets.The code generates synthetic datasets following the work of the paper "Empirical Asset Pricing via Machine Learning" (2018) from  Shihao Gu, Bryan Kelly and Dacheng Xiu, specifically for two cases: Pc=50 and Pc=100. The datasets are generated using various parameters such as N, m, T, and other simulation parameters.
Requirements

Usage

    Clone this repository to your local machine or download the source code.
    Ensure that Python and the required dependencies are installed.
    Open the simulated_datasets.py file.
    Modify the parameters such as N, m, T, stdv, theta_w, stde, and path according to your needs.
    Run the code using a Python interpreter or an integrated development environment (IDE).

The simulation code will generate two directories: SimuData_p50 and SimuData_p100, each containing the corresponding simulation datasets. The generated datasets will be stored as CSV files.
Parameters

    N: Number of data points.
    m: Number of variables.
    T: Number of time steps.
    stdv: Standard deviation for generating random values.
    theta_w: Weight parameter for theta values.
    stde: Standard deviation for generating error term.
    path: Path to the directory where the simulation datasets will be stored.

Output

The simulation code will generate the following datasets:

    SimuData_p50: Datasets for the case Pc=50.
        c{M}.csv: Dataset containing the c values.
        r1_{M}.csv: Dataset containing the r1 values for Model 1.
        r2_{M}.csv: Dataset containing the r1 values for Model 2.

    SimuData_p100: Datasets for the case Pc=100.
        c{M}.csv: Dataset containing the c values.
        r1_{M}.csv: Dataset containing the r1 values for Model 1.
        r2_{M}.csv: Dataset containing the r1 values for Model 2.

Source:

https://github.com/xiubooth/ML_Codes

## FST converter

This code snippet demonstrates how to read an FST (Faster Serialization Format) file, convert it to a data frame, and save it as a CSV file. It assumes the presence of the fst library in R.