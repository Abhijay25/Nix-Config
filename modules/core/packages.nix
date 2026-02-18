{ pkgs, ... }:

let
  nusvpn = pkgs.writeShellScriptBin "nusvpn" ''
    cookie=$(${pkgs.openfortivpn-webview}/bin/openfortivpn-webview webvpn.comp.nus.edu.sg 443)
    if [ -z "$cookie" ]; then
      echo "Failed to obtain SVPNCOOKIE" >&2
      exit 1
    fi
    exec sudo ${pkgs.openfortivpn}/bin/openfortivpn webvpn.comp.nus.edu.sg:443 --cookie="$cookie"
  '';
in {
  environment.systemPackages = with pkgs; [
    docker-compose
    git
    ghostty
    vim
    wget
    nix-output-monitor
    openfortivpn
    openfortivpn-webview
    nusvpn
  ];

  security.sudo.extraRules = [{
    users = [ "abhijay" ];
    commands = [{
      command = "${pkgs.openfortivpn}/bin/openfortivpn";
      options = [ "NOPASSWD" ];
    }];
  }];
}
