import sys
import time

t0 = time.time()
sys.path.append('src/')

from pre_processing import OpenData, Monitor, WrdsData


Monitor.time_elapsed(t0,True)

data = OpenData.read_csv_large('data/datashare.csv')

#data = OpenData.read_csv_chunks('data/datashare.csv')

unique_stocks = set(data['permno'])
print(f'This dataset has {len(unique_stocks)} uniques stocks out of {len(data)} observations')

print(unique_stocks)

#db = WrdsData()
#libraries = db.get_libraries()

data_filtered = OpenData.filter_data_n_stocks_random(data, 'permno', 100)

## Create data for this



Monitor.time_elapsed(t0,True)