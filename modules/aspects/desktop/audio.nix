{
  flake.modules.nixos.audio =
    { pkgs, ... }:
    {
      environment.systemPackages =
        with pkgs;
        [
          pavucontrol
        ];

      services.pulseaudio.enable = false;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;

        # Fuxi H3 (USB 040b:0897) reports a bogus hardware dB range
        # (0.00..0.39 dB playback, 0.00..0.12 dB mic). Any volume below 100%
        # gets clamped to the raw minimum (muting playback / zeroing mic gain).
        # Use software volume instead and leave the hardware mixer alone.
        wireplumber.extraConfig."51-fuxi-h3-soft-mixer" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "device.name" = "~alsa_card.usb-XiiSound_Technology_Corporation_Fuxi-H3*"; }
              ];
              actions.update-props = {
                "api.alsa.soft-mixer" = true;
              };
            }
          ];
        };
      };

      security.rtkit.enable = true;
    };
}
