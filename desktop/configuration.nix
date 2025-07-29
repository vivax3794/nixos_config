{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../visual/configuration.nix
  ];

  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
    videoDrivers = [ "nvidia" ];
  };
  console.keyMap = "us";

  services.getty.autologinUser = "viv";

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      egl-wayland
      libvdpau-va-gl
      vaapiVdpau
    ];
  };

  # https://github.com/YaLTeR/niri/discussions/2062
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
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

  powerManagement.cpuFreqGovernor = "performance";
  services.avahi.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-youtube-dl-2021.12.17"
  ];
}
