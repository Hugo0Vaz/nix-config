{ pkgs, ... }: {
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    nix-output-monitor
    gnupg
    pinentry-gnome3
    deskflow
  ];

  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-gnome3;
    enableSSHSupport = true;
    enable = true;
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;

  # TODO: coloquei essa variável de ambiente para resolver problemas de crashing
  # do gnome shell
  environment.variables = {
    GSK_RENDERER = "ngl";
  };

  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos
    ../../modules/nixos/desktop
    ../../modules/nixos/virtualization
    ../../modules/nixos/locale
    ../../modules/nixos/locale/time.nix
    ../../modules/nixos/gpu/nvidia.nix
    ../../modules/nixos/networking/tailscale.nix
    ../../modules/nixos/networking/firewall.nix
    ../../modules/nixos/user
  ];

  monolitoSystem.user = {
    name = "hugomvs";
    description = "Hugo Martins Vaz Silva";
  };
}
