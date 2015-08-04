# Recipe from this blog post:
# https://blog.jessfraz.com/post/R-containers-for-data-science/
# http://r-pkgs.had.co.nz/intro.html

# our R base image
FROM registry.federation.mip.hbp/hbp/r-database-mass

RUN apt-get update && apt-get install -y curl=7.38.0-4+deb8u2 git \
    && apt-get clean \
    && echo -n > /var/lib/apt/extended_states \
	&& rm -rf /var/lib/apt/lists/*

# install packages
# these are ones I like
RUN install2.r --error devtools roxygen2 testthat knitr rstudioapi ggplot2 plyr reshape2 RColorBrewer scales grid wesanderson \
  && echo 'devtools::install_github("hadley/devtools")' >> /tmp/packages.R \
  && Rscript /tmp/packages.R \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# create an R user
ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
    && chown -R user:user $HOME

WORKDIR $HOME
USER user

# set the command
CMD ["R"]
