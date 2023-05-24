import sys
sys.path.append('src/')

from pre_processing import OpenData

data = OpenData.read_csv_large('data/datashare.csv')

print(data.columns)