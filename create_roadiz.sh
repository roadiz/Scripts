#!/usr/bin/env bash
# Author: Ambroise Maupate
# Contributor: Maxime Constantinian
# Contributor: Maxime Bérard
source `dirname $0`/methods.sh;

echo -e "${CYAN}---------------------------------- ROADIZ CMS ----------------------------------${NC}"
echo -e "${CYAN}\tNew Roadiz website with BaseTheme on `hostname`${NC}"
echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"

. `dirname $0`/config.sh || {
    echo -e "`dirname $0`/config.sh";
    echo -e "❌\t${RED}Impossible to import your configuration.${NC}";
    exit 1;
}

cd $APACHE_ROOT || {
    echo -e "❌\t${RED}Your apache directory does not exist. \tAborting.${NC}" ;
    exit 1;
}

command -v mysql >/dev/null 2>&1 || { echo -e "⚠️\t${RED}I require mysql but it's not installed, no database will be created.${NC}" >&2; }
command -v git >/dev/null 2>&1 || { echo -e "❌\t${RED}I require git but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v composer >/dev/null 2>&1 || { echo -e "❌\t${RED}I require composer but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "❌\t${RED}I require npm but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v bower >/dev/null 2>&1 || { echo -e "❌\t${RED}I require bower but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v sed >/dev/null 2>&1 || { echo -e "❌\t${RED}I require sed but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v find >/dev/null 2>&1 || { echo -e "❌\t${RED}I require find but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v gulp >/dev/null 2>&1 || { echo -e "❌\t${RED}I require gulp but it's not installed. \tAborting.${NC}" >&2; exit 1; }

echo -e "${ORANGE}1. Type your new website name and type [ENTER].${NC}"
echo -e "${ORANGE}This name will be used for your web folder and your MySQL user and database name:${NC}";
read destination;

command -v mysql >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${ORANGE}2. Choose a password for your MySQL user and type [ENTER]:${NC}";
    stty -echo
    read password;
    stty echo
fi

echo -e "${ORANGE}3. Choose a prefix for your Roadiz theme. Type it in CamelCase syntax and hit [ENTER].${NC}"
echo -e "${ORANGE}For example 'MySuper' will generate a theme called 'MySuperTheme':${NC}";
read theme_prefix;

mkdir -p $destination;
cd $APACHE_ROOT$destination;

#
# Roadiz
#
$GIT clone -b $ROADIZ_BRANCH $ROADIZ_URL ./ || {
    echo -e "❌\t${RED}Impossible to clone Roadiz. \tAborting.${NC}" ;
    exit 1;
}
echo -e "✅\t${GREEN}Download latest Roadiz sources.${NC}";

$COMPOSER install -n --no-dev -o
if [ $? -eq 0 ]; then
    echo -e "✅\t${GREEN}Installed latest Roadiz dependencies with composer.${NC}";
else
    echo -e "❌\t${RED}Impossible to install Composer dependencies. \tAborting.${NC}" ;
    exit 1;
fi

bin/roadiz generate:htaccess;
echo -e "✅\t${GREEN}Generate .htaccess files for Apache.${NC}";

cp -f $DEV_SAMPLE $APACHE_ROOT$destination/dev.php;
if [ $? -eq 0 ]; then
    echo -e "✅\t${GREEN}Copy a sample dev.php file with LAN access and preview flag.${NC}";
else
    echo -e "❌\t${RED}Impossible to copy a sample dev.php file. \tAborting.${NC}";
fi

cp -f $CACHE_SAMPLE $APACHE_ROOT$destination/clear_cache.php;
if [ $? -eq 0 ]; then
    echo -e "✅\t${GREEN}Copy a sample clear_cache.php file with LAN access.${NC}";
else
    echo -e "❌\t${RED}Impossible to copy a sample clear_cache.php file. \tAborting.${NC}";
fi

#
# BaseTheme
#
createTheme;

#
# Installation MySQL
#
installMySQL;
if [ $? -eq 0 ]; then
    echo -e "✅\t${GREEN}MySQL database and user created on `hostname`.${NC}";
    echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
    echo -e "${CYAN}\tYour new website '$destination' has been created with its own database.${NC}"
    echo -e "${CYAN}\tMySQL Database: '$destination' User: '$destination' Password: '$password'.${NC}"
    echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
else
    echo -e "❌\t${RED}Impossible to create your site database.${NC}" ;
    echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
    echo -e "${CYAN}\tYour new website '$destination' has been created with NO database.${NC}"
    echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
fi
