let
  mach-nix = import (builtins.fetchGit {
    url = "https://github.com/DavHau/mach-nix";
  }) {
    python = "python310";
  };

  pyEnv = mach-nix.mkPython rec {
    requirements = builtins.readFile ./requirements.txt;
  };

in

mach-nix.nixpkgs.mkShell {

  buildInputs = [
    pyEnv
  ] ;
  propagatedBuildInputs = [
    mach-nix.nixpkgs.mypy
    mach-nix.nixpkgs.jdk8_headless
  ];
}
