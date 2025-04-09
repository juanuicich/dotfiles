{
  description = "Modular Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";  # Replace with your preferred nixpkgs version
  };

  outputs = { self, nixpkgs, ... }:
    let
      # Helper function to load a Nix file if it exists
      loadIfExists = path: if builtins.pathExists path then import path else {};

      # Load universal default configuration (default packages)
      defaultPackages = import ./default.nix;

      # Load OS-specific configuration dynamically
      os = builtins.getEnv "OSTYPE";  # Detect OS, e.g., "darwin" or "linux"
      osConfig = loadIfExists ./os/${os}.nix;

      # Load host-specific configuration dynamically
      hostname = builtins.getEnv "HOSTNAME";  # Detect hostname
      hostConfig = loadIfExists ./hosts/${hostname}.nix;

      # Merge configurations
      mergedConfig = defaultPackages // osConfig // hostConfig;
    in
    {
      # nix-darwin configurations (macOS-specific)
      darwinConfigurations = {
        "${hostname}" = nixpkgs.lib.nixosSystem {
          system = "x86_64-darwin";
          modules = [ mergedConfig ];
        };
      };

      # nixos configurations (Linux-specific, for x86_64 and aarch64)
      nixosConfigurations = {
        # For x86_64 Linux
        "${hostname}-x86_64" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ mergedConfig ];
        };

        # For ARM (aarch64) Linux
        "${hostname}-aarch64" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ mergedConfig ];
        };
      };
    };
}
