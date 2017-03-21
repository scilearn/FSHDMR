# Feature Selection with HDMR (FSHDMR)
This repository is created to give an interested reader an opportunity to repeat all the experiments in the manuscript titled "Feature Selection Based on High Dimensional Model Representation for Hyperspectral Images".

## Prerequisites
Python and the packages [`python-pip`](https://pypi.python.org/pypi/pip), [`scipy`](https://www.scipy.org), [`numpy`](http://www.numpy.org), [`sklearn`](http://scikit-learn.org), [`joblib`](https://pypi.python.org/pypi/joblib), and [`scikit-feature`](https://github.com/jundongl/scikit-feature.git) should be installed. For Mac OSX, and Windows you may use [`Brew`](http://brew.sh) and [`Cygwin`](https://www.cygwin.com),respectively. If you have an Ubuntu distribution the following steps will be sufficient. For other distributions, the name of the packages may differ.

	apt-get install python-pip
	pip install --upgrade pip
	pip install scipy numpy sklearn joblib
	git clone https://github.com/jundongl/scikit-feature.git
	cd scikit-feature/
	python setup.py install

If you want to visualize the results, then you will also need `MATLAB`, [`export_fig`](https://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig), and [`subaxis`](https://www.mathworks.com/matlabcentral/fileexchange/3696-subaxis-subplot) packages. 
The PDF files of the visualization are already provided in the repository for those who doesn't have `MATLAB`.

## Installing
The installation is nothing but cloning the repository by issuing the following command. After that you will have a `FSHDMR` folder.

	git clone https://github.com/scilearn/FSHDMR.git
	cd FSHDMR

## Feature Selection
In order to run all feature-selection methods on all datasets, you may run `findFeatures.py` script in the `src` folder as follows:

    # cd src
    # python findFeatures.py

The above command will run eight different feature-selection methods including `HDMR` on Indian Pines, Botswana and Sundiken (not included) at once. The selected features will be saved to the `../results` directory. Running all of the experiments will require too much time, so, for the impatient readers, the script is designed to skip already computed results. Since all of the results are precomputed and saved in the repository, you will see something similar below when you execute `findFeatures.py`:

    # python findFeatures.py
    Skipping ../results/SUNDIKEN_features4c_mrmr.mat
    Skipping ../results/SUNDIKEN_features4c_chi2.mat
    Skipping ../results/SUNDIKEN_features4c_hdmr.mat
    ...

If you want to repeat a specific experiment, you can remove the specific result file and rerun the script. For instance to run `Chi2` algorithm to select the features for `SUNDIKEN` dataset, you should first remove the related result file and rerun the script.

~~~bash
rm ../results/SUNDIKEN_features4c_chi2.mat
# python findFeatures.py
Skipping ../results/SUNDIKEN_features4c_mrmr.mat
Number of cores: 4
Obtaining features for classification chi2 SUNDIKEN fold:  0
Obtaining features for classification chi2 SUNDIKEN fold:  1
Obtaining features for classification chi2 SUNDIKEN fold:  2
[ 28  27  96  26  95  25  94  93 126  24  23  29  97  22  21  20 127  19
98  99 100 101 125 124 128 102 131  18  30 108 109 130 105 113 122 103
110 129 112 118 114 121 111 119 123 115 120 106 117 107 116 104  11 132
12  17  10 137 133 136 139 141 140 142 138 134  16  13 135   9 143 144
14  15 146 145 147  31   8 148 154 152 149 153 155 151 150  79  80  76
77  78  83  81  84  91  82  75  92  87  88   7  90  32  89  74   3  86
85  73   4  72  58   6  57  56  59  71  61  55  60  33  62  70  63  54
64  69  53  50  65  52  68  66  49  51  48  47  67   5  6  34  45  35
36  44  43  37  42  41  40  39  38   0   2   1]
...
Skipping ../results/INDIANPINES_features_hdmr.mat
~~~
As you see, this time, the script will use `chi2` feature-selection method and recreate the file `../results/SUNDIKEN_features4c_chi2.mat`. 

## Classification
Once you obtained all features by running `python findFeatures.py`, you are ready to use those features in the classification. To do this, it is enough to give the following command:

	# python classification.py
	
The script will use the already calculated features incremently in the classification and records the classification accuracies in the `results` folder as `DATASET_accuracy_FSMETHOD.mat` for **DATASET** and **FSMETHOD**.

## Visualization of the Results
If you have `MATLAB` and the MATLAB packages [`export_fig`](https://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig), and [`subaxis`](https://www.mathworks.com/matlabcentral/fileexchange/3696-subaxis-subplot), you can transform the results into PDF files by using the following scripts in the `src` folder. If you don't, you can find already saved PDF files in the `figures` directory. 

* `visualizeAccuracy.m`: This script reads the result files of classification accuracies and produce the PDF files `DATASET_accuracy_CLASSIFIER.pdf`.
* `visualizeAccuracyAllinOne.m`: This script collects all the classification results and compiles into the PDF file `accuracyAllinOne.pdf`.
* `visualizeRobustness.m`: It collects all the selected features and compile them into the PDF files `DATASET_robustness.pdf` for each dataset.

## Contents of the package
Cloning the [repository](https://github.com/scilearn/FSHDMR) will create a "**FSHDMR**" directory which has the following structure:

### src/
* `findFeatures.py`: Runs the feature selection methods including HDMR.
* `classification.py`: Use already calculated features in classification.
* `hdmr.py`: Contains the implementation of feature selection via HDMR.
* `sobol_set.mat`: A file required by hdmr.py. This file contains a precomputed Sobol' sequence which is to fill in the unit hypercube.
* `svmrfe.py`: A wrapper for SVM-RFE
* `visualizeAccuracy.m`:  Visualize the classification accuracies.
* `visualizeAccuracyAllinOne.m`: Another way to visualize the classification accuracies.
* `visualizeRobustness.m`: Visualize the robustness of the feature selection methods.

### data/
* `INDIANPINES.mat`: Indian Pines dataset. The file contains `X`, and `Y` matrices which corresponds to the all instances and their class labels, respectively. The number of rows and columns corresponds the number of samples, and the number of features, respectively. The file is read from Python as follows:
* 
~~~python
import scipy.io
mat = scipy.io.loadmat('data/INDIANPINES.mat')
X = mat['X'].astype(float)
y = mat['Y'].astype(int)
n_samples, n_features = X.shape
~~~

* `INDIANPINES_part4c.mat`: Training and testing partitions for classification task (4c means **f**or **c**lassification). It includes a `Partition` matrix with size (m by 10) where m is the total number of instances in the dataset. 10 is the number of different random realizations of the dataset. To get the training and testing sets for each trial, the following technique is used:
* 
~~~python
mat = scipy.io.loadmat('data/INDIANPINES_part4c.mat')
P = mat['Partition'].astype(int)
for trial in range(10):
		train = P[:,trial] == +1
		test  = P[:,trial] == -1
		# training set and the labels
  		trnX = X[train]
    	trnY = y[train]
    	# testing set and the labels
    	tstX = X[test]
    	tstY = y[test]    
~~~
* `INDIANPINES_part.mat`: Training and testing partitions for robustness. It is more or less the same with `part4c` except that 100 different partitions exist in the `Partition` matrix. This partition is used for robustness calculation so the features selected by using these partitions are never used in the classification.
* `BOTSWANA.mat`: BOTSWANA dataset. The datastructure is the same as Indian Pines.
* `BOTSWANA_part4c.mat`: Training and testing partitions for classification task.
* `BOTSWANA_part.mat`: Training and testing partitions for robustness.
* `SUNDIKEN.mat`: SUNDIKEN dataset. It is not provided due to the permission issues. However, the partitions and related results are in the repository.
* `SUNDIKEN_part4c.mat`: Training and testing partitions for classification task.
* `SUNDIKEN_part.mat`: Training and testing partitions for robustness.

### results/
Running the Python scripts in the `src` folder will populate the `results` folders. You can always check each result file by loading it to `MATLAB`. However, you can also run the `MATLAB` scripts to visualize and produce PDF files.

* `DATASET_features_FSMETHOD.mat`: The features obtained by a feature selection method **FSMETHOD** on **DATASET** for robustness calculation. If you load this file onto `MATLAB`, you will see an (n by 100) `features` matrix where n is the number of total features in the dataset. The computational times are also recorded in (1 by 100) `cputimes` vector. The number 100 is the number of different random realizations of training set. This means that the feature selection method **FSMETHOD** is run 100 times on the same dataset with different training set. The partitioning of the training sets are defined in `data/DATASET_part.mat` file (see above). 
* 
~~~matlab
>> load('../results/INDIANPINES_features_chi2.mat')
>> whos
  Name            Size              Bytes  Class     Attributes

  cputimes        1x100               800  double              
  features      200x100            160000  double  
~~~
* `DATASET_features4c_FSMETHOD.mat`: The features obtained by the feature selection method **FSMETHOD** on **DATASET** by using the partitions file `DATASET_part4c.mat`. The data structure is the same with the previous one except that there are only 10 different random realizations.
* 
~~~matlab
>> load('../results/SUNDIKEN_features4c_hdmr.mat')
>> whos
  Name            Size            Bytes  Class     Attributes

  cputimes        1x10               80  double              
  features      156x10            12480  double 
~~~
* `DATASET_accuracy_FSMETHOD_CLASSIFIER.mat`: The classification results of the **CLASSIFIER** using the features obtain by **FSMETHOD**. The classification starts from 5 features and adding 5 at each step until using all of the features. This prosess is repeated 10 different partitions. The `frange` vector in the file show exactly how many features are taken in each step. For instance in the following example, the Bayes classifier is evaluated 31 times with the number of features specified in the `frange` variable.
*  
~~~matlab
>> load('../results/SUNDIKEN_accuracy_chi2_bayes.mat')
>> whos
  Name                 Size            Bytes  Class     Attributes

  accuracies          10x31             2480  double              
  classifiertime      10x31             2480  double              
  frange               1x31              248  int64    
>> fprintf('%3d ',frange)
  5  10  15  20  25  30  35  [...omitted...] 135 140 145 150 156 
~~~

### figures/
The PDF files in this folder are created by running the `MATLAB` scripts in the `src` folder. 

* `DATASET_accuracy_CLASSIFIER.pdf`: The visualization of the classification accuracies.
* `accuracyAllinOne.pdf`: A different visualization combining all the classification accuracies into one.
* `DATASET_robustness.pdf`: The visualization of the stability of the features.

## The Figures in the Manuscript
For the interested readers, here is list of the figures used in the manuscript *"Feature Selection Based on High Dimensional Model Representation for Hyperspectral Images"*, and their locations in the repository. To recreate the figures, you should remove all the results and PDF files in `results` and `figures` folder and rerun `findFeatures.py`, and `classification.py`. Then you should run the `MATLAB` scripts to recreate the PDF files. Remember that **SUNDIKEN dataset is not included** in the repository for permission issues, so you will not be  able to recreate those results.
 
- Figure 4a --> `figures/INDIANPINES_accuracy_svm.pdf`
- Figure 4b --> `figures/INDIANPINES_accuracy_bayes.pdf`
- Figure 4c --> `figures/INDIANPINES_accuracy_tree.pdf`
- Figure 4d --> `figures/BOTSWANA_accuracy_svm.pdf`
- Figure 4e --> `figures/BOTSWANA_accuracy_bayes.pdf`
- Figure 4f --> `figures/BOTSWANA_accuracy_tree.pdf`
- Figure 4g --> `figures/SUNDIKEN_accuracy_svm.pdf`
- Figure 4h --> `figures/SUNDIKEN_accuracy_bayes.pdf`
- Figure 4i --> `figures/SUNDIKEN_accuracy_tree.pdf`
- Figure 5 --> `figures/accuracyAllinOne.pdf`
- Figure 6a --> `figures/INDIANPINES_robustness.pdf`
- Figure 6b --> `figures/BOTSWANA_robustness.pdf`
- Figure 6c --> `figures/SUNDIKEN_robustness.pdf`
