#Data Generation

#######################
#######################

#1) M definida como Monthly 
#2) N es ...
#3) m es ...
#4) T es...
#5) stdv es desviación estandar 
#6) theta_w es ...
#7) stde es ...

#######################
#######################
M <- 1
N <- 200
m <- 100
T <- 180

stdv <- 0.05
theta_w <- 0.02
stde <- 0.05
#######################
#######################
#1) 'rho' is a vector from a random numbers from a uniform distribution
#2) 'c' es una matriz de ceros
#3) Tengo una matrix llamada 'c' de (36000, 100) (N=200*T=180), (m=100)
#4) Tengo un vector 'rho' con numeros random desde una distribucion unifome con m (100) valores
#5) Hace un loop con el numero de columnas (m=100)
#6) Crea una matrix llamada 'x' de ceros con dimension (N=200, T=180)
#7) A la primera columna de la matrix 'x' le agrego un vector con números random de dimension N (N=200)
#8) Hace un loop desde 2 hasta T [2,T=180]
#9) En cada columna de 'x' (>1) se agrega un valor de rho multiplicado por la columna anterior de 'x' más
#   un vector de numeros aleatearos de N (200) valores con distribución normal multiplicado por la raiz cuadrada
#   de la diferencia de 1 menos el valor de rho al cuadrado
#10) Después a esa matrz 'x' se le agrega aplica una función que las rankea las variables por cada columna
#11) tx0 es la transpuesta de r multiplicado por 2 y dividido por N+1 (N=200) (No es parte del código original, creada para leer mejor el código)
#12) Se crea una matriz 'x1' con las mismas dimensiones que 'x', la cuál es la transpuesta de 'tx0' menos 1
#13) Se actualiza la columna 'i' con el vector de la transpuesta de 'x1'

#######################
#######################
rho <- runif(m, 0.9, 1) #random numbers from a uniform distribution
c <- matrix(0, nrow=N*T, ncol=m) # 36000 (N*T), 100 # 

for (i in 1:m) {
  x <- matrix(0, nrow=N, ncol=T)
  x[,1] <- rnorm(N, 0, 1) #vector with random numbers from a normal distribution
  
  for (t in 2:T) {
    x[,t] <- rho[i]*x[,t-1] + rnorm(N, 0, 1)*sqrt(1-rho[i]^2)
  }
  r <- apply(x, 2, rank) #rank x
  tx0 <- t(r)*2/(N+1)
  x1 <- (t(tx0)-1)
  c[,i] <- as.vector(t(x1))
}

#######################
#######################
#1) 'per' is a vector of to repeat T (180) times a sequence from 1 to N (200)
#2) 'time' is a vector that repeats each number N (200) times from 1 to T (180)
#3) 'vt' with 3 rows and T (180) columns of random numbers from a normal distribution
#4) 'beta' is a sample that takes the first 3 columns of matrix 'c'
#5) 'betav' is a repetition of zeros N*T (200*180=36000) times.
#6) loop from 1 to T (180) with loop variable 't'
#7) 'ind' returns the index from vector 'time' of those values equal to 't'
#8) Then those values from 'betav' corresponding to the index 'ind' are equal to 
#   the matrix multiplication of 'beta' rows equal to 'ind' with the 'vt' columns 
#   equals to 't'

#######################
#######################
per <- rep(1:N,T)
time <- rep(1:T, each=N)
vt <- matrix(rnorm(3*T, 0, stdv), nrow=3, ncol=T)
beta <- c[,1:3]
betav <- rep(0,N*T)

for (t in 1:T) {
  ind <- which(time==t)
  betav[ind] <- beta[ind,] %*% vt[,t]
}

#######################
#######################

#1) 'y' is vector that repeats 0 T (180) times
#2) 'y[1]' replaces the first element of the 'y' vector with a random number 
#   drawn from a standard normal distribution.
#3) 'q' is assigned with the value 0.95 
#4) loop from 2 to T(180)
#5) each loops updates the t-th element of the vector 'y' based on the multiplication
#   of 'q' and the t-th - 1 element of the vector 'y' plus a a single random number 
#   from a standard normal distribution multiply by multiplies it by the square root 
#   of (1-q^2)

y <- rep(0,T)
y[1] <- rnorm(1, 0, 1)
q <- 0.95

for (t in 2:T) {
  y[t] <- q*y[t-1] + rnorm(1, 0, 1)*sqrt(1-q^2)
}

#######################
#######################
#1) 'cy' is a copy of 'c'
#2) loop from 1 to T(180)
#3) 'ind' returns the index from vector 'time' of those values equal to 't'
#4) each row equal to 'ind' is updated by its value multiply by the t-th 
#   element of y
#5) 'ep' is a vector with a random variable following a Student's t-distribution 
#   with N*T (200*180) values and 5 degrees of freedom.
#   then it's being scaled by stde (0.05).
#######################
#######################
cy <- c
for (t in 1:T) {
  ind <- which(time==t)
  cy[ind,] <- c[ind,] * y[t]
}
ep <- rt(5,N*T)*stde

#######################
#######################
#1) 'theta' is a vector with a specific pattern first two elements are 1 then the 
#   following are a repetition of zeros m-2 times (98), then two more zeros, then 
#   one 1 and then again a repetion of zeros m-2 times (97).
#   then all the vector is multiplied by theta_w(0.02)
#2) 'r1' is a linear combination of the columns of c and cy (already merged), 
#   with weights given by 'theta', plus 'betav' and 'ep'.
#3) 'rt' is a linear combination of the columns of c and cy (already merged), 
#   with weights given by 'theta'.
#4) The combination of 'c' and 'cy' is save into a csv.
#5) Variable 'r1' is save into a csv.
#######################
#######################

### Model 1
theta <- c(1, 1, rep(0, m-2), 0, 0, 1, rep(0, m-3))*theta_w
r1 <- cbind(c, cy) %*% theta + betav + ep
rt <- cbind(c, cy) %*% theta

#write.csv(cbind(c, cy), paste0(path, name2, '/c', M, '.csv'))
#write.csv(r1, paste0(path, name2, '/r1_', M, '.csv'))


#######################
#######################
#1) 'z' is the combination of 'c' and 'cy'.
#2) the first column of 'z' is twice the square of the first column of c.
#3) the second column of 'z' to be 1.5 times the product of the first and 
#   second columns of c
#4) the m+3 (103) column of 'z' it is equal to 0.6 times by the sign 
#   (-1 or 1 if it is neg. or positive) of the third column of 'cy'
#5) 'r1' is linear combination of the columns of 'z' with 'theta', 'betav' 
#    and 'ep'.
#6) then 'r1' is save into a csv file.
#######################
#######################

### Model 2
z <- cbind(c, cy)
z[,1] <- c[,1]^2 * 2
z[,2] <- c[,1] * c[,2] * 1.5
z[,(m+3)] <- sign(cy[,3]) * 0.6

r1 <- z %*% theta + betav + ep

## write.csv(r1, paste0(path, name2, '/r2_', M, '.csv'))


#######################
#######################
#######################
#######################
### Analysis ###

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

