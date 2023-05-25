import numpy as np
import os

# Generate quarterly, half-year, and annual returns

path = './SimulatedData'  # set your own folder path
name1 = '/SimuData_p50'  # Case Pc=50
name2 = '/SimuData_p100'  # Case Pc=100

for name in [name1, name2]:
    for mo in [1, 2]:
        for M in range(1, 2):

            dirstock = path+name
            path2 = os.path.join(dirstock, 'r')
            path2 = path2 + str(mo) + '_' + str(M) + '.csv'
            r = np.genfromtxt(path2, delimiter=',')
            r3 = np.zeros_like(r)
            r6 = np.zeros_like(r)
            r12 = np.zeros_like(r)

            per = np.tile(np.arange(1, 201), 180)
            time = np.repeat(np.arange(1, 181), 200)
            u = np.unique(per)
            #############################################

            for i in u:
                ind = np.where(per == i)
                ret = r[ind]
                
                ret3 = np.zeros(len(ret))
                N = len(ret3)
                for j in range(N-2):
                    ret3[j] = np.sum(ret[j:(j+3)])
                r3[ind] = ret3
                
                ret6 = np.zeros(len(ret))
                N = len(ret6)
                for j in range(N-5):
                    ret6[j] = np.sum(ret[j:(j+6)])
                r6[ind] = ret6
                
                ret12 = np.zeros(len(ret))
                N = len(ret12)
                for j in range(N-11):
                    ret12[j] = np.sum(ret[j:(j+12)])
                r12[ind] = ret12

            ############################################
            K = 200 * 180
            a = np.arange(0, K+1)
            df = np.column_stack((a, r))
            pathr = os.path.join(dirstock, 'r')
            pathr = pathr + str(mo) + '_' + str(M) + '_1.csv'
            np.savetxt(pathr, df, delimiter=',')

            df = np.column_stack((a, r3))
            pathr = os.path.join(dirstock, 'r')
            pathr = pathr + str(mo) + '_' + str(M) + '_3.csv'
            np.savetxt(pathr, df, delimiter=',')

            df = np.column_stack((a, r6))
            pathr = os.path.join(dirstock, 'r')
            pathr = pathr + str(mo) + '_' + str(M) + '_6.csv'
            np.savetxt(pathr, df, delimiter=',')

            df = np.column_stack((a, r12))
            pathr = os.path.join(dirstock, 'r')
            pathr = pathr + str(mo) + '_' + str(M) + '_12.csv'
            np.savetxt(pathr, df, delimiter=',')
