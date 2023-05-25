import os
import numpy as np
import pandas as pd


for M in range(1, 2):
    path = './SimulatedData'  # set your own folder path
    name1 = '/SimuData_p50'  # Case Pc=50
    name2 = '/SimuData_p100'  # Case Pc=100
    os.makedirs(path, exist_ok=True)
    os.makedirs(f'{path}{name1}', exist_ok=True)
    os.makedirs(f'{path}{name2}', exist_ok=True)

    # Case Pc=100
    N = 200
    m = 100
    T = 180
    stdv = 0.05
    theta_w = 0.02
    stde = 0.05

    rho = np.random.uniform(0.9, 1, size=(m, 1))
    c = np.zeros((N * T, m))
    for i in range(m):
        x = np.zeros((N, T))
        x[:, 0] = np.random.normal(0, 1, size=(N,))
        for t in range(1, T):
            x[:, t] = rho[i] * x[:, t - 1] + np.random.normal(0, 1, size=(N,)) * np.sqrt(1 - rho[i] ** 2)
        r = np.sort(x, axis=0)
        szx = x.shape
        x1 = np.zeros(szx)
        ridx = np.arange(1, szx[0] + 1)
        for k in range(szx[1]):
            x1[r[:, k].astype(int), k] = ridx * 2 / (N + 1) - 1

        c[:, i] = x1.flatten()

    per = np.repeat(np.arange(1, N + 1), T)
    time = np.tile(np.arange(1, T + 1), N)
    vt = np.random.normal(0, 1, size=(3, T)) * stdv
    beta = c[:, [0, 1, 2]]
    betav = np.zeros(N * T)
    for t in range(T):
        ind = (time == t + 1)
        betav[ind] = beta[ind].dot(vt[:, t])

    y = np.zeros(T)
    y[0] = np.random.normal(0, 1)
    q = 0.95
    for t in range(1, T):
        y[t] = q * y[t - 1] + np.random.normal(0, 1) * np.sqrt(1 - q ** 2)

    cy = c.copy()
    for t in range(T):
        ind = (time == t + 1)
        cy[ind, :] = c[ind, :] * y[t]

    ep = np.random.standard_t(5, size=(N * T,)) * stde


    # Model 1
    theta = np.array([1, 1] + [0] * (m - 2) + [0, 0, 1] + [0] * (m - 3)) * theta_w
    r1 = np.hstack((c, cy)).dot(theta) + betav + ep
    rt = np.hstack((c, cy)).dot(theta)

    pathc = f'{path}{name2}/c{M}.csv'
    pd.DataFrame(np.hstack((c, cy))).to_csv(pathc, index=False)

    pathr = f'{path}{name2}/r1_{M}.csv'
    pd.DataFrame(r1).to_csv(pathr, index=False)

    # Model 2
    theta = np.array([1, 1] + [0] * (m - 2) + [0, 0, 1] + [0] * (m - 3)) * theta_w
    z = np.hstack((c, cy))
    z[:, 0] = c[:, 0] ** 2 * 2
    z[:, 1] = c[:, 0] * c[:, 1] * 1.5
    z[:, m + 3] = np.sign(cy[:, 2]) * 0.6

    r1 = z.dot(theta) + betav + ep
    rt = z.dot(theta)
    # print(1 - np.sum((r1 - rt) ** 2) / np.sum((r1 - np.mean(r1)) ** 2))

    pathr = f'{path}{name2}/r2_{M}.csv'
    pd.DataFrame(r1).to_csv(pathr, index=False)

    # Case Pc=50
    m = 50

    # Model 1
    theta = np.array([1, 1] + [0] * (m - 2) + [0, 0, 1] + [0] * (m - 3)) * theta_w
    r1 = np.hstack((c[:, :m], cy[:, :m])).dot(theta) + betav + ep
    rt = np.hstack((c[:, :m], cy[:, :m])).dot(theta)
    # print(1 - np.sum((r1 - rt) ** 2) / np.sum((r1 - np.mean(r1)) ** 2))

    pathc = f'{path}{name1}/c{M}.csv'
    pd.DataFrame(np.hstack((c[:, :m], cy[:, :m]))).to_csv(pathc, index=False)

    pathr = f'{path}{name1}/r1_{M}.csv'
    pd.DataFrame(r1).to_csv(pathr, index=False)

    # Model 2
    theta = np.array([1, 1] + [0] * (m - 2) + [0, 0, 1] + [0] * (m - 3)) * theta_w
    z = np.hstack((c[:, :m], cy[:, :m]))
    z[:, 0] = c[:, 0] ** 2 * 2
    z[:, 1] = c[:, 0] * c[:, 1] * 1.5
    z[:, m + 3] = np.sign(cy[:, 2]) * 0.6

    r1 = z.dot(theta) + betav + ep
    rt = z.dot(theta)
    # print(1 - np.sum((r1 - rt) ** 2) / np.sum((r1 - np.mean(r1)) ** 2))

    pathr = f'{path}{name1}/r2_{M}.csv'
    pd.DataFrame(r1).to_csv(pathr, index=False)

