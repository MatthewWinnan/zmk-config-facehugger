default:
    @just --list --unsorted

tie_tem:
  nix develop .#tie_tem_shell

kyria:
  nix develop .#kyria_shell

tie_tem_build:
  mkdir -p firmware
  nix build .#tie_tem_left
  cp result/* firmware/
  nix build .#tie_tem_right
  cp result/* firmware/

kyria_build:
  mkdir -p firmware
  nix build .#kyria_left
  cp result/* firmware/
  nix build .#kyria_right
  cp result/* firmware/
