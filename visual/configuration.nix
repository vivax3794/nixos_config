{
  config,
  pkgs,
  host,
  inputs,
  ...
}:

{
  imports = [
    ../base/configuration.nix
    inputs.niri.nixosModules.niri
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    xwayland-satellite
    pavucontrol
  ];

  hardware.keyboard.zsa.enable = true;

  networking.networkmanager.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };
  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 5000 ];
  networking.firewall.allowedUDPPorts = [
    5353
    1900
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
  services.blueman.enable = true;
  hardware.enableRedistributableFirmware = true;
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=n
  '';

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

  };
  users.users.viv.extraGroups = [ "audio" ];

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  services.cloudflare-warp = {
    enable = true;
  };

  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     initial_session = {
  #       command = "niri-session";
  #       user = "viv";
  #     };
  #   };
  # };

  system.stateVersion = "25.05";
}
