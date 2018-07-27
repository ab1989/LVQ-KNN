#Hilfsprogramme

#Berechnung des euklidischen Abstandes zwischen p und q
d <- function(p,q){
    return(sqrt(t(p-q)%*%(p-q)))
    #return(t(p-q)%*%(p-q))
    #return(sum(abs(p-q)))
}

#Naechster Nachbar von x bzgl der Prototypen inp berechnen
NN <- function(x,inp){
    n <- nrow(inp) #Anzahl der Prototypen
    dis <- rep(0,n) #Speichern der Abstaende von x zu den Prototypen
    anzv <- length(x)
    
    for(i in 1:n){
        dis[i] <- d(as.numeric(x[1:(anzv)]),as.numeric(inp[i,]))
    }
    return(which.min(dis))
}

#Lernrate des LVQ-Algorithmus - muss monoton fallend sein
alpha <- function(t){
    return(1/(4*(t^2)))
}

#Schaut ob grep als Ausgabe "integer(empty)" hat oder tatsaechlich etwas findet
is.int <- function(x){
    is.integer(x)&&length(x)==0L
}

anzProto <- function(dataframe,maxProto){ #gibt entweder maxProto oder Anzahl der Objekte pro Klasse aus
    anzv <- ncol(dataframe)
    kla <- length(unique(dataframe[,anzv]))
    anz <- a <- rep(0,kla)
    for(i in 1:kla){
        anz[i] <- length(dataframe[which(i==dataframe[,anzv]),anzv])
        if(anz[i] < maxProto){
            a[i] <- anz[i]
        }else{
            a[i] <- maxProto
        }
    }
    return(a)
}

#Naechste Nachbar Klassifizierung mit Ausgabe von min-Abstand und Indize des nnPrototypen
nn_with_dist <- function(x,inp){
    n <- nrow(inp) #Anzahl der Prototypen
    dis <- rep(0,(n+1)) #Speichern der Abstaende von x zu den Prototypen
    anzv <- length(x)
    
    for(i in 1:n){
        dis[i] <- d(as.numeric(x[1:(anzv)]),as.numeric(inp[i,]))
    }
    dis[n+1] <- which.min(dis[1:n])
    return(dis)
}
