# Recipe from this blog post:
# https://blog.jessfraz.com/post/R-containers-for-data-science/
# http://r-pkgs.had.co.nz/intro.html

FROM r-base:3.2.3

COPY scripts/setup.sh /usr/local/bin/r-interactive-docker-setup

ADD https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar /usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar
ADD https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar /usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar
RUN wget --http-user guest --http-password guest -O /usr/lib/R/libraries/denodo-vdp-jdbcdriver.jar http://hbps1.chuv.ch/community/share/_IT-tools/federation/drivers/vdp-jdbcdriver-core/denodo-vdp-jdbcdriver.jar

RUN /usr/local/bin/r-interactive-docker-setup

ENV HOME /home/docker

WORKDIR $HOME/data
USER docker

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
