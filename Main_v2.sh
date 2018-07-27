#!/bin/bash
# Main file containing the standard programm calls

#path to program
path=~/path-to-program

#parameter setting
o=~/path-to-output/
p=name-of-analysis
tr=y                            # training-dataset creation y/n
te=y                            # test-dataset creation y/n
l=y                             # prototype dataset creation y/n
k=y                             # classification y/n
c=2                             # oligonucleotide: dinucleotide=2, tri = 3, tetra = 4
f1=~/path-to/trainingdata
f2=~/path-to/testdata

# Training dataset and prototype computation

sh "${path}"/Prototype-computing/training_prototypes.sh -o $o -p $p -t $tr -l $l -c $c -f $f1

# Test dataset and classification results

sh "${path}"/k-NN-classification/test-classification.sh -o $o -p $p -t $te -k $k -c $c -f $f2


