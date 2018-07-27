#!/bin/bash
# Main file containing the standard programm calls

#path to program and Config
path=~/R/LVQ-KNN/
. ${path}/Config.txt

#INPUT OPTIONS

tr=y
te=y
p=analysis_output
l=y
k=y
c=2

unset p                                                     # project directory name
unset o                                                     # working directory

while getopts o:p:t:q:l:k:r:u:c: opt 2>/dev/null              # input options
    do                                                         
        case ${opt} in                                      # get input parameters
            o)                              
                o=$OPTARG;;                                 # enter working directory (absolute path)
            p)                              
                p=$OPTARG;;                                 # a name for the output folder must be specified
            t)                              
                tr=$OPTARG;;                                # should training dataset be created, default y
            q)                              
                te=$OPTARG;;                                # should test dataset be created, default y
            l)
                l=$OPTARG;;                                 # should prototypes be created, default y
            k)
                k=$OPTARG;;                                 # should be classified, default y
            r)
                f1=$OPTARG;;                                # full path directory of reference sequence files / reference oligonucleotide information
            u)
                f2=$OPTARG;;                                # full path directory of query sequence files
            c)
                c=$OPTARG;;                                 # information which oligonucleotide to use: default 2 (di); up to 4 sensible
            *)                                              # at unvalid input
                cat ${installdir}/input_info.txt            # show info and 
                exit;;                                      # exit program
        esac                            
    done                        

# Training dataset and prototype computation
export path
sh "${path}"/Prototype-computing/training_prototypes.sh -o $o -p $p -t $tr -l $l -c $c -f $f1

# Test dataset and classification results
if [ "$te" != "y" ] && [ "$k" != "y" ]
    then
        #do nothing
        echo -e "The classification of sequences was not chosen.\n"                                 2>&1 | tee -a ${o}/${p}/progress.log
        exit
    else
        export path
        sh "${path}"/k-NN-classification/test-classification.sh -o $o -p $p -t $te -k $k -c $c -f $f2
fi

