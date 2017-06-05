from joblib import Parallel, delayed
import multiprocessing
import scipy.io
import time
import numpy as np
import os.path
from skfeature.function.information_theoretical_based import MIM # infogain
from skfeature.function.information_theoretical_based import JMI
from skfeature.function.information_theoretical_based import MRMR
from skfeature.function.information_theoretical_based import LCSI
from skfeature.function.statistical_based import chi_square
from skfeature.function.similarity_based import fisher_score
from skfeature.function.similarity_based import reliefF
from skfeature.utility import construct_W

from svmrfe import svmrfe
from hdmr import hdmrlearn,hdmrselect

def main():
    np.random.seed(0)
    parttypes = {'classification','robustness'}
    methods = {'hdmr','chi2','svmrfe','relieff','infogain','fisher','mrmr','jmi'}
    #datasets = {'SUNDIKEN','INDIANPINES','BOTSWANA'}
    datasets = {'INDIANPINES','BOTSWANA'}
    for dataset in datasets:
        for parttype in parttypes:
            for method in methods:
                find_features(method,dataset,parttype)

def find_features(method,dataset,parttype):
    if parttype == 'classification':
        outfile='../results/' + dataset + '_features4c_' + method + '.mat'
    elif parttype == 'robustness':
        outfile='../results/' + dataset + '_features_' + method + '.mat'
    else:
        print 'unknown partition type, exiting'
        return
    if os.path.isfile(outfile):
        print('Skipping '+outfile)
        return

    # load data
    mat = scipy.io.loadmat('../data/' + dataset + '.mat')
    if parttype == 'classification':
        par = scipy.io.loadmat('../data/' + dataset + '_part4c.mat')
    elif parttype == 'robustness':
        par = scipy.io.loadmat('../data/' + dataset + '_part.mat')
    else:
        print 'unknown partition type, exiting'
        return

    X = mat['X'].astype(float)
    y = mat['Y'].astype(int)
    y = y[:, 0]
    P = par['Partition'];
    n_samples, n_features = X.shape 
    n_samples, n_trials   = P.shape

    if method != 'chi2': 
        for i in range(n_features):
            X[:,i] = (X[:,i]-np.min(X[:,i]))/(np.max(X[:,i])-np.min(X[:,i]))

    features = np.zeros((n_features,n_trials))
    cputimes = np.zeros((1,n_trials))

    num_cores = multiprocessing.cpu_count()
    print 'Number of cores: %d' % (num_cores)
    results = Parallel(n_jobs=num_cores)(delayed(run_fold)(trial,P,X,y,method,dataset,parttype) for trial in range(n_trials))
    for trial in range(n_trials):
        result = results[trial]
        cputimes[:,trial] = result['cputime']
        features[:,trial] = result['features']

    scipy.io.savemat(outfile,mdict={'features': features,'cputimes': cputimes})

def run_fold(trial,P,X,y,method,dataset,parttype):
    print 'Obtaining features for %s %s %s fold: %2d' % (parttype,method,dataset,trial)
    n_samples, n_features = X.shape
    train = P[:,trial] == 1
    trnX = X[train]
    trnY = y[train]

    start_time = time.time()
    if method == 'fisher': 
        score = fisher_score.fisher_score(trnX,trnY)
        features = fisher_score.feature_ranking(score)
    elif method == 'chi2':
        score = chi_square.chi_square(trnX,trnY)
        features = chi_square.feature_ranking(score)
    elif method == 'relieff':
        score = reliefF.reliefF(trnX,trnY)
        features = reliefF.feature_ranking(score)
    elif method == 'jmi':
        features = JMI.jmi(trnX,trnY,  n_selected_features=n_features)
    elif method == 'mrmr':
        features = MRMR.mrmr(trnX,trnY,n_selected_features=n_features)
    elif method == 'infogain':
        features = MIM.mim(trnX,trnY,n_selected_features=n_features)
    elif method == 'svmrfe':
        features = svmrfe(trnX,trnY)
    elif method == 'hdmr':
        sobol_set_all = scipy.io.loadmat('sobol_set.mat')
        sobol_set     = sobol_set_all['sobol_set']
        sobol_set     = sobol_set.astype(float)
        params = {'sobol_set':sobol_set,'k':1,'p':3,'M':1000,'b':'L'}
        models  = hdmrlearn(trnX,trnY,params)
        features,w = hdmrselect(X,models)
    elif method == 'hdmrhaar':
        sobol_set_all = scipy.io.loadmat('sobol_set.mat')
        sobol_set     = sobol_set_all['sobol_set']
        sobol_set     = sobol_set.astype(float)
        params = {'sobol_set':sobol_set,'k':1,'p':255,'M':1000,'b':'H'}
        models  = hdmrlearn(trnX,trnY,params)
        features,w = hdmrselect(X,models)
    else:
        print(method + 'does no exist')

    cputime = time.time() - start_time
    print features
    print 'cputime %f' % cputime
    return {'features': features, 'cputime': cputime}

if __name__ == '__main__':
    main()
