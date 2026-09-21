{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          localsend
          inkscape
          gimp2
          pinta
          copyq
          # bitwarden-desktop
          remmina
          samba
          meld
          darktable
          proton-vpn
          dbeaver-bin
          scribus
          cups-bjnp
          cups
          gparted
          vscode-fhs
          openvpn3
        ] ++ [ pkgs.libxcb-cursor pkgs.qt6.qtwayland ];

      services.gvfs.enable = true;
      services.dbus.enable = true;
      services.gnome.gnome-keyring.enable = true;

      services.printing = {
        enable = true;
        drivers = [ pkgs.cups-filters pkgs.cnijfilter2 ];
      };
      services.ipp-usb.enable = true;

      services.avahi = {
        enable = true;
        openFirewall = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
        };
      };

      environment.variables = {
        QT_QPA_PLATFORM = "wayland";
        # Force GLib's poll-based (non-threaded) file monitor instead of
        # inotify. Sidesteps a recurring SIGSEGV in dconf clients (emacs,
        # remmina) where dconf's GDBus worker thread races the inotify
        # monitor's dispatch in g_file_monitor_source_dispatch. A prior
        # attempt at this used "polling", which isn't a real GIO module name
        # (only "poll" is) and silently did nothing.
        GIO_USE_FILE_MONITOR = "poll";
      };

      programs.dconf.enable = true;

      # dconf-service never exits on its own (it holds a permanent
      # GApplication use-count and only reacts to SIGTERM/SIGINT/SIGHUP) — so
      # every "Stopping/Stopped User preferences database" outside of an
      # actual shutdown is us restarting it. nixos-rebuild switch bounces it
      # on every generation because its store path changes, which races
      # against long-lived dconf clients (emacs, remmina) that still hold a
      # GFileMonitor/GDBus connection to the old instance, crashing them in
      # g_file_monitor_source_dispatch. Leave the already-running instance
      # alone across switches instead.
      systemd.user.services.dconf.restartIfChanged = false;

    };
}
