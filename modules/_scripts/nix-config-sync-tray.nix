{ pkgs
, repoPath
, stateFile
, icons
}:

let
  python = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);
  typelibs = pkgs.lib.makeSearchPath "lib/girepository-1.0" (map pkgs.lib.getLib (with pkgs; [
    glib
    gobject-introspection
    cairo
    freetype
    fontconfig
    gtk3
    gdk-pixbuf
    pango
    harfbuzz
    atk
    libayatana-appindicator
  ]));
  trayPy = pkgs.writeText "nix-config-sync-tray.py" ''
    import os
    import subprocess
    import gi

    gi.require_version("Gtk", "3.0")
    gi.require_version("AyatanaAppIndicator3", "0.1")
    from gi.repository import GLib, Gtk, AyatanaAppIndicator3 as AppIndicator

    REPO = os.environ["NIX_CONFIG_REPO"]
    STATE_FILE = os.environ["NIX_CONFIG_STATE_FILE"]
    GIT = os.environ["NIX_CONFIG_GIT"]
    ICONS = {
        "synced": os.environ["NIX_CONFIG_ICON_SYNCED"],
        "dirty": os.environ["NIX_CONFIG_ICON_DIRTY"],
        "behind": os.environ["NIX_CONFIG_ICON_BEHIND"],
        "ahead": os.environ["NIX_CONFIG_ICON_AHEAD"],
        "diverged": os.environ["NIX_CONFIG_ICON_DIVERGED"],
    }
    DEFAULT_ICON = ICONS["diverged"]
    SERVICE = "nix-config-sync-check.service"

    ind = AppIndicator.Indicator.new(
        "nix-config-sync",
        DEFAULT_ICON,
        AppIndicator.IndicatorCategory.APPLICATION_STATUS,
    )
    ind.set_status(AppIndicator.IndicatorStatus.ACTIVE)

    menu = Gtk.Menu()
    info = Gtk.MenuItem(label="nix-config")
    info.set_sensitive(False)
    menu.append(info)
    menu.append(Gtk.SeparatorMenuItem())


    def check_now(_item=None):
        subprocess.Popen(["systemctl", "--user", "start", "--no-block", SERVICE])


    def git_then_check(cmd):
        def run(_item):
            def done(*_a):
                check_now()

            proc = subprocess.Popen([GIT, "-C", REPO] + cmd)
            GLib.child_watch_add(GLib.PRIORITY_DEFAULT, proc.pid, done)

        return run


    for label, handler in (
        ("Pull", git_then_check(["pull"])),
        ("Pull --rebase", git_then_check(["pull", "--rebase"])),
        ("Push", git_then_check(["push"])),
        ("Check now", check_now),
    ):
        item = Gtk.MenuItem(label=label)
        item.connect("activate", handler)
        menu.append(item)

    menu.show_all()
    ind.set_menu(menu)

    last = ["<init>"]


    def refresh():
        try:
            with open(STATE_FILE) as f:
                state, branch, ahead, behind, dirty = f.read().split()[:5]
        except (OSError, ValueError):
            state = None
        if state != last[0]:
            last[0] = state
            if state is None:
                ind.set_icon_full(ICONS["synced"], "synced")
                info.set_label("In sync with remote")
            else:
                ind.set_icon_full(ICONS.get(state, DEFAULT_ICON), state)
                info.set_label(
                    f"{branch}: {ahead} ahead, {behind} behind, {dirty} uncommitted"
                )
        return True


    refresh()
    GLib.timeout_add_seconds(5, refresh)
    Gtk.main()
  '';
in
pkgs.writeShellScriptBin "nix-config-sync-tray" ''
  export GI_TYPELIB_PATH="${typelibs}"
  export NIX_CONFIG_REPO="${repoPath}"
  export NIX_CONFIG_STATE_FILE="${stateFile}"
  export NIX_CONFIG_ICON_SYNCED="${icons.synced}"
  export NIX_CONFIG_ICON_DIRTY="${icons.dirty}"
  export NIX_CONFIG_ICON_BEHIND="${icons.behind}"
  export NIX_CONFIG_ICON_AHEAD="${icons.ahead}"
  export NIX_CONFIG_ICON_DIVERGED="${icons.diverged}"
  export NIX_CONFIG_GIT="${pkgs.git}/bin/git"
  exec ${python}/bin/python ${trayPy}
''
