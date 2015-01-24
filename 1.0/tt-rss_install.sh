#!/bin/bash

error()
{
    echo Error: $@ >&2
    exit 1
}

warninig()
{
    echo Warning: $@ >&2
}

info()
{
    echo Info: $@
}

BASE_DIR=/tmp
CONFIG_FILE=${BASE_DIR}/config.php
DUMPMYSQL=${BASE_DIR}/ttrss.sql

info "Inicio configuracion tt-rss"
info "Relizando validaciones de requisitos"
#todo validar archivos y variables de entorno
#validacion archivos
[ -w "$CONFIG_FILE" ] && [ -r "$DUMPMYSQL" ] || error "no estan presentes todos los archivos en $BASE_DIR"

#validaciones de variables
[ -n "$DOMAIN" ] && [ -n "$MYSQLHOST" ] && [ -n "$MYSQLROOTPASSWD" ] && [ -n "$MYSQLHOST" ] && [ -n "$MYSQLUSERPASSWD" ] || error "no fueron suministradas todas la variables"

info "modificando archivo de configuracion"
sed -i "s/<<<MYSQLHOST>>>/$MYSQLHOST/" "$CONFIG_FILE" &&
sed -i "s/<<<MYSQLUSERPASSWD>>>/$MYSQLUSERPASSWD/" "$CONFIG_FILE" &&
sed -i "s/<<<DOMAIN>>/$DOMAIN/" "$CONFIG_FILE" || error "Al modificar el archivo de configuracion"

info "instalando mysql client"
apt-get install mysql-client || error "No se pudo instalar mysql-client"

info "Descargando archivos de instalacion y moviendolos al path /usr/local/lib/"
wget https://github.com/gothfox/Tiny-Tiny-RSS/archive/1.12.tar.gz || error "No se pudo descargar el archivo"
tar xzvf 1.12.tar.gz && rm 1.12.tar.gz || error "Descomprimiendo archivo"
mv Tiny-Tiny-RSS-1.12 tt-rss &&
chown -R root:root tt-rss/ &&
mv tt-rss/ /usr/local/lib/ &&
echo "Alias /tt-rss /usr/local/lib/tt-rss" | sudo tee /etc/apache2/conf.d/tt-rss.local &&
mv "$CONFIG_FILE" /usr/local/lib/tt-rss/ &&
chown www-data /usr/local/lib/tt-rss &&
chown -R www-data:www-data /usr/local/lib/tt-rss/cache &&
chown -R www-data:www-data /usr/local/lib/tt-rss/lock &&
chown -R www-data:www-data /usr/local/lib/tt-rss/feed-icons || error "moviendo el directorio a /usr/local/lib"

info "Creando el usuario ttrss dentro de la base de datos"
echo "CREATE USER ttrss@$MYSQLHOST IDENTIFIED BY '$MYSQLUSERPASSWD';
CREATE DATABASE ttrss;
GRANT all ON ttrss.* TO ttrss;" | mysql -u root -p "$MYSQLROOTPASSWD" || warninig "no se pudo crear el usuario"

info "Creando la base de datos para el usuario ttrss"
mysql -h $MYSQLHOST -u ttrss -p "$MYSQLUSERPASSWD" ttrss < "$DUMPMYSQL" || error "no se pudo crear la base de datos"

info "Creando usuario ttrss en el sistema"
addgroup --quiet --system ttrss || error "en la creacion del usuario"
adduser --quiet --system --ingroup ttrss --no-create-home --disabled-password ttrss || error "en la creacion del usuario"

info "Ajustando permisos en los directorios"
chown -R ttrss /usr/local/lib/tt-rss/cache &&
chown -R ttrss /usr/local/lib/tt-rss/feed-icons &&
chown -R ttrss /usr/local/lib/tt-rss/lock || error "al ajustar los permisos"
