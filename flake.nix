{
  description = "Base58 Lightning Network Class";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        clightning = pkgs.clightning.overrideAttrs (final: prev: {
            version = "v23.11rc1";
            src = pkgs.fetchFromGitHub {
                owner = "ElementsProject";
                repo = "lightning";
                rev = "v23.11rc1";
                fetchSubmodules = true;
                sha256 = "sha256-qKmb++5DrJ8/hgg+mksOSPo3h5m3aAGOHBR6BkZw3TM=";
            };
            configureFlags = [ "--disable-valgrind" ];
            makeFlags = [ "VERSION=v23.11rc1" ];
        });
        pyln_bolt7 = pkgs.python3Packages.buildPythonPackage rec {
            pname = "pyln_bolt7";
            version = "cd894663";
            src = pkgs.fetchFromGitHub {
              owner = "niftynei";
              repo = "${pname}";
              rev = "${version}";
              sha256 = "sha256-//XG8aF2mW5DX0sBsAV1bL+9RLrvUXYpPSX9bz5f/OU=";
            };
            doCheck = false;
            propagatedBuildInputs = [];
        };
        pyln_proto = pkgs.python3Packages.buildPythonPackage rec {
            pname = "pyln_proto";
            version = "87643bed";
            src = pkgs.fetchFromGitHub {
              owner = "niftynei";
              repo = "${pname}";
              rev = "${version}";
              sha256 = "sha256-q8Qh39e23C0jyerRlfobArKwWB9Zj3ghFS479oxcep8=";
            };
            doCheck = false;
            propagatedBuildInputs = [];
        };
        pyln_client = pkgs.python3Packages.buildPythonPackage rec {
            pname = "pyln_client";
            version = "23.5.2";
            src = pkgs.fetchFromGitHub {
              inherit version;
              owner = "niftynei";
              repo = "${pname}";
              rev = "250b8a2";
              sha256 = "sha256-vhGyBA5C5bgi5nMHgs9hjIUGOOKTwV31/OeBnQJUaL0=";
            };
            doCheck = false;
            propagatedBuildInputs = [ pyln_proto pyln_bolt7];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bashInteractive
            jq
            bitcoind
            clightning
            magic-wormhole
            pyln_client
            pyln_proto
            pyln_bolt7

            (python3.withPackages (ps: with ps; with python3Packages; [
              jupyter
              ipython
              pip
              base58
              bitstring
              pysocks
              cryptography
              coincurve
            ]))
          ];
          # Automatically run jupyter when entering the shell.
          #shellHook = "jupyter notebook";

          BITCOIN_BIN_DIR= "${pkgs.bitcoind}/bin";
          PATH_TO_LIGHTNING = "${clightning}/bin";
        };
      });
}
