library(ggplot2)
set.seed(69)

# Flexibility constants
k_1 <- 1
k_2 <- 10
k_3 <- 100

# Other parameters
n_1 <- n_2 <- n_3 <- 200 # initial number of workers
threshold <- 5 # how low the health can go before the company goes bankrupt
graph_step <- 4000 # when to save the graph

# Backend parameters (don't touch!)
t_a <- 0.3 # start time
t_b <- 0.4 # end time
t_step <- 0.001 # timestep
oddness <- 30 # how radical the proposals are (i.e. the max. amount of workers that can get hired/fired per timestep)


health <- function(t, n) {
	return(exp(-(t^4 * n - 6*t)^2) / t^4)
}

choice <- function(delta_n, delta_health, k) {
	p <- runif(1,0,1)
	return((delta_n >= 0 && delta_health >= 0) | (delta_n <= 0 && p < exp(delta_n/k)))
}

engine <- function(t, n, k, alive) {
	delta_health <- health(t, n + proposal) - health(t, n)
	if (!(choice(proposal, delta_health, k)))
		proposal <- 0
	n <- n + proposal
	
	h <- health(t, n)
	if (h < threshold) {
		alive <- FALSE
		h <- 0
	} else {
		plot <<- plot + geom_point(aes(n, h, col = paste(k, "thatchers")))
	}
	
	return(list(proposal, h, alive))
}


t <- t_a
p <- 1
alive_1 <- alive_2 <- alive_3 <- TRUE
rows <- (t_b - t_a) / t_step
stats_1 <- stats_2 <- stats_3 <- data.frame(n=rep(NA, rows), delta_n=rep(NA, rows), health=rep(NA, rows), stringsAsFactors=FALSE)

while (t >= t_a) {
	plot <- ggplot() + xlim(c(0,500)) + xlab("Nº de trabalhadores") + ylim(c(0,150)) + ylab("Receita") +
		stat_function(fun = health, args = list(t = t)) + labs(col = "Austeridade") + scale_color_manual(values=c("red", "green", "blue"))
	
	proposal <- runif(1, -oddness, oddness)
	
	if (alive_1) {
		e1 <- engine(t, n_1, k_1, alive_1)

		stats_1[p, 1] <- n_1 <- n_1 + e1[[1]]
		stats_1[p, 2] <- e1[[1]]
		stats_1[p, 3] <- e1[[2]]
		alive_1 <- e1[[3]]
	} else {
		stats_1[p, ] <- list(0,NA,0)
	}
	
	if (alive_2) {
		e2 <- engine(t, n_2, k_2, alive_2)
		
		stats_2[p, 1] <- n_2 <- n_2 + e2[[1]]
		stats_2[p, 2] <- e2[[1]]
		stats_2[p, 3] <- e2[[2]]
		alive_2 <- e2[[3]]
	} else {
		stats_2[p, ] <- list(0,NA,0)
	}
	
	if (alive_3) {
		e3 <- engine(t, n_3, k_3, alive_3)

		stats_3[p, 1] <- n_3 <- n_3 + e3[[1]]
		stats_3[p, 2] <- e3[[1]]
		stats_3[p, 3] <- e3[[2]]
		alive_3 <- e3[[3]]
	} else {
		stats_3[p, ] <- list(0,NA,0)
	}
	
	
	if (!(alive_1 | alive_2 | alive_3))
		stop("Game over")
	
	if (p %% graph_step == 0)
		ggsave(paste("plot", p, ".jpg", sep=""))
	p <- p + 1
	
	t <- t + t_step
	if (isTRUE(all.equal(t, t_b)))
		t_step <- -t_step
}


ggplot() + xlab("Worker flux") + ylab("N") + xlim(c(-oddness, oddness)) + ylim(c(0,p)) + 
	geom_histogram(aes(stats_1$delta_n), binwidth=1)
ggsave("hist_1.jpg")

ggplot() + xlab("Worker flux") + ylab("N") + xlim(c(-oddness, oddness)) + ylim(c(0,p)) + 
	geom_histogram(aes(stats_2$delta_n), binwidth=1)
ggsave("hist_2.jpg")

ggplot() + xlab("Worker flux") + ylab("N") + xlim(c(-oddness, oddness)) + ylim(c(0,p)) +
	geom_histogram(aes(stats_3$delta_n), binwidth=1)
ggsave("hist_3.jpg")

ggplot() + labs(col = "k") + xlab("Time") + ylab("Health") +
	geom_line(data=stats_1, aes(x=as.numeric(row.names(stats_1)), y=health, col=toString(k_1))) +
	geom_line(data=stats_2, aes(x=as.numeric(row.names(stats_2)), y=health, col=toString(k_2))) +
	geom_line(data=stats_3, aes(x=as.numeric(row.names(stats_3)), y=health, col=toString(k_3))) + scale_color_manual(values=c("red", "green", "blue"))
ggsave("health.jpg")

ggplot() + labs(col = "k") + xlab("Time") + ylab("Workers") +
	geom_line(data=stats_1, aes(x=as.numeric(row.names(stats_1)), y=n, col=toString(k_1))) +
	geom_line(data=stats_2, aes(x=as.numeric(row.names(stats_2)), y=n, col=toString(k_2))) +
	geom_line(data=stats_3, aes(x=as.numeric(row.names(stats_3)), y=n, col=toString(k_3))) + scale_color_manual(values=c("red", "green", "blue"))
ggsave("workers.jpg")
