{
  flake.modules.nixos.gnupg =
    { pkgs
    , ...
    }:
    {

      environment.systemPackages = with pkgs; [
        gnupg
        pinentry-all
      ];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        # pinentry-all falls back to the curses UI when no display is
        # available, and to Qt/GTK when one is, so it works on both
        # headless and desktop hosts.
        pinentryPackage = pkgs.pinentry-all;
      };
    };
}
