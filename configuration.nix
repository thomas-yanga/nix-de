{ config, pkgs, ... }:
{
  imports = [
    # Include the hardware-specific configuration
    ./hardware-configuration.nix
  ];
  ############################################################################
  # Nix Package Manager Configuration
  ############################################################################
  nix = {
    # Enable flakes and nix-command experimental features
    settings.experimental-features = [ "nix-command" "flakes" ];
    # Configure binary caches for faster package installation
    settings.substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    # Trusted public keys for the binary caches
    settings.trusted-public-keys = [
      "mirrors.tuna.tsinghua.edu.cn-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  # Allow installation of unfree packages
  nixpkgs.config.allowUnfree = true;
  ############################################################################
  # Boot and Hardware Configuration
  ############################################################################
  boot = {
    # Use systemd-boot as the bootloader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  ############################################################################
  # Networking Configuration
  ############################################################################
  networking = {
    # Set hostname
    hostName = "nix-de";
    # Enable NetworkManager for network management
    networkmanager.enable = true;
    # Firewall configuration
    firewall = {
      enable = true;
    };
  };
  ############################################################################
  # Localization and Time Settings
  ############################################################################
  time.timeZone = "Asia/Shanghai";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    # Additional locale settings for Chinese environment
    extraLocaleSettings = {
      LC_ADDRESS = "zh_CN.UTF-8";
      LC_IDENTIFICATION = "zh_CN.UTF-8";
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_NAME = "zh_CN.UTF-8";
      LC_NUMERIC = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
      LC_TELEPHONE = "zh_CN.UTF-8";
      LC_TIME = "zh_CN.UTF-8";
    };
    # Configure IBus input method for Chinese input (KEEP)
    inputMethod = {
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
    };
  };
  ############################################################################
  # Font Configuration
  ############################################################################
  fonts = {
    # Install Chinese and international fonts
    packages = with pkgs; [
      wqy_zenhei
      wqy_microhei
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];
  };
  ############################################################################
  # Desktop Environment Configuration (GNOME Only, Remove i3)
  ############################################################################
  services.xserver = {
    # Enable X11 windowing system
    enable = true;
    # Configure GNOME desktop environment (KEEP)
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # Keyboard layout configuration (keep existing for consistency)
    xkb = {
      layout = "us";
      variant = "";
      options = "grp:alt_shift_toggle";  # Toggle with Alt+Shift
    };
  };
  ############################################################################
  # Audio Configuration
  ############################################################################
  # Enable PipeWire for audio services
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  ############################################################################
  # Printing Services
  ############################################################################
  services.printing.enable = true;
  ############################################################################
  # User Configuration
  ############################################################################
  users.users.yangdi = {
    isNormalUser = true;
    home = "/home/yangdi";
    description = "Yangdi";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
  ############################################################################
  # System Packages (Remove i3-related tools)
  ############################################################################
  environment.systemPackages = with pkgs; [
    pciutils util-linux procps inetutils nmap arp-scan axel dconf htop
  ];
  programs = {
    # Enable Zsh shell
    zsh.enable = true;
  };
  ############################################################################
  # Home Manager Configuration (Remove i3, Keep Chinese Input)
  ############################################################################
  home-manager = {
    useUserPackages = true;
    users.yangdi = { pkgs, unstable, ... }: {
      home.packages = with pkgs; [
        # Essential user tools (keep non-i3 tools)
        vim tmux git tree fastfetch
        # Chinese Input Method (KEEP)
        ibus ibus-engines.libpinyin
        # Network tools
        lftp
        # Fonts (user-level fonts)
        cascadia-code wqy_zenhei noto-fonts-cjk-sans
      ];
      # Import dotfiles (remove i3-related dotfiles)
      home.file.".vimrc".source = ./dotfiles/.vimrc;
      home.file.".zshrc".source = ./dotfiles/.zshrc;
      home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
      # Keep IBus dotfile for input method
      #home.file.".config/ibus/ibus.conf".source = /home/yangdi/nixos-config/dotfiles/ibus/ibus.conf;
      # Enable programs managed by home-manager
      programs.zsh.enable = true;
      programs.tmux.enable = true;
      # Environment variables for IBus input method (KEEP)
      home.sessionVariables = {
        GTK_IM_MODULE = "ibus";
        QT_IM_MODULE = "ibus";
        XMODIFIERS = "@im=ibus";
      };
      # User-level fontconfig (keep for consistent font rendering)
      fonts = {
        fontconfig = {
          enable = true;
          defaultFonts = {
            serif = [ "Noto Serif" "WenQuanYi Zen Hei" ];
            sansSerif = [ "Noto Sans" "WenQuanYi Zen Hei" ];
            monospace = [ "Cascadia Mono NF" "WenQuanYi Zen Hei" ];
          };
        };
      };
      home.stateVersion = "25.05";
    };
  };
  ############################################################################
  # System State Version
  ############################################################################
  system.stateVersion = "25.05";
}
