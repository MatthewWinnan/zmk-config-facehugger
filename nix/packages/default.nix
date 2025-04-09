{callPackage, ...}: {
  kyria_left = callPackage ./kyria/kyria_left.nix {};
  kyria_right = callPackage ./kyria/kyria_right.nix {};
  tie_tem_left = callPackage ./tie_tem/tie_tem_left.nix {};
  tie_tem_right = callPackage ./tie_tem/tie_tem_right.nix {};
}
