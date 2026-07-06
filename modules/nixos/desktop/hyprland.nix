{ ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland compositor managed by UWSM";
      # Hyprland 0.53+ requires launching via start-hyprland; running the raw
      # Hyprland binary is debug-only and warns on startup. Upstream guidance:
      # uwsm should launch start-hyprland (hypr.land forum thread 1260).
      binPath = "/run/current-system/sw/bin/start-hyprland";
    };
  };
}
