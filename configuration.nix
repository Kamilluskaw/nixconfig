# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Kamillaptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Budapest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "hu_HU.UTF-8";
    LC_IDENTIFICATION = "hu_HU.UTF-8";
    LC_MEASUREMENT = "hu_HU.UTF-8";
    LC_MONETARY = "hu_HU.UTF-8";
    LC_NAME = "hu_HU.UTF-8";
    LC_NUMERIC = "hu_HU.UTF-8";
    LC_PAPER = "hu_HU.UTF-8";
    LC_TELEPHONE = "hu_HU.UTF-8";
    LC_TIME = "hu_HU.UTF-8";
  };

  # Enable the X11 windowing system.
# Enable the XFCE Desktop Environment.
services.xserver = {
  enable = true;
  displayManager.lightdm.enable = true;
  desktopManager.xfce.enable = true;

  # Configure Xfce window manager margins
  displayManager.sessionCommands = ''
    xfconf-query -c xfwm4 -p /general/margin_top -s 10
    xfconf-query -c xfwm4 -p /general/margin_bottom -s 10
    xfconf-query -c xfwm4 -p /general/margin_left -s 10
    xfconf-query -c xfwm4 -p /general/margin_right -s 10
  '';
};
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "hu";
    variant = "101_qwerty_comma_dead";
  };

  # Configure console keymap
  console.keyMap = "hu";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # your Open GL, Vulkan and VAAPI drivers
      vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
      # onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
      # intel-media-sdk   # for older GPUs
    ];
  };

  #Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.milka = {
    isNormalUser = true;
    description = "milka";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "milka";
  # Install firefox.
  programs.firefox.enable = true;

  #Steam
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;  # Optional: Open ports for Steam Remote Play
  dedicatedServer.openFirewall = true;  # Optional: Open ports for Source Dedicated Server
};

  #Charging setting 
  services.tlp.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
		#Office/system
			libreoffice
			obsidian
			vscode
			unrar
			git
			picom
			conky
			xwinwrap
			mpv
			krita
			kdenlive
			godot_4
		#Gaming
			obs-studio
			steamcmd
			steam-tui
			(prismlauncher.override {
                		additionalPrograms = [ ffmpeg ];
        		})
			lutris 
			wine
			(discord.override {
    				withVencord = true; # Enable Vencord
  			})

		#Anime
		   	ani-cli
		#Recum
			(writeShellScriptBin "recum" ''
			#Rebuilds the system
                                echo "woah, i can do thiss,,,"
                                ${config.system.build.nixos-rebuild}/bin/nixos-rebuild switch

		        #Empties trashcan
                                echo "yummmm ><"
                                ${pkgs.glib.bin}/bin/gio trash --empty

      			#Clears gens older than 3days, only keeps latest 3
     				echo "woof woof deleted :3"
    				${pkgs.nix}/bin/nix-env --delete-generations +3

			#Upgrades the system 
                                echo "uwu,,,i love new packages ;3"
                                ${config.system.build.nixos-rebuild}/bin/nixos-rebuild switch --upgrade

 			# Mirror the config to git
  				echo "Mirroringgg :0"
  			if [ -d "/etc/nixos/.git" ]; then
    				cd /etc/nixos
    			if [ -n "$(${pkgs.git}/bin/git status --porcelain)" ]; then
      			# Run Git commands as the user who owns the repository
      				sudo -u milka ${pkgs.git}/bin/git add .
      				sudo -u milka ${pkgs.git}/bin/git commit -m "Automated NixOS configuration update"
     				sudo -u milka ${pkgs.git}/bin/git push origin master
    			else
     				echo "woof nothing happened,,,"
    			fi
  			else
   				echo "huh"
 			fi
   			# Wait for 10 seconds before shutting down
  			        echo "honk mimimi,,"
      				${pkgs.coreutils}/bin/sleep 10
     		   	# Shuts the system
      				echo "nyaaa,,,"
   				echo "Cum again :3"
      				${pkgs.systemd}/bin/shutdown -h now
    			'')
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;

  # List services that you want to enable
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
