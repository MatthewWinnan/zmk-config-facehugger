{
  mkShellNoCC,
  zephyr,
  cmake,
  dtc,
  ninja,
  just,
  yq,
  python3Packages,
  ...
}: let
  keymap_drawer = python3Packages.callPackage ../packages/keymap {};
in
  mkShellNoCC {
    packages = [
      # Python Env Dependencies
      (zephyr.sdk.override {
        targets = [
          "arm-zephyr-eabi"
        ];
      })
      zephyr.pythonEnv
      zephyr.hosttools-nix

      cmake
      dtc
      ninja

      just
      yq # Make sure yq resolves to python-yq.

      keymap_drawer
    ];
  }
