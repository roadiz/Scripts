#!bin/bash
# Ambroise Maupate

echo "------------------ ROADIZ CMS -------------------\n"
echo "--------- New Roadiz website on `hostname` ------\n"
echo "-------------------------------------------------\n"

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

echo "1. Type your new website name and type [ENTER].\nThis name will be used for your web folder and your MySQL user and database name:";
read destination;

echo "2. Choose a password for your MySQL user and type [ENTER]:";
read password;

echo "3. Choose a prefix for your Roadiz theme. Type it in CamelCase syntax and hit [ENTER].\nFor example 'MySuper' will generate a theme called 'MySuperTheme':";
read theme_prefix;

mkdir -p $destination;
cd $APACHE_ROOT$destination;

#
# Roadiz
#
$GIT clone -b $ROADIZ_BRANCH $ROADIZ_URL ./;
echo "* Download latest Roadiz sources - OK";

$COMPOSER install;
$COMPOSER dumpautoload -o;
echo "* Download latest Roadiz dependencies - OK";

cp conf/config.default.json conf/config.json;
echo "* Make a copy of default configuration file - OK";

bin/roadiz config --generateHtaccess
echo "* Generate .htaccess files for Apache - OK";

#
# BaseTheme
#
$GIT clone -b $THEME_BRANCH $THEME_URL ./themes/${theme_prefix}Theme;
echo "* Download Base theme sources into themes folder - OK";

cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;

rm -rf ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/.git
echo "* Delete existing Git history - OK";

mv BaseThemeApp.php ${theme_prefix}ThemeApp.php
mv static/js/BaseTheme.js static/js/${theme_prefix}Theme.js
mv static/js/BaseTheme.min.js static/js/${theme_prefix}Theme.min.js
echo "* Rename theme files against you theme name - OK";

LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/BaseTheme/${theme_prefix}Theme/g" {} \;
LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/Base theme/${theme_prefix} theme/g" {} \;
LC_ALL=C $FIND ./ -type f -name '*.bak' -exec rm -f {} \;
echo "* Rename every occurrences of BaseTheme in your theme - OK";

#
# Grunt
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/static;
$NPM install;
echo "* Install Grunt for your theme - OK";

$GRUNT
echo "* Launch Grunt for the first time - OK";


#
# Git
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;
$GIT init;
$GIT add --all;
$GIT commit -a -m "First commit";
echo "* Reinit Git repository and first commit - OK";

#
# Installation MySQL
#
MYSQL=`which mysql`;

Q1="CREATE DATABASE IF NOT EXISTS $destination;";
Q2="CREATE USER '$destination'@'$MYSQL_HOST' IDENTIFIED BY '$password';";
Q4="GRANT ALL PRIVILEGES ON \`$destination\`.* TO '$destination'@'$MYSQL_HOST' WITH GRANT OPTION;";

SQL="${Q1}${Q2}${Q4}";


$MYSQL -u$MYSQL_USER -p$MYSQL_PASS -e "$SQL";
echo "* MySQL database creation on `hostname` - OK\n";

echo "--------------------------------------------------------------------------------\n"
echo "--- Your new website '$destination' has been created with its own database -----\n"
echo "-- MySQL Database: '$destination' User: '$destination' Password: '$password' ---\n"
echo "--------------------------------------------------------------------------------\n"
