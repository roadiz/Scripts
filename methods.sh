#!/usr/bin/env bash
# Author: Ambroise Maupate
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m'
# No Color
NC='\033[0m'

GIT=`command -v git`
COMPOSER=`command -v composer`
NPM=`command -v npm`
BOWER=`command -v bower`
SED=`command -v sed`
FIND=`command -v find`
GULP=`command -v gulp`
DEV_SAMPLE="`pwd`/dev.sample.php"
CACHE_SAMPLE="`pwd`/clear_cache.sample.php"
MYSQL=`command -v mysql`;

#
# Installation MySQL
#
function installMySQL {

    command -v mysql >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        Q1="CREATE DATABASE IF NOT EXISTS $destination;";
        Q2="CREATE USER '$destination'@'$MYSQL_HOST' IDENTIFIED BY '$password';";
        Q4="GRANT ALL PRIVILEGES ON \`$destination\`.* TO '$destination'@'$MYSQL_HOST' WITH GRANT OPTION;";

        SQL="${Q1}${Q2}${Q4}";

        $MYSQL -u$MYSQL_USER -p$MYSQL_PASS -e "$SQL" || {
            return 1;
        }
        return 0;
    else
        return 1;
    fi
    return 0;
}

#
# Installation BaseTheme
#
function createTheme {

    local THEME_ROOT=${APACHE_ROOT}${destination}/themes/${theme_prefix}Theme;
    local GIT=`command -v git`

    $GIT clone -b $THEME_BRANCH $THEME_URL $THEME_ROOT;
    if [ $? -eq 0 ]; then
        echo -e "✅\t${GREEN}Download Base theme sources into themes folder.${NC}";
    else
        echo -e "❌\t${RED}Impossible to clone BaseTheme. \tAborting.${NC}" ;
        return 1;
    fi

    cd ${THEME_ROOT};

    rm -rf ${THEME_ROOT}/.git
    echo -e "✅\t${GREEN}Delete existing Git history.${NC}";

    mv BaseThemeApp.php ${theme_prefix}ThemeApp.php
    echo -e "✅\t${GREEN}Rename theme files against you theme name.${NC}";

    LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/BaseTheme/${theme_prefix}Theme/g" {} \;
    LC_ALL=C $FIND ./ -type f -exec $SED -i.bak -e "s/Base theme/${theme_prefix} theme/g" {} \;
    LC_ALL=C $FIND ./static -type f -exec $SED -i.bak -e "s/Base/${theme_prefix}/g" {} \;
    LC_ALL=C $FIND ./ -type f -name '*.bak' -exec rm -f {} \;
    echo -e "✅\t${GREEN}Rename every occurrences of BaseTheme in your theme.${NC}";

    #
    # NPM, Bower, Gulp...
    #
    cd ${THEME_ROOT};
    make;

    #
    # Git
    #
    cd ${THEME_ROOT};
    $GIT init;
    $GIT add --all;
    $GIT commit -a -m "First commit";
    echo -e "✅\t${GREEN}Reinit Git repository and first commit.${NC}";

    return 0;
}
