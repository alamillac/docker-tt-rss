# tt-rss
#
# VERSION               0.0.1

FROM     ubuntu:14.04
MAINTAINER Andres F. Lamilla, "alamilla@gmail.com"

# se actualiza la base de datos de apt
RUN apt-get update -qq

# instalacion de la base de datos para la app
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor mysql-client tt-rss apache2 libapache2-mod-php5 php5-mysql

# se adicionan los archivos template de configuracion
ADD src/apache2.sv.conf /etc/supervisor/conf.d/apache2.sv.conf
ADD src/config.php /etc/tt-rss/config.php
ADD src/database.php /etc/tt-rss/database.php
ADD src/run.sh /usr/local/bin/run.sh
ADD src/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/*.sh

# Se elimina la pagina por defecto
RUN rm /etc/apache2/sites-enabled/*
RUN rm -rf /var/www/

# se crea enlace simbolico a la config de apache
#RUN ln -s /etc/apache2/conf-available/50-tt-rss.conf /etc/apache2/conf-enabled/
ADD src/tt-rss.virtualhost.conf /etc/apache2/sites-enabled/tt-rss

EXPOSE 80
CMD ["/usr/local/bin/run.sh"]
