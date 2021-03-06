#!/usr/bin/env bash
# Author: Ambroise Maupate
# Contributor: Maxime Constantinian
# Contributor: Maxime Bérard
source `dirname $0`/methods.sh;

echo -e "${CYAN}---------------------------------- ROADIZ CMS ----------------------------------${NC}"
echo -e "${CYAN}\tNew BaseTheme on `hostname`.${NC}"
echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"

. `dirname $0`/config.sh || {
    echo -e "`dirname $0`/config.sh";
    echo -e "❌\t${RED}Impossible to import your configuration.${NC}" ;
    exit 1;
}

cd $APACHE_ROOT || {
    echo -e "❌\t${RED}Your apache directory does not exist. \tAborting.${NC}" ;
    exit 1;
}

command -v git >/dev/null 2>&1 || { echo -e "❌\t${RED}I require git but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo -e "❌\t${RED}I require npm but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v bower >/dev/null 2>&1 || { echo -e "❌\t${RED}I require bower but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v sed >/dev/null 2>&1 || { echo -e "❌\t${RED}I require sed but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v find >/dev/null 2>&1 || { echo -e "❌\t${RED}I require find but it's not installed. \tAborting.${NC}" >&2; exit 1; }
command -v gulp >/dev/null 2>&1 || { echo -e "❌\t${RED}I require gulp but it's not installed. \tAborting.${NC}" >&2; exit 1; }

echo -e "${ORANGE}1. Type your existing site folder name and type [ENTER].${NC}"
read destination;

cd $APACHE_ROOT$destination 2>&1 || {
    echo -e "❌\t${RED}Your site folder does not exist. \tAborting.${NC}" ;
    exit 1;
}

echo -e "${ORANGE}3. Choose a prefix for your Roadiz theme. Type it in CamelCase syntax and hit [ENTER].${NC}"
echo -e "${ORANGE}For example 'MySuper' will generate a theme called 'MySuperTheme':${NC}";
read theme_prefix;

#
# BaseTheme
#
createTheme;

echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
echo -e "${CYAN}\tYour new theme for '$destination' site has been created.${NC}"
echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
