#!/usr/bin/env bash
# Author: Ambroise Maupate
# Contributor: Maxime Constantinian

echo -e "\033[36m------------------ ROADIZ CMS -------------------\033[0m"
echo -e "\033[36m--------- New Roadiz website on `hostname` ------\033[0m"
echo -e "\033[36m-------------------------------------------------\033[0m"

APACHE_ROOT="/var/www/"

ROADIZ_URL="https://github.com/roadiz/roadiz.git"
ROADIZ_BRANCH="master"

THEME_URL="https://github.com/roadiz/BaseTheme.git"
THEME_BRANCH="master"

#
# MySQL credentials
# Change these with your own
#
MYSQL_HOST="localhost"
MYSQL_USER="root"
MYSQL_PASS="****password****"

GIT=`which git`
COMPOSER=`which composer`
NPM=`which npm`
SED=`which sed`
FIND=`which find`
GRUNT=`which grunt`

cd $APACHE_ROOT;

echo -e "\033[33m1. Type your new website name and type [ENTER].\033[0m"
echo -e "\033[33mThis name will be used for your web folder and your MySQL user and database name:\033[0m";
read destination;

echo -e "\033[33m2. Choose a password for your MySQL user and type [ENTER]:\033[0m";
stty -echo
read password;
stty echo

echo -e "\033[33m3. Choose a prefix for your Roadiz theme. Type it in CamelCase syntax and hit [ENTER].\033[0m"
echo -e "\033[33mFor example 'MySuper' will generate a theme called 'MySuperTheme':\033[0m";
read theme_prefix;

mkdir -p $destination;
cd $APACHE_ROOT$destination;

#
# Roadiz
#
$GIT clone -b $ROADIZ_BRANCH $ROADIZ_URL ./;
echo -e "\033[32m* Download latest Roadiz sources - OK\033[0m";

$COMPOSER install --no-dev;
$COMPOSER dumpautoload -o;
echo -e "\033[32m* Download latest Roadiz dependencies - OK\033[0m";

cp conf/config.default.yml conf/config.yml;
echo -e "\033[32m* Make a copy of default configuration file - OK\033[0m";

bin/roadiz config --generateHtaccess
echo -e "\033[32m* Generate .htaccess files for Apache - OK\033[0m";

#
# BaseTheme
#
$GIT clone -b $THEME_BRANCH $THEME_URL ./themes/${theme_prefix}Theme;
echo -e "\033[32m* Download Base theme sources into themes folder - OK\033[0m";

cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;

rm -rf ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/.git
echo -e "\033[32m* Delete existing Git history - OK\033[0m";

mv BaseThemeApp.php ${theme_prefix}ThemeApp.php
mv static/js/BaseTheme.js static/js/${theme_prefix}Theme.js
mv static/js/BaseTheme.min.js static/js/${theme_prefix}Theme.min.js
echo -e "\033[32m* Rename theme files against you theme name - OK\033[0m";

LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/BaseTheme/${theme_prefix}Theme/g" {} \;
LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/Base theme/${theme_prefix} theme/g" {} \;
LC_ALL=C $FIND ./ -type f -name '*.bak' -exec rm -f {} \;
echo -e "\033[32m* Rename every occurrences of BaseTheme in your theme - OK\033[0m";

#
# Grunt
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/static;
$NPM install;
echo -e "\033[32m* Install Grunt for your theme - OK\033[0m";

$GRUNT
echo -e "\033[32m* Launch Grunt for the first time - OK\033[0m";


#
# Git
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;
$GIT init;
$GIT add --all;
$GIT commit -a -m "First commit";
echo -e "\033[32m* Reinit Git repository and first commit - OK\033[0m";

#
# Installation MySQL
#
MYSQL=`which mysql`;

Q1="CREATE DATABASE IF NOT EXISTS $destination;";
Q2="CREATE USER '$destination'@'$MYSQL_HOST' IDENTIFIED BY '$password';";
Q4="GRANT ALL PRIVILEGES ON \`$destination\`.* TO '$destination'@'$MYSQL_HOST' WITH GRANT OPTION;";

SQL="${Q1}${Q2}${Q4}";


$MYSQL -u$MYSQL_USER -p$MYSQL_PASS -e "$SQL";
echo -e "\033[32m* MySQL database creation on `hostname` - OK\033[0m";

echo -e "\033[33m--------------------------------------------------------------------------------\033[0m"
echo -e "\033[33m--- Your new website '$destination' has been created with its own database -----\033[0m"
echo -e "\033[33m-- MySQL Database: '$destination' User: '$destination' Password: '$password' ---\033[0m"
echo -e "\033[33m--------------------------------------------------------------------------------\033[0m"
