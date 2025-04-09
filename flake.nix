{
  description = "Modular Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      # Helper function to load a Nix file if it exists
      loadIfExists = path: if builtins.pathExists path then import path else {};

      # Load universal default configuration
      defaultPackages = import ./default.nix;

      # Get hostname from the environment
      hostname = builtins.getEnv "HOSTNAME";

      # Host-specific configuration - only load if hostname is provided
      hostConfig = if hostname != "" then loadIfExists ./host/${hostname}.nix else {};

      # OS-specific configuration files
      darwinConfig = loadIfExists ./os/darwin.nix;
      linuxConfig = loadIfExists ./os/linux.nix;
      
      # Common home-manager configuration
      username = builtins.getEnv "USER";
      homeManagerConfig = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${username} = import ./home.nix;
      };
      
      # Common module sets for each system
      commonModules = [
        hostConfig
        defaultPackages
      ];
    in {
      # nix-darwin configurations (macOS-specific)
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin"; # Change to x86_64-darwin if needed
        modules = commonModules ++ [
          darwinConfig
          home-manager.darwinModules.home-manager
          homeManagerConfig
        ];
      };

      # nixos configurations (Linux-specific)
      nixosConfigurations = {
        # For x86_64 Linux
        "${hostname}-x86_64" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = commonModules ++ [
            linuxConfig
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ];
        };

        # Same configuration but for ARM Linux if needed
        "${hostname}-aarch64" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = commonModules ++ [
            linuxConfig
            home-manager.nixosModules.home-manager
            homeManagerConfig
          ];
        };
      };
    };
}
