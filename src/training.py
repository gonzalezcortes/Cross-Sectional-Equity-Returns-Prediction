
import numpy as np
import pandas as pd
from sklearn.metrics import r2_score

class getXY:
    def __init__(self, X, y, steps):
        #self.arrays = [array1, array2]
        self.X = X
        self.y = y
        self.arrays = [X, y]
        self.indices = [0, 0] 
        self.steps = steps

    def get_next(self):
        results = []
        for i in range(2):
            end_index = min(self.indices[i] + self.steps, self.arrays[i].size)
            chunk = self.arrays[i][0 : end_index]
            results.append(chunk)

            self.indices[i] = end_index

        return results[0],results[1]

    def get_next_test(self,step_test):
        results_t = []
        for i in range(2):
            end_index = min(self.indices[i], self.arrays[i].size)
            chunk = self.arrays[i][end_index : end_index+step_test]
            results_t.append(chunk)

            #self.indices[i] = end_index

        return results_t[0],results_t[1]

class Metrics:

    @staticmethod
    def r2(y_real, y_pred):
        if np.ndim(y_pred) > 1:
            y_pred = np.squeeze(y_pred)
        return r2_score(y_real, y_pred)
