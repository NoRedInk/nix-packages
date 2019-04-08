# This file provides all the buildable and cacheable packages and
# package outputs in you package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{ pkgs ? import <nixpkgs> {} }:

with builtins;

let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: { name = n; value = v; };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [p]
        else [];
    in
      concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs or [ "out" ];

  allPkgs = if (builtins.getEnv "USE_AS_OVERLAY" == "")
    then import ./default.nix { inherit pkgs; }
    else import <nixpkgs> { # Ignores "pkgs", but probably no other way to do this
      overlays = import ./manifest.nix;
    };

  nurAttrs = allPkgs.nixpkgs-diff;

  nurPkgs =
    flattenPkgs
    (listToAttrs
    (map (n: nameValuePair n nurAttrs.${n})
    (filter (n: !isReserved n)
    (attrNames nurAttrs))));

in

rec {
  inherit nurPkgs;

  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}