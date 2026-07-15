import os
import pandas as pd
import numpy as np
import jpype as jp
import typing

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

def jarray_from_csv(filename: str) -> np.ndarray:
    df = pd.read_csv(filename)
    X  = np.concatenate([ np.array(df[[f"x_{i}" for i in range(17, 27)]]),
                          np.array(df[[f"y_{i}" for i in range(17, 27)]]) ], axis = 1)

    return X

def calc_multivar_mi(X: np.ndarray, Y: np.ndarray) -> float:
    """
    Compute mutlivariate mutual information from two time series with the same
    number of data points and variables
    """
    tlen = min(X.shape[0], Y.shape[0])
    X = X[:tlen]
    Y = Y[:tlen]

    miCalc = jp.JClass('infodynamics.measures.continuous.gaussian.MutualInfoCalculatorMultiVariateGaussian')()
    miCalc.initialise(X.shape[1], Y.shape[1])
    miCalc.startAddObservations()

    jX = javify(X, jp.JDouble)
    jY = javify(Y, jp.JDouble)

    miCalc.setObservations(jX, jY)
    miCalc.finaliseAddObservations()

    return miCalc.computeAverageLocalOfObservations()

if __name__ == "__main__":

    data_files = [ f'data/eyebrows/{name}' for name in sorted(os.listdir('data/eyebrows')) if 'std' in name ]
    pairs = list(zip(data_files[::2], data_files[1::2]))

    jvm_start()

    for xfile, yfile in pairs:
        jX = jarray_from_csv(xfile)
        jY = jarray_from_csv(yfile)
        mi = calc_multivar_mi(jX, jY,)
        print(f"{mi}")

