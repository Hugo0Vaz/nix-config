{
  flake.modules.nixos.gnupg =
    { pkgs
    , ...
    }:
    {

      environment.systemPackages = with pkgs; [
        gnupg
        pinentry-gnome3 # or pinentry-qt, pinentry-gnome3, etc.
        pinentry-curses
      ];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true; # Optional: use GPG agent for SSH authentication
        pinentryPackage = pkgs.pinentry-curses; # Match your preferred pinentry UI
      };
    };
}
