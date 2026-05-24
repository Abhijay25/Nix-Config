{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Terminal & NixOS tooling
    btop
    delta
    fd
    ffmpeg
    lazygit
    nh
    nixpkgs-fmt
    nodejs
    ripgrep
    semgrep
    tldr
    unzip
    zip

    # Editor & Languages
    claude-code
    code-cursor
    codex
    go
    gnumake
    nil
    tinymist
    typst

    # Coding
    uv
    yarn

    # Utilities
    zathura
  ];
}
