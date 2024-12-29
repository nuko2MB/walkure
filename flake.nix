{
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixos-cosmic/nixpkgs"; # NOTE: change "nixpkgs" to "nixpkgs-stable" to use stable NixOS release
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      #  inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";
    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:WilliButz/preservation";
  };
  outputs =
    {
      flakelight,
      self,
      treefmt-nix,
      agenix-rekey,
      agenix,
      helix,
      ...
    }@inputs:
    flakelight ./. (
      { lib, ... }:
      {
        inherit inputs;
        nixDirAliases.homeConfigurations = [ "homes" ];
        nixDirAliases.nixosConfigurations = [ "hosts" ];
        nixpkgs.config.allowUnfree = true;

        nixosModules = {
          inherit (inputs.lix-module.nixosModules) lixFromNixpkgs;
          agenix = agenix.nixosModules.default;
          agenix-rekey = agenix-rekey.nixosModules.default;
        };

        homeModules = {
          inherit (inputs.nix-index-database.hmModules) nix-index;
        };

        devShell = {
          env.EDITOR = "hx";
          packages = pkgs: [
            pkgs.tree-fmt-nix-wrapped
            (pkgs.writeShellScriptBin "agenix" ''
              ${
                pkgs.lib.getExe agenix-rekey.packages.${pkgs.system}.default
              } --extra-flake-params "?submodules=1"   "$@"
            '')
          ];
        };

        withOverlays = [
          agenix-rekey.overlays.default
          (final: prev: {
            tree-fmt-nix-wrapped = (treefmt-nix.lib.evalModule final ./treefmt.nix).config.build.wrapper;
          })

          # Overlay updated mpv with bug fix.
          # TODO: Remove on mpv 0.40.0 release
          (final: prev: {
            mpv-unwrapped = prev.mpv-unwrapped.overrideAttrs {
              src = prev.fetchFromGitHub {
                owner = "mpv-player";
                repo = "mpv";
                rev = "83bb49815cc163e4481097034e1058c4a04a9299";
                hash = "sha256-ZuGcTdVX0VBrXKylVGGPWSMlO2JJWpy+mh6D5LqWRxs=";
              };
              postPatch = lib.concatStringsSep "\n" [
                # Don't reference compile time dependencies or create a build outputs cycle
                # between out and dev
                ''
                  substituteInPlace meson.build \
                    --replace-fail "conf_data.set_quoted('CONFIGURATION', meson.build_options())" \
                                   "conf_data.set_quoted('CONFIGURATION', '<omitted>')"
                ''
                # A trick to patchShebang everything except mpv_identify.sh
                ''
                  pushd TOOLS
                  mv mpv_identify.sh mpv_identify
                  patchShebangs *.py *.sh
                  mv mpv_identify mpv_identify.sh
                  popd
                ''
              ];
            };
          })
        ];

        app = pkgs: pkgs.agenix-rekey;

        outputs = {
          agenix-rekey = agenix-rekey.configure {
            userFlake = self;
            inherit (self) nixosConfigurations;
          };
        };
      }
    );
}
