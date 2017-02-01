from sklearn.svm import SVC
from sklearn.feature_selection import RFE
from sklearn.model_selection import train_test_split
from sklearn.model_selection import GridSearchCV
import numpy as np

def svmrfe(X, y):
    Cs = np.logspace(-1,3,5,base=10)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.4, random_state=0)

    svc = SVC(kernel="linear")
    clf = GridSearchCV(estimator=svc, param_grid=dict(C=Cs),n_jobs=1)
    clf.fit(X_train,y_train)

    bestC = clf.best_estimator_.C   
    print 'SVMRFE grid search bestC: %f' % (bestC)

    svc = SVC(kernel="linear",C=bestC)
    rfe = RFE(estimator=svc, n_features_to_select=1, step=1)
    rfe.fit(X, y)
    # one-based to zero-based
    ranking = rfe.ranking_ - 1
    return ranking
