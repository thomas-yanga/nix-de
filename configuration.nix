# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    settings = {
      substituters = [ 
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "mirrors.ustc.edu.cn-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #  systemd.sleep.enable = false;

  networking.hostName = "nix-de"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # 禁用电源管理中的自动待机
  services.logind.extraConfig = "
  LidSwitchIgnoreInhibited=no
  HandleLidSwitch=suspend
  SuspendKeyIgnoreInhibited=no
  HandleSuspendKey=suspend
  HibernateKeyIgnoreInhibited=no
  HandleHibernateKey=hibernate
  ";

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;

  # Home manager configuration
  home-manager = {
    useUserPackages = true;
    users = {
      yangdi = { pkgs, ... }: {
        # 用户软件包
        home.packages = with pkgs; [
          zsh
        ];

        # 将现有的配置文件链接到 Home Manager
        # 注意: home-manager 无法直接访问用户的家目录，你需要将配置文件移动到 /etc/nixos/dotfiles/
        # 然后将 source 路径改为 ./dotfiles/.vimrc 等
        home.file.".vimrc".source = ./dotfiles/.vimrc;
        home.file.".zshrc".source = ./dotfiles/.zshrc;
        home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;

        # home-manager 会话管理
        programs.zsh = {
          enable = true;
        };
        programs.tmux = {
          enable = true;
        };

        home.stateVersion = "25.05";
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yangdi = {
    isNormalUser = true;
    home = "/home/yangdi";
    description = "yangdi";
    extraGroups = [ "networkmanager" "wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # To search, run:
  # $ nix search wget
  environment.systemPackages = [                                                                                                                                                                                                           
  #  vim # Do not forget to add an editor to edit configuration.nix!
  # The Nano editor is also installed by default.
  #  wget
    pkgs.vim
    pkgs.wget
    pkgs.pciutils
    pkgs.util-linux
    pkgs.procps
    pkgs.inetutils
    pkgs.tree
    pkgs.axel
    pkgs.nmap
    pkgs.arp-scan
    pkgs.git
    pkgs.tmux
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  #services.openssh.enable = true;
  #services.openssh.settings.PermitRootLogin = "no";
  #  services.openssh.PermitRootLogin = "no";
  #services.openssh.settings.PasswordAuthentication = false;
  #  services.openssh.PasswordAuthentication = false;
  #services.openssh.ports = [2233];

  # Open ports in the firewall.
  # networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [2233];
  networking.firewall = {
    enable = true;
   # allowedTCPPorts = [2233];
    
   # extraCommands = ''
    # create nixos-fw table
   # nft add table inet nixos-fw 2>/dev/null || true
    # 使用 nft 的完整路径
   # ${pkgs.nftables}/bin/nft delete chain inet nixos-fw output 2>/dev/null || true
    
    # 设置 OUTPUT 链默认策略为 DROP
   # ${pkgs.nftables}/bin/nft add chain inet nixos-fw output { type filter hook output priority 0 \; policy drop \; }
    
    # 添加允许规则
   # ${pkgs.nftables}/bin/nft add rule inet nixos-fw output ip daddr 127.0.0.1 counter accept
   # ${pkgs.nftables}/bin/nft add rule inet nixos-fw output ip daddr 172.18.23.207 counter accept
   # ${pkgs.nftables}/bin/nft add rule inet nixos-fw output ct state established,related counter accept
   # '';

   # extraPackages = [ pkgs.nftables ];

  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
