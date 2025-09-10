# configuration.nix
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
      # allowedTCPPorts = [2233]; # Example: open specific port if needed
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

    # Configure IBus input method for Chinese input
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

    # Configure font fallback preferences
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "DejaVu Serif" "WenQuanYi Zen Hei" ];
      sansSerif = [ "Noto Sans" "DejaVu Sans" "WenQuanYi Zen Hei" ];
      monospace = [ "Cascadia Mono NF" "DejaVu Sans Mono" "WenQuanYi Zen Hei" ];
    };
  };

  ############################################################################
  # Desktop Environment Configuration
  ############################################################################

  services.xserver = {
    # Enable X11 windowing system
    enable = true;

    # Configure GNOME desktop environment
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # add i3 and i3 additional tools
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
      i3status  # status bar for time, battery, net
      i3lock    # screenlock tool
      ibus
      ibus-engines.libpinyin
      ];
      extraSessionCommands = ''
      # auto start alacritty after longin i3
      gnome-terminal &

      # auto start i3 status bar tool
      i3status &

      # input method variables
      export GTK_IM_MODULE=ibus
      export QT_IM_MODULE=ibus
      export XMODIFIERS=@im=ibus

      # Start ibus daemon with proper settings
      ibus-daemon --daemonize --xim --replace &
    '';
      configFile = "/home/yangdi/.config/i3/config";  # enable config file
    };

    # Keyboard layout configuration
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
  # System Packages
  ############################################################################

  environment.systemPackages = with pkgs; [
    # Essential utilities
    vim
    wget
    git
    tmux
    tree

    # System monitoring tools
    pciutils
    util-linux
    procps
    inetutils

    # Network tools
    nmap
    arp-scan
    axel

    # Input method and fonts
    ibus
    ibus-engines.libpinyin
    cascadia-code

    # Miscellaneous
    fastfetch
    gnome-terminal

    # i3 initialtor
    rofi

    # config tool
    dconf
  ];

  ############################################################################
  # Wrap with apps
  ############################################################################
  environment.extraInit = ''
  # Wrap Firefox to include IBus input method variables
    if [ -x "${pkgs.firefox}/bin/firefox" ]; then
      ${pkgs.makeWrapper}/bin/wrapProgram "${pkgs.firefox}/bin/firefox" \
        --set GTK_IM_MODULE "ibus" \
        --set QT_IM_MODULE "ibus" \
        --set XMODIFIERS "@im=ibus"
    fi

  # Add gnome-terminal wrap (new code)
    if [ -x "${pkgs.gnome-terminal}/bin/gnome-terminal" ]; then
      ${pkgs.makeWrapper}/bin/wrapProgram "${pkgs.gnome-terminal}/bin/gnome-terminal" \
        --set GTK_IM_MODULE "ibus" \
        --set QT_IM_MODULE "ibus" \
        --set XMODIFIERS "@im=ibus" \
        --set LANG "zh_CN.UTF-8"  # Ensure terminal uses Chinese locale
    fi
  '';

  ############################################################################
  # Program Enablement
  ############################################################################

  programs = {
    # Enable Zsh shell
    zsh.enable = true;

    # Enable Firefox browser
    firefox.enable = true;
  };

  ############################################################################
  # Home Manager Configuration
  ############################################################################

  home-manager = {
    useUserPackages = true;
    users.yangdi = { pkgs, unstable, ... }: {
      home.packages = with pkgs; [
        zsh
        ibus-engines.libpinyin
        gnome-terminal
      ];

      # Import dotfiles from the repository
      home.file.".vimrc".source = ./dotfiles/.vimrc;
      home.file.".zshrc".source = ./dotfiles/.zshrc;
      home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;

      # Enable programs managed by home-manager
      programs.zsh.enable = true;
      programs.tmux.enable = true;

      # Environment variables for input method
      home.sessionVariables = {
        GTK_IM_MODULE = "ibus";
        QT_IM_MODULE = "ibus";
        XMODIFIERS = "@im=ibus";
      };

      home.stateVersion = "25.05";
    };
  };

  ############################################################################
  # System State Version
  ############################################################################

  system.stateVersion = "25.05";
}
