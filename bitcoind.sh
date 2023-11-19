if [ -z "$PATH_TO_BITCOIN" ]; then
    DIR=.bitcoin
else
    DIR=$PATH_TO_BITCOIN
fi

echo "Using bitcoin dir: $DIR"

if [[ -s $DIR/bitcoind.port ]]; then
  PORT=$(cat $DIR/bitcoind.port)
  echo "existing port found $PORT"
else
  PORT=18443
fi
bitcoind -regtest -daemon -listen=0 -datadir=$DIR -rpcport=$PORT >/dev/null 2>&1 && sleep 1
if ! bitcoin-cli -regtest -datadir=$DIR -rpcport=$PORT -getinfo >/dev/null 2>&1; then
  for p in {18443..19000}; do (echo >/dev/tcp/localhost/$p) >/dev/null 2>&1 || { export PORT=$p; break; }; done;
  echo "Port $PORT occupied, launching new regtest node on port $PORT"
  echo -n $PORT > $DIR/bitcoind.port
  bitcoind -regtest -daemon -listen=0 -datadir=$DIR -rpcport=$PORT && sleep 1
  if bitcoin-cli -regtest -datadir=$DIR -rpcport=$PORT -getinfo; then
    alias btcli="bitcoin-cli -regtest -datadir=$DIR -rpcport=$PORT"
  fi
else
  alias btcli="bitcoin-cli -regtest -datadir=$DIR -rpcport=$PORT"
fi
