{ compiler ? "ghc8107"
, system ? builtins.currentSystem
, haskellNix ? import
    (builtins.fetchTarball
      "https://github.com/input-output-hk/haskell.nix/archive/974a61451bb1d41b32090eb51efd7ada026d16d9.tar.gz")
    { }
, nixpkgsSrc ? haskellNix.sources.nixpkgs-unstable
, nixpkgsArgs ? haskellNix.nixpkgsArgs
}:
let
  pkgs = import nixpkgsSrc (nixpkgsArgs // {
    overlays =
      haskellNix.overlays;
  });
  mkProject = arch:
    ( arch.haskell-nix.project {
        compiler-nix-name = compiler;
        projectFileName = "cabal.project";
        src = arch.haskell-nix.haskellLib.cleanSourceWith {
          name = "elm-src";
          src = ./.;
        };
      }
    ).elm.components.exes.elm;
in {
  platform = {
    amd64 = (mkProject pkgs.pkgsCross.musl64);
    arm64 = (mkProject pkgs.pkgsCross.aarch64-multiplatform-musl);
  };
}
