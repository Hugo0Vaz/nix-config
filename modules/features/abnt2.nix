{
  flake.modules.nixos.abnt2 =
    {
      services.xserver.xkb = {
        layout = "br";
        variant = "abnt2";
        model = "abnt2";
      };
      i18n.defaultLocale = "pt_BR.UTF-8";
      i18n.extraLocaleSettings = {
          LC_ADDRESS = "pt_BR.UTF-8";
          LC_IDENTIFICATION = "pt_BR.UTF-8";
          LC_MEASUREMENT = "pt_BR.UTF-8";
          LC_MONETARY = "pt_BR.UTF-8";
          LC_NAME = "pt_BR.UTF-8";
          LC_NUMERIC = "pt_BR.UTF-8";
          LC_PAPER = "pt_BR.UTF-8";
          LC_TELEPHONE = "pt_BR.UTF-8";
          LC_TIME = "pt_BR.UTF-8";
        };
      console.keyMap = "br-abnt2";
    };
}
