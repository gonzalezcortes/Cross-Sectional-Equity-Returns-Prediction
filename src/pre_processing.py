#import pynini
import numpy as np
import pandas as pd
import dask.dataframe as dd
import time


class OpenData:
    """
    @staticmethod
    def fst_read(file_path):
        fst = pynini.Fst.read(file_path)
        return fst
    """
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

class Monitor:
    def time_elapsed(t0, verbose):
        seg_min = lambda seconds : divmod(seconds, 60)
        minutes, seconds = seg_min(time.time()-t0)
        if verbose == True:
            print(f'Running time: {int(minutes)} Minutes and {round(seconds, 4)} Seconds')
        else:
            seconds, minutes