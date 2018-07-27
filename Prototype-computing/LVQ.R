LVQ <- function(df,apk,ls){
  # df = data.frame, apk = Anzahl der Prototypen Pro Klasse, ls = Lernschritte
  
  #Datensatz
  # Aufbau:
  #       Spalte 1-16 _ Verhaeltnisse der einzelnen Frequenzen
  #       Spalte 17 _ Gruppe des Objektes (= anzv)
  x <- df
  
  #Anzahl der Prototypen pro Klasse
  kla <<- x[,ncol(x)]
  anz <- NULL
  a <- NULL
  for(i in sort(unique(kla))){
      anz <- length(which(i == kla))
      if(anz < apk){
          a <- c(a,anz)
      }else{
          a <- c(a,apk)
      }
  }
  cat("Anzahl Prototypen pro Klasse: ",a)

  #Hilfsvariablen
  anzv <- ncol(x) # Anzahl der zugrundeliegenden Variablen
  anzo <- nrow(x) # Anzahl der Objekte
  kl <- length(unique(x[,anzv])) # Anzahl der Klassen
  nrkla <- sort(unique(x[,anzv])) # Klassen-Nr. wenn nicht 1,2,3... sondern eher 2,3,7,8
  su <- rep(0,(kl+1)) # Hilft bei der zufaelligen Wahl der Prototypen
  
  cat("\n Anzahl Klasse: ",kl,"\n Klassencodierung: ",nrkla,"\n")

  #Anzahl der Objekte pro Klasse
  anz <- rep(0,kl)
  
  #Wahl zufaelliger Indizes
  inp1 <- list()
  
  for(i in 1:kl){
      anz[i] <- length(x[which(nrkla[i]==x[,anzv]),anzv])
      su[i+1] <- su[i] +anz[i] #Aufsummierung der Objekte pro Klasse
      inp1[[i]] <- sample((su[i]+1):(su[i+1]),a[i]) #a Indizes fuer Prototypen
  }
  
  #Initial-Prototypen
  inp <- inpk<- NULL
  for(i in 1:kl){
      inp <- rbind(inp,x[inp1[[i]],1:(anzv-1)]) # Prototypen nach Gruppen sortiert
      inpk <- c(inpk,x[inp1[[i]],anzv]) # und deren Gruppen
  }

  for(i in 1:ls){ # Lernschritte
  	  cat("Schritt: ",i,"\n")
      for(j in 1:anzo){ # Lernprozess ueber alle Objekte
          
          # Naechster-Nachbar von x zu inp
          c <- NN(x[j,1:(anzv-1)],inp)
          
          #Klasse des Indizes c
          l <- inpk[c]
          
          #Lernschritt
          if(x[j,anzv]==l){
              inp[c,] <- inp[c,] + alpha(i)*(as.numeric(x[j,c(1:(anzv-1))])-inp[c,])
          }else{
              inp[c,] <- inp[c,] - alpha(i)*(as.numeric(x[j,c(1:(anzv-1))])-inp[c,])
          }
      }
      #Hier fehlt noch der Test der Prototypen am Trainingsdatensatz
  }
  
  output <- cbind(inp,inpk)
  
  return(output)
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
	ls = 1										# 15 optimal values for training data
	apk = 50
}else if(o == 3){
	oliname="tri"
	ls = 10
	apk = 500
}else{
	oliname="tetra"
	ls = 15
	apk = 1000
}


p <- paste(wdir,"/trainingdata",sep="")

liste <- list.files(p,pattern = "training.*.txt",full.names = T)

for(i in liste)
{
	oli=4^o
	df <- read.table(i,header = T,sep="\t",dec=".")
	proto <- LVQ(df[order(df[,oli+1]),],apk,ls)
	colnames(proto)[ncol(proto)] <- "DoRNA"
	name <- gsub("[.]txt","",gsub("^.*/|\\\\","",i))
	write.table(x = proto,file = paste(wdir,"/prototypes/proto_",oliname,"_ls_",ls,"_apk_",apk,"_tds_",name,".txt",sep=""),sep = "\t",dec = ".",quote = F)
}
