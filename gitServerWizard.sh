#! /bin/sh
#
#

if [ $(id -u) -ne 0 ]; then
    echo "git-server-wizard must be run as root... exiting..."
    exit 1
fi

## Source files
. utils.sh

## Get stagit, compile and install
# Don't reinstall, if we already have stagit
(which stagit && which stagit-index) || getStagit

## Variables
read -p "Name of the 'git' user [git]: " GIT_USER_NAME
GIT_USER_NAME=${GIT_USER_NAME:-git}

read -p "Abbsolute of your git repositories [/home/$GIT_USER_NAME] :" GIT_HOME_DIR
GIT_HOME_DIR=${GIT_HOME_DIR:-/home/$GIT_USER_NAME}

read -p "Where do you want to place your git web html files [/var/www/htdocs/git]: " GIT_WEB_DIR
GIT_WEB_DIR=${GIT_WEB_DIR:-/var/www/htdocs/git}

# Confirm if we got all the right information

echo "This is what you entered as your required config:"
echo "Git User Name: $GIT_USER_NAME"
echo "Git Directory: $GIT_HOME_DIR"
echo "Git Web Pages Directory: $GIT_WEB_DIR"
confirm "Are you sure this is the config you want [y/n]" || exit 1

## Make the git user

adduser $GIT_USER_NAME || errorOut
su $GIT_USER_NAME || errorOut


