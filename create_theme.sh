#!/usr/bin/env bash
# Author: Ambroise Maupate
# Contributor: Maxime Constantinian
# Contributor: Maxime Bérard

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m'
# No Color
NC='\033[0m'

echo "${CYAN}------------------ ROADIZ CMS -------------------${NC}"
echo "${CYAN}------- New Roadiz BaseTheme on `hostname` ------${NC}"
echo "${CYAN}-------------------------------------------------${NC}"

. `dirname $0`/config.sh || {
    echo "`dirname $0`/config.sh";
    echo "❌\t${RED}Impossible to import your configuration.${NC}" ;
    exit 1;
}

GIT=`command -v git`
NPM=`command -v npm`
BOWER=`command -v bower`
SED=`command -v sed`
FIND=`command -v find`
GULP=`command -v gulp`

cd $APACHE_ROOT || {
    echo "❌\t${RED}Your apache directory does not exist. \tAborting.${NC}" ;
    exit 1;
}

command -v git >/dev/null 2>&1 || { echo "❌\t${RED}I require git but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌\t${RED}I require npm but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v bower >/dev/null 2>&1 || { echo "❌\t${RED}I require bower but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v sed >/dev/null 2>&1 || { echo "❌\t${RED}I require sed but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v find >/dev/null 2>&1 || { echo "❌\t${RED}I require find but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v gulp >/dev/null 2>&1 || { echo "❌\t${RED}I require gulp but it's not installed. \tAborting.${NC}" >&2; exit 1; }

echo "${ORANGE}1. Type your existing site folder name and type [ENTER].${NC}"
read destination;

cd $APACHE_ROOT$destination 2>&1 || {
    echo "❌\t${RED}Your site folder does not exist. \tAborting.${NC}" ;
    exit 1;
}

echo "${ORANGE}3. Choose a prefix for your Roadiz theme. Type it in CamelCase syntax and hit [ENTER].${NC}"
echo "${ORANGE}For example 'MySuper' will generate a theme called 'MySuperTheme':${NC}";
read theme_prefix;

#
# BaseTheme
#
$GIT clone -b $THEME_BRANCH $THEME_URL ./themes/${theme_prefix}Theme || {
    echo "❌\t${RED}Impossible to clone BaseTheme. \tAborting.${NC}" ;
    exit 1;
}
echo "✅\t${GREEN}Download Base theme sources into themes folder.${NC}";

cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;

rm -rf ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme/.git
echo "✅\t${GREEN}Delete existing Git history.${NC}";

mv BaseThemeApp.php ${theme_prefix}ThemeApp.php
echo "✅\t${GREEN}Rename theme files against you theme name.${NC}";

LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/BaseTheme/${theme_prefix}Theme/g" {} \;
LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/Base theme/${theme_prefix} theme/g" {} \;
LC_ALL=C $FIND ./static -type f -exec $SED -i.bak -e "s/Base/${theme_prefix}/g" {} \;
LC_ALL=C $FIND ./ -type f -name '*.bak' -exec rm -f {} \;
echo "✅\t${GREEN}Rename every occurrences of BaseTheme in your theme.${NC}";

#
# NPM, Bower, Gulp...
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;
make;

#
# Git
#
cd ${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;
$GIT init;
$GIT add --all;
$GIT commit -am "First commit";
echo "✅\t${GREEN}Reinit Git repository and first commit.${NC}";


echo "${CYAN}--------------------------------------------------------------------------------${NC}"
echo "${CYAN}\tYour new theme for '$destination' site has been created.${NC}"
echo "${CYAN}--------------------------------------------------------------------------------${NC}"
