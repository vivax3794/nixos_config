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

  # pam_u2f mapping file (public key material, safe to commit). PAM 2FA below
  # only turns on once this exists, so an un-enrolled checkout can't lock you out.
  u2fMappings = ./u2f_mappings;
  u2fEnrolled = builtins.pathExists u2fMappings;
in
{
  imports = [
    ./cachix.nix
    ./hardware/${host}.nix
    inputs.niri.nixosModules.niri
  ];

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "nowatchdog"
    "modprobe.blacklist=sp5100_tco"
  ]
  ++ lib.optionals isLaptop [
    "quiet"
    "splash"
    "udev.log_level=3"
    "pcie_aspm=off" # force-disable ASPM globally; rtw89 RTL8852BE firmware SER crashes
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=n
  ''
  + lib.optionalString isLaptop ''
    options rtw89_core disable_ps_mode=Y
    options rtw89_pci disable_clkreq=Y disable_aspm_l1=Y disable_aspm_l1ss=Y
  ''
  + lib.optionalString isDesktop ''
    options it87 force_id=0x8696 ignore_resource_conflict=1 mmio=on
  '';
  boot.extraModulePackages = lib.mkIf isDesktop [ it87-patch ];
  boot.kernelModules = lib.mkIf isDesktop [ "it87" ];

  boot.initrd.luks.devices = lib.mkIf isLaptop {
    "luks-25fa8b36-82c5-45bf-84b1-6dfc46042013".device =
      "/dev/disk/by-uuid/25fa8b36-82c5-45bf-84b1-6dfc46042013";
  };

  boot.plymouth.enable = lib.mkIf isLaptop true;
  boot.initrd.systemd.enable = lib.mkIf isLaptop true;

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 1048576;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  networking.hostName = host;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = lib.mkIf isLaptop false;

  # The laptop's RTL8852BE (rtw89) firmware occasionally crashes and self-recovers
  # via SER, stalling all traffic for ~60s while NetworkManager still reports "up".
  # This watchdog pings the gateway and force-reconnects on a sustained stall,
  # turning the minute-long outage into a ~5s blip.
  systemd.services.wifi-watchdog = lib.mkIf isLaptop {
    description = "Recover rtw89 wifi from firmware SER stalls by reconnecting";
    after = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.iputils
      pkgs.iproute2
      pkgs.networkmanager
      pkgs.gawk
    ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 10;
    };
    script =
      let
        iface = "wlo1";
        pollSeconds = 5;
        failThreshold = 3;
      in
      ''
        fails=0
        while true; do
          gw=$(ip -4 route show default dev ${iface} 2>/dev/null | awk '{print $3; exit}')
          if [ -z "$gw" ]; then
            fails=0
          elif ping -c1 -W2 -I ${iface} "$gw" >/dev/null 2>&1; then
            fails=0
          else
            fails=$((fails + 1))
            if [ "$fails" -ge ${toString failThreshold} ]; then
              echo "gateway $gw unreachable ${toString failThreshold}x; reconnecting ${iface}"
              nmcli device disconnect ${iface} || true
              nmcli device connect ${iface} || true
              fails=0
              sleep 8
            fi
          fi
          sleep ${toString pollSeconds}
        done
      '';
  };

  networking.firewall.checkReversePath = "loose";
  networking.firewall.allowedTCPPorts = [
    5000
    8888
  ];
  networking.firewall.allowedUDPPorts = [
    5353
    1900
  ];
  networking.firewall.trustedInterfaces = [ "CloudflareWARP" ];

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
      "wireshark"
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
  nixpkgs.config.rocmSupport = isDesktop;
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    xwayland-satellite
    pavucontrol
    pam_u2f # provides pamu2fcfg for enrolling the YubiKey into /etc/nixos/u2f_mappings
  ];

  hardware.keyboard.zsa.enable = true;
  hardware.opentabletdriver.enable = true;
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

  hardware.amdgpu = lib.mkIf isDesktop {
    # Loading amdgpu in stage 1 hard-hangs this machine when a display is
    # attached to HDMI-A-1 at boot: a few kernel lines, then black, then fans to
    # 100% as the SMU falls back. Stage 2 has the firmware and udev it needs.
    initrd.enable = false;
    opencl.enable = true;
    # Exposes pp_od_clk_voltage, without which LACT can only read clocks rather
    # than set them. The module default masks the bits known to cause flicker.
    overdrive.enable = true;
  };
  hardware.graphics = lib.mkIf isDesktop {
    enable = true;
    enable32Bit = true;
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
  # Upstream NixOS module is missing capabilities and tools in PATH.
  # nftables: tunnel firewall rules; iproute2: TUN device routing.
  systemd.services.cloudflare-warp = {
    path = with pkgs; [
      nftables
      iproute2
    ];
    serviceConfig = {
      CapabilityBoundingSet = lib.mkForce [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_PTRACE"
        "CAP_DAC_READ_SEARCH"
        "CAP_NET_RAW"
        "CAP_SETUID"
        "CAP_SETGID"
      ];
      AmbientCapabilities = lib.mkForce [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_PTRACE"
        "CAP_DAC_READ_SEARCH"
        "CAP_NET_RAW"
        "CAP_SETUID"
        "CAP_SETGID"
      ];
    };
  };
  services.xserver.xkb = {
    layout = if isLaptop then "en" else "us";
    variant = "";
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
      # No initial_session: auto-login would bypass PAM entirely (no password,
      # no key). Going through tuigreet means login enforces password + YubiKey.
    };
  };

  # Auto-unlock the gnome-keyring at login. Its unlock dialog is gcr's own prompt,
  # not PAM, so u2f can't gate it directly; instead we unlock it during the now
  # 2FA-gated login so the secret store is protected by that login and the popup
  # disappears. Requires the keyring password to equal the login password.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.wivrn = lib.mkIf isDesktop {
    enable = true;
    openFirewall = true;
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
  services.fail2ban.enable = isDesktop;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraLv2Packages = [ pkgs.ldacbt ];
    wireplumber.extraLv2Packages = [ pkgs.ldacbt ];
  };

  security.rtkit.enable = true;
  security.pam.services.swaylock = lib.mkIf isLaptop { };

  # YubiKey FIDO2/U2F as a REQUIRED second factor for every PAM service on both
  # hosts: login/greetd, sudo, su, polkit, swaylock, etc. (control = "required"
  # → password AND a key touch). Guarded on the mapping file existing so a fresh
  # checkout without ./u2f_mappings stays password-only and can't lock you out.
  #
  # origin/appid are pinned (instead of the default pam://$HOSTNAME) so a single
  # enrollment works on both desktop and laptop.
  security.pam.u2f = lib.mkIf u2fEnrolled {
    enable = true;
    control = "required";
    settings = {
      authfile = "${u2fMappings}";
      cue = true;
      origin = "pam://viv";
      appid = "pam://viv";
    };
  };
  # SSH can't prompt for an interactive touch — keep sshd on password auth only.
  security.pam.services.sshd.u2fAuth = lib.mkIf isDesktop false;

  programs.coolercontrol.enable = isDesktop;
  # LACT drives clocks, power limit and undervolting. CoolerControl owns the fan
  # curves; aiming both at the GPU's pwm1 makes them fight over the same knob.
  services.lact.enable = isDesktop;

  powerManagement.cpuFreqGovernor = if isDesktop then "balance_performance" else "balance_power";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.appimage.enable = false;
  programs.appimage.binfmt = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.preferStaticEmulators = true;

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  system.stateVersion = "25.05";
}
