# Roadiz scripts

## create_roadiz.sh

This script is made for creating automatically a Roadiz website folder structure and MySQL database. It will create a folder and a database named after the same string.
`create_roadiz.sh` clone Roadiz and BaseTheme from github. Then it will rename BaseTheme against your chosen name and create a git repository for it.

**Make sure you have *Git*, *Composer*, *NPM* (NodeJS) and *Grunt* globally installed on your server.**

* Rename `create_roadiz.default.sh` file to `create_roadiz.sh`
* Edit your own server-root folder configuration and mysql user credentials
* Set `create_roadiz.sh` executable using `chmod +x create_roadiz.sh`
* Call `sh create_roadiz.sh` to launch Roadiz creation wizard.

## create_theme.sh

This script is made for adding automatically a new theme based on BaseTheme (https://github.com/roadiz/BaseTheme).
It will clone `BaseTheme` in a chosen existing Roadiz website folder. Then it will rename it against your chosen name and create a git repository for it.

**Make sure you have *Git*, *NPM* (NodeJS) and *Grunt* globally installed on your server.**

* Rename `create_theme.default.sh` file to `create_theme.sh`
* Edit your own server-root folder configuration
* Set `create_theme.sh` executable using `chmod +x create_theme.sh`
* Call `sh create_theme.sh` to launch BaseTheme creation wizard.