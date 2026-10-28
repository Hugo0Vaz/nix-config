{
  flake.modules.nixos.gnome =
    { lib, config, ... }:
    {
      options.my.gnome.enable = lib.mkEnableOption "the GNOME desktop environment";

      config = lib.mkIf config.my.gnome.enable {
        services.desktopManager.gnome.enable = true;

        # Deliberately no environment.gnome.excludePackages here: unlike
        # kde.nix, keep GNOME's full stock app bundle (nautilus,
        # gnome-console, gnome-text-editor, gnome-calculator, etc.) as the
        # desktop's app base rather than deferring to other aspects' tool
        # choices.

        # Prefer GDM as the greeter over niri.nix's SDDM default whenever
        # GNOME is enabled alongside niri. mkForce is required because
        # niri.nix sets services.displayManager.sddm.enable as a plain
        # (non-mkDefault) assignment.
        services.displayManager.gdm.enable = true;
        services.displayManager.sddm.enable = lib.mkForce false;

        # Unlock the login keyring with the GDM password so libsecret
        # clients (Claude Desktop, etc.) find an unlocked Secret Service.
        security.pam.services.gdm-password.enableGnomeKeyring = true;
      };
    };
}
