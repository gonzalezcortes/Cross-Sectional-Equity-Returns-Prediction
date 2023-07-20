import os
import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.linear_model import LinearRegression

MC=1  # setup MC number
datanum=50  # Or datanum=100; separately run two cases
path='./SimulatedData'  # set your own folder path    
dirstock=f'{path}/SimuData_p{datanum}/'

for hh in [1]:  # correspond to monthly quarterly half-year and annually returns
    title=f'{path}/Simu_p{datanum}/Reg{hh}'
    if not (os.path.isdir(title)) and MC==1:
        os.mkdir(title)
    titleB = f'{title}/B'
    if not (os.path.isdir(titleB)) and MC==1:
        os.mkdir(titleB)
    if datanum == 50:
        nump=50
    if datanum ==100:
        nump=100

    mu=0.2*np.sqrt(hh)
    tol=1e-10

    # Start to MCMC
    for M in [MC]:
        for mo in [1,2]:

            print(f'### MCMC :{M}, Model :{mo} ###')
            N=200  # Number of CS tickers
            m=nump*2  # Number of Characteristics
            T=180  # Number of Time Periods

            per=np.tile(range(1, N+1), T)
            time=np.repeat(range(1, T+1), N)
            stdv=0.05
            theta_w=0.005

            #%% Read Files
            path1=f'{dirstock}c{M}.csv'
            path2=f'{dirstock}r{mo}_{M}.csv'
            c=pd.read_csv(path1, header=None).values
            r1=pd.read_csv(path2, header=None).values

            #%% Add Some Elements %%%
            daylen=np.repeat(N,T/3)
            daylen_test=daylen
            ind=range(int(N*T/3))
            xtrain=c[ind,:]
            ytrain=r1[ind]
            trainper=per[ind]
            ind=range(int(N*T/3), int(N*(T*2/3-hh+1)))
            xtest=c[ind,:]
            ytest=r1[ind]
            testper=per[ind]

            l1=c.shape[0]
            l2=len(r1)
            l3=l2-np.isnan(r1).sum()

            ind=range(int(N*T*2/3), min([l1, l2, l3]))
            xoos=c[ind,:]
            yoos=r1[ind]
            del c, r1

            #%% Monthly Demean %%%
            ytrain_demean=ytrain-np.mean(ytrain)
            ytest_demean=ytest-np.mean(ytest)
            mtrain=np.mean(ytrain)
            mtest=np.mean(ytest)

            #%% Calculate Sufficient Stats %%%
            sd=np.zeros((xtrain.shape[1],1))  # dim of sd?
            for i in range(xtrain.shape[1]):
                s=np.std(xtrain[:,i])
                if s>0:
                    xtrain[:,i]=xtrain[:,i]/s
                    xtest[:,i]=xtest[:,i]/s
                    xoos[:,i]=xoos[:,i]/s
                    sd[i]=s

            XX=np.matmul(xtrain.T,xtrain)
            U, S, V = np.linalg.svd(XX)
            L=S[0]
            Y=ytrain_demean
            XY=np.matmul(xtrain.T,Y)

            #%% Start to Train %%%

            #%% OLS %%%
            r2_oos=np.zeros((13,1))  #%% OOS R2
            r2_is=np.zeros((13,1))  #%% IS R2

            modeln=1
            groups=0; nc=0
            clf=LinearRegression(fit_intercept=False).fit(xtrain,ytrain_demean)
            yhatbig1=clf.predict(xoos)+mtrain
            r2_oos[modeln-1]=1-np.sum((yhatbig1-yoos)**2)/np.sum((yoos-mtrain)**2)
            yhatbig1=clf.predict(xtrain)+mtrain
            r2_is[modeln-1]=1-np.sum((yhatbig1-ytrain)**2)/np.sum((ytrain-mtrain)**2)
            b=clf.coef_
            pathb=f'{title}/B/b{mo}_{M}_{modeln}.csv'
            np.savetxt(pathb, b, delimiter=",")
            print(f'Simple OLS R2 : {r2_oos[modeln-1]:.3f}')

            # Further steps involve calls to external functions which are not available in Python by default
            # You will have to provide Python equivalents of these functions for the code to work.
