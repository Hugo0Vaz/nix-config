{
  flake.modules.nixos.kde =
    { pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;

      # Disable drkonqi's automatic systemd-coredump hook. It launches a Qt
      # crash-report dialog for every core dump on the system (not just
      # Plasma apps), but under niri it can't reach a Wayland display if the
      # compositor exits (e.g. a niri restart), fails with "Failed to create
      # wl_display", and aborts — which is itself a coredump, so it
      # relaunches itself in a crash loop. Masking the socket that triggers
      # it removes the auto-popup entirely; drkonqi can still be launched
      # manually from a Plasma session if ever needed.
      systemd.user.sockets."drkonqi-coredump-launcher".enable = false;

      # Exclude KDE's default packages that conflict or overlap with
      # packages already managed by other aspects.
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        konsole
        qt6ct
        okular
        kde-gtk-config # GTK theme is managed declaratively by home-manager; this sync daemon clobbers ~/.gtkrc-2.0
      ];
    };
}
