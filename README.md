# groestlcoin-core-setup
Groestlcoin Full Node SetUp

The install-full-node.sh script is based on [bitnodes script](https://bitnodes.io/install-full-node.sh) with some custom changes.

# Getting started

1.  Clone this repository.
```sh
$ git clone https://github.com/Groestlcoin/groestlcoin-core-setup.git
```

2. Open a terminal and navigate to the folder where the repository was cloned.
3. Change the access permission of install-full-node.sh
```sh
$ chmod +x install-full-node.sh
```
4. Execute the shell script
```sh
$ ./install-full-node.sh
```

# Usage  
This is the install script for Groestlcoin full node based on Groestlcoin Core.

  Usage: ./install-full-node.sh [-h] [-v <version>] [-t <target_directory>] [-p <port>] [-b] [-u]

  -h
      Print help.

  -v <version>
      Version of Groestlcoin Core to install.
      Default: 2.20.1

  -t <target_directory>
      Target directory for source files and binaries.
      Default: /Users/Groestlcoin/groestlcoin-core

  -p <port>
      Groestlcoin Core listening port.
      Default: 1331

  -b
      Build and install Groestlcoin Core from source.
      Default: 0

  -u
      Uninstall Groestlcoin Core.

# Once groestlcoin core is successfully installed

To stop Groestlcoin Core:
```sh
$ cd $TARGET_DIR/bin && ./stop.sh
```

To start Groestlcoin Core again:
```sh
$ cd $TARGET_DIR/bin && ./start.sh
```

To use groestlcoin-cli program:
```sh
$ cd $TARGET_DIR/bin && ./groestlcoin-cli -conf=$TARGET_DIR/.groestlcoin/groestlcoin.conf getnetworkinfo
```

To view Groestlcoin Core log file:
```sh
$ tail -f $TARGET_DIR/.groestlcoin/debug.log
```

To uninstall Groestlcoin Core:
```sh
$ ./install-full-node.sh -u
```
