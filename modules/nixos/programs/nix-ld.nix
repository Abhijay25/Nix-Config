{ pkgs, ... }: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # C/C++ runtime
      stdenv.cc.cc.lib
      glibc
      libgcc.lib

      # Compression & encoding
      zlib
      zstd
      bzip2
      xz

      # Crypto & TLS
      openssl
      libffi

      # Common system libs (Python, Node native addons, etc.)
      glib
      libxml2
      libxslt
      sqlite
      readline
      ncurses
      icu
      libuuid

      # Networking
      curl

      # Python-specific
      expat

      # Node/npm native addon deps
      libuv
      libsecret

      # Build tools
      pkg-config
    ];
  };
}
