{
  zephyr,
  west2nix,
  stdenv,
  multiStdenv,
  lib,
  cmake,
  ninja,
  git,
  callPackage,
  just,
  ...
}: let
  # We need 32-bit support
  stdenv_32 =
    if stdenv.hostPlatform.isLinux
    then multiStdenv
    else stdenv;
in
  stdenv_32.mkDerivation {
    name = "kyria-shell";

    buildInputs = [
      # Python Env Dependencies
      (zephyr.sdk.override {
        targets = [
          "arm-zephyr-eabi"
        ];
      })
      zephyr.pythonEnv
      zephyr.hosttools-nix

      west2nix.west2nix

      cmake
      ninja
      git
      just
    ];

    shellHook = ''

      echo "KYRIA Rev3 Development Environment"

      # Move into the directory
      cd zmk/kyria/

      # We need to establish if this is the first time west has been used, thus has it been initialized
      if [ -d ".west" ]; then
        echo "West has been initialized.";
      else
        echo "West has not been initialized. Initializing";
        west init -l config/;
      fi

      # We always need to update
      west update;

      # Export runtime variables
      west zephyr-export;

      # Configure the cmake exports, we can use west config -l to see if this is done, but complex bash is annoying
      west config build.cmake-args -- "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DZMK_CONFIG=$(git rev-parse --show-toplevel)/zmk/kyria/config"

      # Now if the build does exist we can symlink the compile_commands
      if [ -d "firmware" ]; then
        ln -fs firmware/compile_commands.json .;
      else
        echo "There has been no builds yet, as such can not symlink compile_commands";
      fi

    '';
  }
