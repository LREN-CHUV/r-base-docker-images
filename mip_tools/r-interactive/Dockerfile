# Recipe from this blog post:
# https://blog.jessfraz.com/post/R-containers-for-data-science/
# http://r-pkgs.had.co.nz/intro.html

# our R base image
FROM registry.federation.mip.hbp/mip_base/r-database

# Fix the versions to ensure reproducible builds.
RUN apt-get update && apt-get install -y --force-yes \
        curl=7.38.0-4+deb8u2 \
        libcurl3=7.38.0-4+deb8u2 \
        libcurl4-openssl-dev=7.38.0-4+deb8u2 \
        r-base-dev \
        gcc=4:5.2.1-4 \
        cpp=4:5.2.1-4 \
        gfortran=4:5.2.1-4 \
        git \
        openssl \
        libssl-dev \
        libxml2-dev \
        pandoc \
        texinfo \
        texlive-base \
        texlive-extra-utils \
        texlive-fonts-extra \
        texlive-fonts-recommended \
        texlive-generic-recommended \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
        subversion \
        git \
    && apt-get clean \
    && echo -n > /var/lib/apt/extended_states \
	&& rm -rf /var/lib/apt/lists/*

# install packages
# these are ones I like
RUN install2.r --error devtools roxygen2 testthat knitr rmarkdown rstudioapi ggplot2 plyr reshape2 RColorBrewer scales gridBase wesanderson \
                       formatR lintr sjPlot jsonlite \
  && echo 'devtools::install_github("hadley/devtools")' >> /tmp/packages.R \
  && Rscript /tmp/packages.R \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

ENV HOME /home/docker

WORKDIR $HOME/data
USER docker

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
