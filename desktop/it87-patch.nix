{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation rec {
  pname = "it87-frankcrawford";
  version = "2024-unstable";

  src = fetchFromGitHub {
    owner = "frankcrawford";
    repo = "it87";
    rev = "master";
    sha256 = "sha256-xlUyq1DQFBCvAs9DP6i1ose+6e+nmmXFRyuzRXCg+Ko=";
  };

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  preConfigure = ''
    sed -i 's|depmod|#depmod|' Makefile
  '';

  makeFlags = [
    "TARGET=${kernel.modDirVersion}"
    "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
    "MODDESTDIR=$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon"
  ];

  meta = with lib; {
    description = "Linux Driver for ITE LPC chips - Frank Crawford fork";
    homepage = "https://github.com/frankcrawford/it87";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    broken = false;
  };
}
