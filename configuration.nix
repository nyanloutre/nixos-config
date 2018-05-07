# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./users.nix
      ./services.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];

  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

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
  nixpkgs.overlays = [
    (import ./overlays/riot-web.nix)
    (import ./overlays/lidarr.nix)
    (import ./overlays/organizr.nix)
    (import ./overlays/sudo.nix)
  ];
  environment.systemPackages = with pkgs; [
    neovim
    git
    tmux
    ncdu
  ];

  nixpkgs.config.allowUnfree = true;

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.ohMyZsh.plugins = [ "git" "colored-man-pages" "command-not-found" "extract" ];
  programs.zsh.ohMyZsh.theme = "bureau";

  environment.variables = { EDITOR = "nvim"; };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  networking.firewall.allowedTCPPorts = [  ];
  networking.firewall.allowedUDPPorts = [  ];
  networking.firewall.enable = true;

  security.sudo.wheelNeedsPassword = false;

  system.autoUpgrade.enable = true;
  systemd.services.nixos-upgrade.path = with pkgs; [ gzip gnutar xz.bin config.nix.package.out ];

  services.fstrim.enable = true;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 15d";

  system.stateVersion = "18.03";
}
