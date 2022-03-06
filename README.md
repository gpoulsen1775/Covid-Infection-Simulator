# Covid-Infection-Simulator
A covid infection simulator I came up with for an upper level mathematical modeling class. My model involved N infective individuals emitting aerosolized virions at a constant rate with a single uninfected agent in the room. The aerosolized virions underwent brownian motion. When aerosolized virions collided with the uninfected agent, their virion count grew. After an estimated infectious threshold, the agent was considered infected. Two processes for obtaining a solution to the agent's chance of contracting Covid were implemented. One process was based off of statistical sampling and the other was probabilistic modeling.

PofIPs: A file that calculated the probability of infection using Poisson modeling.
PofISt: A file that calculated the probability of infecgtion using statistical sampling. 
RWA: A file that conducted a random walk for infectous aerosols, this is the more scientifically accurate model. 
RWV: A file that conducted a random walk for virions, this is less scientifically correct as a model. 
testing: shows off the infecion simulator. 
