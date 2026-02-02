{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../visual/configuration.nix
  ];

  security.pam.services.swaylock = { };

  boot.initrd.luks.devices."luks-25fa8b36-82c5-45bf-84b1-6dfc46042013".device =
    "/dev/disk/by-uuid/25fa8b36-82c5-45bf-84b1-6dfc46042013";

  services.xserver.xkb = {
    layout = "en";
    variant = "";
  };
  console.keyMap = "en";

  services.udev.extraRules = ''
    # Rules for LEGO programmable bricks

    # MINDSTORMS NXT brick 
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0002", TAG+="uaccess"

    # MINDSTORMS NXT brick in firmware update mode (Atmel SAM-BA mode)
    # Note: this USB ID is also used by some Arduino boards
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", TAG+="uaccess"

    # MINDSTORMS EV3 brick
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0005", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0005", TAG+="uaccess"

    # MINDSTORMS EV3 brick in firmware update mode
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0006", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0006", TAG+="uaccess"

    # SPIKE Prime hub in firmware update mode (DFU mode)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0008", TAG+="uaccess"

    # SPIKE Prime hub
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0009", TAG+="uaccess"

    # SPIKE Essential hub in firmware update mode (DFU mode)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="000c", TAG+="uaccess"

    # SPIKE Essential hub
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="000d", TAG+="uaccess"

    # MINDSTORMS Inventor hub
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0010", TAG+="uaccess"

    # MINDSTORMS Inventor hub in firmware update mode (DFU mode)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0011", TAG+="uaccess"
  '';
}
