{
  description = "Sonata Software";
  inputs = {
    sonata-system.url = "github:gregac/sonata-system/verilator_v5";
    lowrisc-nix.follows = "sonata-system/lowrisc-nix";
    nixpkgs.follows = "lowrisc-nix/nixpkgs";
    flake-utils.follows = "lowrisc-nix/flake-utils";
  };

  nixConfig = {
    extra-substituters = ["https://nix-cache.lowrisc.org/public/"];
    extra-trusted-public-keys = ["nix-cache.lowrisc.org-public-1:O6JLD0yXzaJDPiQW1meVu32JIDViuaPtGDfjlOopU7o="];
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    lowrisc-nix,
    sonata-system,
  }: let
    system_outputs = system: let
      pkgs = import nixpkgs {inherit system;};
      lrPkgs = lowrisc-nix.outputs.packages.${system};
      sonataSystemPkgs = sonata-system.outputs.packages.${system};
      cheriotPkgs = lowrisc-nix.outputs.devShells.${system}.cheriot.nativeBuildInputs;
    in {
      formatter = pkgs.alejandra;
      devShells = rec {
        default = pkgs.mkShell {
          name = "sonata-sw";
          packages = cheriotPkgs ++ [lrPkgs.uf2conv];
        };
        env-with-sim = pkgs.mkShell {
          name = "sonata-sw-with-sim";
          packages = default.nativeBuildInputs ++
          (with sonataSystemPkgs; [
            sonata-simulator
            sonata-sim-boot-stub
          ]);
          shellHook = ''
            export SONATA_SIM_BOOT_STUB=${sonataSystemPkgs.sonata-sim-boot-stub.out}/share/sim_boot_stub
          '';
        };
      };
    };
  in
    flake-utils.lib.eachDefaultSystem system_outputs;
}
