#!bin/bash
# Ambroise Maupate

echo "------------------ ROADIZ CMS -------------------\n"
echo "--- Création d'un nouveau site sur `hostname` ---\n"
echo "-------------------------------------------------\n"

APACHE_ROOT="/var/www/"

ROADIZ_URL="https://github.com/roadiz/roadiz.git"
ROADIZ_BRANCH="master"

THEME_URL="https://github.com/roadiz/BaseTheme.git"
THEME_BRANCH="master"

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

echo "1. Entrez le nom du nouveau site et appuyez sur [ENTRER]\nCe nom sera utilisé pour le dossier et l'utilisateur MySQL :";
read destination;

echo "2. Entrez le mot de passe de la base de donnée et appuyez sur [ENTRER]:";
read password;

echo "3. Entrez le préfix de votre futur thème en CamelCase et appuyez sur [ENTRER].\nPar exemple 'MySuper' donnera un thème 'MySuperTheme':";
read theme_prefix;

mkdir -p $destination;
cd $APACHE_ROOT$destination;

#
# Roadiz
#
$GIT clone -b $ROADIZ_BRANCH $ROADIZ_URL ./;
echo "* Téléchargement des sources - OK";

$COMPOSER install;
$COMPOSER dumpautoload -o;
echo "* Téléchargement des dépendances - OK";

cp conf/config.default.json conf/config.json;
echo "* Copie de la configuration par défaut - OK";

bin/roadiz config --generateHtaccess
echo "* Generation des .htaccess - OK";

#
# BaseTheme
#
$GIT clone -b $THEME_BRANCH $THEME_URL ./themes/${theme_prefix}Theme;
echo "* Téléchargement des sources du theme - OK";

cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;

rm -rf ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/.git
echo "* Suppression de l’historique Git du thème - OK";

mv BaseThemeApp.php ${theme_prefix}ThemeApp.php
mv static/js/BaseTheme.js static/js/${theme_prefix}Theme.js
mv static/js/BaseTheme.min.js static/js/${theme_prefix}Theme.min.js
echo "* Renommage des fichiers de votre thème - OK";

LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/BaseTheme/${theme_prefix}Theme/g" {} \;
LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/Base theme/${theme_prefix} theme/g" {} \;
LC_ALL=C $FIND ./ -type f -name '*.bak' -exec rm -f {} \;
echo "* Renommage des occurences de votre thème - OK";

#
# Grunt
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/static;
$NPM install;
echo "* Installation du Grunt pour votre theme - OK";

$GRUNT
echo "* Lancement du premier Grunt - OK";


#
# Git
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;
$GIT init;
$GIT add --all;
$GIT commit -a -m "First commit";
echo "* Réinitialisation du dépôt Git et premier commit - OK";

#
# Installation MySQL
#
MYSQL=`which mysql`;

Q1="CREATE DATABASE IF NOT EXISTS $destination;";
Q2="CREATE USER '$destination'@'$MYSQL_HOST' IDENTIFIED BY '$password';";
Q4="GRANT ALL PRIVILEGES ON \`$destination\`.* TO '$destination'@'$MYSQL_HOST' WITH GRANT OPTION;";

SQL="${Q1}${Q2}${Q4}";


$MYSQL -u$MYSQL_USER -p$MYSQL_PASS -e "$SQL";
echo "* Création de la base de donnée sur `hostname` - OK\n";

	echo "--------------------------------------------------------------------------------\n"
	echo "---- Le nouveau site '$destination' a été créé ainsi que sa base de donnée -----\n"
	echo "---- MySQL Base: '$destination' User: '$destination' Password: '$password' -----\n"
	echo "--------------------------------------------------------------------------------\n"
