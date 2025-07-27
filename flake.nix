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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            host = hostname;
          };
          modules = [
            ./${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "HMBackup";

              home-manager.users.viv = import ./${hostname}/home.nix;
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
    };
}
