# Recipe from this blog post:
# https://blog.jessfraz.com/post/R-containers-for-data-science/
# http://r-pkgs.had.co.nz/intro.html

# our R base image
FROM registry.federation.mip.hbp/hbp/r-database-mass

RUN apt-get update && apt-get install -y --force-yes \
        curl=7.38.0-4+deb8u2 \
        libcurl3=7.38.0-4+deb8u2 \
        libcurl4-openssl-dev=7.38.0-4+deb8u2 \
        git \
        openssl \
        libssl-dev \
        libxml2-dev \
        pandoc \
    && apt-get clean \
    && echo -n > /var/lib/apt/extended_states \
	&& rm -rf /var/lib/apt/lists/*

# install packages
# these are ones I like
RUN install2.r --error devtools roxygen2 testthat knitr rmarkdown rstudioapi ggplot2 plyr reshape2 RColorBrewer scales gridBase wesanderson \
                       formatR lintr \
  && echo 'devtools::install_github("hadley/devtools")' >> /tmp/packages.R \
  && Rscript /tmp/packages.R \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

ENV HOME /home/docker

WORKDIR $HOME
USER docker

# set the command
ENTRYPOINT ["R"]
