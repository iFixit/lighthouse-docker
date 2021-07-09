# Sys.setenv(RENV_PATHS_CACHE = "~/.rpkgcache")


setwd("~")
library(tidyverse)
library(magrittr)
devtools::install_local("./webperf/", upgrade="never")
library(webperf)

# Change the following directory to switch to your results directory
setwd("results/")

# Change the vector of `www` and `dev` below to have all the prefix names from
# your lighthouse run.
specs <- webperf::read_lighthouse_json(c("www", "dev"), 3)

# Analyze key performance metrics
specs %>% webperf::analyze_change(largestContentfulPaint)
specs %>% webperf::analyze_change(cumulativeLayoutShift)
specs %>% webperf::analyze_change(totalBlockingTime)

# Show most interesting statistics
specs %>%
  pivot_longer(firstContentfulPaint:observedSpeedIndexTs) %>%
  ggplot(aes(env, value)) +
    facet_wrap(vars(name), scales="free") +
    geom_boxplot() +
    expand_limits(y=0)

# Demo of grabbing network performance information out of the results
img_transfers <- specs %>% 
  unnest(network) %>%
  unnest_wider(value) %>%
  mutate(diff=endTime-startTime)

# Frame visualization
frames <- specs %>% 
  unnest(frames) %>%
  unnest_wider(value)
