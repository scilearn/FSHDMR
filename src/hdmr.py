from sklearn import neighbors
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import scipy.io
from scipy.special import legendre
import numpy as np
import math
import sys
import time

def hdmrselect(X,models):
    m,n = X.shape
    w = np.zeros((n));
    for model in models:
        w += model['w']
    w = w/len(models)
    ranks = np.argsort(w)
    flist = ranks[::-1]
    return flist,w

def hdmrlearn(X,y,params):
    m, n = X.shape
    XP =params['sobol_set']
    k = params['k']
    p = params['p']
    M = params['M']
    b = params['b']

    XP = XP[0:M,0:n]

    labels = np.unique(y)
    nlabels = np.size(labels)
    #print 'labels (learn)', labels
    models = []

    for class1 in range(0,nlabels-1):
        label1 = labels[class1]
        for class2 in range(class1+1,nlabels):
            label2 = labels[class2]
            idx = np.logical_or(y == label1, y == label2)
            ynew = np.copy(y[idx])
            label1idx = ynew == label1
            label2idx = ynew == label2
            ynew[label1idx] = +1
            ynew[label2idx] = -1
            Xnew = X[idx,:]

            clf = neighbors.KNeighborsClassifier(n_neighbors=k,algorithm='brute')

            clf.fit(Xnew, ynew)
            yp = clf.predict(XP)

            #plt.plot(XP[yp==+1,0],XP[yp==+1,1], 'ko')
            #plt.plot(XP[yp==-1,0],XP[yp==-1,1], 'ro')
            #plt.plot(Xnew[ynew==+1,0],Xnew[ynew==+1,1], 'ks')
            #plt.plot(Xnew[ynew==-1,0],Xnew[ynew==-1,1], 'rs')
            #plt.show()

            alpha = np.zeros((n,p))
            w = np.zeros((n))
            f0 = np.mean(yp)
            D = np.mean(np.square(yp)) - f0**2
            for i in range(n):
                for ip in range(p):
                    if b == 'H':
                        phival = haar(XP[:,i],ip)
                    else:
                        phi = legendre(ip+1)
                        phival = np.sqrt(2*ip+3)*phi(2*XP[:,i]-1)
                    alpha[i,ip] = np.inner(yp,phival)
                alpha[i,:] = alpha[i,:]/M
                w[i] = np.sum(np.square(alpha[i,:]))
            if abs(D) < 1e-08:
                w.fill(0.0)
            else:
                w = w / D
            model = {'label1':label1,'label2':label2,'n': n,'p': p, 'D': D,'w': w,\
                  'b': b, 'f0': f0,'alpha': alpha}
            models.append(model)
            #print '%2d vs %2d TRN [%5d vs %5d] AUX [%5d vs %5d] D:%8.5f f0:%8.5f S0:%8.5f S1:%8.5f' % \
            #     (label1,label2,np.size(ynew[ynew==1]),np.size(ynew[ynew==-1]),\
            #     np.size(yp[yp==1]),np.size(yp[yp==-1]),D,f0,w[0],w[1])

    return models

def hdmrpredict(X,models):
    #print 'labels (predict)', uniqlabels
    m,n = X.shape
    y = np.zeros(m)
    n_models = len(models)

    # external/internal labelling stuff
    allextlabels = np.empty(0,dtype=int)
    for model in models:
        allextlabels=np.append(allextlabels,np.array([model['label1'],model['label2']]))
    extlabels = np.unique(allextlabels)
    nlabels = np.size(extlabels)
    intlabels = np.arange(nlabels)
    ext2int = {}; int2ext = {}
    for i in range(nlabels):
        int2ext[i] = extlabels[i]
        ext2int[extlabels[i]] = i

    estimatedlabels = np.zeros((m,n_models),dtype=int)
    for model_no in range(n_models):
        model = models[model_no]
        n = model['n']
        p = model['p']
        b = model['b']
        f0 = model['f0']
        alpha = model['alpha']
        f=np.zeros(m)
        for i in range(n):
            for j in range(p):
                if b == 'H':
                    phival = haar(X[:,i],j)
                else:
                    phi = legendre(j+1)
                    phival = np.sqrt(2*j+3)*phi(2*X[:,i]-1)
                f += alpha[i,j]*phival
        f += f0
        estimatedlabels[f >= 0,model_no] = ext2int[model['label1']]
        estimatedlabels[f  < 0,model_no] = ext2int[model['label2']]

    for i in range(m):
        frequency=np.bincount(estimatedlabels[i,:])
        y[i] = int2ext[np.argmax(frequency)]
    return y

def haarmaster(x):
    out = np.zeros(x.shape)
    r1 =  (x>=0.0) & (x<0.5)
    r2 =  (x>=0.5) & (x<1.0)
    out[r1] =  1
    out[r2] = -1
    return out

# j, k are from k=0
def haarbase(x,j,k):
    return np.sqrt(2**j)*haarmaster( (2**j) * x - k )

def haar(x,n):
    j=np.floor(np.log2(n+1)).astype('int')
    k=n-np.sum(2**np.arange(j)).astype('int')
    return haarbase(x,j,k)
