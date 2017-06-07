from joblib import Parallel, delayed
import multiprocessing
import scipy.io
import time
import numpy as np
import os.path
from sklearn import svm
from sklearn import tree
from sklearn import naive_bayes
from sklearn.metrics import accuracy_score
from sklearn.model_selection import GridSearchCV
from sklearn import neighbors

def main():
    #datasets = {'SUNDIKEN','INDIANPINES','BOTSWANA'}
    datasets = {'INDIANPINES','BOTSWANA'}
    classifiers  = {'bayes','tree','svm'}
    methods = {'hdmr','chi2','svmrfe','relieff','infogain','fisher','mrmr','jmi'}
    for dataset in datasets:
        for classifier in classifiers:
            for method in methods:
                classification(method,classifier,dataset)

def classification(method,classifier,dataset):
    outfile='../results/' + dataset + '_accuracy_' + method + '_' + classifier+'.mat'
    if os.path.isfile(outfile):
        print('Skipping '+outfile)
        return

    # load data
    mat = scipy.io.loadmat('../data/' + dataset + '.mat')
    par = scipy.io.loadmat('../data/' + dataset + '_part4c.mat')
    feafile = '../results/' + dataset + '_features4c_' + method + '.mat'
    if not os.path.isfile(feafile):
        print('There is no feature file, skipping '+outfile)
        return
    fea = scipy.io.loadmat(feafile)
    features = fea['features'];
    features = features.astype(int)
    X = mat['X'].astype(float)
    n_samples, n_features = X.shape

    for i in range(0,n_features):
        X[:,i] = (X[:,i] - np.min(X[:,i]))/(np.max(X[:,i])-np.min(X[:,i]))

    y = mat['Y']  
    y = y[:, 0]
    P = par['Partition'];
    n_samples, n_folds    = P.shape

    frange=list(range(5,n_features,5))
    frange[len(frange)-1]=n_features

    accuracies  = np.zeros((n_folds,len(frange)))
    classifiertime  = np.zeros((n_folds,len(frange)))

    for fold in range(0,n_folds):
        print 'Classification %s %s %s fold:%d ' % (method,dataset,classifier,fold)

        train = P[:,fold] ==  1
        test  = P[:,fold] == -1
        flist = features[:,fold];

        print(flist)

        num_cores = multiprocessing.cpu_count()
        print 'Number of cores: %d' % (num_cores)
        results = Parallel(n_jobs=num_cores)(delayed(classification_kernel)(findex,frange,flist,classifier,X,train,test,fold,n_folds,y,method,dataset) for findex in range(0,len(frange)))
        for findex in range(0,len(frange)):
            result = results[findex]
            classifiertime[fold,findex] = result['cputime']
            accuracies[fold,findex]=result['accuracy']

    scipy.io.savemat(outfile,mdict={'frange': frange,
        'accuracies': accuracies,
        'classifiertime': classifiertime})

def classification_kernel(findex,frange,flist,classifier,X,train,test,fold,n_folds,y,method,dataset):
    n_samples, n_features = X.shape

    flen=frange[findex]
    selected_features = X[:, flist[0:flen]]

    if classifier == 'svm':
        clf = svm.SVC(kernel='linear')
    elif classifier == 'bayes':
        clf = naive_bayes.GaussianNB()
    elif classifier == 'tree':
        clf = tree.DecisionTreeClassifier()
    else:
        print(classifier + 'does not exist');

    start_time = time.time()
    clf.fit(selected_features[train], y[train])
    y_predict = clf.predict(selected_features[test])
    cputime = time.time() - start_time

    accuracy = accuracy_score(y[test], y_predict)

    print '%s %s %s fold: %2d/%2d fnum: %3d/%3d acc: %5.2f' % (method,dataset,classifier,fold,n_folds,flen,frange[len(frange)-1],accuracy)
    return {'cputime': cputime,'accuracy': accuracy}

if __name__ == '__main__':
    main()
