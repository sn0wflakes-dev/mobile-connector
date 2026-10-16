{
  description = "flakes for tauri projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          pkg-config
          glib
        ];

        buildInputs = with pkgs; [
          # insert desired packages
          librsvg
          webkitgtk_4_1
        ];

        shellHook = ''
          # Needed on Wayland to report the correct display scale
          export XDG_DATA_DIRS="$GSETTINGS_SCHEMAS_PATH"

          # Shell function for build desktop app
          build() {
              BUILD_TARGET="$1"

              if [[ "$BUILD_TARGET" == "web" ]]; then
                nix develop -c sh -c "cd ./desktop/ && bun run build"
              elif [[ "$BUILD_TARGET" == "desk" ]]; then
                nix develop -c sh -c "cd ./desktop/ && bun tauri build"
              else
                echo "build option is not set, please set the build option first"
              fi
          }

          # Shell function for build desktop app (dev mode)
          build-dev() {
              BUILD_TARGET="$1"

              if [[ "$BUILD_TARGET" == "web" ]]; then
                nix develop -c sh -c "cd ./desktop/ && bun run dev"
              elif [[ "$BUILD_TARGET" == "desk" ]]; then
                nix develop -c sh -c "cd ./desktop/ && bun tauri dev"
              else
                echo "build option is not set, please set the build option first"
              fi
          }

          # Shell function for load .env to os environment 
          load_dotenv() {
             TARGET_ENV="$1"

             sed -i 's/\r$//' "$TARGET_ENV"

             echo "load .env file from $TARGET_ENV"
             if [ -f "$TARGET_ENV" ]; then
               echo "Found .env at $TARGET_ENV"
               set -a
               source "$TARGET_ENV"
               set +a
               echo ".env file successfully loaded from $TARGET_ENV !"
             else
               echo "Could not load .env file. File not found"
             fi
           }
        '';
      };
    };
}
