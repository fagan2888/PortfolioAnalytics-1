# example Sortino Ratio and related portfolio methods
# 
# Author: Brian G. Peterson
###############################################################################

## Load the necessary packages
# Include optimizer and multi-core packages
library(PortfolioAnalytics)
library(PerformanceAnalytics)
require(xts)
require(DEoptim)
require(TTR)


#note: these may not be appropriate on Windows
require(doMC)
registerDoMC()
# for Windows
#require(doParallel)
#registerDoParallel()


### Load the data
# Monthly total returns of four asset-class indexes
data(indexes)
#only look at 2000 onward
#indexes<-indexes["2000::"]


# parameter MAR
MAR =.005 #~6%/year

#'# Example 1 maximize Sortino Ratio
SortinoConstr <- constraint(assets = colnames(indexes[,1:4]), min = 0.05, max = 1, min_sum=.99, max_sum=1.01, weight_seq = generatesequence(by=.001))
SortinoConstr <- add.objective(constraints=SortinoConstr, type="return", name="SortinoRatio",  enabled=TRUE, arguments = list(MAR=MAR))
SortinoConstr <- add.objective(constraints=SortinoConstr, type="return", name="mean",  enabled=TRUE, multiplier=0) # multiplier 0 makes it availble for plotting, but not affect optimization

### Use random portfolio engine
SortinoResult<-optimize.portfolio(R=indexes[,1:4], constraints=SortinoConstr, optimize_method='random', search_size=2000, trace=TRUE, verbose=TRUE)
plot(SortinoResult, risk.col='SortinoRatio')

### alternately, Use DEoptim engine
#SortinoResultDE<-optimize.portfolio(R=indexes[,1:4], constraints=SortinoConstr, optimize_method='DEoptim', search_size=2000, trace=TRUE, verbose=FALSE,strategy=6, parallel=TRUE) #itermax=55, CR=0.99, F=0.5,
#plot(SortinoResultDE, risk.col='SortinoRatio')

### now rebalance quarterly
SortinoRebalance <- optimize.portfolio.rebalancing(R=indexes[,1:4], constraints=SortinoConstr, optimize_method="random", trace=TRUE, rebalance_on='quarters', trailing_periods=NULL, training_period=36, search_size=2000)

###############################################################################
# R (http://r-project.org/) Numeric Methods for Optimization of Portfolios
#
# Copyright (c) 2004-2010 Kris Boudt, Peter Carl and Brian G. Peterson
#
# This library is distributed under the terms of the GNU Public License (GPL)
# for full details see the file COPYING
#
# $Id$
#
###############################################################################