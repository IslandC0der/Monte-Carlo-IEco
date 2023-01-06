""" Very simple Monte Carlo simulation to illustrate the effect on a company of its (un)willingness to fire workers during a recession, using an adapted version of the Metropolis-Hastings algorithm """

import math, random

## Main parameters
k = 10 # k constant
n = 200 # initial number of workers

## Backend parameters
t_a = 0.3 # start time
t_b = 0.4 # end time
t_step = 0.001 # timestep
oddness = 30 # how radical the proposals are (i.e. the max. amount of workers that can get hired/fired per timestep)


def health(_t: float, _n: int) -> float:
	return math.exp(-(_t**4 * _n - 6*_t)**2)/_t**4 - 5
	# simple model for the finantial viability of a company during a recession as a function of the number of workers

def choose(_delta_n: int, _delta_health: float, _k: float) -> bool:
	p = random.random()
	return (_delta_n >= 0 and _delta_health >= 0) or (_delta_n <= 0 and p < math.exp(_delta_n/_k)) # Metropolis


t = t_a
while t >= t_a:
	print("t =", int(t*1000), "n =", n, "h(t,n) =", health(t, n))
	
	if health(t, n) < 0:
		raise ValueError("Dead")
	
	proposal = random.randint(-oddness, oddness)
	delta_health = health(t, n + proposal) - health(t, n)
	if choose(proposal, delta_health, k):
		n += proposal # if the proposal is accepted, enact it
	
	t += t_step
	
	if math.isclose(t, t_b):
		t_step = -t_step
		# the clock ticks backwards to emulate the recovery period after the recession ends
