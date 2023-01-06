library(ggplot2)
# set.seed(69)

# Main parameters
K <- c(1, 10, 100) # k values
n_1 <- n_2 <- n_3 <- 200 # initial number of workers

# Backend parameters
t_a <- 0.3 # start time
t_b <- 0.4 # end time
t_step <- 0.001 # timestep
oddness <- 30 # how radical the proposals are (i.e. the max. amount of workers that can get hired/fired per timestep)

# Misc
graph_step <- 10 # generate a health plot every nth timestep
Colors <- c("#aa55ff", "#ffaa00", "#ff007f") # colors
names(Colors) = K


health <- function(t, n) {
	return(exp(-(t^4 * n - 6*t)^2) / t^4 - 5)
}

choose <- function(delta_n, delta_health, k) {
	p <- runif(1,0,1)
	return((delta_n >= 0 & delta_health >= 0) | (delta_n <= 0 & p < exp(delta_n/k)))
}

get_results <- function(t, n, k, death) {
	delta_health <- health(t, n + proposal) - health(t, n)
	if (!(choose(proposal, delta_health, k)))
		proposal <- 0
	n <- n + proposal
	
	h <- health(t, n)
	if (h <= 0) {
		death <- m
		h <- 0
	} else {
		plot <<- plot + geom_point(aes(n, h, col=toString(k)), size=3) +
			annotate(geom="text", x=450, y=140, label=paste("step =", m))
	}
	
	return(c(proposal, h, death))
}


t <- t_a
m <- 1
death_1 <- death_2 <- death_3 <- runtime <- 2*(t_b - t_a) / t_step
stats_1 <- stats_2 <- stats_3 <- data.frame(n=rep(NA, runtime), delta_n=rep(NA, runtime), health=rep(NA, runtime), stringsAsFactors=FALSE)

while (t >= t_a) {
	plot <- ggplot() + xlim(c(0,500)) + xlab("Nº de Trabalhadores") + ylim(c(0,150)) + ylab("Rentabilidade") +
		stat_function(fun=health, args=list(t=t)) + labs(col="k") +
		scale_color_manual(values=Colors)
	
	proposal <- runif(1, -oddness, oddness)
	
	if (death_1 == runtime) {
		results <- get_results(t, n_1, K[1], death_1)

		stats_1[m, 1] <- n_1 <- n_1 + results[1]
		stats_1[m, 2] <- results[1]
		stats_1[m, 3] <- results[2]
		if (results[3] < death_1)
			death_1 <- results[3]
	} else {
		stats_1[m, ] <- list(0,NA,0)
	}
	
	if (death_2 == runtime) {
		results <- get_results(t, n_2, K[2], death_2)
		
		stats_2[m, 1] <- n_2 <- n_2 + results[1]
		stats_2[m, 2] <- results[1]
		stats_2[m, 3] <- results[2]
		if (results[3] < death_2)
			death_2 <- results[3]
	} else {
		stats_2[m, ] <- list(0,NA,0)
	}
	
	if (death_3 == runtime) {
		results <- get_results(t, n_3, K[3], death_3)

		stats_3[m, 1] <- n_3 <- n_3 + results[1]
		stats_3[m, 2] <- results[1]
		stats_3[m, 3] <- results[2]
		if (results[3] < death_3)
			death_3 <- results[3]
	} else {
		stats_3[m, ] <- list(0,NA,0)
	}
	
	
	if (all(c(death_1, death_2, death_3) != runtime))
		stop("Game over")
	
	if ((m - 1) %% graph_step == 0)
		ggsave(paste("plot", m, ".jpg", sep=""))
	m <- m + 1
	
	t <- t + t_step
	if (isTRUE(all.equal(t, t_b)))
		t_step <- -t_step
}

ggplot() + xlab("Fluxo de Trabalhadores") + ylab("Nº de Ocorrências") + xlim(c(-oddness, oddness)) +
	geom_histogram(aes(x=stats_1$delta_n), binwidth=1)
ggsave("fluxo_1.jpg")

ggplot() + xlab("Fluxo de Trabalhadores") + ylab("Nº de Ocorrências") + xlim(c(-oddness, oddness)) +
	geom_histogram(aes(x=stats_2$delta_n), binwidth=1)
ggsave("fluxo_2.jpg")

ggplot() + xlab("Fluxo de Trabalhadores") + ylab("Nº de Ocorrências") + xlim(c(-oddness, oddness)) +
	geom_histogram(aes(x=stats_3$delta_n), binwidth=1)
ggsave("fluxo_3.jpg")

ggplot() + labs(col = "k") + xlab("Tempo") + ylab("Emprego Marginal") +
	xlim(c(0,min(death_1, death_2, death_3))) + ylim(c(-oddness, oddness)) +
	geom_line(aes(x=as.numeric(row.names(stats_1)), y=stats_1$delta_n, col=toString(K[1]))) +
	geom_line(aes(x=as.numeric(row.names(stats_2)), y=stats_2$delta_n, col=toString(K[2]))) +
	geom_line(aes(x=as.numeric(row.names(stats_3)), y=stats_3$delta_n, col=toString(K[3]))) +
	scale_color_manual(values=Colors)
ggsave("emprego.jpg")

ggplot() + labs(col = "k") + xlab("Tempo") + ylab("Nº de Trabalhadores") +
	geom_line(data=stats_1, aes(x=as.numeric(row.names(stats_1)), y=n, col=toString(K[1]))) +
	geom_line(data=stats_2, aes(x=as.numeric(row.names(stats_2)), y=n, col=toString(K[2]))) +
	geom_line(data=stats_3, aes(x=as.numeric(row.names(stats_3)), y=n, col=toString(K[3]))) + scale_color_manual(values=Colors)
ggsave("trabalhadores.jpg")

ggplot() + labs(col = "k") + xlab("Tempo") + ylab("Rentabilidade") +
	geom_line(data=stats_1, aes(x=as.numeric(row.names(stats_1)), y=health, col=toString(K[1]))) +
	geom_line(data=stats_2, aes(x=as.numeric(row.names(stats_2)), y=health, col=toString(K[2]))) +
	geom_line(data=stats_3, aes(x=as.numeric(row.names(stats_3)), y=health, col=toString(K[3]))) + scale_color_manual(values=Colors)
ggsave("rentabilidade.jpg")

d <- data.frame(k=paste(unlist(K)), lifespan=c(death_1, death_2, death_3))
ggplot(d, aes(x=k, y=lifespan, label=lifespan, fill=k)) + xlab("k") + ylab("Iterações Sobrevividas") +
	geom_bar(stat="identity") +
	geom_text(size = 9) +
	scale_fill_manual(values=Colors)
ggsave("vida.jpg")
