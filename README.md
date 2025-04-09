# FaceHugger's ZMK Config

## Introduction

The following serves as a mono-repo for all to required configuration files and build files for my [ZMK](https://zmk.dev/) based keyboards.

The main tool I am using is [Zephyr](https://github.com/adisbladis/west2nix)'s own meta-tool [West](https://docs.zephyrproject.org/latest/develop/west/index.html).

The build environments are configured using the [Nix](https://nixos.org/) declarative language and open Nix modules by [adisbladis](https://github.com/adisbladis).
These include their [zephyr-nix](https://github.com/adisbladis/zephyr-nix) and [west2nix](https://github.com/adisbladis/west2nix) modules.

## Basic Structure

The project files are split into two main sections. The `nix` directory contains all the nix code used to generate the
development environments and the final build environment.

This directory is further split into `packages` and `shell`.

The `shell` directory contains the needed nix code to perform the following steps:
- Builds the needed Zephyr SDK and adds it to `buildInputs` for use.
- Builds the needed Zephyr python environment used to coding and running west.
- Contains the `west2nix` tool which use is documented in the [West2Nix Example](https://github.com/adisbladis/west2nix/tree/master/templates/application)
- Adds simple dependencies like `cmake`, `ninja` and `git`.
- If a west manifest directory does not exist is creates one in root.
- Updates the west manifest.
- Exports the Zephyr build environment variables.
- Configure some cmake options for west to point to the right keymap config file and to export compile commands. This
is important for static code analysis and for LSP services to work.

The main shell is added into nix/shell/default.nix as a key value pair and simply called from the flakes.nix

The `packages` directory contains the needed nix code to build a reproducible uf2 image used in conjunction with the built
in bootloader used by most hobby microcontrollers to flash the firmware.

This directory is further defined in subdirectories whose names correspond to the names of the keyboards being built for.
The contents of these subdirectories include the needed nix build code. In the general the code is in charge of
the following steps:
- Builds the needed Zephyr SDK and adds it to `buildInputs` for use.
- Builds the needed Zephyr python environment used to coding and running west.
- Adds the `mkWest2nixHook` hook as provided by [west2nix](https://github.com/adisbladis/west2nix)
- Overrides the `configPhase` to ensure the needed board configs are in the right place. Configures the west config
file to add `board-shield` specific settings and the location of the board config files. Tells cmake where Zephyr is located
since we can not use the typical west commands for this. In this override `__west2nix_configureHook` and `__west2nix_copyProjectsHook` are
manually called.
- Builds the ZMK project and copies the resultant .uf2 binary to the output directory.

Project build configurations are added under nix/packages/default.nix as key value pairs. This is then again just called from the flakes.

The `zmk` directory contains the needed config and west.yaml files to fetch the needed source code
to build the firmware one can use to flash the keyboards with.

The `zmk` directory is further divided into sub-directories whose names correspond to the boards one
wishes to make firmware for (similar to the case of the `nix shell` and `nix packages` directory.).

Under these named directories the only needed part is the `config` sub-directory which contains the following:
- The keyboard specific configuration file.
- The desired keyboards keymap file.
- The west.yml file.
- west2nix.toml whose contents are the frozen west manifest formatted into a structure `west2nix` can ingest.

Optionally one can add board specific overlay files, which are of themselves device tree .dtsi files. Please consult
[ZMK Configuration Overview](https://zmk.dev/docs/config) for more information and for what else can be done here.

The parent directory (the names directory under zmk/) is then further used to contain all of the project files such as:
- The loaded modules used by ZMK.
- The ZMK source code.
- The desired zephyr source code.

These are loaded in by west update during the usage of the development environment mentioned above.
The gitignore is already configured to not commit any of these artifacts, however including them will simplify the
needed `west2nix` process and eliminate the need to perform the `configPhase` overwrite.

In this repo the decision was made to keep it lean and only include configuration files needed to set the project up
and get to building.

## Basic usage

The basic workflow can be summarized as follows.

Add your desired board config files under `zmk/<board_name>/config`.

Next add your development shell to `nix/shell/<boardname>.nix` and add it to the default.nix
file included in nix/shell/. Use the provided shells as examples.

Run the shell with `nix develop .#board_name`. You can configure [Direnv](https://direnv.net/) to perform this step when
one is busy with a specific project, or to configure some sort of default shell. I prefer not to and have dedicated shells
for each project and I don't want to have to switch it around in the .envrc config.

After waiting for west to update and being happy with the configuration of the board you should then ensure all
the west modules are pinned locally and upstream.

`west --freeze` can only provide a frozen manifest if all of the files are committed.
In my case the upstream babblesim and optional groups in the ZMK fork of Zephyr was not pinned and I had
to exclude it with the parameter `name-blocklist`.

For more information about the west manifest please consult [West Manifests](https://docs.zephyrproject.org/latest/develop/west/manifest.html#west-manifest-groups).

If you can freeze the manifest then it is possible to run `west2nix` to produce the needed `west2nix.toml` file which can then be ingested by
west2nix.

Next create a build config under `nix/packages/<board_name>`. Typically one would need to include two, one for the left and another for the right
side. Non split keyboards only need one and as such you can just have a central one. Here there is no convention, just make it reasonable.

Use the included build configs for examples.

Add the final build configs to `nix/packages/default.nix` and then one can build it with `nix build .#<build_name>`. The final .uf2 file
will be located in the symlinked results/ directory. This is directly references into the nix store, as such this can be used within other hooks
and or derivations to perform automatic renaming, group building, flashing and so forth.

## Supported Boards
- The [Kyria](https://docs.splitkb.com/product-guides/kyria) revision 3.
- Modified hand wired [TOTEM](https://github.com/GEIGEIGEIST/TOTEM) keyboard called the [TIE-TEM](https://github.com/MatthewWinnan/TIE-TEM).

## Additional Flake features

I have included the [Alejandra](https://github.com/kamadorueda/alejandra) nix formatter. To format any nix code simply use `nix fmt` within the
flake directory. You can further define what needs to be formatted. Simply run `nix fmt --help` for additional commands.

## Current issues to work on

- I need a per left side override on .keymap config level. This is due to me assembling the board incorrectly,
currently I am overriding the row declarations in the dtsi, but I would rather not.

## Special Thanks

- [urob](https://github.com/urob) for their amazing ZMK modules and helper configs.
- [adisbladis](https://github.com/adisbladis) for their west2nix and zephyr-nix nix modules.
