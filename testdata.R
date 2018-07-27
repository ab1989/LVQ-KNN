# Trainingsdaten mittels comseq erstellen und abspeichern

testdata <- function(p,o){
    #Packages
    require(seqinr,quietly = T)
  
    #Dinukleotidinfos berechnen
    #cat("Wählen Sie den Pfad von Compseq.exe aus.\n")
    path_compseq <- compseq
  
    #Sequenzordner wählen
    path_seq <-p #Initialpfad
    
    #fna <- list.files(path_seq,pattern=".f") # listing of founded files
    
    #M:\Eigene Dokumente\Daten\lca\Testdaten\Bakterien
    #setwd(paste(path_seq,"/",sep="",collapse=NULL))
    seqlist <- list.files(path=path_seq,pattern=".fna|.fasta")
	oli <- 4^o
	
	idx <- 1
    for(i in 1:length(seqlist)){
    
        cat("Sequenzen: ",seqlist[i],"\n")
    
        output <<- data.frame(matrix(0,nrow=0,ncol=oli))
        zeile <- NULL
        seqs <- read.fasta(paste(path_seq,"/",seqlist[i],sep=""),as.string=TRUE)
        seqname <<- NULL
        name <<- NULL
        
        err_out <-NULL
        hilf <- NULL
        for(k in 1:length(seqs)){
            laenge_seq <- nchar(seqs[[k]][[1]])
            if(laenge_seq == 0){
                #tue nichts
                err <- "keine Sequenz enthalten"
                err_out <- rbind(err_out,c(attributes(seqs[k])[[1]],err))
                hilf <- c(hilf,k)
            }else{
            }
        }
        
        if(is.null(hilf)==TRUE){
            #tue nichts
        }else{
            cat(hilf)
            seqs <- seqs[-hilf]
        }
        
        name <- gsub("[.]f.*$","",strsplit(seqlist[i],"/")[[1]][1])
        write.table(err_out,file=paste(path_seq,"/test",idx,"_",name,"_err.log",sep=""),dec=".",sep="\t",quote=F)
   		
        dir.create(paste(path_seq,"/test-",idx,sep=""))
        for(j in 1:length(seqs)){

            seq_name <- attributes(seqs[j])[[1]]
            #cat("Sequenz: ",seq_name,"\n")

            seq <- paste(path_seq,"/test-",idx,"/",seqlist[i],"_",j,".fasta",sep="",collapse = NULL)
        
            write.fasta(seqs[j],seq_name,file.out=seq)
        
            z <- sub("fasta","compseq",seq)
            #out <- paste(path_seq,z,sep="",collapse = NULL)
    
            #cat("--------------------------------------\n")
            system2(command = path_compseq,input = c(seq,o,z),stdout = NULL,stderr = NULL)
    
            output[j,1:oli] <<- read.table(file = z,fill = T)[3:(3+oli-1),5]
        
            seqname[j] <<- paste(j,"_",gsub(":","_",attributes(seqs[j])[[1]]),sep="")
        
            #cat("\n--------------------------------------\n")
    
   
            #zeile <- c(zeile,strsplit(x = seqlist[i],split = "\\Q|\\E")[[1]][4])
            #cat("Zeilenname: ",zeile,"\n")
            #cat("\n--------------------------------------\n")
            #cat("--------------------------------------\n")
    
        }

        write.table(seqname,file=paste(path_seq,"/test",idx,"_",name,"_rownames.log",sep=""),dec=".",sep="\t",quote=F)

        rownames(output) <<- seqname
        #rownames(output) <- zeile
		
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

		colname <- sort(cn3)
		
        colnames(output) <<- colname
    
        #Abspeichern der testdatensätze
        #return(output)
        write.table(output,file=paste(path_seq,"/test",idx,"_",name,"_",oliname,".txt",sep=""),dec=".",sep="\t",quote=F)
        idx <- idx+1
    }
  
}

# load environment variables from bash
compseq = Sys.getenv("compseq")
wdir =Sys.getenv("wdir")
installdir = Sys.getenv("installdir")
o = as.numeric(Sys.getenv("composition"))
# load Hilfsprogramme.R, otherwise errors will occure
source(paste(installdir,"/Hilfsprogramme.R",sep=""))

if(o == 2)
{
	oliname="di"
}else if(o == 3){
	oliname="tri"
}else{
	oliname="tetra"
}

p <- paste(wdir,"/testdata",sep="")
test <- testdata(p,o)
