# Training dataset
# reference sequences in fasta format, with extention: *.fasta or *.fna

trainingdata <- function(p,o){ # o = Oligonucleotide, Dinucleotide=2
  # used packages and functions
  require(seqinr,quietly = T)
  path_compseq <- compseq
  
  # p = path of *.fasta/*.fna
  path_fna <- p
  
  # auxiliary variable
  start <- 1
  ende <- 0
  
  # loading of the data
  fna <- list.files(path_fna,pattern=".f") # listing of founded files
  
  if(is.int(grep(".fasta",fna))==FALSE){
    fna2 <- gsub(".fasta","",fna) # auxiliary variable, to create names of sequences
  }else{
    fna2 <- gsub(".fna","",fna) # auxiliary variable, to create names of sequences
  }
  ndir <- paste(path_fna,"/",fna2,"-tmp/",sep="") # save individual sequences and their information
  dirs <- apply(X=as.matrix(ndir),MARGIN=1,FUN=dir.create) # creating directories, where *.compseq-files of the various classes are stored

  # create file containing the sorted class information - coding-class dependency
  write.table(x = fna2,file = paste(path_fna,"/sortedClasses.txt",sep=""),sep = "\t",dec = ".",quote = F,col.names = F)
  
  #output computation
  oli <- 4^o
  output <- data.frame(matrix(0,nrow=0,ncol=oli+1))
  
  fpath <- paste(path_fna,"/",fna,sep="") # Um auf die Daten in den *.fna zugreifen zu koennen
  
  for(j in 1:length(fpath)){
    #Sequenzen der einzelnen Klassen
    seq <- read.fasta(fpath[j],as.string=T,seqonly=F)
    
    #Damit die Daten abgespeichert werden koennen
    start <- start
    ende <- ende + length(seq)
    h <- seq(start,ende,1)
    
    #Abspeichern der Daten in compseq und im Dataframe
    for(i in 1:length(seq)){
      a <- gsub("\\Q|\\E","_",attributes(seq[[i]])[[1]])
      b <- paste(ndir[j],"/",fna2[j],a,".compseq",sep="") # Ausgabe
      a <- paste(ndir[j],"/",fna2[j],a,".fasta",sep="")  # Eingabe
      #cat(a)
      zz <- file.create(a)
      sink(a)
      cat(attributes(seq[[i]])[[2]],"\n")
      cat(seq[[i]])
      sink()
      
	  system2(path_compseq,input=c(a,o,b),stdout = NULL,stderr = NULL) #Erstellen der compseq-Datei
      #system(path_compseq,input=c(a,2,b),show.output.on.console = F) #Erstellen der compseq-Datei
	  
      output[h[i],1:oli] <- read.table(b,fill=T)[3:(3+oli-1),5]
	  #output[h[i],1:16] <- read.table(b,fill=T)[3:18,5]
      rownames(output)[h[i]] <- attributes(seq[[i]])[[1]]
      
      #Gruppenzuweisung
      
      # eine der t taxonomischen Gruppen
      #output[h[i],(oli+1)] <- j
      
      # DNA (1) oder RNA (2)
      if(is.int(grep("DNA",ndir[j]))==FALSE|| is.int(grep("Bacteria",ndir[j]))==FALSE){
        output[h[i],(oli+1)] <- 1
      }else{
          output[h[i],(oli+1)] <-2 #RNA
      }
      
      # Virus (1) und Bakterien (2)
      #if(is.int(grep("Bacteria",ndir[j]))==FALSE){
      #  output[h[i],(oli+3)] <- 2
      #}else{
      #  output[h[i],(oli+3)] <- 1 #Virus
      #}

    }
    start <- start + length(seq)
    #cat("Klasse ",j,"\n")
  }
  
	x = s2c("ACGT")
	liste <- list()
	for(k in 1:o){
  
		liste[[k]] <- x
  
	}

	cn <- list(expand.grid(liste))

	cn3 <-NULL
	for(l in 1: length(cn[[1]][,1])){
		cn2 <- NULL
		for(m in 1:length(cn[[1]][1,])){
			cn2 <- paste(cn2,cn[[1]][l,m],sep="")
		}
		cn3 <- c(cn3,cn2)
	}

	#colname <- c(sort(cn3),"Untergruppen","DoRNA","VoB")
	colname <- c(sort(cn3),"DoRNA")

  colnames(output) <- colname
  return(output)
  
}

# load environment variables from bash
compseq = Sys.getenv("compseq")
wdir =Sys.getenv("wdir")
installdir = Sys.getenv("installdir")
o = as.numeric(Sys.getenv("composition"))
# load Hilfsprogramme.R, otherwise errors will occure
source(paste(installdir,"/Hilfsprogramme.R",sep=""))

p <- paste(wdir,"/trainingdata",sep="")
training <- trainingdata(p,o)

if(o == 2)
{
	oliname="di"
}else if(o == 3){
	oliname="tri"
}else{
	oliname="tetra"
}

write.table(x = training,file = paste(wdir,"/trainingdata/training_",oliname,".txt",sep=""),sep = "\t",dec = ".",quote = F)
