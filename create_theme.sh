#!/usr/bin/env bash
# Author: Ambroise Maupate
# Contributor: Maxime Constantinian
# Contributor: Maxime Bérard

echo -e "\033[36m------------------ ROADIZ CMS -------------------\033[0m"
echo -e "\033[36m------- New Roadiz BaseTheme on `hostname` ------\033[0m"
echo -e "\033[36m-------------------------------------------------\033[0m"

source config.sh

GIT=`which git`
NPM=`which npm`
BOWER=`which bower`
SED=`which sed`
FIND=`which find`
GRUNT=`which grunt`

cd $APACHE_ROOT || {
    echo 'Your apache directory does not exist.' ;
    exit 1;
}

echo -e "\033[33m1. Type your existing site folder name and type [ENTER].\033[0m"
read destination;

echo -e "\033[33m3. Choose a prefix for your Roadiz theme. Type it in CamelCase syntax and hit [ENTER].\033[0m"
echo -e "\033[33mFor example 'MySuper' will generate a theme called 'MySuperTheme':\033[0m";
read theme_prefix;

mkdir -p $destination;
cd $APACHE_ROOT$destination;


#
# BaseTheme
#
$GIT clone -b $THEME_BRANCH $THEME_URL ./themes/${theme_prefix}Theme || {
    echo 'Impossible to clone BaseTheme.' ;
    exit 1;
}
echo -e "\033[32m* Download Base theme sources into themes folder - OK\033[0m";

cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;

rm -rf ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/.git
echo -e "\033[32m* Delete existing Git history - OK\033[0m";

mv BaseThemeApp.php ${theme_prefix}ThemeApp.php
echo -e "\033[32m* Rename theme files against you theme name - OK\033[0m";

LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/BaseTheme/${theme_prefix}Theme/g" {} \;
LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/Base theme/${theme_prefix} theme/g" {} \;
LC_ALL=C $FIND ./ -type f -name '*.bak' -exec rm -f {} \;
echo -e "\033[32m* Rename every occurrences of BaseTheme in your theme - OK\033[0m";

#
# Grunt
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/static;
$NPM install || {
    echo 'Impossible to install NPM.' ;
    exit 1;
}
echo -e "\033[32m* Install Grunt for your theme - OK\033[0m";
$BOWER install || {
    echo 'Impossible to install Bower.' ;
    exit 1;
}
echo -e "\033[32m* Install Bower for your theme - OK\033[0m";

$GRUNT || {
    echo 'Impossible to launch Grunt.' ;
    exit 1;
}
echo -e "\033[32m* Launch Grunt for the first time - OK\033[0m";


#
# Git
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;
$GIT init;
$GIT add --all;
$GIT commit -a -m "First commit";
echo -e "\033[32m* Reinit Git repository and first commit - OK\033[0m";



echo -e "\033[33m--------------------------------------------------------------------------------\033[0m"
echo -e "\033[33m----         Your new theme for '$destination' site has been created        ----\033[0m"
echo -e "\033[33m--------------------------------------------------------------------------------\033[0m"
