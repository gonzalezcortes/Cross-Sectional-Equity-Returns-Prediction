import sys
import time
t0 = time.time()
sys.path.append('src/')

from pre_processing import OpenData, Monitor, WrdsData

Monitor.time_elapsed(t0,True)

"""
data = OpenData.read_csv_large('data/datashare.csv')
unique_stocks = set(data['permno'])
print(f'This dataset has {len(unique_stocks)} uniques stocks out of {len(data)} observations')
"""

db = WrdsData()


#91789, 91790, 91791

Monitor.time_elapsed(t0,True)