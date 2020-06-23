#! /bin/sh
#
# Author: Dhruv Sharma

## Source files
. ./config.rc
. ./utils.sh

if [ $(id -u) -ne 0 ]; then
    echo "${RED}git-server-wizard must be run as root... exiting...${NC}"
    exit 1
fi

(which figlet >/dev/null 2>&1 && figlet 'git server wizard') || echo "~~~~~~~~~~~git server wizard~~~~~~~~~~~"
echo

echo "The following packages will be needed: git, make, gcc, libgit2-dev, nginx, certbot, python3-certbot-nginx, git-core, fcgiwrap, apache2-utils"
echo "I can install these packages for you in case you are missing any (Ubuntu/Debian only)"
confirm  "Should I install the packages? [y/N]?" && installPackages

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
echo
confirm "Are you sure this is the config you want [y/N]" || exit 1
confirm "Are you absolutely sure? [y/N]" || exit 1

echo
echo "[git-server-wizard] The git user is being created now..."
## Make the git user
grep '$GIT_USER' /etc/passwd >/dev/null || adduser $GIT_USER || errorOut

echo "[git-server-wizard] Creating git and web directories..."
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

echo "[git-server-wizard] Copying files..."
## Copy the config file to the git users home directory
cp ./config.rc $GIT_HOME

## Modify the temp files so they contain the correct path:
ESCAPED_HOME=$(printf '%s\n' "$GIT_HOME" | sed -e 's/[]\/$*.^[]/\\&/g');
sed '/#<<<SOURCE_CONFIG_HERE>>>/s/.*/\. '$ESCAPED_HOME'\/config\.rc/' ./stagit-newrepo > ./stagit-newrepo.temp
sed '/#<<<SOURCE_CONFIG_HERE>>>/s/.*/\. '$ESCAPED_HOME'\/config\.rc/' ./stagit-gen-index > ./stagit-gen-index.temp
cp -R ./template ./template.temp/
sed '/#<<<SOURCE_CONFIG_HERE>>>/s/.*/\. '$ESCAPED_HOME'\/config\.rc/' ./template/post-receive > ./template.temp/post-receive

## Move all 3 files into users directories
mv ./stagit-newrepo.temp /usr/local/bin/stagit-newrepo
mv ./stagit-gen-index.temp /usr/local/bin/stagit-gen-index
chmod +x /usr/local/bin/stagit-newrepo
chmod +x /usr/local/bin/stagit-gen-index
mv ./template.temp $GIT_HOME/template

echo "[git-server-wizard] Git Server Setup has been completed..."
echo
echo "[git-server-wizard] Setting up nginx..."

echo "[git-server-wizard] Creating git http backend for git clone"
sed 's/<<<SOURCE_CONFIG_HERE>>>/'$ESCAPED_HOME'/' ./git-http-backend.conf > ./git-http-backend.conf.temp
[ -d "/etc/nginx" ] && mv ./git-http-backend.conf.temp /etc/nginx/git-http-backend.conf
[ -d "/etc/nginx" ] || echo "${YELLOW}[git-server-wizard] I was unable to find your nginx directory. This could be because you don't have nginx on this system. Please copy ./git-http-backend.conf.temp to /etc/nginx/git-http-backend.conf or wherever you nginx config is. Remember to remove the .temp suffix when you copy${NC}"

## Setup nginx

# Get path of git clone URL
proto="$(echo "$CLONE_URI" | grep :// | sed -e's,^\(.*://\).*,\1,g')"
url=$CLONE_URI
[ -z "$proto"  ] || url="$(echo "$CLONE_URI" | sed 's|'$proto'||')"
path="$(echo "$url" | grep / | cut -d/ -f2-)"
path='/'$path

ESCAPED_SITE_NAME=$(printf '%s\n' "$GIT_SITE_NAME" | sed -e 's/[]\/$*.^[]/\\&/g');
ESCAPED_PATH=$(printf '%s\n' "$path" | sed -e 's/[]\/$*.^[]/\\&/g');
sed 's/<<<SERVER_NAME_HERE>>>/'$ESCAPED_SITE_NAME'/' ./git-nginx.conf > ./git-nginx.conf.temp
sed -i 's/<<<GIT_HOME_HERE>>>/'$ESCAPED_HOME'/' ./git-nginx.conf.temp
sed -i 's/<<<PATH_HERE>>>/'$ESCAPED_PATH'/' ./git-nginx.conf.temp

[ -d "/etc/nginx/sites-available" ] && [ -d "/etc/nginx/sites-enabled" ] && NGINX_FOUND=0
[ -z "$NGINX_FOUND" ] || mv ./git-nginx.conf.temp /etc/nginx/sites-available/git-nginx.conf
[ -z "$NGINX_FOUND" ] || ln -s /etc/nginx/sites-available/git-nginx.conf /etc/nginx/sites-enabled/git-nginx.conf

[ -z "$NGINX_FOUND" ] && echo "${YELLOW}[git-server-wizard] I was unable to load your nginx config. Take ./git-nginx.conf.temp and place it in your nginx config.${NC}"

echo
echo "${GREEN}[git-server-wizard] Your git server has been created at $GIT_HOME.${NC}"
[ -z "$NGINX_FOUND" ] || echo "${GREEN}[git-server-wizard] nginx for $GIT_SITE_NAME has been set up${NC}"
[ -z "$NGINX_FOUND" ] && echo "${RED}[git-server-wizard] I was unable to find your nginx config.Copy ./git-http-backend.conf.temp to /etc/nginx/git-http-backend.conf and write the contents of ./git-nginx.conf to the appropriate nginx server config files.${NC}"
echo
echo "${YELLOW}If you want https/ssl on this website. Run 'certbot --nginx' and select your git website to generate a certificate. The process is automated and should not require much work"
echo
echo "You can now create new repositories with 'sudo stagit-newrepo'. You can add your ssh keys to $GIT_USER/.ssh to get ssh based git access to your repos. The address will be $GIT_USER@<site-name.com>:$GIT_HOME/<repo>.git . If your git repositories are in the git users home directory, you can even avoid long path at the end of that address and use :<repo>.git"
echo "To edit your website styling and logo, add logo.png and style.css to $WWW_HOME and edit $WWW_HOME/index.html"
