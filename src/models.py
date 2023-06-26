from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import LinearRegression
from xgboost import XGBRegressor

class RF:
    def __init__(self, n_estimators=100, random_state=0):
        self.model = RandomForestRegressor(n_estimators=n_estimators, random_state=random_state)

    def train(self, X, y):
        self.model.fit(X, y)

    def predict(self, X):
        return self.model.predict(X)

class LR:
    def __init__(self, random_state=0):
        self.model = LinearRegression()

    def train(self, X, y):
        self.model.fit(X, y)

    def predict(self, X):
        return self.model.predict(X)

class XGB:
    def __init__(self, n_estimators=100, learning_rate=0.1, max_depth=3):
        self.model = XGBRegressor(n_estimators=n_estimators, learning_rate=learning_rate, max_depth=max_depth)

    def train(self, X, y):
        self.model.fit(X, y)

    def predict(self, X):
        return self.model.predict(X)
