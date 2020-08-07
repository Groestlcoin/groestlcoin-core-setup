# bitcoin-core-setup
Bitcoin Full Node SetUp

The install-full-node.sh script is based on [bitnodes script](https://bitnodes.io/install-full-node.sh) with some custom changes.

# Bitcoin Core: The Reference Implementation [Mastering Bitcoin](https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch03.asciidoc)

Bitcoin is an open source project and the source code is available under an open (MIT) license, free to download and use for any purpose. Open source means more than simply free to use. It also means that bitcoin is developed by an open community of volunteers. At first, that community consisted of only Satoshi Nakamoto. By 2016, bitcoin’s source code had more than 400 contributors with about a dozen developers working on the code almost full-time and several dozen more on a part-time basis. Anyone can contribute to the code—including you!

When bitcoin was created by Satoshi Nakamoto, the software was actually completed before the whitepaper reproduced in [satoshi_whitepaper] was written. Satoshi wanted to make sure it worked before writing about it. That first implementation, then simply known as "Bitcoin" or "Satoshi client," has been heavily modified and improved. It has evolved into what is known as Bitcoin Core, to differentiate it from other compatible implementations. Bitcoin Core is the reference implementation of the bitcoin system, meaning that it is the authoritative reference on how each part of the technology should be implemented. Bitcoin Core implements all aspects of bitcoin, including wallets, a transaction and block validation engine, and a full network node in the peer-to-peer bitcoin network.


Also visit [bitcoin.org](https://bitcoin.org/en/bitcoin-core/) for further information.

-   [What Is A Full Node?](https://bitcoin.org/en/full-node#what-is-a-full-node)
-   [Sample Bitcoin Configuration File](https://github.com/bitcoin/bitcoin/blob/master/share/examples/bitcoin.conf)
-   [Bitcoin Core Config Generator](https://jlopp.github.io/bitcoin-core-config-generator/)
-   [Networking Configuration](https://bitcoin.org/en/full-node#network-configuration)

# Getting started

1.  Clone this repository.
```sh
$ git clone https://github.com/cjrequena/bitcoin-core-setup.git
```

2. Open a terminal and navigate to the folder where the repository was cloned.
3. Change the access permission of install-full-node.sh
```sh
$ chmod +x install-full-node.sh
```
4. Excute the shell script
```sh
$ ./install-full-node.sh
```

# Usage  
This is the install script for Bitcoin full node based on Bitcoin Core.

  Usage: ./install-full-node.sh [-h] [-v <version>] [-t <target_directory>] [-p <port>] [-b] [-u]

  -h
      Print help.

  -v <version>
      Version of Bitcoin Core to install.
      Default: 0.19.0.1

  -t <target_directory>
      Target directory for source files and binaries.
      Default: /Users/cjrequena/bitcoin-core

  -p <port>
      Bitcoin Core listening port.
      Default: 8333

  -b
      Build and install Bitcoin Core from source.
      Default: 0

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
