{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Terminal & NixOS tooling
    btop
    delta
    fd
    ffmpeg
    gh
    jq
    lazygit
    nh
    nixfmt
    nodejs
    ripgrep
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
    google-cloud-sdk
    pnpm
    python3Packages.huggingface-hub
    uv
    wrangler
    yarn

    # Utilities
    zathura
  ];
}
