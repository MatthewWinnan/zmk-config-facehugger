{
  zephyr,
  west2nix,
  stdenv,
  multiStdenv,
  lib,
  cmake,
  ninja,
  callPackage,
  ...
}:
let
  # We need 32-bit support
  stdenv_32 = if stdenv.hostPlatform.isLinux then multiStdenv else stdenv;
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
  ];
}
