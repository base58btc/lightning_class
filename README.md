# Base58 Lightning Class Notebooks

Notebooks and gossip store used for the November 2023 @base58btc class
at PlebLab in Austin, TX.

## Use nix

Use nix to import all the dependencies you need to get the plugin
and lightning examples running.

```
	nix develop
```

Once nix is up and running, you can add in some utilities
for running a test lightning node network using the
startup regtest script.

```
	source startup_regtest.sh
```

To get two nodes up and running on regtest, run `start_ln`.

This will print out a list of commands. Try

```
	fund_nodes
```

To have all the nodes connect to each other with balanced channels
using the v2 open protocol :)
