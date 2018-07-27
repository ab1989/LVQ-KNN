require(class,quietly = T)

k.nn <- function(ptest,pprot){
	liste <- list.files(path = ptest,full.names = T,pattern ="txt")

	liste_prot <- list.files(path = pprot,full.names = T,pattern ="txt")

	for(o in liste_prot){
		prot <- read.table(file = o,sep = "\t",dec = ".",header = T,stringsAsFactors = F)
		for(m in liste){
			
			df <- read.table(file = m ,header = T,sep = "\t",dec = ".",stringsAsFactors = F)
			
			erg_class <- data.frame(knn(prot[,1:(ncol(prot)-1)],df,cl = prot[,ncol(prot)],k = k,l = l))
			erg_class$sequence <- row.names(df)
			output <- cbind(erg_class$sequence,erg_class[,1])
			name <- gsub("[.].*$","",gsub("^.*/","",m))
			name2 <- unlist(strsplit(o,"_"))[c(4,6)]
			name3 <- gsub("([.].*$)|(_.*$)","",name2[2])
			name2[2] <- name3
			write.table(x = output,file = paste(wdir,"/results/result_",name,"_ls_",name2[1],"_apk_",name2[2],"_",oliname,".ergeb",sep = ""),sep = "\t",dec = ".",row.names = F,col.names = F,quote = F)
		}
	}
}


# load environment variables from bash
wdir =Sys.getenv("wdir")
installdir = Sys.getenv("installdir")
o = as.numeric(Sys.getenv("composition"))

# load Hilfsprogramme.R, otherwise errors will occure
source(paste(installdir,"/Hilfsprogramme.R",sep=""))

if(o == 2)
{
	oliname="di"
	k = 16
	l = 14
}else if(o == 3){
	oliname="tri"
	k = 18
	l = 16
}else{
	oliname="tetra"
	k = 17
	l = 16
}

ptest <- paste(wdir,"/testdata/",sep="")
pprot <- paste(wdir,"/prototypes/",sep="")

k.nn(ptest,pprot)
