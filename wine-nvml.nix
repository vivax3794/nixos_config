{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  meson,
  ninja,
  wine64,
  gnused,
  pkgsCross,
}:

let
  nvmlVersion = "610.43.02";
  nvmlHeader = fetchurl {
    url = "https://raw.githubusercontent.com/NVIDIA/nvidia-settings/${nvmlVersion}/src/nvml.h";
    hash = "sha256-MaJuPObwuYp2zqOKPPKKoRKiDPs36QV3hsdocS1qSH8=";
  };
  mingw64 = pkgsCross.mingwW64.buildPackages.gcc;
in
stdenv.mkDerivation {
  pname = "wine-nvml";
  version = "unstable-2026-06-08";

  src = fetchFromGitHub {
    owner = "Saancreed";
    repo = "wine-nvml";
    rev = "a1a7d8fac0e054122cbaf9205c9bee33f5831015";
    hash = "sha256-Qco3anR7x8FmHJsyP/1R+wbqGX7iqn6g/BxzvXxRsFE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    wine64
    mingw64
  ];

  # make_nvml normally curls this header; the build sandbox has no network,
  # so the pinned header is fetched ahead of time and dropped in place.
  postPatch = ''
    cp ${nvmlHeader} src/nvml_${nvmlVersion}.h
    patchShebangs src/make_nvml
  '';

  configurePhase = ''
    runHook preConfigure

    (cd src && ./make_nvml ${nvmlVersion})

    meson setup --cross-file cross-mingw64.txt --prefix "$out" --libdir lib64 --buildtype release build-mingw64 .
    meson setup --cross-file cross-wine64.txt --prefix "$out" --libdir lib64 --buildtype release build-wine64 .

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    ninja -C build-mingw64
    ninja -C build-wine64

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ninja -C build-mingw64 install
    ninja -C build-wine64 install

    runHook postInstall
  '';

  meta = {
    description = "NVIDIA Management Library (nvml.dll) wrapper for Wine/Proton";
    homepage = "https://github.com/Saancreed/wine-nvml";
    license = lib.licenses.lgpl21Plus;
    platforms = [ "x86_64-linux" ];
  };
}
