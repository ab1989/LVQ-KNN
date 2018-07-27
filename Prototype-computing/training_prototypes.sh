#!/bin/bash
# creating training data sets and computing prototypes with LVQ

#------------------------- Config
. ~/Homelaufwerk/Eigene\ Dokumente/Paper/Abstracts/erster_Entwurf/Programm/Config.txt

#------------------------- Input, directory creation, and user information
training=y
prototypes=y
composition=2

unset projectname                                           # project directory name
unset wdir                                                  # working directory

while getopts o:p:t:l:f:c: opt 2>/dev/null            # input options
    do                                                         
        case ${opt} in                                      # get input parameters
            o)                              
                outputdir=$OPTARG;;                         # enter working directory (absolute path)
            p)                              
                projectname=$OPTARG;;                       # a name for the output folder must be specified                                                               # path and name to input date if not format is specified 
            t)                              
                training=$OPTARG;;                          # should training data set be created, default y
            l)
                prototypes=$OPTARG;;                        # should prototypes be created, default y
            f)
                trainingfiles=$OPTARG;;                     # full path directory of reference sequence files / reference oligonucleotide information
            c)
                composition=$OPTARG;;                       # information which oligonucleotide to use: default 2 (di); up to 4 sensible
            *)                                              # at unvalid input                                                                                                                        
                cat ${installdir}/input_info.txt            # show info and 
                exit;;                                      # exit program                                                                                     
        esac                            
    done                        

wdir=${outputdir}${projectname}

mkdir -p ${wdir}
touch ${wdir}/progress.log

echo -e "\n\n############# LVQ Prototype Computation ################"                      2>&1 | tee -a ${wdir}/progress.log
echo -e "#      Ariane Belka, Dirk Hoeper, Mareike Fischer      #"                          2>&1 | tee -a ${wdir}/progress.log
echo -e "#              Martin Beer, Anne Pohlmann              #"                          2>&1 | tee -a ${wdir}/progress.log
echo -e "#                   Copyright 2017                     #"                          2>&1 | tee -a ${wdir}/progress.log
echo -e "########################################################\n"                        2>&1 | tee -a ${wdir}/progress.log
echo -e "Working directory: $wdir"                                                          2>&1 | tee -a ${wdir}/progress.log
echo -e "Reference sequence directory: $trainingfiles"                                      2>&1 | tee -a ${wdir}/progress.log
echo -e "Training: $training - Prototypes: $prototypes\n\n"                                 2>&1 | tee -a ${wdir}/progress.log

mkdir -p ${wdir}/trainingdata
mkdir -p ${wdir}/prototypes

#------------------------- get training data information

date1=`date`
echo -e "----------------------------\n"                                                    2>&1 | tee -a ${wdir}/progress.log
echo -e "Start of computation: $date1"                                                      2>&1 | tee -a ${wdir}/progress.log

if [ "${training}" == "y" ]
    then
        fna=`ls ${trainingfiles} | grep .*.fasta`
        if [ -n fna ]
            then
                echo -e "Reference sequence files *.fasta are copied to trainingdata"       2>&1 | tee -a ${wdir}/progress.log
                cp ${trainingfiles}/*.fasta ${wdir}/trainingdata
                echo -e "\n Done \n"                                                        2>&1 | tee -a ${wdir}/progress.log
            else
                echo -e "Reference sequence files *.fna are copied to trainingdata"         2>&1 | tee -a ${wdir}/progress.log
                cp ${trainingfiles}/*.fna ${wdir}/trainingdata
                echo -e "\n Done \n"                                                        2>&1 | tee -a ${wdir}/progress.log
        fi
        
        #-------------------------- create training*.txt with R script trainingdata.R
        d=`date`
        echo -e "Training dataset will be created... $d"                                    2>&1 | tee -a ${wdir}/progress.log
        
        compseq=${embossdir}/compseq
        export compseq
        export installdir
        export wdir
        export composition
        ${rdir}/Rscript "${installdir}"/Prototype-computing/trainingdata.R  
        
        rm -r ${wdir}/trainingdata/*-tmp
        
        d=`date`
        echo -e "\n Done $d\n"                                                              2>&1 | tee -a ${wdir}/progress.log
    else
        echo -e "Reference sequence oligonucleotide information file is copied to trainingdata"   2>&1 | tee -a ${wdir}/progress.log
        cp ${trainingfiles}/training*.txt ${wdir}/trainingdata
        echo -e "\n Done \n"                                                                2>&1 | tee -a ${wdir}/progress.log
fi

if [ "${prototypes}" == "y" ]
    then
        d=`date`
        echo -e "Prototype computation... $d"                                               2>&1 | tee -a ${wdir}/progress.log
        echo -e "This take a while..."                                                      2>&1 | tee -a ${wdir}/progress.log
        
        #-------------------------- LVQ - Algorithm with R: More than 2 classes possible
        #export compseq
        #export installdir
        #export wdir
        #export composition
        #${rdir}/Rscript "${installdir}"/Prototype-computing/LVQ.R
        
        #-------------------------- LVQ - Algorithm with perl: just 2 classes possible
        train=`ls ${wdir}/trainingdata | grep "training.*.txt"`
        training=${wdir}/trainingdata/${train}
        
        if [ $composition == 2 ] # optimal values from validation - can be changed if necessary
            then
                T=15
                n=500
            elif [ $composition == 3 ]
                then
                    T=10
                    n=500
                else
                    T=15
                    n=1000
        fi
        
        path=${wdir}/prototypes/
        
        export composition
        export training
        export path
        export T
        export n
        "${installdir}"/Prototype-computing/LVQ.pl                                          2>&1 | tee -a ${wdir}/progress.log
        
        d=`date`
        echo -e "\n Done $d\n"                                                              2>&1 | tee -a ${wdir}/progress.log
    else
        echo -e "Please provide your prototype set in the ${wdir}/prototypes directory!"    2>&1 | tee -a ${wdir}/progress.log
fi

date2=`date`
echo -e "--------------------------\n"                                                      2>&1 | tee -a ${wdir}/progress.log
echo -e "End of computation: $date2"                                                        2>&1 | tee -a ${wdir}/progress.log



