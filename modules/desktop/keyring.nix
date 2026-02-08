{ ... }: {
  # GNOME Keyring for network credentials
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
