{callPackage, ...}: {
  kyria_left = callPackage ./kyria/kyria_left.nix {};
  kyria_right = callPackage ./kyria/kyria_right.nix {};
}
