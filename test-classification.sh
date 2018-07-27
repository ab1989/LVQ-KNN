#!/bin/bash
# creating test data sets and computing classification results with K-NN

#------------------------- Config
. ~/Homelaufwerk/Eigene\ Dokumente/Paper/Abstracts/erster_Entwurf/Programm/Config.txt

#------------------------- Input, directory creation, and user information
test=y
classification=y
composition=2

unset projectname                                           # project directory name
unset wdir                                                  # working directory

while getopts o:p:t:k:c:f: opt 2>/dev/null                  # input options
    do                                                         
        case ${opt} in                                      # get input parameters
            o)                              
                outputdir=$OPTARG;;                         # enter working directory (absolute path)
            p)                              
                projectname=$OPTARG;;                       # a name for the output folder must be specified                                                               # path and name to input date if not format is specified 
            t)                              
                test=$OPTARG;;                              # should training data set be created, default y
            k)
                classification=$OPTARG;;                    # should prototypes be created, default y
            c)
                composition=$OPTARG;;                       # information which oligonucleotide to use: default 2 (di); up to 4 sensible
            f)
                testfiles=$OPTARG;;                         # full path directory of test sequence files / test oligonucleotide information
            *)                                              # at unvalid input                                                                                                                        
                cat ${installdir}/input_info.txt            # show info and 
                exit;;                                      # exit program                                                                                     
        esac                            
    done                        

wdir=${outputdir}${projectname}

mkdir -p ${wdir}
touch ${wdir}/progress.log

echo -e "\n\n############### K-NN Classification ################"                          2>&1 | tee -a ${wdir}/progress.log
echo -e "#    Ariane Belka, Dirk Hoeper, Mareike Fischer    #"                              2>&1 | tee -a ${wdir}/progress.log
echo -e "#            Martin Beer, Anne Pohlmann            #"                              2>&1 | tee -a ${wdir}/progress.log
echo -e "#                 Copyright 2017                   #"                              2>&1 | tee -a ${wdir}/progress.log
echo -e "####################################################\n"                            2>&1 | tee -a ${wdir}/progress.log
echo -e "Working directory: $wdir"                                                          2>&1 | tee -a ${wdir}/progress.log
echo -e "Test sequence directory: $testfiles"                                               2>&1 | tee -a ${wdir}/progress.log
echo -e "Test: $test - Classification: $classification\n\n"                                 2>&1 | tee -a ${wdir}/progress.log

mkdir -p ${wdir}/testdata
mkdir -p ${wdir}/results

#------------------------- get training data information

date1=`date`
echo -e "----------------------------\n"                                                    2>&1 | tee -a ${wdir}/progress.log
echo -e "Start of computation: $date1"                                                      2>&1 | tee -a ${wdir}/progress.log

if [ "${test}" == "y" ]
    then
        fna=`ls ${testfiles} | grep .*.fasta`
        if [ -n "$fna" ]
            then
                echo -e "Test sequence files *.fasta are copied to testdata"                2>&1 | tee -a ${wdir}/progress.log
                cp ${testfiles}/*.fasta ${wdir}/testdata
                echo -e "\n Done \n"                                                        2>&1 | tee -a ${wdir}/progress.log
            else
                echo -e "Test sequence files *.fna are copied to testdata"                  2>&1 | tee -a ${wdir}/progress.log
                cp ${testfiles}/*.fna ${wdir}/testdata
                echo -e "\n Done \n"                                                        2>&1 | tee -a ${wdir}/progress.log
        fi
        
        #-------------------------- create test*.txt with R script testdata.R
        d=`date`
        echo -e "Test dataset will be created... $d"                                        2>&1 | tee -a ${wdir}/progress.log
        
        compseq=${embossdir}/compseq
        export compseq
        export installdir
        export wdir
        export composition
        ${rdir}/Rscript "${installdir}"/k-NN-classification/testdata.R                      2>&1 | tee -a ${wdir}/progress.log
        
        rm -r ${wdir}/testdata/test-*
        
        d=`date`
        echo -e "\n Done $d\n"                                                              2>&1 | tee -a ${wdir}/progress.log
    else
        echo -e "Test sequence oligonucleotide information file is copied to testdata"      2>&1 | tee -a ${wdir}/progress.log
        cp ${testfiles}/test*.txt ${wdir}/testdata
        echo -e "\n Done \n"                                                                2>&1 | tee -a ${wdir}/progress.log
fi

if [ "${classification}" == "y" ]
    then
        d=`date`
        echo -e "Classification results complete are created... $d"                         2>&1 | tee -a ${wdir}/progress.log
        echo -e "This take a while..."                                                      2>&1 | tee -a ${wdir}/progress.log
        
        #-------------------------- K-NN - Method with R
        export installdir
        export wdir
        export composition
        ${rdir}/Rscript "${installdir}"/k-NN-classification/k-nn.R                          2>&1 | tee -a ${wdir}/progress.log
        
        d=`date`
        echo -e "\n Done $d\n"                                                              2>&1 | tee -a ${wdir}/progress.log
        
        echo -e "Classification results compact are created... $d"                          2>&1 | tee -a ${wdir}/progress.log
        export wdir
        ${rdir}/Rscript "${installdir}"/k-NN-classification/results_compact.R               2>&1 | tee -a ${wdir}/progress.log
        echo -e "\n Done $d\n"                                                              2>&1 | tee -a ${wdir}/progress.log
    else
        echo -e "Classification was not selected!"                                          2>&1 | tee -a ${wdir}/progress.log
fi

date2=`date`
echo -e "--------------------------\n"                                                      2>&1 | tee -a ${wdir}/progress.log
echo -e "End of computation: $date2"                                                        2>&1 | tee -a ${wdir}/progress.log

