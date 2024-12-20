# TODO:
#     - Improve latency
#     - Can headroom be decreased furhter without triggering the bug?
{ lib, ... }:
{
  hardware.pulseaudio.enable = lib.mkForce false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Workarounds for Momentum 3 hardware bugs.
    # All identifiers are strings to prevent forgetting quotes and the breaking config. (again)
    wireplumber.extraConfig = {
      # Use soft mixer because of issues With absolute volume.
      "11-momentum3-softmixer" = {
        "monitor.alsa.rules" = [
          {
            "matches" = [ { "device.name" = "~alsa_card.*"; } ];
            "actions" = {
              "update-props" = {
                "api.alsa.soft-mixer" = true;
              };
            };
          }
        ];
      };

      # Bug fix where auido stops working with multiple streams.
      "11-momentum3-multistream-fix" = {
        "monitor.alsa.rules" = [
          {
            "matches" = [
              {
                # Matches all sources
                "node.name" = "~alsa_input.*";
              }
              {
                # Matches all sinks
                "node.name" = "~alsa_output.*";
              }
            ];
            "actions" = {
              "update-props" = {
                "api.alsa.headroom" = 1024;
              };
            };
          }
        ];
      };

    };
  };
  security.rtkit.enable = true;

  # Disable hardware volume controls on Momentum 3
  services.udev.extraRules = ''
    ACTION=="add", ATTR{idVendor}=="1377", ATTR{idProduct}=="6004", RUN+="/bin/sh -c 'echo 0 > /sys$DEVPATH/`basename $DEVPATH`:1.2/authorized'"
  '';
}
