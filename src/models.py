from sklearn.ensemble import RandomForestRegressor

class RF:
    def __init__(self, n_estimators=100, random_state=0):
        self.model = RandomForestRegressor(n_estimators=n_estimators, random_state=random_state)

    def train(self, X, y):
        self.model.fit(X, y)

    def predict(self, X):
        return self.model.predict(X)