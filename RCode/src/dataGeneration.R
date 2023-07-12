#Data Generation
M <- 1

N <- 200
m <- 100
T <- 180

stdv <- 0.05
theta_w <- 0.02
stde <- 0.05

rho <- runif(m, 0.9, 1) #random numbers from a uniform distribution
c <- matrix(0, nrow=N*T, ncol=m) # 36000 (N*T), 100 # 
print(dim(c))
#######################
#######################

#1) Tengo una matrix llamada 'c' de (36000, 100) (N=200*T=180), (m=100)
#2) Tengo un vector 'rho' con numeros random desde una distribucion unifome con m (100) valores
#3) Hace un loop con el numero de columnas (m=100)
#4) Crea una matrix llamada 'x' de ceros con dimension (N=200, T=180)
#5) A la primera columna de la matrix 'x' le agrego un vector con números random de dimension N (N=200)
#6) Hace un loop desde 2 hasta T [2,T=180]
#7) En cada columna de 'x' (>1) se agrega un valor de rho multiplicado por la columna anterior de 'x' más
#   un vector de numeros aleatearos de N (200) valores con distribución normal multiplicado por la raiz cuadrada
#   de la diferencia de 1 menos el valor de rho al cuadrado
#8) Después a esa matrz 'x' se le agrega aplica una función que las rankea las variables por cada columna
#9) tx0 es la transpuesta de r multiplicado por 2 y dividido por N+1 (N=200) (No es parte del código original, creada para leer mejor el código)
#10) Se crea una matriz 'x1' con las mismas dimensiones que 'x', la cuál es la transpuesta de 'tx0' menos 1
#11) Se actualiza la columna 'i' con el vector de la transpuesta de 'x1'

#######################
#######################

#output x
for (i in 1:m) {
  x <- matrix(0, nrow=N, ncol=T)
  
  x[,1] <- rnorm(N, 0, 1) #vector with random numbers from a normal distribution
  
  for (t in 2:T) {
    x[,t] <- rho[i]*x[,t-1] + rnorm(N, 0, 1)*sqrt(1-rho[i]^2)
  }
  #print(x)
  r <- apply(x, 2, rank) #rank x
  
  tx0 <- t(r)*2/(N+1)

  x1 <- (t(tx0)-1)

  c[,i] <- as.vector(t(x1))
}

#######################
#######################

per <- rep(1:N,T)
time <- rep(1:T, each=N)
vt <- matrix(rnorm(3*T, 0, stdv), nrow=3, ncol=T)
beta <- c[,1:3]
betav <- rep(0,N*T)

#ouput betav
for (t in 1:T) {
  ind <- which(time==t)
  betav[ind] <- beta[ind,] %*% vt[,t]
}

#######################
#######################

y <- rep(0,T)
y[1] <- rnorm(1, 0, 1)
q <- 0.95

#output y
for (t in 2:T) {
  y[t] <- q*y[t-1] + rnorm(1, 0, 1)*sqrt(1-q^2)
}

#######################
#######################


cy <- c
for (t in 1:T) {
  ind <- which(time==t)
  cy[ind,] <- c[ind,] * y[t]
}


ep <- rt(5,N*T)*stde #generate random numbers according to the Student's t-distribution

### Model 1
theta <- c(1, 1, rep(0, m-2), 0, 0, 1, rep(0, m-3))*theta_w
r1 <- cbind(c, cy) %*% theta + betav + ep
rt <- cbind(c, cy) %*% theta

print(dim(r1))
#write.csv(cbind(c, cy), paste0(path, name2, '/c', M, '.csv'))
#write.csv(r1, paste0(path, name2, '/r1_', M, '.csv'))

print(M)
### Analysis ###
print(dim(c))
print(dim(cy))
print(length(theta))
print(dim(r1))
print(dim(rt))
print(dim(cbind(c, cy)))

#######################
#######################

#######################
#######################


### Model 2
z <- cbind(c, cy)
z[,1] <- c[,1]^2 * 2
z[,2] <- c[,1] * c[,2] * 1.5
z[,(m+3)] <- sign(cy[,3]) * 0.6

r1 <- z %*% theta + betav + ep

## write.csv(r1, paste0(path, name2, '/r2_', M, '.csv'))

### Analysis ###
print(dim(r1))


### Case Pc=50 ###

m <- 50

### Model 1
theta <- c(1, 1, rep(0, m-2), 0, 0, 1, rep(0, m-3))*theta_w
r1 <- cbind(c[,1:m], cy[,1:m]) %*% theta + betav + ep

##write.csv(cbind(c[,1:m], cy[,1:m]), paste0(path, name1, '/c', M, '.csv'))
##write.csv(r1, paste0(path, name1, '/r1_', M, '.csv'))

### Model 2
z <- cbind(c[,1:m], cy[,1:m])
z[,1] <- c[,1]^2 * 2
z[,2] <- c[,1] * c[,2] * 1.5
z[,(m+3)] <- sign(cy[,3]) * 0.6

r1 <- z %*% theta + betav + ep

## write.csv(r1, paste0(path, name1, '/r2_', M, '.csv'))

print(M)


a <- 1000
for (i in 1:30){
  a <- a*1.1
  a <- round(a,2)
  print(paste0(i," - ",a))
}
