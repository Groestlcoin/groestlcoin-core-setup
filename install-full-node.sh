#!/bin/sh

#----------------------------------
#
#----------------------------------
ARCH=$(uname -m)
SYSTEM=$(uname -s)
MAKE="make"
if [ "$SYSTEM" = "FreeBSD" ]; then
    MAKE="gmake"
fi
SUDO=""

#----------------------------------
#
#----------------------------------
REPO_URL="https://github.com/groestlcoin/groestlcoin.git"
VERSION=2.20.1 # See https://github.com/groestlcoin/groestlcoin/tags for latest version.
TARGET_DIR=$HOME/groestlcoin-core
PORT=1331
BUILD=0
UNINSTALL=0

#----------------------------------
#
#----------------------------------
RESET='\033[0m'
RED='\033[31;1m'
GREEN='\033[32;1m'
YELLOW='\033[33;1m'
BLUE='\033[34;1m'
MAGENTA='\033[35;1m'
CYAN='\033[36;1m'
WHITE='\033[37;1m'

print_info() {
    printf "$BLUE$1$RESET\n"
}

print_success() {
    printf "$GREEN$1$RESET\n"
    sleep 1
}

print_warning() {
    printf "$YELLOW$1$RESET\n"
}

print_error() {
    printf "$RED$1$RESET\n"
    sleep 1
}

print_start() {
    print_info "Start date: $(date)"
}

print_end() {
    print_info "\nEnd date: $(date)"
}

program_exists() {
    type "$1" > /dev/null 2>&1
    return $?
}

#----------------------------------
#
#----------------------------------
help() {
cat <<EOF

  This is the install script for Groestlcoin full node based on Groestlcoin Core.

  Usage: $0 [-h] [-v <version>] [-t <target_directory>] [-p <port>] [-b] [-u]

  -h
      Print help.

  -v <version>
      Version of Groestlcoin Core to install.
      Default: $VERSION

  -t <target_directory>
      Target directory for source files and binaries.
      Default: $HOME/groestlcoin-core

  -p <port>
      Groestlcoin Core listening port.
      Default: $PORT

  -b
      Build and install Groestlcoin Core from source.
      Default: $BUILD

  -u
      Uninstall Groestlcoin Core.

EOF
}

readme() {
cat <<EOF

  # README

  To stop Groestlcoin Core:

      cd $TARGET_DIR/bin && ./stop.sh

  To start Groestlcoin Core again:

      cd $TARGET_DIR/bin && ./start.sh

  To use groestlcoin-cli program:

      cd $TARGET_DIR/bin && ./groestlcoin-cli -conf=$TARGET_DIR/.groestlcoin/groestlcoin.conf getnetworkinfo

  To view Groestlcoin Core log file:

      tail -f $TARGET_DIR/.groestlcoin/debug.log

  To uninstall Groestlcoin Core:

      ./install-full-node.sh -u

EOF
}

welcome(){
cat <<EOF

  Welcome!

  You are about to install a Groestlcoin full node based on Groestlcoin Core v$VERSION.

  All files will be installed under $TARGET_DIR directory.

  Your node will be configured to accept incoming connections from other nodes in
  the Groestlcoin network by using uPnP feature on your router.

  For security reason, wallet functionality is not enabled by default.

  After the installation, it may take several hours for your node to download a
  full copy of the blockchain.

  If you wish to uninstall Groestlcoin Core later, you can download this script and
  run "sh install-full-node.sh -u".

EOF
}

config_file(){
cat  <<EOF
listen=1
server=1
bind=0.0.0.0
port=$PORT
maxconnections=64
upnp=1
dbcache=5094
par=2
checkblocks=24
checklevel=0
disablewallet=0
timeout=6000
rpcauth=foo:abb4d11ae9ebbd29e050566bcb85fcb4$ccdbda870e28a23b60b3037aebf82832a18862860e6aaa2b95eb86131caeb350
rpcuser=foo
rpcpassword=WzW8vHRH6u48TW7qizm-CHgJNMffLJXjMPDBpwH38qQ=
rpcbind=127.0.0.1
rpcport=1441
EOF
}

start_sh(){
cat <<EOF
	#!/bin/sh
	if [ -f $TARGET_DIR/bin/groestlcoind ]; then
	    $TARGET_DIR/bin/groestlcoind -conf=$TARGET_DIR/.groestlcoin/groestlcoin.conf -datadir=$TARGET_DIR/.groestlcoin -daemon
	fi
EOF
}

stop_sh(){
cat  <<EOF
	#!/bin/sh
	if [ -f $TARGET_DIR/.groestlcoin/groestlcoind.pid ]; then
	    kill \$(cat $TARGET_DIR/.groestlcoin/groestlcoind.pid)
	fi
EOF
}

start_qt_sh(){
cat<<EOF
  #!/bin/sh
	if [ -f $TARGET_DIR/bin/groestlcoin-qt ]; then
      $TARGET_DIR/bin/groestlcoin-qt -conf=$TARGET_DIR/.groestlcoin/groestlcoin.conf -datadir=$TARGET_DIR/.groestlcoin -server
  fi
EOF
}

create_target_dir() {
    if [ ! -d "$TARGET_DIR" ]; then
        print_info "\nCreating target directory: $TARGET_DIR"
        mkdir -p $TARGET_DIR
        print_success "Target directory: $TARGET_DIR created successfully"
    else
      print_info "\nTarget directory: $TARGET_DIR already exists."
    fi
}

init_system_install() {
    if [ $(id -u) -ne 0 ]; then
        if program_exists "sudo"; then
            SUDO="sudo"
            print_info "\nInstalling required system packages.."
        else
            print_error "\nsudo program is required to install system packages. Please install sudo as root and rerun this script as normal user."
            exit 1
        fi
    fi
}

install_miniupnpc() {
    print_info "Installing miniupnpc from source.."
    rm -rf miniupnpc-2.0 miniupnpc-2.0.tar.gz &&
        wget -q http://miniupnp.free.fr/files/download.php?file=miniupnpc-2.0.tar.gz -O miniupnpc-2.0.tar.gz && \
        tar xzf miniupnpc-2.0.tar.gz && \
        cd miniupnpc-2.0 && \
        $SUDO $MAKE install > build.out 2>&1 && \
        cd .. && \
        rm -rf miniupnpc-2.0 miniupnpc-2.0.tar.gz
}

install_debian_build_dependencies() {
    $SUDO apt-get update
    $SUDO apt-get install -y \
        automake \
        autotools-dev \
        build-essential \
        curl \
        git \
        libboost-all-dev \
        libevent-dev \
        libminiupnpc-dev \
        libssl-dev \
        libtool \
        pkg-config
}

install_fedora_build_dependencies() {
    $SUDO dnf install -y \
        automake \
        boost-devel \
        curl \
        gcc-c++ \
        git \
        libevent-devel \
        libtool \
        miniupnpc-devel \
        openssl-devel
}

install_centos_build_dependencies() {
    $SUDO yum install -y \
        automake \
        boost-devel \
        curl \
        gcc-c++ \
        git \
        libevent-devel \
        libtool \
        openssl-devel
    install_miniupnpc
    echo '/usr/lib' | $SUDO tee /etc/ld.so.conf.d/miniupnpc-x86.conf > /dev/null && $SUDO ldconfig
}

install_archlinux_build_dependencies() {
    $SUDO pacman -S --noconfirm \
        automake \
        boost \
        curl \
        git \
        libevent \
        libtool \
        miniupnpc \
        openssl
}

install_alpine_build_dependencies() {
    $SUDO apk update
    $SUDO apk add \
        autoconf \
        automake \
        boost-dev \
        build-base \
        curl \
        git \
        libevent-dev \
        libtool \
        openssl-dev
    install_miniupnpc
}

install_mac_build_dependencies() {
    if ! program_exists "gcc"; then
        print_info "When the popup appears, click 'Install' to install the XCode Command Line Tools."
        xcode-select --install
    fi

    if ! program_exists "brew"; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    brew install \
        --c++11 \
        automake \
        boost \
        libevent \
        libtool \
        miniupnpc \
        openssl \
        pkg-config
}

install_freebsd_build_dependencies() {
    $SUDO pkg install -y \
        autoconf \
        automake \
        boost-libs \
        curl \
        git \
        gmake \
        libevent2 \
        libtool \
        openssl \
        pkgconf \
        wget
    install_miniupnpc
}

install_build_dependencies() {
    init_system_install
    case "$SYSTEM" in
        Linux)
            if program_exists "apt-get"; then
                install_debian_build_dependencies
            elif program_exists "dnf"; then
                install_fedora_build_dependencies
            elif program_exists "yum"; then
                install_centos_build_dependencies
            elif program_exists "pacman"; then
                install_archlinux_build_dependencies
            elif program_exists "apk"; then
                install_alpine_build_dependencies
            else
                print_error "\nSorry, your system is not supported by this installer."
                exit 1
            fi
            ;;
        Darwin)
            install_mac_build_dependencies
            ;;
        FreeBSD)
            install_freebsd_build_dependencies
            ;;
        *)
            print_error "\nSorry, your system is not supported by this installer."
            exit 1
            ;;
    esac
}

get_bin_url() {
    url="https://github.com/Groestlcoin/groestlcoin/releases/download/v$VERSION"
    case "$SYSTEM" in
        Linux)
            if program_exists "apk"; then
                echo ""
            elif [ "$ARCH" = "armv7l" ]; then
                url="$url/groestlcoin-$VERSION-arm-linux-gnueabihf.tar.gz"
                echo "$url"
            else
                url="$url/groestlcoin-$VERSION-$ARCH-linux-gnu.tar.gz"
                echo "$url"
            fi
            ;;
        Darwin)
            url="$url/groestlcoin-$VERSION-osx64.tar.gz"
            echo "$url"
            ;;
        FreeBSD)
            echo ""
            ;;
        *)
            echo ""
            ;;
    esac
}

download_bin() {
    checksum_url="https://github.com/Groestlcoin/groestlcoin/releases/download/v$VERSION/SHA256SUMS.asc"
    signing_key_url="https://groestlcoin.org/jackielove4u.asc"

    cd $TARGET_DIR

    rm -f groestlcoin-$VERSION.tar.gz checksum.asc signing_key.asc

    print_info "\nDownloading Groestlcoin Core binaries.."
    if program_exists "wget"; then
        wget -q "$1" -O groestlcoin-$VERSION.tar.gz &&
        wget -q "$checksum_url" -O checksum.asc &&
        wget -q "$signing_key_url" -O signing_key.asc &&
        mkdir -p groestlcoin-$VERSION &&
        tar xzf groestlcoin-$VERSION.tar.gz -C groestlcoin-$VERSION --strip-components=1
    elif program_exists "curl"; then
        curl -s "$1" -o groestlcoin-$VERSION.tar.gz &&
        curl -s "$checksum_url" -o checksum.asc &&
        curl -s "$signing_key_url" -o signing_key.asc &&
        mkdir -p groestlcoin-$VERSION &&
        tar xzf groestlcoin-$VERSION.tar.gz -C groestlcoin-$VERSION --strip-components=1
    else
        print_error "\nwget or curl program is required to continue. Please install wget or curl as root and rerun this script as normal user."
        exit 1
    fi

    if program_exists "shasum"; then
        checksum=$(shasum -a 256 groestlcoin-$VERSION.tar.gz | awk '{ print $1 }')
        if grep -q "$checksum" checksum.asc; then
            print_success "Checksum passed: groestlcoin-$VERSION.tar.gz ($checksum)"
        else
            print_error "Checksum failed: groestlcoin-$VERSION.tar.gz ($checksum). Please rerun this script to download and validate the binaries again."
            exit 1
        fi
    fi

    if program_exists "gpg"; then
        gpg --import signing_key.asc 2> /dev/null
        gpg --verify checksum.asc 2> /dev/null
        retcode=$?
        if [ $retcode -eq 0 ]; then
            print_success "Signature passed: Signed checksum.asc verified successfully!"
        else
            print_error "Signature failed: Signed checksum.asc cannot be verified."
            exit 1
        fi
    fi

    rm -f groestlcoin-$VERSION.tar.gz checksum.asc signing_key.asc
}

build_groestlcoin_core() {
    cd $TARGET_DIR

    if [ ! -d "$TARGET_DIR/groestlcoin" ]; then
        print_info "\nDownloading Groestlcoin Core source files.."
        git clone --quiet $REPO_URL
    fi

    # Tune gcc to use less memory on single board computers.
    cxxflags=""
    if [ "$SYSTEM" = "Linux" ]; then
        ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        if [ $ram_kb -lt 1500000 ]; then
            cxxflags="--param ggc-min-expand=1 --param ggc-min-heapsize=32768"
        fi
    fi

    print_info "\nBuilding Groestlcoin Core v$VERSION"
    print_info "Build output: $TARGET_DIR/groestlcoin/build.out"
    print_info "This can take up to an hour or more.."
    rm -f build.out
    cd groestlcoin &&
    git fetch > build.out 2>&1 &&
    git checkout "v$VERSION" 1>> build.out 2>&1 &&
    git clean -f -d -x 1>> build.out 2>&1 &&
    ./autogen.sh 1>> build.out 2>&1 &&
    ./configure \
        CXXFLAGS="$cxxflags" \
        --without-gui \
        --with-miniupnpc \
        --disable-wallet \
        --disable-tests \
        --enable-upnp-default \
        1>> build.out 2>&1 &&
    $MAKE 1>> build.out 2>&1

    if [ ! -f "$TARGET_DIR/groestlcoin/src/groestlcoind" ]; then
        print_error "Build failed. See $TARGET_DIR/groestlcoin/build.out"
        exit 1
    fi

    sleep 1

    $TARGET_DIR/groestlcoin/src/groestlcoind -? > /dev/null
    retcode=$?
    if [ $retcode -ne 1 ]; then
        print_error "Failed to execute $TARGET_DIR/groestlcoin/src/groestlcoind. See $TARGET_DIR/groestlcoin/build.out"
        exit 1
    fi
}

install_groestlcoin_core() {
    cd $TARGET_DIR

    print_info "\nInstalling Groestlcoin Core v$VERSION"

    if [ ! -d "$TARGET_DIR/bin" ]; then
        mkdir -p $TARGET_DIR/bin
    fi

    if [ ! -d "$TARGET_DIR/.groestlcoin" ]; then
        mkdir -p $TARGET_DIR/.groestlcoin
    fi

    if [ "$SYSTEM" = "Darwin" ]; then
        if [ ! -e "$HOME/Library/Application Support/Groestlcoin" ]; then
            ln -s $TARGET_DIR/.groestlcoin "$HOME/Library/Application Support/Groestlcoin"
        fi
    else
        if [ ! -e "$HOME/.groestlcoin" ]; then
            ln -s $TARGET_DIR/.groestlcoin $HOME/.groestlcoin
        fi
    fi

    if [ -f "$TARGET_DIR/groestlcoin/src/groestlcoind" ]; then
        # Install compiled binaries.
        cp "$TARGET_DIR/groestlcoin/src/groestlcoind" "$TARGET_DIR/bin/" &&
        cp "$TARGET_DIR/groestlcoin/src/groestlcoin-cli" "$TARGET_DIR/bin/" &&
        print_success "Groestlcoin Core v$VERSION (compiled) installed successfully!"
    elif [ -f "$TARGET_DIR/groestlcoin-$VERSION/bin/groestlcoind" ]; then
        # Install downloaded binaries.
        cp "$TARGET_DIR/groestlcoin-$VERSION/bin/groestlcoind" "$TARGET_DIR/bin/" &&
        cp "$TARGET_DIR/groestlcoin-$VERSION/bin/groestlcoin-cli" "$TARGET_DIR/bin/" &&
        cp "$TARGET_DIR/groestlcoin-$VERSION/bin/groestlcoin-qt" "$TARGET_DIR/bin/" &&
        cp "$TARGET_DIR/groestlcoin-$VERSION/bin/groestlcoin-tx" "$TARGET_DIR/bin/" &&
        cp "$TARGET_DIR/groestlcoin-$VERSION/bin/groestlcoin-wallet" "$TARGET_DIR/bin/" &&
        cp "$TARGET_DIR/groestlcoin-$VERSION/bin/test_groestlcoin" "$TARGET_DIR/bin/" &&
        rm -rf "$TARGET_DIR/groestlcoin-$VERSION"
        print_success "Groestlcoin Core v$VERSION (binaries) installed successfully!"
    else
        print_error "Cannot find files to install."
        exit 1
    fi

    config_file >  "$TARGET_DIR/.groestlcoin/groestlcoin.conf"
    chmod go-rw $TARGET_DIR/.groestlcoin/groestlcoin.conf

    start_sh > $TARGET_DIR/bin/start.sh
    chmod ugo+x $TARGET_DIR/bin/start.sh

    stop_sh > $TARGET_DIR/bin/stop.sh
    chmod ugo+x $TARGET_DIR/bin/stop.sh

    start_qt_sh > $TARGET_DIR/bin/start-qt.sh
    chmod ugo+x $TARGET_DIR/bin/start-qt.sh
}

start_groestlcoin_core() {
    if [ ! -f $TARGET_DIR/.groestlcoin/groestlcoind.pid ]; then
        print_info "\nStarting Groestlcoin Core.."
        cd $TARGET_DIR/bin && ./start.sh

        timer=0
        until [ -f $TARGET_DIR/.groestlcoin/groestlcoind.pid ] || [ $timer -eq 5 ]; do
            timer=$((timer + 1))
            sleep $timer
        done

        if [ -f $TARGET_DIR/.groestlcoin/groestlcoind.pid ]; then
            print_success "Groestlcoin Core is running!"
        else
            print_error "Failed to start Groestlcoin Core."
            exit 1
        fi
    fi
}

stop_groestlcoin_core() {
    if [ -f $TARGET_DIR/.groestlcoin/groestlcoind.pid ]; then
        print_info "\nStopping Groestlcoin Core.."
        cd $TARGET_DIR/bin && ./stop.sh

        timer=0
        until [ ! -f $TARGET_DIR/.groestlcoin/groestlcoind.pid ] || [ $timer -eq 120 ]; do
            timer=$((timer + 1))
            sleep $timer
        done

        if [ ! -f $TARGET_DIR/.groestlcoin/groestlcoind.pid ]; then
            print_success "Groestlcoin Core stopped."
        else
            print_error "Failed to stop Groestlcoin Core."
            exit 1
        fi
    fi
}

check_groestlcoin_core() {
    if [ -f $TARGET_DIR/.groestlcoin/groestlcoind.pid ]; then
        if [ -f $TARGET_DIR/bin/groestlcoin-cli ]; then
            print_info "\nChecking Groestlcoin Core.."
            sleep 5
            $TARGET_DIR/bin/groestlcoin-cli -conf=$TARGET_DIR/.groestlcoin/groestlcoin.conf -datadir=$TARGET_DIR/.groestlcoin getnetworkinfo
        fi

        reachable=$(curl -I https://bitnodes.io/api/v1/nodes/me-$PORT/ 2> /dev/null | head -n 1 | cut -d ' ' -f2)
        if [ $reachable -eq 200 ]; then
            print_success "Groestlcoin Core is accepting incoming connections at port $PORT!"
        else
            print_warning "Groestlcoin Core is not accepting incoming connections at port $PORT. You may need to configure port forwarding on your router."
        fi
    fi
}

uninstall_groestlcoin_core() {
    stop_groestlcoin_core

    if [ -d "$TARGET_DIR" ]; then
        print_info "\nUninstalling Groestlcoin Core.."
        rm -rf $TARGET_DIR

        # Remove stale symlink.
        if [ "$SYSTEM" = "Darwin" ]; then
            if [ -L "$HOME/Library/Application Support/Groestlcoin" ] && [ ! -d "$HOME/Library/Application Support/Groestlcoin" ]; then
                rm "$HOME/Library/Application Support/Groestlcoin"
            fi
        else
            if [ -L $HOME/.groestlcoin ] && [ ! -d $HOME/.groestlcoin ]; then
                rm $HOME/.groestlcoin
            fi
        fi

        if [ ! -d "$TARGET_DIR" ]; then
            print_success "Groestlcoin Core uninstalled successfully!"
        else
            print_error "Uninstallation failed. Is Groestlcoin Core still running?"
            exit 1
        fi
    else
        print_error "Groestlcoin Core not installed."
    fi
}

while getopts ":v:t:p:bu" opt
do
    case "$opt" in
        v)
            VERSION=${OPTARG}
            ;;
        t)
            TARGET_DIR=${OPTARG}
            ;;
        p)
            PORT=${OPTARG}
            ;;
        b)
            BUILD=1
            ;;
        u)
            UNINSTALL=1
            ;;
        h)
            help
            exit 0
            ;;
        ?)
            help >& 2
            exit 1
            ;;
    esac
done

print_start

if [ $UNINSTALL -eq 1 ]; then
    echo
    read -p "WARNING: This will stop Groestlcoin Core and uninstall it from your system. Uninstall? (y/n) " answer
    if [ "$answer" = "y" ]; then
        uninstall_groestlcoin_core
    fi
else
    welcome
    if [ -t 0 ]; then
        # Prompt for confirmation when invoked in tty.
        echo
        read -p "Install? (y/n) " answer
    else
        # Continue installation when invoked via pipe, e.g. curl .. | sh
        answer="y"
        echo
        echo "Starting installation in 10 seconds.."
        sleep 10
    fi
    if [ "$answer" = "y" ]; then
        if [ "$BUILD" -eq 0 ]; then
            bin_url=$(get_bin_url)
        else
            bin_url=""
        fi
        stop_groestlcoin_core
        create_target_dir
        if [ "$bin_url" != "" ]; then
            download_bin "$bin_url"
        else
            install_build_dependencies && build_groestlcoin_core
        fi
        install_groestlcoin_core && start_groestlcoin_core && check_groestlcoin_core
        readme > $TARGET_DIR/README.md
        cat $TARGET_DIR/README.md
        print_success "If this your first install, Groestlcoin Core may take several hours to download a full copy of the blockchain."
        print_success "\nInstallation completed!"
    fi
fi

print_end
