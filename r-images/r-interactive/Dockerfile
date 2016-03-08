# Recipe from this blog post:
# https://blog.jessfraz.com/post/R-containers-for-data-science/
# http://r-pkgs.had.co.nz/intro.html

FROM r-base:3.2.3

COPY scripts/setup-apt.sh /usr/local/bin/r-interactive-docker-setup-1
COPY scripts/setup-Rlibs.sh /usr/local/bin/r-interactive-docker-setup-2

ADD https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar /usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar
ADD https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar /usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar

RUN /usr/local/bin/r-interactive-docker-setup-1
RUN /usr/local/bin/r-interactive-docker-setup-2

ENV HOME=/home/docker \
    COMPUTE_IN=/data/in \
    COMPUTE_OUT=/data/out \
    COMPUTE_TMP=/tmp \
    SRC=/src

WORKDIR $HOME/data
USER docker

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
