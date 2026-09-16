{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serpentine = {
      url = "github:Serpent-Tools/serpentine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tree-sitter-serpentine.url = "github:Serpent-Tools/tree-sitter-serpentine";
    tree-sitter-paradox = {
      url = "github:Acture/tree-sitter-paradox";
      flake = false;
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    jj-starship = {
      url = "github:dmmulroy/jj-starship";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matrix-wallpaper = {
      url = "github:vivax3794/matrix_reactive_wallpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      niri,
      ...
    }@inputs:
    let
      overlays = [
        # niri-flake still requests `libdisplay-info_0_2` and asserts its version, but
        # nixpkgs dropped that attribute and niri's libdisplay-info-sys is on 0.3.
        (final: prev: {
          libdisplay-info_0_2 = final.libdisplay-info_0_3 // {
            version = "0.2.0";
          };
        })
        # libcap-ng 0.9.5's file_caps_test mocks fgetxattr and fsetxattr but still
        # references fremovexattr. musl ships all three in one libc.a member, so
        # resolving it drags in duplicate definitions of the mocks and the test
        # fails to link. Fixed upstream after 0.9.5.
        (final: prev: {
          libcap_ng =
            if prev.stdenv.hostPlatform.isStatic then
              prev.libcap_ng.overrideAttrs { doCheck = false; }
            else
              prev.libcap_ng;
        })
        inputs.niri.overlays.niri
      ];
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            host = hostname;
          };

          modules = [
            { nixpkgs.overlays = overlays; }
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "HMBackup";

              home-manager.users.viv = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                host = hostname;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations.laptop = mkSystem "laptop";
      nixosConfigurations.desktop = mkSystem "desktop";
    };
}
