import numpy as np
import pandas as pd
import dask.dataframe as dd
import time
import wrds


class OpenData:

    @staticmethod
    def read_csv(file_path):
        data = np.genfromtxt(file_path, delimiter=',', names=True, dtype=None)
        return data

    @staticmethod
    def read_csv_columns(file_path):
        df = pd.read_csv(file_path, nrows=0)
        return df.columns

    @staticmethod
    def read_csv_header(file_path):
        df = pd.read_csv(file_path, nrows=5)
        return df

    @staticmethod
    def read_csv_chunks(file_path):
        chunk_size = 10*6
        chunks = []

        for chunk in pd.read_csv(file_path, chunksize=chunk_size):
            chunks.append(chunk)

        df = pd.concat(chunks, axis=0)
        return df

    @staticmethod
    def read_csv_large(file_path):
        df = dd.read_csv(file_path)
        result = df.compute()
        return result

    @staticmethod
    def filter_data_n_stocks_random(df, column, n):
        unique_values = df[column].unique()
        if len(unique_values) < n:
            raise ValueError(f'The dataframe contains fewer than {n} unique values in the specified column.')
    
        random_values = np.random.choice(unique_values, n, replace=False)
        return df[df[column].isin(random_values)]


class WrdsData:
    def __init__(self):
        self.db = None
        try:
            self.db = wrds.Connection()
            print("Connection to WRDS DB successful")
        except Exception as e:
            print(f"Failed to connect to WRDS DB. Error: {e}")

    def get_libraries(self):
        libraries = self.db.list_libraries()
        libraries_array = np.array(libraries, dtype=str)
        np.savetxt('data/WRDS_libraries.txt', libraries_array, fmt="%s")

    def get_tables(self, table, save):
        table_lists = self.db.list_tables(table)
        if save == True:
            message = "data/table_list_"+str(table)+".txt"
            np.savetxt(message, table_lists, fmt="%s")
        else:
            return table_lists

    def get_data(assets):
        return assets

class Monitor:
    def time_elapsed(t0, verbose):
        seg_min = lambda seconds : divmod(seconds, 60)
        minutes, seconds = seg_min(time.time()-t0)
        if verbose == True:
            print(f'Running time: {int(minutes)} Minutes and {round(seconds, 4)} Seconds')
        else:
            seconds, minutes