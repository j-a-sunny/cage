{
  description = "A Wayland kiosk (waydroid-helper fork) binary release packaged for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkg = pkgs.callPackage ./package.nix { };
        in
        {
          cage-waydroid-helper = pkg;
          default = pkg;
        }
      );

      apps = forAllSystems (system: {
        cage-waydroid-helper = {
          type = "app";
          program = "${self.packages.${system}.cage-waydroid-helper}/bin/cage-waydroid-helper";
        };
        default = self.apps.${system}.cage-waydroid-helper;
      });

      overlays.default = final: prev: {
        cage-waydroid-helper = final.callPackage ./package.nix { };
      };

      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.cage-waydroid-helper;
        in
        {
          options.programs.cage-waydroid-helper = {
            enable = lib.mkEnableOption "cage (waydroid-helper fork)";
            package = lib.mkPackageOption self.packages.${pkgs.system} "cage-waydroid-helper" { };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];
          };
        };

      nixosModules.cage-waydroid-helper = self.nixosModules.default;
    };
}
