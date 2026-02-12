{
  config,
  pkgs,
  host,
  inputs,
  lib,
  ...
}:

let
  isDesktop = host == "desktop";
  isLaptop = host == "laptop";
  it87-patch = config.boot.kernelPackages.callPackage ./it87-patch.nix { };
in
{
  imports = [
    ./cachix.nix
    ./hardware/${host}.nix
    inputs.niri.nixosModules.niri
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=n
  ''
  + lib.optionalString isDesktop ''
    options it87 force_id=0x8696 ignore_resource_conflict=1
  '';
  boot.extraModulePackages = lib.mkIf isDesktop [ it87-patch ];
  boot.kernelModules = lib.mkIf isDesktop [ "it87" ];
  boot.binfmt.emulatedSystems = lib.mkIf isDesktop [ "aarch64-linux" ];
  boot.initrd.luks.devices = lib.mkIf isLaptop {
    "luks-25fa8b36-82c5-45bf-84b1-6dfc46042013".device =
      "/dev/disk/by-uuid/25fa8b36-82c5-45bf-84b1-6dfc46042013";
  };

  networking.hostName = host;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 5000 ];
  networking.firewall.allowedUDPPorts = [
    5353
    1900
  ];

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "en";

  users.users.viv = {
    isNormalUser = true;
    description = "vivax";
    extraGroups = [
      "networkmanager"
      "wheel"
      "remotebuilder"
      "audio"
    ];
    shell = pkgs.fish;
  };
  nix.settings.trusted-users = [
    "viv"
    "@wheel"
  ];
  nix.settings.auto-optimise-store = true;
  programs.fish.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    xwayland-satellite
    pavucontrol
  ];
  environment.etc = lib.mkIf isDesktop {
    "nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
      ''
        {
        	"rules": [{
        		"pattern": {
        			"feature": "procname",
        			"matches": "niri"
        		},
        		"profile": "Limit Free Buffer Pool On Wayland Compositors"
        	}],
        	"profiles": [{
        		"name": "Limit Free Buffer Pool On Wayland Compositors",
        		"settings": [{
        			"key": "GLVidHeapReuseRatio",
        			"value": 0
        		}]
        	}]
        }
        }
      '';
  };

  hardware.keyboard.zsa.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy.AutoEnable = true;
    };
  };
  hardware.enableRedistributableFirmware = true;

  hardware.nvidia = lib.mkIf isDesktop {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  hardware.graphics = lib.mkIf isDesktop {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      egl-wayland
      libvdpau-va-gl
      libva-vdpau-driver
      mesa
    ];
  };

  services.flatpak.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
  };
  services.blueman.enable = true;
  services.cloudflare-warp.enable = true;
  services.xserver.xkb = {
    layout = if isLaptop then "en" else "us";
    variant = "";
  };
  services.xserver.videoDrivers = lib.mkIf isDesktop [ "nvidia" ];
  services.getty.autologinUser = lib.mkIf isDesktop "viv";
  services.wivrn = lib.mkIf isDesktop {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
    highPriority = true;
  };
  services.openssh = lib.mkIf isDesktop {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "viv" ];
    };
  };
  services.fail2ban.enable = lib.mkIf isDesktop true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.jupyter = lib.mkIf isLaptop {
    enable = true;
    password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$rBuNjcP4ENi1sCPxjQYkXA$3x4Kv+KsLfTxaLldNs/olUtEt+nlDU6zhPML4BHGvI4";
    kernels.python3 =
      let
        env = pkgs.python313.withPackages (
          p: with p; [
            ipykernel
            ipython-sql
            psycopg2
          ]
        );
      in
      {
        displayName = "Python 3 (SQL)";
        language = "python";
        argv = [
          "${env.interpreter}"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
      };

  };

  security.rtkit.enable = true;
  security.pam.services.swaylock = lib.mkIf isLaptop { };

  powerManagement.cpuFreqGovernor = "performance";

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
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/layout/monitor.rs \
          --replace-fail 'self.view_size.h * 0.1 * zoom' \
                          'self.view_size.h * 0.0 * zoom'
      '';
    });
  };

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  system.stateVersion = "25.05";
}
