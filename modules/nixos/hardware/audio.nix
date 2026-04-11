{ pkgs, ... }: {
  # PipeWire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;

    # Low-latency config
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
      };
    };

    # Allow volume above 100%
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-volume-boost.conf" ''
        monitor.alsa.rules = [
          {
            matches = [
              {
                node.name = "~alsa_output.*"
              }
            ]
            actions = {
              update-props = {
                api.alsa.soft-mixer = true
                api.alsa.ignore-dB = true
              }
            }
          }
        ]
      '')
    ];
  };
}
