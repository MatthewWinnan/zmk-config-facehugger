# If you look at https://github.com/adisbladis/west2nix/blob/master/project-hook.sh
# And https://github.com/adisbladis/west2nix/blob/master/hook.nix
# It seems that project is being set based on where the west2nix.toml is located, we can make use of
# that or override the config phase and move manually to the correct source
{
  stdenv,
  zephyr, # from zephyr-nix
  callPackage,
  cmake,
  ninja,
  west2nix,
  gitMinimal,
  lib,
}: let
  west2nixHook = west2nix.mkWest2nixHook {
    manifest = ../../../zmk/kyria/config/west2nix.toml;
  };

  # For some reason I need to do this so I do not end up with a broken source path
  projectSource = lib.cleanSourceWith {
    src = ../../../.; # Base source (includes flake)
  };
in
  stdenv.mkDerivation {
    name = "kyria_left";

    nativeBuildInputs = [
      (zephyr.sdk.override {
        targets = [
          "arm-zephyr-eabi"
        ];
      })
      west2nixHook
      zephyr.pythonEnv
      zephyr.hosttools-nix
      gitMinimal
      cmake
      ninja
    ];

    # I am overriding the built in west2nixHook, this is due to ZMK being part of the west.yml itself thus not being pulled
    # In by the flakes, since it is not being managed by this repo
    configurePhase = ''
       __west2nix_copyProjectsHook

      # We need to copy things to standard directories for the __west2nix_configureHook
      mkdir config/
      cp zmk/kyria/config/* config/

       __west2nix_configureHook

       # Go back to root so we can continue, west2nix sends us to the config realm
       cd ..

       # We need to make the build directory so long, we can not do it within the git repo,
       # due to permissions problems
       mkdir build/

       # It does not seem to pick up where zephyr lives so we need to point it
       export CMAKE_PREFIX_PATH=$PWD/zephyr/

       # We further want to add cmake arguments, better to do it here since the -DSHIELD string is being parsed weirdly by
       # westBuildFlags
       west config build.cmake-args -- "-DSHIELD=\"kyria_rev3_left nice_view_adapter kyria_nice_view\" -DZMK_CONFIG=$PWD/zmk/kyria/config"
    '';

    # Note: This should be set by the hook but it's tricky to get the ordering correct
    dontUseCmakeConfigure = true;

    # I really do not get this one
    src = projectSource;

    westBuildFlags = [
      "-b"
      "nice_nano_v2"
      "-d"
      "build"
      "zmk-facehugger/app/"
    ];

    installPhase = ''
      mkdir $out
      cp ./build/zephyr/zmk.uf2 $out/kyria_rev3_left.uf2
    '';
  }
