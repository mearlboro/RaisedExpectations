import numpy as np
import pandas as pd
from typing import List, Tuple

def get_exp_detail_from_file(data_file: str) -> List[str]:

    pair = data_file.split('/')[-1].split('_')[:2]
    word = data_file.split('_')[2]
    cond = 0 if data_file.split('_')[3] == 'ground' else 1
    who  = data_file.split('_')[4]

    return [ *pair, word, cond, who ]

def construct_exp_df(data_files: List[str]):
    data = []
    for data_file in data_files:
       data.append(get_exp_detail_from_file(data_file))

    return pd.DataFrame(data, columns = [ 'Sub1', 'Sub2', 'word', 'board', 'role' ])

def get_new_filename(data_file):
    fdir = '/'.join(data_file.split('/')[:-1])
    fdir += '/std/'
    fnam = data_file.split('/')[-1]
    fnam = fnam.split('.csv')[0] + '_std.csv'
    return fdir + fnam

