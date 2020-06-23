#! /bin/sh

errorOut() {
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
    cd
    git clone git://git.codemadness.org/stagit .stagit.temp.d
    cd .stagit.temp.d || errorOut
    sudo apt install make gcc libgit2-dev
    make && make install
}
