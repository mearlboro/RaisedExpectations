{ pkgs ? import <nixpkgs> {} }:

let

  pyPkgs = pkgs.python312.withPackages (ps: with ps; [
    pip
    setuptools
    mypy
    jupyter
    ipython
    matplotlib
    seaborn
    numpy
    scipy
		pandas
    jpype1
    scikit-learn
    colorama
  ]);

  sysPkgs = with pkgs; [
    jdk_headless
    mypy
  ];

  pyspi = pkgs.fetchFromGitHub {
     owner = "DynamicsAndNeuralSystems";
     repo  = "pyspi";
     rev   = "542defa907b8a27401bdeeb7a4b72dfde63d84ac";
     hash  = "sha256-kttV1wMTA/CFjfkuK4dKNb+3325FhqlBOls7D3samYo=";
  };
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
    export PYTHONPATH=$PWD:${powerlaw}:${pyspi}:$PYTHONPATH
    '';
}
