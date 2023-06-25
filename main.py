import sys
import time
import numpy as np
import pandas as pd

t0 = time.time()
sys.path.append('src/')

from pre_processing import OpenData, Monitor, WrdsData
from training import getXY, Metrics
from models import RF

Monitor.time_elapsed(t0,True)


data = OpenData.read_csv_large('data/data_bigcharMat.csv')
data = np.array(data)[0:21696000]  #50 stocks
data = np.squeeze(data)


exRet = OpenData.read_csv_pandas(path = 'data/data_mRetPerc.csv', header = None)
exRet = np.array(exRet)[0:24000]
exRet = np.ravel(exRet)
#Reshape
#exRet = np.reshape(exRet, (480,501)) #reshape to orignal size
#exRet = exRet[:, :50]  #50 stocks



dates = OpenData.read_csv_pandas(path = 'data/dates.csv', header = None)
dates = np.array(dates)
stocks = OpenData.read_csv_pandas(path = 'data/permno.csv', header = None)
stocks = np.array(stocks)[0:50]  #50 stocks

n_stocks = len(stocks)
n_dates = len(dates)
n_char = 904

#print(n_dates, n_char, n_stocks)

##### Transform data set #####

chars = ['x_' + str(i) for i in range(n_char)] #title for the Characteristic
dates_indices = np.tile(np.repeat(dates, n_char), n_stocks)
char_indices = np.tile(chars, n_dates * n_stocks)
stocks_indices = np.repeat(stocks, n_dates * n_char)
#print(dates_indices.shape,char_indices.shape,data.shape, stocks_indices.shape)

dataFrame = pd.DataFrame({'Date': dates_indices,'Characteristic': char_indices,'Value': data, 'Stock': stocks_indices})
#print(dataFrame.head())

dataFrame = dataFrame.pivot_table(index=['Date','Stock'], columns='Characteristic', values='Value')
dataFrame = dataFrame.reset_index()
#print(dataFrame.head())

data = dataFrame.values #transform it to numpy
print(data.shape)
print(exRet.shape)


### get X and y in a rolling widonw ###
## Start --> 30 % training and 20% testing ##
#Random Data for testing
#array0 = np.random.rand(10, 4)
#array1 = np.random.rand(10, 1)


steps = 50 #training is increased by n
step_training = 50 #considers n period for testing
iterator = getXY(data, exRet, steps) #X, y

print("exRet.shape ", exRet.shape)

### training - Only 3 periods (validation is missing) ###
#check possible data leakage

predictor = RF(n_estimators=100)
days = 3 #480
for i in range(days):
    
    X_train, y_train = iterator.get_next()
    X_test, y_test = iterator.get_next_test(step_training)

    predictor.train(X_train, y_train)
    predictions = predictor.predict(X_test)

    r2 = Metrics.r2(y_test, predictions)

    #print(y_test)
    #print(predictions)
    print(r2)



Monitor.time_elapsed(t0,True)