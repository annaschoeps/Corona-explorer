FROM rocker/shiny-verse:3.5.1

RUN apt-get update && apt-get install libcurl4-openssl-dev libv8-3.14-dev -y &&\
  mkdir -p /var/lib/shiny-server/bookmarks/shiny

# Download and install library
RUN R -e "install.packages(c('plyr','plotly','scales','maps','rworldmap','sf','raster','spData','leaflet','tmap','tmaptools'))"

# copy the app to the image
COPY corona /srv/shiny-server/
# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /srv/shiny-server/

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"] 
