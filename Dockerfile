FROM rocker/shiny-verse:3.6.3

RUN apt-get update && \
    apt-get install \
        libcurl4-openssl-dev \
	libudunits2-dev \
	libgdal-dev -y && \
    mkdir -p /var/lib/shiny-server/bookmarks/shiny

# Download and install library
RUN Rscript -e "install.packages(c('tmaptools', 'sf', 'units', 'raster', 'classInt', 'leaflet', 'mapview', 'scales','spData', 'leafsync', 'tmap'))" 

# copy the app to the image
COPY corona /srv/shiny-server/

# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /srv/shiny-server/

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"] 
