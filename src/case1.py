import numpy as np
import scipy.io
from sklearn import neighbors
from sklearn.metrics import accuracy_score
from hdmr import hdmrlearn,hdmrpredict,hdmrselect
#import matplotlib.pyplot as plt


sobol_set_all = scipy.io.loadmat('sobol_set.mat')
sobol_set     = sobol_set_all['sobol_set']
sobol_set     = sobol_set.astype(float)
sobol_set_labels = np.ones(np.size(sobol_set,0))
sobol_set_labels[sobol_set[:,0] > 0.5] = -1

nrange = np.arange(2,201,1)
mrange = np.array([1000])
Mrange = np.array([10,100,1000,10000])
mat = np.zeros((np.size(nrange)*np.size(mrange)*np.size(Mrange),7))
i=0
for n in nrange:
    for m in mrange:
        for M in Mrange:
            np.random.seed(0)
            # Create case 1 training set
            X = np.random.rand(m,n)
            y = np.ones(m)
            y[X[:,0] > 0.5] = -1

            AUX = sobol_set[0:M,0:n];
            k = 1
            clf = neighbors.KNeighborsClassifier(n_neighbors=k,algorithm='brute')
            clf.fit(X, y)
            AUXlabels = clf.predict(AUX)
            AUXlabelstrue  = sobol_set_labels[0:M]
            score = accuracy_score(AUXlabelstrue, AUXlabels)
            params = {'sobol_set':sobol_set,'k':k,'p':3,'M':M,'b':'L'}
            models=hdmrlearn(X,y,params)
            for model in models:
                S1=model['w'][0]
                Ssum = np.sum(model['w'])
                Soth = np.mean(model['w'][1:n])
                print 'n:%3d m:%3d M:%5d AUX:%8.3f S1:%8.3f S1R:%8.3f Soth:%8.3f' % (n,m,M,score,S1,S1/Ssum,Soth)
                mat[i,:] = np.array([n,m,M,score,S1,S1/Ssum,Soth])
                i = i + 1

scipy.io.savemat('case1.mat',mdict={'results': mat})
