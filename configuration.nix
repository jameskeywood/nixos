# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./home.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hp"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable lightdm
  services.xserver.displayManager.lightdm.enable = true;

  # Enable DWM
  services.xserver.windowManager.dwm.enable = true;

  # Patch DWM
  services.xserver.windowManager.dwm.package = pkgs.dwm.override {
    patches = [
      # for external patches
      (pkgs.fetchpatch {
        url = "https://dwm.suckless.org/patches/fullgaps/dwm-fullgaps-6.4.diff";
        hash = "sha256-+OXRqnlVeCP2Ihco+J7s5BQPpwFyRRf8lnVsN7rm+Cc=";
      })
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "gb";

  # Configure console keymap
  console.keyMap = "uk";

  # Enable natural scrolling
  services.libinput.touchpad.naturalScrolling = true;

  # Configure pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # for JACK applications
    jack.enable = true;
  };

  # Enable use of light
  programs.light.enable = true;

  # Bind volume and brightness keys
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };

  # Enable bluetooth support
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true; # enable the blueman applet and manager

  # Use firmware
  hardware.enableAllFirmware = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Install docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.james = {
    isNormalUser = true;
    description = "James Keywood";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" ];
    packages = with pkgs; [
      firefox
      cmus
      stremio
      texliveFull
      thunderbird
      libreoffice
      sox
    ];
  };

  # Setup virtual machine test user
  users.users.nixosvmtest.isNormalUser = true;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = {};
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    dmenu
    unzip
    xcolor
    scrot

    # Include and patch st
    (st.overrideAttrs (oldAttrs: rec {
      patches = [
        # Fetch them directly from 'st.suckless.org'
        (fetchpatch {
          url = "https://st.suckless.org/patches/solarized/st-solarized-both-20220617-baa9357.diff";
          sha256 = "sha256-rZKbd6VKFmwijnYp6XRkBeQfimoSY7we/puJWPGQESw=";
        })
      ];
    }))
  ];
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
