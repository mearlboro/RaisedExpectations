import os
import pandas as pd
import numpy as np
import jpype as jp
from typing import Tuple

from scripts.utils import construct_exp_df, std

INFODYNAMICS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'infodynamics.jar')

def jvm_start(path = INFODYNAMICS_PATH) -> None:
    if not jp.isJVMStarted():
        print('Starting JVM...')
        jp.startJVM(jp.getDefaultJVMPath(), '-ea', '-Djava.class.path=%s'%INFODYNAMICS_PATH)
        print('JVM started using jpype1')


def javify(X: np.ndarray, dtype: jp.JClass) -> jp.JArray:
    """
    Convert a numpy array into a Java array to pass to the JIDT classes and
    functions.
    Given a 1-dim np array of shape (D,), return Java array[] of size D
    Given a 2-dim np array of shape (1, D), return Java array[] of size D
    Given a 2-dim np array of shape (D1, D2), return Java array[][] of size D1 x D2

    Params
    ------
    X
        numpy array of shape (D,) or (D1,D2) representing a time series

    Returns
    ------
    jX
        the X array cast to Java Array
    """
    X = np.array(X)

    if len(X.shape) > 1 and X.shape[1] == 1:
        X = X.reshape((X.shape[0],))

    if len(X.shape) == 1:
        dim = 1
        X = X[np.newaxis, :]
    else:
        dim = len(X.shape)

    if dim > 1:
        jX = jp.JArray(dtype, dim)(X.tolist())
    else:
        # special case to deal with scalars
        jX = jp.JArray(dtype, 1)(X.flatten())

    return jX

def array_from_csv(filename: str) -> np.ndarray:
    """
    Read the eyebrow CSV with heads x_17, y_17... x_27, y_27 for XY coordinates
    of eyebrows. Extract all coordinates as numpy array.
    """
    df = pd.read_csv(filename)
    X  = np.concatenate([ np.array(df[[f"x_{i}" for i in range(17, 27)]]),
                          np.array(df[[f"y_{i}" for i in range(17, 27)]]) ], axis = 1)

    return X

def calc_multivar_mi(X: np.ndarray, Y: np.ndarray, est: str = 'Kraskov') -> Tuple[float, int]:
    """
    Compute mutlivariate mutual information from two time series with the same
    number of data points and variables
    """
    tlen = min(X.shape[0], Y.shape[0])
    X = X[:tlen]
    Y = Y[:tlen]

    if est == 'Gaussian':
        miCalc = jp.JClass('infodynamics.measures.continuous.gaussian.MutualInfoCalculatorMultiVariateGaussian')()
    elif est == 'Kraskov':
        miCalc = jp.JClass('infodynamics.measures.continuous.kraskov.MutualInfoCalculatorMultiVariateKraskov1')()

    if len(X.shape) > 1:
        miCalc.initialise(X.shape[1], Y.shape[1])
    else:
        miCalc.initialise(1, 1)
    miCalc.startAddObservations()

    jX = javify(X, jp.JDouble)
    jY = javify(Y, jp.JDouble)

    miCalc.setObservations(jX, jY)
    miCalc.finaliseAddObservations()

    return miCalc.computeAverageLocalOfObservations(), tlen


def calc_brow2brow_multivariate() -> None:
    data_files = [ f'data/eyebrows/std/{name}'
                   for name in sorted(os.listdir('data/eyebrows/std'))
                   if 'std' in name ]
    pairs = list(zip(data_files[::2], data_files[1::2]))


    jvm_start()

    mis = []
    tlens = []

    for xfile, yfile in pairs:
        X = array_from_csv(xfile)
        Y = array_from_csv(yfile)
        mi = calc_multivar_mi(X, Y,)
        mis.append(mi[0])
        tlens.append(mi[1])

    df = construct_exp_df(data_files)
    df = df.drop('role', axis=1).drop_duplicates()
    df['eyebrow_MMI'] = mis
    df['tlen']        = tlens

    df.to_csv('data/mutualinfo/eyebrow_multivar_mutual_info.csv')


def calc_brow2pitch_univariate() -> None:

    ground = pd.read_csv('example/merged/103_203.csv')
    ground = std(ground, 'pitch')
    board  = pd.read_csv('example/merged/108_208.csv')
    board  = std(board, 'pitch')
    ground = ground.dropna()
    board  = board.dropna()

    jvm_start()

    # TODO: change hardcoded time duration and file names
    for df in [ground, board]:
        print(calc_multivar_mi(
                np.array(df['eyebrows_interp'][:1800]),
                np.array(df['pitch'][:1800])))


def calc_brow2pitch_timedelay() -> None:

    # TODO: change hardcoded time duration and file names
    ground = pd.read_csv('example/merged/103_203.csv')
    ground = std(ground, 'pitch')
    board  = pd.read_csv('example/merged/108_208.csv')
    board  = std(board, 'pitch')
    ground = ground.dropna()
    board  = board.dropna()

    jvm_start()

    results = []
    for df, cond in zip([ground, board], ['ground', 'board']):
        for dt in range(10):
            mi = calc_multivar_mi(
                    np.array(df['pitch'][:1800]),
                    np.array(df['eyebrows_interp'][dt: 1800 + dt]))[0]

            results.append((dt, cond, mi))
    df = pd.DataFrame(results, columns = [ 'dt', 'condition', 'TDMI' ]).reset_index()
    df.to_csv('data/mutualinfo/eyebrow_pitch_univar_tdmi.csv')


if __name__ == "__main__":
    calc_brow2pitch_univariate()
    calc_brow2pitch_timedelay()
