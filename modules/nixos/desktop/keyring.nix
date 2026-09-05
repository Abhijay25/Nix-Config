{ ... }: {
  # GNOME Keyring. The PAM hooks land in /etc/pam.d/login, and /etc/pam.d/sddm
  # substacks login, so the greeter password unlocks the keyring already — no
  # per-service enableGnomeKeyring is needed.
  #
  # Do NOT also set home-manager's `services.gnome-keyring.enable`: that starts
  # a second daemon, from a different store path, that PAM never hands the
  # login password to. Both ran at once until 2026-09-05.
  services.gnome.gnome-keyring.enable = true;
}
