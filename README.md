# git-server-wizard
An automated script that creates a private git server and a public webpage to view the git repositories.
I am running this server [here](git.dhruv-sharma.com), if you would like to take a look.

This script will:
* Optionally, download a bunch of packages and their dependencies (Works only on Debian based systems for now):
  * (Required) [stagit](https://codemadness.org/stagit.html) - This is the tool that creates the public git webpage
    * Dependencies are: git, make, gcc, libgit2-dev
  * (Required) nginx - For your webpage setup and allowing password based cloning
  * (Optional) certbot, python3-certbot-nginx - For HTTPS/SSL. Highly recommended since some browsers will not allow users to visit not HTTPS websites.
  * (Required) git-core, fcgiwrap, apache2-utils - For git cloning
* Set up 2 programs (scripts, really) in your local bin
  * `stagit-newrepo [name] [description]` - To create a new repository on the serevr with the given name and description
  * `stagit-gen-index` - To regenerate the main git repo index for your website
* Set up a basic git server. This is not required, but a new user can be created to manage the server (highly recommended)
* Configure nginx, git, stagit to play well together
* Create the website for your git server (using stagit)

There is no guarantee that this script will work without any problems. Every system is different. However, you can follow the output and read the script so you can understand what is going on and fix it yourself. Open an issue if you need help or have a change to suggest or a mistake to fix.

## Where should I host this?
There's nothing stopping you from setting up a server on your own machine or raspberry pi or webserver. Anything is fine. However I recommend a VPS. If you don't have a VPS yet, I recommend Vultr. Use my [link](https://www.vultr.com/?ref=8614602-6G) to get $100 in credits (That's enough to host their cheapest server for 3 years). You'll also need a domain (though you don't need that if you just want local access to your server). You can generally get those for about $10 a year and use that for your own website, git website, mail server and more.

## Steps

### 1. Set up config.rc
This is 100% the most important step of the script. The config will be used in all steps of the process so a wrong config will result in a lot of errors. I suggest the default options (they make a lot of sense, work well, result in the shortest clone URLS, look nice, and the script was best designed for them). However, you will have to change `GIT_SITE_NAME` to be your website. I highly recommend `git.<yoursite>.com` or something like that. You can do this by adding a CNAME record in your hosting services DNS settings.

### 2. Add your package manager to `utils.sh`
`utils.sh` contains a few lines where packages are downloaded. Change all the lines where it says `apt install` to something which works with your specific package manager. This could be pacman, yum or whatever. Better yet, just install the packages yourself.

### 3. Run the script

### 4. Check if nginx was configured
The script will tell you if it could find your nginx config and set it up. On Debian/Ubuntu, I doubt the script will fail. From my experience with Amazon Linux, it may fail there; and maybe on more distributions. The script will tell you which file the config has been stored in. Take that file and place it whereever your nginx  server configs are.

If you don't know where that is, just take the contents of that file and dump it into your nginx.conf files http block. This file is most likely in `/etc/nginx`

### 5. Use certbot for HTTPS
Run certbot and get an HTTPS certificate if you want one.
