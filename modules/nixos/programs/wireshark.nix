{ pkgs, ... }: {
  # Full GUI build. `programs.wireshark` also installs the dumpcap setuid
  # wrapper and creates the `wireshark` group, so members can capture without
  # running the GUI as root.
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
