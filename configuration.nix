# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "loutreos"; # Define your hostname.
  networking.hostId = "7e66e347";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "en";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neovim
    git
    zsh
    tmux
    gnupg
  ];

  virtualisation.rkt.enable = true;

  users.extraGroups.rkt = { };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  users.extraUsers.paul =
  { uid = 1000;
    isNormalUser = true;
    description = "Paul TREHIOU";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAF7VlzHzgg70uFbRFtVTS34qNBke/RD36mRENAsa33RxztxrqMsIDscAD/d6CTe6HDy7MCGzJnWCJSXj5iOQFM4RRMvKNEgCKPHqfhmfVvO4YZuMjNB0ufVf6zhJL4Hy43STf7NIWrenGemUP+OvVSwN/ujgl2KKw4KJZt25/h/7JjlCgsZm4lWg4xcjoiKL701W2fbEoU73XKdbRTgTvKoeK1CGxdAPFefFDFcv/mtJ7d+wIxw9xODcLcA66Bu94WGMdpyEAJc4nF8IOy4pW8AzllDi0qNEZGCQ5+94upnLz0knG1ue9qU2ScAkW1/5rIJTHCVtBnmbLNSAOBAstaGQJuSL40TWZ1oPA5i1qUEhunNcJ+Sgtp6XP69qY34T/AeJvHRyw5M5LfN0g+4ka9k06NPBhbpHFASz4M8nabQ0iM63++xcapnw/8gk+EPhYVKW86SsyTa9ur+tt6oDWEKNaOhgscX44LexY7jKdeBRt3GaObtBJtVLBRx3Z2aRXgjgnKGqS40mGRiSkqb2DShspI1l8DV2RrPiuwdBzXVQjWRc0KXmJrcgXX9uoPSxihxwaUQyvmITOV1Y+NEuek4gRkVNOxjoG7RGnaYvYzxEQVoI5TwZC2/DCrAUgCv8DQawkcpEiWnBq7Q5VnpmFx5juVQ/I0G8byOkPXgRUOk9 openpgp:0xAB524BBC" ];
  };


  security.sudo.wheelNeedsPassword = false;

  system.autoUpgrade.enable = true;
}
