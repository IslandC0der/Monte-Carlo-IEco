library(ggplot2)

# Flexibility constants
k_a <- 10 
k_b <- 1
k_c <- 100

# Other parameters
n_a <- n_b <- n_c <- 200 # initial number of workers
threshold <- 5 # how low the health can go before the company goes bankrupt
graph_step <- 4 # when to save the graph

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


t <- t_a
p <- 0
a_alive <- b_alive <- c_alive <- TRUE
while (t >= t_a) {
	plot <- ggplot() + xlim(c(0,500)) + xlab("n") + ylim(c(0,150)) + ylab("Health") +
		stat_function(fun = health, args = list(t = t)) + labs(col = "Empresa") 
	
	proposal <- runif(1, -oddness, oddness)
	
	if (a_alive) {
		delta_health_a <- health(t, n_a + proposal) - health(t, n_a)
		if (choice(proposal, delta_health_a, k_a))
			n_a <- n_a + proposal
		if (health(t, n_a) < threshold) {
			a_alive <- FALSE
		} else {
			plot <- plot + geom_point(aes(n_a, health(t, n_a), col = "A"))
		}
	}
	
	if (b_alive) {
		delta_health_b <- health(t, n_b + proposal) - health(t, n_b)
		if (choice(proposal, delta_health_b, k_b))
			n_b <- n_b + proposal
		if (health(t, n_b) < threshold) {
			b_alive <- FALSE
		} else {
			plot <- plot + geom_point(aes(n_b, health(t, n_b), col = "B"))
		}
	}
	
	if (c_alive) {
		delta_health_c <- health(t, n_c + proposal) - health(t, n_c)
		if (choice(proposal, delta_health_c, k_c))
			n_c <- n_c + proposal
		if (health(t, n_c) < threshold) {
			c_alive <- FALSE
		} else {
			plot <- plot + geom_point(aes(n_c, health(t, n_c), col = "C"))
		}
	}
	
	if (!(a_alive | b_alive | c_alive))
		stop("Dead")
	
	if (p %% graph_step == 0)
		ggsave(paste("plot", p, ".jpg", sep=""))
	p <- p + 1
	t <- t + t_step
	
	if (isTRUE(all.equal(t, t_b)))
		t_step <- -t_step
}
