import pandas as pd
import numpy as np
from scipy.stats import gmean

class PortfolioZeroNet:

    def __init__(self, returns, pred_returns):
        self.returns = returns
        self.pred_returns = pred_returns
        self.holdings = []

    def calculate_deciles(self):
        data = self.pred_returns.copy()
        deciles = data.apply(lambda x: pd.qcut(x, 10, labels=False), axis=0)
        return deciles

    def buy_sell(self):
        deciles = self.calculate_deciles()
        holdings = {"buy": {}, "sell": {}}

        for day in deciles.columns:
            to_buy = deciles[day][deciles[day] == 9].index.tolist()  # Decile 10 (0-indexed as 9)
            to_sell = deciles[day][deciles[day] == 0].index.tolist()  # Decile 1
            holdings["buy"][day] = to_buy
            holdings["sell"][day] = to_sell
            
        return holdings

    def calculate_cumulative_log_returns(returns):
        cumulative_log_returns = np.cumsum(np.log(1 + returns)) 
        return cumulative_log_returns

    """
    def calculate_returns(prices):
        returns = np.diff(prices) / prices[:-1]
        return returns

    def get_log_returns(data):
        log_returns = np.log(1 + data)  
        return log_returns

    def calculate_cumulative_returns(returns):
        cumulative_returns = np.cumprod(1 + returns) - 1  
        return cumulative_returns
    """

    def cumulative_returns_of_holdings(self):
        holdings = self.buy_sell()
        returns = []
        for operation in ["buy", "sell"]:
            for day in holdings[operation]:
                if operation == "buy":
                    index_holding = holdings[operation][day] #index of holdings (long) after get the decile of the prediction
                    real_values =  np.array(self.returns[0].iloc[index_holding])
                    returns.append(np.mean(real_values))
        
        returns = np.array(returns)
        cumulative_log_returns = np.cumsum(np.log(1 + returns)) 
        return cumulative_log_returns
        
                #else:  # "sell"

        #return pd.DataFrame(returns)


class PortfolioEquWei:

    def __init__(self, returns):
        self.returns = returns

    def mean_returns(self):
        return np.array(self.returns.mean())

    def calculate_cumulative_log_returns(self):
        returns = self.mean_returns()
        cumulative_log_returns = np.cumsum(np.log(1 + returns)) 
        return cumulative_log_returns