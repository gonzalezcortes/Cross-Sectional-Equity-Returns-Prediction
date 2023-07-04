import sys
import time
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

t0 = time.time()
sys.path.append('src/')

from pre_processing import OpenData, Monitor, WrdsData
from training import getXY, Metrics
from portfolio import PortfolioZeroNet, PortfolioEquWei
from models import RF, LR, XGB

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
print(data.head())
print(data.shape)
print(exRet.shape)
print(exRet.head())

### get X and y in a rolling widonw ###
## Start --> 30 % training and 20% testing ##
#Random Data for testing

#array0 = np.random.rand(24000, 1)
#array1 = np.random.rand(24000)


steps = 50 #training is increased by n
step_training = 50 #considers n period for testing
perc_start = 0.3 #Start with 30%

#iterator = getXY(array0, array1, perc_start, steps) #X, y
iterator = getXY(data, exRet, perc_start, steps) #X, y

#print("exRet.shape ", exRet.shape)

### training - Only 3 periods (validation is missing) ###
#check possible data leakage

predictor_0 = RF(n_estimators=100)
predictor_1 = LR()
predictor_2 = XGB()

days = 100 # 480 days
predictionsArray_1 = []
predictionsArray_2 = []
realArray = []

for i in range(days):
    
    X_train, y_train = iterator.get_next()
    X_test, y_test = iterator.get_next_test(step_training)

    predictor_1.train(X_train, y_train)
    predictions_1 = predictor_1.predict(X_test)

    predictionsArray_1.append(predictions_1)
    r2_1 = Metrics.r2(y_test, predictions_1)
    
    predictor_2.train(X_train, y_train)
    predictions_2 = predictor_2.predict(X_test)

    predictionsArray_2.append(predictions_2)
    r2_2 = Metrics.r2(y_test, predictions_2)

    realArray.append(y_test)

    print(i, r2_1, r2_2)

### Portfolio ###

predictionsDataFrame_1 = pd.DataFrame(np.reshape(predictionsArray_1, (steps, days)))
predictionsDataFrame_2 = pd.DataFrame(np.reshape(predictionsArray_2, (steps, days)))
realDataFrame = pd.DataFrame(np.reshape(realArray, (steps, days)))
print(realArray.shape)
print(realDataFrame.shape)

port_zn_1 = PortfolioZeroNet(realDataFrame, predictionsDataFrame_1)
port_zn_2 = PortfolioZeroNet(realDataFrame, predictionsDataFrame_2)
port_eq = PortfolioEquWei(realDataFrame)
#print(realDataFrame)

#print(port_zn.cumulative_returns_of_holdings())
#print(port_eq.mean_returns())

x1 = port_zn_1.cumulative_returns_of_holdings()
x2 = port_zn_2.cumulative_returns_of_holdings()
x3 = port_eq.calculate_cumulative_log_returns()

index = list(range(days))
plt.plot(index, x1, 'b', label='Predicted LR')
plt.plot(index, x2, 'g', label='Predicted XGB')
plt.plot(index, x3, 'r', label='Equally weighted')

plt.xlabel('Time')
plt.ylabel('Values')

plt.legend()

plt.title('Cumulative Portfolio log Returns')

plt.show()