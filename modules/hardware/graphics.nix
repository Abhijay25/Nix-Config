{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For Steam, Wine

    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver    # Hardware Video Acceleration (Broadwell+)
      intel-vaapi-driver    # Fallback for older chips
      libvdpau-va-gl
    ];
  };

  # Force Intel Gen8+ driver
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
}
