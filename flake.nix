{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {pkgs, ...}: {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "kumir";
          version = "2.1.0-rc11";
          src = pkgs.fetchgit {
            url = "https://github.com/a-a-maly/kumir2.git";
            rev = "${version}";
            sha256 = "sha256-WcxFlCpvrnW92XksXhg94EVZdaoHw42D0EK2HIpWVOk=";
            leaveDotGit = true;
          };
          postPatch = ''
            substituteInPlace scripts/query_version_info.py\
              --replace "/usr/bin" "${pkgs.git}/bin"
            substituteInPlace cmake/kumir2/kumir2_common.cmake\
              --replace /bin/lrelease ${pkgs.libsForQt5.qt5.qttools.dev}/bin/lrelease
            substituteInPlace scripts/gen_actor_source.py \
              --replace 'encoding="utf-8"' "" \
              --replace 'encoding="utf-8-sig"' ""
          '';
          nativeBuildInputs = with pkgs; [
            python3
            cmake
            git
            libsForQt5.wrapQtAppsHook
            libsForQt5.qttools
          ];
          buildInputs = with pkgs; [
            zlib.dev
            boost.dev
            llvm.dev
            libsForQt5.qt5.qtbase
            libsForQt5.qt5.qtx11extras
            libsForQt5.qt5.qtscript
            libsForQt5.qt5.qttools
          ];

          cmakeFlags = [
            "-DCMAKE_BUILD_TYPE=Release"
            "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
            "-DUSE_QT=5"
            "-Wno-dev"
          ];
        };
        formatter = pkgs.alejandra;
      };
    };
}
