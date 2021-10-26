########################################
########################################
#R project 1 Schuyler Louie
########################################
########################################
library(expm)

########################################
#1
########################################

#a
u <- runif(7)

#b
s <- sum(u)
P1 <- u/s
#sanity check, this should equal 1
sum(P1)

#c
P_rest <- c()
for (i in 1:6) {
  u_tmp <- runif(7)
  s_tmp <- sum(u_tmp)
  P_rest <- c(P_rest, u_tmp/s_tmp)
}
#sanity check this should equal 6
sum(P_rest)

#d

#turn into matrix

P <- matrix(c(P1,P_rest), nrow= 7, byrow = TRUE)

#another sanity check, this should be 1 for all rows
rowSums(P)

P %^% 5000


#e, subtracting pi's from LHS of SOE so I can use solve function
b <- c(rep(0,7), 1)
#here is where I subtract, call this matrix p_tmp
p_tmp <- rbind(t(P) - diag(7), rep(1,7))
pi_v <- solve(t(p_tmp)%*%p_tmp, t(p_tmp)%*%b)

#should sum to 1
sum(pi_v)


#e

#compare
print(pi_v)
print(P %^% 5000)

#Yes! my pi_v is equal to every row of P^5000.This is because the limit as n
#goes to infinity of P_ij^(n) is equal to pi_j. So as you raise P to higher
#and higher powers, every row will tend towards pi_v.


#f
X <- rep (NA, 10001)
X[1] <- 1

for (i in 2:10001) {
  prev <- X[i - 1]
  X[i] <- sample(c(1,2,3,4,5,6,7), size = 1, replace = TRUE, prob = P[c(1), ])
}

avg_time<- rep(NA, 7)
for (i in 1:7) {
  avg_time[i] = sum(X == i)/10001
}

print(avg_time)


#g
#just looping the above with 2:7 starting values

for (j in 2:7) {
  X <- rep (NA, 10001)
  X[1] <- j

  for (i in 2:10001) {
    prev <- X[i - 1]
    X[i] <- sample(c(1,2,3,4,5,6,7), size = 1, replace = TRUE, prob = P[c(1), ])
  }

  avg_time<- rep(NA, 7)
  for (i in 1:7) {
    avg_time[i] = sum(X == i)/10001
  }

  print(avg_time)
}

########################################
#2
########################################

#a

X <- rep(NA, 1001)
X[1] <- 0
for (i in 2:1001) {
  X[i] <- sample(c(X[i-1] + 1, X[i-1] - 1), 1, replace = TRUE, prob = c(0.5,0.5))
}

print(X[1:11])

#b
plot(1:1001, X, xlab = "Step", ylab = "State", col="blue")

#c
for (i in 2:1001) {
  if (X[i] == 0) {
    print(c("Returns to 0 at step ", i - 1))
    break
  }
}


#d, just looping 1000 times and appending the return time to vector mrt

mrt <- rep(NA,1000)

for (j in 1:1000){
  X <- rep(NA, 1001)
  X[1] <- 0

  for (i in 2:1001) {
    X[i] <- sample(c(X[i-1] + 1, X[i-1] - 1), 1, replace = TRUE, prob = c(0.5,0.5))
  }

  for (i in 2:1001) {
    if (X[i] == 0) {
      mrt[j] <- i
      break
    }
  }
}

#heres the histogram
hist(mrt)


#ALL DONE! :)
