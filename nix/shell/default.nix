{callPackage, ...}: {
  kyria_shell = callPackage ./kyria.nix {};
  tie_tem_shell = callPackage ./tie_tem.nix {};
}
