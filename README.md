# ROADIZ scripts
## create_roadiz.sh

This script is made for creating automatically a Roadiz website folder structure and MySQL database. It will create a folder and a database named after the same string.
`create_roadiz.sh` clone Roadiz and BaseTheme from github. Then it will rename BaseTheme against your chosen name and create a git repository for it.

**Make sure you have *Git*, *Composer*, *NPM* (NodeJS) and *Grunt* globally installed on your server.**

* Rename `create_roadiz.default.sh` file to `create_roadiz.sh`
* Edit your own folder configuration and mysql user credentials
* Set `create_roadiz.sh` executable using `chmod +x create_roadiz.sh`
* Call `sh create_roadiz.sh` to launch Roadiz creation wizard.
