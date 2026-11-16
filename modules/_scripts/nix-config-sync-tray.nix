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

    from gi.repository import Gio, GLib

    gi.require_version("GdkPixbuf", "2.0")
    from gi.repository import GdkPixbuf

    REPO = os.environ["NIX_CONFIG_REPO"]
    STATE_FILE = os.environ["NIX_CONFIG_STATE_FILE"]
    GIT = os.environ["NIX_CONFIG_GIT"]
    KITTY = os.environ["NIX_CONFIG_KITTY"]
    ICON_FILES = {
        "synced": os.environ["NIX_CONFIG_ICON_SYNCED"],
        "dirty": os.environ["NIX_CONFIG_ICON_DIRTY"],
        "behind": os.environ["NIX_CONFIG_ICON_BEHIND"],
        "ahead": os.environ["NIX_CONFIG_ICON_AHEAD"],
        "diverged": os.environ["NIX_CONFIG_ICON_DIVERGED"],
    }
    DEFAULT_STATE = "diverged"
    SERVICE = "nix-config-sync-check.service"

    ITEM_PATH = "/StatusNotifierItem"
    MENU_PATH = "/MenuBar"

    SNI_XML = """
    <node>
      <interface name="org.kde.StatusNotifierItem">
        <property name="Category" type="s" access="read"/>
        <property name="Id" type="s" access="read"/>
        <property name="Title" type="s" access="read"/>
        <property name="Status" type="s" access="read"/>
        <property name="WindowId" type="u" access="read"/>
        <property name="IconName" type="s" access="read"/>
        <property name="IconPixmap" type="a(iiay)" access="read"/>
        <property name="ItemIsMenu" type="b" access="read"/>
        <property name="Menu" type="o" access="read"/>
        <property name="ToolTip" type="(sa(iiay)ss)" access="read"/>
        <method name="Activate"><arg type="i" direction="in"/><arg type="i" direction="in"/></method>
        <method name="SecondaryActivate"><arg type="i" direction="in"/><arg type="i" direction="in"/></method>
        <method name="ContextMenu"><arg type="i" direction="in"/><arg type="i" direction="in"/></method>
        <method name="Scroll"><arg type="i" direction="in"/><arg type="s" direction="in"/></method>
        <signal name="NewIcon"/>
        <signal name="NewToolTip"/>
        <signal name="NewStatus"><arg type="s"/></signal>
      </interface>
    </node>
    """

    MENU_XML = """
    <node>
      <interface name="com.canonical.dbusmenu">
        <property name="Version" type="u" access="read"/>
        <property name="TextDirection" type="s" access="read"/>
        <property name="Status" type="s" access="read"/>
        <property name="IconThemePath" type="as" access="read"/>
        <method name="GetLayout">
          <arg type="i" direction="in"/><arg type="i" direction="in"/><arg type="as" direction="in"/>
          <arg type="u" direction="out"/><arg type="(ia{sv}av)" direction="out"/>
        </method>
        <method name="GetGroupProperties">
          <arg type="ai" direction="in"/><arg type="as" direction="in"/>
          <arg type="a(ia{sv})" direction="out"/>
        </method>
        <method name="GetProperty">
          <arg type="i" direction="in"/><arg type="s" direction="in"/><arg type="v" direction="out"/>
        </method>
        <method name="Event">
          <arg type="i" direction="in"/><arg type="s" direction="in"/><arg type="v" direction="in"/><arg type="u" direction="in"/>
        </method>
        <method name="AboutToShow"><arg type="i" direction="in"/><arg type="b" direction="out"/></method>
        <signal name="LayoutUpdated"><arg type="u"/><arg type="i"/></signal>
      </interface>
    </node>
    """


    def load_pixmap(path, size=48):
        pb = GdkPixbuf.Pixbuf.new_from_file_at_size(path, size, size)
        if not pb.get_has_alpha():
            pb = pb.add_alpha(False, 0, 0, 0)
        w, h, stride = pb.get_width(), pb.get_height(), pb.get_rowstride()
        src = pb.get_pixels()
        out = bytearray()
        for y in range(h):
            row = src[y * stride:y * stride + w * 4]
            for x in range(w):
                r, g, b, a = row[x * 4:x * 4 + 4]
                out += bytes((a, r, g, b))  # ARGB, network byte order
        return (w, h, bytes(out))


    PIXMAPS = {k: load_pixmap(v) for k, v in ICON_FILES.items()}


    def open_commit():
        # Dedicated floating kitty window (niri rule matches the class).
        subprocess.Popen([
            KITTY, "--class", "nix-config-commit", "--directory", REPO,
            "sh", "-c", 'git status -sb; exec "''${SHELL:-sh}"',
        ])


    def check_now():
        subprocess.Popen(["systemctl", "--user", "start", "--no-block", SERVICE])


    def git_then_check(cmd):
        def run():
            proc = subprocess.Popen([GIT, "-C", REPO] + cmd)
            GLib.child_watch_add(GLib.PRIORITY_DEFAULT, proc.pid, lambda *_a: check_now())

        return run


    state = {"name": None, "info": "In sync with remote", "rev": 1}

    # Menu items: (id, label, handler); id 1 is the info line, 2 a separator.
    ACTIONS = {
        3: ("Commit…", open_commit),
        4: ("Pull", git_then_check(["pull"])),
        5: ("Pull --rebase", git_then_check(["pull", "--rebase"])),
        6: ("Push", git_then_check(["push"])),
        7: ("Check now", check_now),
    }


    def item_props(item_id):
        if item_id == 0:
            return {"children-display": GLib.Variant("s", "submenu")}
        if item_id == 1:
            return {
                "label": GLib.Variant("s", state["info"]),
                "enabled": GLib.Variant("b", False),
            }
        if item_id == 2:
            return {"type": GLib.Variant("s", "separator")}
        return {"label": GLib.Variant("s", ACTIONS[item_id][0])}


    def layout_node(item_id):
        kids = []
        if item_id == 0:
            kids = [GLib.Variant("(ia{sv}av)", (i, item_props(i), [])) for i in (1, 2, 3, 4, 5, 6, 7)]
        return (item_id, item_props(item_id), kids)


    def menu_call(conn, sender, path, iface, method, params, inv):
        if method == "GetLayout":
            inv.return_value(GLib.Variant("(u(ia{sv}av))", (state["rev"], layout_node(params[0]))))
        elif method == "GetGroupProperties":
            ids = params[0] or [0, 1, 2, 3, 4, 5, 6, 7]
            inv.return_value(GLib.Variant("(a(ia{sv}))", ([(i, item_props(i)) for i in ids],)))
        elif method == "GetProperty":
            inv.return_value(GLib.Variant("(v)", (item_props(params[0]).get(params[1], GLib.Variant("s", "")),)))
        elif method == "Event":
            if params[1] == "clicked" and params[0] in ACTIONS:
                ACTIONS[params[0]][1]()
            inv.return_value(None)
        elif method == "AboutToShow":
            inv.return_value(GLib.Variant("(b)", (False,)))
        else:
            inv.return_value(None)


    MENU_PROPS = {
        "Version": GLib.Variant("u", 3),
        "TextDirection": GLib.Variant("s", "ltr"),
        "Status": GLib.Variant("s", "normal"),
        "IconThemePath": GLib.Variant("as", []),
    }


    def item_call(conn, sender, path, iface, method, params, inv):
        if method == "Activate":
            open_commit()
        elif method == "SecondaryActivate":
            open_commit()
        inv.return_value(None)


    def item_prop(conn, sender, path, iface, name):
        name_state = state["name"] or "synced"
        if name == "Category":
            return GLib.Variant("s", "ApplicationStatus")
        if name == "Id":
            return GLib.Variant("s", "nix-config-sync")
        if name == "Title":
            return GLib.Variant("s", "nix-config")
        if name == "Status":
            return GLib.Variant("s", "Active")
        if name == "WindowId":
            return GLib.Variant("u", 0)
        if name == "IconName":
            return GLib.Variant("s", "")
        if name == "IconPixmap":
            w, h, data = PIXMAPS.get(name_state, PIXMAPS[DEFAULT_STATE])
            return GLib.Variant("a(iiay)", [(w, h, list(data))])
        if name == "ItemIsMenu":
            return GLib.Variant("b", False)
        if name == "Menu":
            return GLib.Variant("o", MENU_PATH)
        if name == "ToolTip":
            return GLib.Variant("(sa(iiay)ss)", ("", [], "nix-config", state["info"]))
        return None


    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    bus.register_object(
        ITEM_PATH, Gio.DBusNodeInfo.new_for_xml(SNI_XML).interfaces[0],
        item_call, item_prop, None,
    )
    bus.register_object(
        MENU_PATH, Gio.DBusNodeInfo.new_for_xml(MENU_XML).interfaces[0],
        menu_call, lambda c, s, p, i, n: MENU_PROPS.get(n), None,
    )

    BUS_NAME = f"org.kde.StatusNotifierItem-{os.getpid()}-1"
    Gio.bus_own_name_on_connection(bus, BUS_NAME, Gio.BusNameOwnerFlags.NONE, None, None)


    def register(*_a):
        bus.call(
            "org.kde.StatusNotifierWatcher", "/StatusNotifierWatcher",
            "org.kde.StatusNotifierWatcher", "RegisterStatusNotifierItem",
            GLib.Variant("(s)", (BUS_NAME,)), None, Gio.DBusCallFlags.NONE, -1, None, None,
        )


    Gio.bus_watch_name_on_connection(
        bus, "org.kde.StatusNotifierWatcher", Gio.BusNameWatcherFlags.NONE, register, None,
    )


    def emit(iface_path, iface, signal, params=None):
        bus.emit_signal(None, iface_path, iface, signal, params)


    def refresh():
        try:
            with open(STATE_FILE) as f:
                name, branch, ahead, behind, dirty = f.read().split()[:5]
        except (OSError, ValueError):
            name = None
        if name != state["name"] or state["rev"] == 1 and name is None:
            state["name"] = name
            state["info"] = (
                "In sync with remote" if name is None
                else f"{branch}: {ahead} ahead, {behind} behind, {dirty} uncommitted"
            )
            state["rev"] += 1
            emit(ITEM_PATH, "org.kde.StatusNotifierItem", "NewIcon")
            emit(ITEM_PATH, "org.kde.StatusNotifierItem", "NewToolTip")
            emit(MENU_PATH, "com.canonical.dbusmenu", "LayoutUpdated",
                 GLib.Variant("(ui)", (state["rev"], 0)))
        return True


    refresh()
    GLib.timeout_add_seconds(5, refresh)
    GLib.MainLoop().run()
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
  export NIX_CONFIG_KITTY="${pkgs.kitty}/bin/kitty"
  exec ${python}/bin/python ${trayPy}
''
