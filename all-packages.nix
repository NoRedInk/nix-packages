/*
 * An overlay to add all packages.
 *
 * Requirement: extend-lib.
 */

self: super:

let
  inherit (builtins) fetchTarball;
  inherit (self) callPackage;
  pkgs = with self; {
    fetchNpmPackage = callPackage ./pkgs/development/nodejs/npm/fetchNpmPackage { };
    buildNpmPackage = callPackage ./pkgs/development/nodejs/npm/buildNpmPackage { };
    mkInstalledNpmPackage = callPackage ./pkgs/development/nodejs/npm/mkInstalledNpmPackage { };
    mkNpmPackageBundle = callPackage ./pkgs/development/nodejs/npm/mkNpmPackageBundle { };
    mkNodePackage = callPackage ./pkgs/development/nodejs/npm/mkNodePackage { };
    mkNodeEnv = callPackage ./pkgs/development/nodejs/npm/mkNodeEnv { };
    mkNodeEnvForPackage = callPackage ./pkgs/development/nodejs/npm/mkNodeEnvForPackage { };
    mkNodePackageWithRuntime = callPackage ./pkgs/development/nodejs/npm/mkNodePackageWithRuntime { };
    npmjs2nix = callPackage ./pkgs/development/nodejs/npmjs2nix/package.nix { };

    npm = callPackage ./pkgs/development/nodejs/npm { };
    mkNodeEnvDerivation = npm.mkNodeEnv;
    mkNpmPackageDerivation = npm.mkNpmPackageWithRuntime;
    npm-package-to-nix = callPackage ./pkgs/development/nodejs/npm-package-to-nix/package.nix { };

    neofetch-web = callPackage (
      builtins.fetchGit {
        url = "https://github.com/zetavg/neofetch-web.git";
        ref = "master";
        rev = "8b8c6936b025d209604b8f4a00eace3bd77caa2a";
      }
    ) { inherit pkgs mkNodePackageWithRuntime; };

    buildRubyGem = callPackage ./pkgs/development/ruby/gem {
      buildRubyGem = super.buildRubyGem;
    };
    buildRailsApp = callPackage ./pkgs/development/ruby/rails-app { };

    passenger = callPackage ./pkgs/servers/passenger { };
    nginx-mod-passenger = callPackage ./pkgs/servers/nginx-mod-passenger.nix { };
    nginx-with-passenger = callPackage ./pkgs/servers/nginx-with-passenger.nix { };

    sample-rails-app = callPackage (
      builtins.fetchGit {
        url = "https://github.com/zetavg/rails-nix-sample.git";
        ref = "master";
        rev = "22b727b95ea7c9e5eca013a794e0d526caa7f4d5";
      }
    ) { inherit pkgs buildRailsApp; };

    overlays-compat = callPackage ./pkgs/os-specific/nixos/overlays-compat.nix { };

    # Log the differentials we made to the nixpkgs-diff attr. Do aware that
    # changes made by subsequent overlays will not be reflected here, unless
    # they'll also add their changes to nixpkgs-diff.
    nixpkgs-diff = (super.nixpkgs-diff or { }) // pkgs;
  };
in pkgs
