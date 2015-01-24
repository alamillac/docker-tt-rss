#!/bin/bash
set -e

CONFIG_FILE=/etc/tt-rss/config.php
DATABASE_FILE=/etc/tt-rss/database.php
DUMPMYSQL=/usr/share/tt-rss/schema/ttrss_schema_mysql.sql

#validaciones de variables
echo "validando variables"
MYSQLPORT=$DB_PORT_3306_TCP_PORT
MYSQLHOST=$DB_PORT_3306_TCP_ADDR
MYSQLUSER=$DB_ENV_MYSQL_USER
MYSQLUSERPASSWD=$DB_ENV_MYSQL_PASSWORD
MYSQLDB=$DB_ENV_MYSQL_DATABASE
[ -n "$DOMAIN" ] && [ -n "$MYSQLUSER" ] && [ -n "$MYSQLHOST" ] && [ -n "$MYSQLUSERPASSWD" ] && [ -n "$MYSQLDB" ] && [ -n "$MYSQLPORT" ]

echo "modificando archivo de configuracion"
sed -i "s/<<<MYSQLUSER>>>/$MYSQLUSER/" "$DATABASE_FILE"
sed -i "s/<<<MYSQLHOST>>>/$MYSQLHOST/" "$DATABASE_FILE"
sed -i "s/<<<MYSQLUSERPASSWD>>>/$MYSQLUSERPASSWD/" "$DATABASE_FILE"
sed -i "s/<<<MYSQLDB>>>/$MYSQLDB/" "$DATABASE_FILE"
sed -i "s/<<<MYSQLPORT>>>/$MYSQLPORT/" "$DATABASE_FILE"
sed -i "s/<<<DOMAIN>>/$DOMAIN/" "$CONFIG_FILE"

echo "Creando la base de datos para el usuario ttrss"
mysql -h $MYSQLHOST -u $MYSQLUSER "-p$MYSQLUSERPASSWD" -P $MYSQLPORT $MYSQLDB < "$DUMPMYSQL" || true

exec supervisord -n
