#! /bin/sh

TEMP_DIR="./.git-server-wizard.temp.d"
STAGIT_CLONE_DIR="$TEMP_DIR/.stagit"

cleanup() {
    rm -rf $TEMP_DIR
}

errorOut() {
    cleanup
    echo "[git-server-wizard] An error occured. Please see the previous output to find out what went wrong"
    exit 1
}

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

getStagit() {
    echo "[git-server-wizard] stagit not found. Downloading and installing..."
    cd
    git clone git://git.codemadness.org/stagit $STAGIT_CLONE_DIR
    cd .stagit.temp.d || errorOut
    sudo apt install make gcc libgit2-dev
    make && make install
    (which stagit >/dev/null 2>&1 && which stagit >/dev/null 2>&1) || errorOut
}

installPackages() {
    apt install git make gcc libgit2-dev nginx certbot git-core fcgiwrap apache2-utils python3-certbot-nginx
}
