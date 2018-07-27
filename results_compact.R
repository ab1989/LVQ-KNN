wdir =Sys.getenv("wdir")

setwd(paste(wdir,"/results/",sep=""))

liste <- list.files("." ,full.names = T)
j <- 1
output <- data.frame("Name" = character(),"Class.1"=integer(),"Class.2"=integer(),"Unclassified"=integer(),stringsAsFactors = F)
for(i in liste)
{
	h <- read.table(i,header = F,sep="\t",dec=".",row.names = NULL)
	erg <- data.frame(table(h[,2],useNA = "always"))
	cm <- paste(erg$Var1,sep=" ",collapse = " ")
	name <- gsub("[.]ergeb","",gsub("[.]/.*test","",i))
	if(cm == "1 2 NA")
	{
		output[j,] <- c(name,erg$Freq)
	}else if (cm == "1 NA")
	{
		output[j,] <- c(name,erg$Freq[1],NA,erg$Freq[2])
	}else
	{
		output[j,] <- c(name,NA,erg$Freq[1],erg$Freq[2])
	}
	j <- j+1
}

output[j,] <- c("Sum", sum(as.numeric(output$Class.1),na.rm = T),sum(as.numeric(output$Class.2),na.rm = T),sum(as.numeric(output$Unclassified),na.rm = T))
for(i in 1:nrow(output))
{
	output$Sum[i] <- sum(as.numeric(output[i,2:4]),na.rm = T)
}

write.table(output,paste(wdir,"/result-compact.txt",sep=""),sep="\t",dec=".",quote=F,row.names = F)
