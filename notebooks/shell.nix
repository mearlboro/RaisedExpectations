{ pkgs ? import <nixpkgs> {} }:

let

  pyPkgs = pkgs.python312.withPackages (ps: with ps; [
    jupyter
    ipython

    matplotlib
		jpype1
    mypy
    numpy
    scipy
		pandas
    seaborn
    pip
    setuptools
  ]);

  sysPkgs = with pkgs; [
    jdk_headless
    mypy
  ];

  powerlaw = pkgs.fetchFromGitHub {
     owner = "schae234";
     repo  = "powerlaw";
     rev   = "f95e8057128f132be6ee8ac5ed5c419a6ead97f1";
     hash  = "sha256-m2psea9y4zmk2P1/skBPTMrCsV7UFC0Ew85ikDz4SK8=";
  };

in

pkgs.mkShell {
  buildInputs = [ pyPkgs sysPkgs ];

  shellHook = ''
    # Allow the use of wheels.
    SOURCE_DATE_EPOCH=$(date +%s)

    # Add powerlaw to path
    export PYTHONPATH=$PWD:${powerlaw}:$PYTHONPATH
    '';
}
