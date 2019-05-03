# disaggregator
This is an algorithm for the non-intrusive disaggregation of energy consumption into its end-uses, also known as non-intrusive appliance load monitoring (NIALM). 
The algorithm solves an optimisation problem where the objective is to minimise the error between the total energy consumption and the sum of the individual contributions of each appliance. The algorithm assumes that a fraction of the loads present  in the household is known (e.g. washing machine, dishwasher, etc.),  but it also considers unknown loads, treating them as a single load.
