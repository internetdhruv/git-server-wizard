#! /bin/sh
#
# Author: Dhruv Sharma

if [ $(id -u) -ne 0 ]; then
    echo "git-server-wizard must be run as root... exiting..."
    exit 1
fi

## Source files
. ./config.rc
. ./utils.sh

## Get stagit, compile and install
# Don't reinstall, if we already have stagit
echo "[git-server-wizard] Checking if stagit exists..."
(which stagit >/dev/null 2>&1 && which stagit-index >/dev/null 2>&1) || getStagit


# Confirm if we got all the right information
echo
echo "This is what you entered as your required config..."
echo "Make sure none of these fields are blank..."
echo
echo "Git User Name: $GIT_USER"
echo "Git Directory: $GIT_HOME"
echo "Git Web Pages Directory: $WWW_HOME"
echo "Git Clone Base URL: $CLONE_URI"
echo "Default Repo Owner: $DEFAULT_OWNER"
echo "Default Repo Description: $DEFAULT_DESCRIPTION"
confirm "Are you sure this is the config you want [y/N]" || exit 1
confirm "Are you absolutely sure? [y/N]" || exit 1

## Make the git user
grep '$GIT_USER' /etc/passwd >/dev/null || adduser $GIT_USER || errorOut

## Make the git dir
mkdir -p $GIT_HOME
## Make the HTML dir
mkdir -p $WWW_HOME

# Give permissions
# The first of these commands is useless for someone
# who uses the default config or places the git
# directory somewhere where git user  has permissions
chown -R $GIT_USER:$GIT_USER $GIT_HOME
chown -R $GIT_USER:$GIT_USER $WWW_HOME

## Copy the config file to the git users home directory
cp ./config.rc $GIT_HOME

## Modify the temp files so they contain the correct path:
ESCAPED_HOME=$(printf '%s\n' "$GIT_HOME" | sed -e 's/[]\/$*.^[]/\\&/g');
sed '/#<<<SOURCE_CONFIG_HERE>>>/s/.*/\. '$ESCAPED_HOME'\/config\.rc/' ./stagit-newrepo > ./stagit-newrepo.temp
sed '/#<<<SOURCE_CONFIG_HERE>>>/s/.*/\. '$ESCAPED_HOME'\/config\.rc/' ./stagit-gen-index > ./stagit-newrepo.temp
cp -R ./template ./template.temp/
sed '/#<<<SOURCE_CONFIG_HERE>>>/s/.*/\. '$ESCAPED_HOME'\/config\.rc/' ./template.temp/post-receive > ./template.temp/post-receive

