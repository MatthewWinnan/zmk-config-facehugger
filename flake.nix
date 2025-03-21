{
  description = "Flakes for ZMK based projects";

  inputs = {
   # unstable gcovr is missing from the zephyr python environment
   nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

   # Customize the version of Zephyr used by the flake here
    zephyr = {
      url = "github:zephyrproject-rtos/zephyr/v3.5.0";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    zephyr-nix = {
      url = "github:adisbladis/zephyr-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zephyr.follows = "zephyr";
    };

    west2nix = {
      url = "github:adisbladis/west2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zephyr-nix.follows = "zephyr-nix";
    };
  };

   outputs = { self, nixpkgs, flake-utils, ... }@inputs: (
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zephyr = inputs.zephyr-nix.packages.${system};

        callPackage = pkgs.newScope (pkgs // {
          zephyr = inputs.zephyr-nix.packages.${system};
          west2nix = callPackage inputs.west2nix.lib.mkWest2nix { };
        });
      in
      {
        devShells.kyria = callPackage ./kyria_v3/shell.nix { };
      }
    ));
}
