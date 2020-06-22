# bitcoin-core-setup
Bitcoin Full Node SetUp

The install-full-node.sh script is based on [bitnodes script](https://bitnodes.io/install-full-node.sh) with some custom changes.

# Bitcoin Core

Bitcoin Core is programmed to decide which block chain contains valid transactions. The users of Bitcoin Core only accept transactions 
for that block chain, making it the Bitcoin block chain that everyone else wants to use. For the latest developments related to Bitcoin Core, 
be sure to visit the project’s [official website](https://bitcoincore.org/).

Also visit [bitcoin.org](https://bitcoin.org/en/bitcoin-core/) for further information.

-   [What Is A Full Node?](https://bitcoin.org/en/full-node#what-is-a-full-node)
-   [Sample Bitcoin Configuration File](https://github.com/bitcoin/bitcoin/blob/master/share/examples/bitcoin.conf)
-   [Bitcoin Core Config Generator](https://jlopp.github.io/bitcoin-core-config-generator/)
-   [Networking Configuration](https://bitcoin.org/en/full-node#network-configuration)

# Usage

This is the install script for Bitcoin full node based on Bitcoin Core.

  Usage: $0 [-h] [-v <version>] [-t <target_directory>] [-p <port>] [-b] [-u]

  -h
      Print help.

  -v <version>
      Version of Bitcoin Core to install.
      Default: $VERSION

  -t <target_directory>
      Target directory for source files and binaries.
      Default: $HOME/bitcoin-core

  -p <port>
      Bitcoin Core listening port.
      Default: $PORT

  -b
      Build and install Bitcoin Core from source.
      Default: $BUILD

  -u
      Uninstall Bitcoin Core.
      
# Once bitcoin core is successfully installed

To stop Bitcoin Core:
```sh
$ cd $TARGET_DIR/bin && ./stop.sh
```
  
To start Bitcoin Core again:
```sh
$ cd $TARGET_DIR/bin && ./start.sh
```

To use bitcoin-cli program:
```sh
$ cd $TARGET_DIR/bin && ./bitcoin-cli -conf=$TARGET_DIR/.bitcoin/bitcoin.conf getnetworkinfo
```

To view Bitcoin Core log file:
```sh
$ tail -f $TARGET_DIR/.bitcoin/debug.log
```

To uninstall Bitcoin Core:
```sh
$ ./install-full-node.sh -u
```
