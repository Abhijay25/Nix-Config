# flake-parts Multi-Host Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure dotfiles from a single-host NixOS flake into a flake-parts layout that cleanly supports NixOS (doge ThinkPad), future nix-darwin (Mac), future VPS, and future Pi — with shared home-manager config factored out from platform-specific config.

**Architecture:** flake-parts wraps the flake outputs; NixOS system modules live in `modules/nixos/`; home-manager config is split into `modules/home/shared/` (cross-platform: shell, programs, dev tools) and `modules/home/linux/` (Wayland desktop, Linux packages, Linux aliases); each host gets its own `hosts/<name>/default.nix` that imports the relevant system modules.

**Tech Stack:** Nix flakes, flake-parts (`hercules-ci/flake-parts`), home-manager, nix-darwin (input added now, not yet wired), NixOS 25.11-unstable

---

## Current State (read this first)

```
dotfiles/
├── flake.nix                          # single nixosConfigurations.doge output
├── hardware-configuration.nix         # at root — needs to move to hosts/doge/
├── modules/
│   ├── default.nix                    # imports everything — will be replaced
│   ├── core/{boot,networking,nix,packages,system}.nix
│   ├── hardware/{graphics,audio,bluetooth,power}.nix
│   ├── desktop/{niri,niri-autotile,sddm,portal,theming,keyring}.nix
│   ├── programs/{shell,nixvim,wireshark}.nix
│   ├── services/docker.nix
│   └── users/{system,abhijay}.nix    # abhijay.nix is home-manager (monolithic)
├── configs/{ghostty,niri,satty,starship,brrtfetch}/
└── pkgs/niri-autotile/
```

### What goes where after migration

| Current file | Destination | Reason |
|---|---|---|
| `hardware-configuration.nix` | `hosts/doge/hardware-configuration.nix` | Host-specific hardware |
| `modules/default.nix` | DELETED | Replaced by `hosts/doge/default.nix` |
| `modules/core/*` | `modules/nixos/core/*` | NixOS system-level |
| `modules/hardware/*` | `modules/nixos/hardware/*` | NixOS system-level |
| `modules/desktop/*` | `modules/nixos/desktop/*` | NixOS system-level |
| `modules/programs/shell.nix` | `modules/nixos/programs/shell.nix` | System zsh enable |
| `modules/programs/wireshark.nix` | `modules/nixos/programs/wireshark.nix` | System program |
| `modules/programs/nixvim.nix` | `modules/home/shared/nixvim.nix` | Home-manager, cross-platform |
| `modules/services/docker.nix` | `modules/nixos/services/docker.nix` | NixOS service |
| `modules/users/system.nix` | `modules/nixos/users/system.nix` | NixOS user declaration |
| `modules/users/abhijay.nix` | SPLIT (see below) | Home-manager — monolithic |

### abhijay.nix split

| New file | Content from abhijay.nix |
|---|---|
| `modules/home/shared/shell.nix` | zsh config (shared parts), starship, zoxide, fzf, direnv, yazi, git, vscode, `EDITOR` var, `xdg.enable`, shared aliases (`btw`, `flakeupdate`) |
| `modules/home/shared/packages.nix` | Cross-platform packages (btop, delta, fd, go, ripgrep, etc.) |
| `modules/home/shared/nixvim.nix` | Moved from `modules/programs/nixvim.nix` |
| `modules/home/linux/desktop.nix` | swaync, nm-applet, gnome-keyring, ghostty systemd service, polkit service, GTK theming, `xdg.configFile` symlinks, `xdg.userDirs`, `NIXOS_OZONE_WL`, linux aliases (`nrs`, `fastfetch`, `vpn`) |
| `modules/home/linux/packages.nix` | Linux-specific packages (bluez, grim, satty, slurp, chromium, brave, vesktop, etc.) |
| `modules/home/linux/abhijay.nix` | Entry point: `home.username`, `home.homeDirectory`, `home.stateVersion`, imports shared/* + linux/* + noctalia |

---

## File Map After Migration

```
dotfiles/
├── flake.nix                          # flake-parts, adds nix-darwin input
├── flake.lock
├── hosts/
│   └── doge/
│       ├── default.nix               # CREATE: imports nixos modules
│       └── hardware-configuration.nix # MOVE from root
├── modules/
│   ├── nixos/                         # RENAME from modules/{core,hardware,...}
│   │   ├── core/{boot,networking,nix,packages,system}.nix
│   │   ├── hardware/{graphics,audio,bluetooth,power}.nix
│   │   ├── desktop/{niri,niri-autotile,sddm,portal,theming,keyring}.nix
│   │   ├── programs/{shell,wireshark}.nix
│   │   ├── services/docker.nix
│   │   └── users/system.nix
│   ├── darwin/                        # CREATE (placeholder for future)
│   │   └── .gitkeep
│   └── home/
│       ├── shared/
│       │   ├── shell.nix             # CREATE: zsh+tools, cross-platform
│       │   ├── packages.nix          # CREATE: cross-platform packages
│       │   └── nixvim.nix            # MOVE from modules/programs/nixvim.nix
│       ├── linux/
│       │   ├── abhijay.nix           # CREATE: entry point for linux user
│       │   ├── desktop.nix           # CREATE: wayland/linux-specific HM config
│       │   └── packages.nix          # CREATE: linux-specific packages
│       └── darwin/
│           └── .gitkeep              # CREATE: placeholder
├── configs/                           # UNCHANGED
└── pkgs/                              # UNCHANGED
```

---

## Task 1: Add flake-parts and nix-darwin inputs

**Files:**
- Modify: `flake.nix`

- [ ] **Step 1: Add two new inputs to flake.nix**

Open `flake.nix` and add these two inputs inside the `inputs = { ... }` block, after the existing `nixpkgs` input:

```nix
flake-parts.url = "github:hercules-ci/flake-parts";

nix-darwin = {
  url = "github:LnL7/nix-darwin";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

The `outputs` block is NOT changed yet — leave it as `nixpkgs.lib.nixosSystem { ... }`. This step only primes `flake.lock`.

- [ ] **Step 2: Update flake.lock**

```bash
cd ~/dotfiles && nix flake lock
```

Expected: `flake.lock` updated with flake-parts and nix-darwin entries. No build errors.

- [ ] **Step 3: Commit**

```bash
git add flake.nix flake.lock
git commit -m "chore: add flake-parts and nix-darwin inputs"
```

---

## Task 2: Create directory skeleton

**Files:**
- Create: `hosts/doge/` (directory)
- Create: `modules/nixos/` (directory)
- Create: `modules/home/shared/`, `modules/home/linux/`, `modules/home/darwin/`
- Create: `modules/darwin/`

- [ ] **Step 1: Create all directories**

```bash
cd ~/dotfiles
mkdir -p hosts/doge
mkdir -p modules/nixos/core modules/nixos/hardware modules/nixos/desktop
mkdir -p modules/nixos/programs modules/nixos/services modules/nixos/users
mkdir -p modules/home/shared modules/home/linux modules/home/darwin
mkdir -p modules/darwin
```

- [ ] **Step 2: Add placeholders for empty dirs that will be used later**

```bash
touch modules/darwin/.gitkeep
touch modules/home/darwin/.gitkeep
```

- [ ] **Step 3: Verify structure**

```bash
find ~/dotfiles/hosts ~/dotfiles/modules/nixos ~/dotfiles/modules/home ~/dotfiles/modules/darwin -type d | sort
```

Expected output includes:
```
dotfiles/hosts/doge
dotfiles/modules/darwin
dotfiles/modules/home/darwin
dotfiles/modules/home/linux
dotfiles/modules/home/shared
dotfiles/modules/nixos/core
dotfiles/modules/nixos/desktop
dotfiles/modules/nixos/hardware
dotfiles/modules/nixos/programs
dotfiles/modules/nixos/services
dotfiles/modules/nixos/users
```

---

## Task 3: Move NixOS system modules

**Files:**
- Move: `modules/core/*` → `modules/nixos/core/*`
- Move: `modules/hardware/*` → `modules/nixos/hardware/*`
- Move: `modules/desktop/*` → `modules/nixos/desktop/*`
- Move: `modules/programs/shell.nix` → `modules/nixos/programs/shell.nix`
- Move: `modules/programs/wireshark.nix` → `modules/nixos/programs/wireshark.nix`
- Move: `modules/services/docker.nix` → `modules/nixos/services/docker.nix`
- Move: `modules/users/system.nix` → `modules/nixos/users/system.nix`
- Move: `hardware-configuration.nix` → `hosts/doge/hardware-configuration.nix`

None of these files change content — pure moves.

- [ ] **Step 1: Move core modules**

```bash
cd ~/dotfiles
git mv modules/core/boot.nix modules/nixos/core/boot.nix
git mv modules/core/networking.nix modules/nixos/core/networking.nix
git mv modules/core/nix.nix modules/nixos/core/nix.nix
git mv modules/core/packages.nix modules/nixos/core/packages.nix
git mv modules/core/system.nix modules/nixos/core/system.nix
```

- [ ] **Step 2: Move hardware modules**

```bash
git mv modules/hardware/audio.nix modules/nixos/hardware/audio.nix
git mv modules/hardware/bluetooth.nix modules/nixos/hardware/bluetooth.nix
git mv modules/hardware/graphics.nix modules/nixos/hardware/graphics.nix
git mv modules/hardware/power.nix modules/nixos/hardware/power.nix
```

- [ ] **Step 3: Move desktop modules**

```bash
git mv modules/desktop/keyring.nix modules/nixos/desktop/keyring.nix
git mv modules/desktop/niri-autotile.nix modules/nixos/desktop/niri-autotile.nix
git mv modules/desktop/niri.nix modules/nixos/desktop/niri.nix
git mv modules/desktop/portal.nix modules/nixos/desktop/portal.nix
git mv modules/desktop/sddm.nix modules/nixos/desktop/sddm.nix
git mv modules/desktop/theming.nix modules/nixos/desktop/theming.nix
```

- [ ] **Step 4: Move program and service modules**

```bash
git mv modules/programs/shell.nix modules/nixos/programs/shell.nix
git mv modules/programs/wireshark.nix modules/nixos/programs/wireshark.nix
git mv modules/services/docker.nix modules/nixos/services/docker.nix
git mv modules/users/system.nix modules/nixos/users/system.nix
```

- [ ] **Step 5: Move hardware-configuration to hosts/doge/**

```bash
git mv hardware-configuration.nix hosts/doge/hardware-configuration.nix
```

- [ ] **Step 6: Verify git sees renames (not deletions)**

```bash
git status
```

Expected: All changes show as `renamed:`, not `deleted:` + `new file:`.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "refactor: move nixos modules to modules/nixos/ and hardware-configuration to hosts/doge/"
```

---

## Task 4: Create hosts/doge/default.nix

**Files:**
- Create: `hosts/doge/default.nix`

This replaces `modules/default.nix` as the host entry point. It imports the same modules, just with updated paths.

- [ ] **Step 1: Create hosts/doge/default.nix**

```nix
{ ... }: {
  imports = [
    ./hardware-configuration.nix

    # Core
    ../../modules/nixos/core/boot.nix
    ../../modules/nixos/core/networking.nix
    ../../modules/nixos/core/nix.nix
    ../../modules/nixos/core/packages.nix
    ../../modules/nixos/core/system.nix

    # Hardware
    ../../modules/nixos/hardware/graphics.nix
    ../../modules/nixos/hardware/audio.nix
    ../../modules/nixos/hardware/bluetooth.nix
    ../../modules/nixos/hardware/power.nix

    # Desktop
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/niri-autotile.nix
    ../../modules/nixos/desktop/sddm.nix
    ../../modules/nixos/desktop/portal.nix
    ../../modules/nixos/desktop/theming.nix
    ../../modules/nixos/desktop/keyring.nix

    # Programs
    ../../modules/nixos/programs/shell.nix
    ../../modules/nixos/programs/wireshark.nix

    # Services
    ../../modules/nixos/services/docker.nix

    # Users
    ../../modules/nixos/users/system.nix
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add hosts/doge/default.nix
git commit -m "feat: add hosts/doge/default.nix with full module import list"
```

---

## Task 5: Create modules/home/shared/nixvim.nix

**Files:**
- Move content: `modules/programs/nixvim.nix` → `modules/home/shared/nixvim.nix`

nixvim.nix imports `inputs.nixvim.homeModules.nixvim` — this is a home-manager module. No content changes, just path.

- [ ] **Step 1: Move nixvim.nix**

```bash
cd ~/dotfiles
git mv modules/programs/nixvim.nix modules/home/shared/nixvim.nix
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "refactor: move nixvim home module to modules/home/shared/"
```

---

## Task 6: Create modules/home/shared/shell.nix

**Files:**
- Create: `modules/home/shared/shell.nix`

Extracted from `modules/users/abhijay.nix`. Contains everything that works identically on Linux and macOS: zsh, starship, zoxide, fzf, direnv, yazi, git, vscode, XDG base, EDITOR var, and platform-neutral aliases.

- [ ] **Step 1: Create modules/home/shared/shell.nix**

```nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    completionInit = ''
      autoload -Uz compinit
      if [[ -n ''${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
        compinit -d ''${ZDOTDIR}/.zcompdump
      else
        compinit -C -d ''${ZDOTDIR}/.zcompdump
      fi
    '';

    initContent = lib.mkBefore ''
      export ZSH_DISABLE_COMPFIX="true"
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      # Move fzf file-search from Ctrl+T (taken by ghostty new-tab) to Ctrl+F
      bindkey -r '^T'
      bindkey '^F' fzf-file-widget
    '';

    shellAliases = {
      btw = "echo I use Nix btw";
      flakeupdate = "~/dotfiles/scripts/update-flake.sh";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        hide_env_diff = true;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Abhijay";
        email = "163997617+Abhijay25@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        syntax-theme = "tokyonight_night";
        line-numbers = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings = {
      manager = {
        ratio = [ 1 2 6 ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = false;
        show_symlink = true;
      };
      preview = {
        max_width = 4096;
        max_height = 4096;
      };
    };
    keymap = {
      manager.prepend_keymap = [
        { on = [ "q" ]; run = "quit"; desc = "Exit yazi"; }
        { on = [ "<Esc>" ]; run = "escape"; desc = "Cancel operation"; }
      ];
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.enable = true;
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/shared/shell.nix
git commit -m "feat: add modules/home/shared/shell.nix with cross-platform shell config"
```

---

## Task 7: Create modules/home/shared/packages.nix

**Files:**
- Create: `modules/home/shared/packages.nix`

Packages from `abhijay.nix` that exist in nixpkgs for both Linux and macOS.

- [ ] **Step 1: Create modules/home/shared/packages.nix**

```nix
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
    yarn

    # Utilities
    zathura
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/shared/packages.nix
git commit -m "feat: add modules/home/shared/packages.nix with cross-platform packages"
```

---

## Task 8: Create modules/home/linux/packages.nix

**Files:**
- Create: `modules/home/linux/packages.nix`

Packages from `abhijay.nix` that are Linux/Wayland-specific.

- [ ] **Step 1: Create modules/home/linux/packages.nix**

```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # System
    bluez
    bluez-tools
    gcc
    polkit_gnome
    engrampa

    # Terminal
    fastfetch

    # Quality of Life
    brightnessctl
    libnotify
    pamixer
    playerctl

    # Wayland Utilities
    grim
    satty
    slurp
    wl-clipboard

    # Ricing & Themes
    adwaita-icon-theme
    swww
    util-linux

    # Applications
    (chromium.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform"
      ];
    })
    localsend
    telegram-desktop
    vesktop
    spotify

    (brave.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
      ];
    })
  ];
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/linux/packages.nix
git commit -m "feat: add modules/home/linux/packages.nix with linux/wayland packages"
```

---

## Task 9: Create modules/home/linux/desktop.nix

**Files:**
- Create: `modules/home/linux/desktop.nix`

Linux-specific home-manager config from `abhijay.nix`: services, GTK, systemd user units, XDG config symlinks, user dirs, Wayland session variables, and linux-only shell aliases.

- [ ] **Step 1: Create modules/home/linux/desktop.nix**

```nix
{
  config,
  pkgs,
  ...
}: {
  # Notification daemon
  services.swaync = {
    enable = true;
    settings = {
      focus-window = false;
    };
  };

  services.network-manager-applet.enable = true;
  services.gnome-keyring.enable = true;

  gtk.enable = true;
  gtk.iconTheme = {
    name = "Papirus";
    package = pkgs.papirus-icon-theme;
  };

  # Pre-load Ghostty terminal daemon
  systemd.user.services.ghostty = {
    Unit = {
      Description = "Ghostty Terminal Daemon";
    };
    Service = {
      ExecStart = "${pkgs.ghostty}/bin/ghostty --initial-window=false";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Config symlinks (mutable — editable without rebuilding)
  xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/niri/config.kdl";
  xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/ghostty/config";
  xdg.configFile."satty/config.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/satty/config.toml";
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/abhijay/dotfiles/configs/starship/starship.toml";

  xdg.userDirs.enable = true;
  xdg.userDirs.setSessionVariables = false;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Linux-specific aliases
  programs.zsh.shellAliases = {
    nrs = "sudo -v && nh os switch ~/dotfiles";
    fastfetch = "${config.home.homeDirectory}/dotfiles/configs/brrtfetch/brrtfetch -width 80 -height 60 -multiplier 2.5 -info 'fastfetch --logo-type none' ${config.home.homeDirectory}/dotfiles/configs/brrtfetch/gifs/random/lizard.gif";
    vpn = "nusvpn";
  };
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/linux/desktop.nix
git commit -m "feat: add modules/home/linux/desktop.nix with wayland/linux-specific hm config"
```

---

## Task 10: Create modules/home/linux/abhijay.nix (entry point)

**Files:**
- Create: `modules/home/linux/abhijay.nix`

The new entry point that home-manager will import for the `abhijay` user on Linux hosts. Sets identity fields (`home.username`, `home.homeDirectory`, `home.stateVersion`) and imports all the pieces.

- [ ] **Step 1: Create modules/home/linux/abhijay.nix**

```nix
{
  inputs,
  ...
}: {
  home.username = "abhijay";
  home.homeDirectory = "/home/abhijay";
  home.stateVersion = "25.11";

  imports = [
    inputs.noctalia.homeModules.default
    ../shared/shell.nix
    ../shared/packages.nix
    ../shared/nixvim.nix
    ./desktop.nix
    ./packages.nix
  ];

  programs.noctalia-shell.enable = true;
}
```

- [ ] **Step 2: Commit**

```bash
git add modules/home/linux/abhijay.nix
git commit -m "feat: add modules/home/linux/abhijay.nix as linux home-manager entry point"
```

---

## Task 11: Rewrite flake.nix to use flake-parts

**Files:**
- Modify: `flake.nix`

This is the main wiring step. The outputs are now wrapped in `flake-parts.lib.mkFlake`. The `nixosConfigurations.doge` is moved into the `flake = {}` block. The home-manager user now points to `modules/home/linux/abhijay.nix`. The old `modules/default.nix` import is replaced with `./hosts/doge`.

- [ ] **Step 1: Replace flake.nix with flake-parts version**

Write the following as the complete contents of `flake.nix`:

```nix
{
  description = "NixOS + nix-darwin dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Declare supported systems for future perSystem outputs (devShells etc.)
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      flake = {
        nixosConfigurations.doge = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/doge
            inputs.home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                (final: _: {
                  niri-autotile = final.callPackage ./pkgs/niri-autotile {
                    craneLib = inputs.crane.mkLib final;
                  };
                })
              ];
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.abhijay = import ./modules/home/linux/abhijay.nix;
                backupFileExtension = "backup";
              };
            }
          ];
        };
      };
    };
}
```

- [ ] **Step 2: Verify the new flake evaluates**

```bash
cd ~/dotfiles
nix flake show
```

Expected: output shows `nixosConfigurations.doge` under the flake outputs. No eval errors.

- [ ] **Step 3: Commit**

```bash
git add flake.nix
git commit -m "feat: migrate flake.nix to flake-parts with multi-host structure"
```

---

## Task 12: Dry-build to verify the full NixOS config builds

**Files:** none — verification only

- [ ] **Step 1: Run a dry-build**

```bash
cd ~/dotfiles
nixos-rebuild dry-build --flake .#doge 2>&1 | tail -30
```

Expected: no errors, ends with something like `these 0 paths will be built` or similar. A warning about `backupFileExtension` collision is acceptable.

If there are errors, they will be one of:
- **"file not found"** — a path in `hosts/doge/default.nix` or an import is wrong. Check the path.
- **"attribute missing"** — a module references something no longer in scope. Check that `inputs` is threaded through properly.
- **"infinite recursion"** — a circular import. Check `hosts/doge/default.nix` isn't importing itself.

- [ ] **Step 2: If dry-build passes, run the actual switch**

```bash
nh os switch ~/dotfiles
```

Expected: generation created and activated. Desktop and services come up normally.

---

## Task 13: Remove old files

**Files:**
- Delete: `modules/default.nix`
- Delete: `modules/users/abhijay.nix`
- Delete: empty dirs: `modules/programs/`, `modules/services/`, `modules/users/`, `modules/core/`, `modules/hardware/`, `modules/desktop/`

Only do this step after Task 12 succeeds.

- [ ] **Step 1: Remove old entry point and monolithic user config**

```bash
cd ~/dotfiles
git rm modules/default.nix
git rm modules/users/abhijay.nix
```

- [ ] **Step 2: Remove now-empty directories**

```bash
rmdir modules/programs modules/services modules/users modules/core modules/hardware modules/desktop
```

(These should be empty since all files were moved via `git mv` in earlier tasks.)

- [ ] **Step 3: Verify no orphaned files remain**

```bash
find ~/dotfiles/modules -name "*.nix" | grep -v nixos | grep -v home | sort
```

Expected: no output (all .nix files now live under `modules/nixos/` or `modules/home/`).

- [ ] **Step 4: Final dry-build to confirm nothing broke**

```bash
nixos-rebuild dry-build --flake ~/dotfiles#doge
```

Expected: clean.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: remove old modules/ structure after flake-parts migration"
```

---

## Adding a future host (reference — don't do this now)

When you get the Mac, the pattern is:

```bash
# 1. Create hosts/mac/default.nix importing modules/darwin/* modules
mkdir hosts/mac
# 2. Create modules/home/darwin/abhijay.nix importing modules/home/shared/*
# 3. Add to flake.nix inside the flake = {} block:
darwinConfigurations.mac = inputs.nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs; };
  modules = [
    ./hosts/mac
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        users.abhijay = import ./modules/home/darwin/abhijay.nix;
      };
    }
  ];
};
```

For the VPS and Pi (both NixOS), add `nixosConfigurations.vps` and `nixosConfigurations.pi` the same way as `doge` — just different `hosts/` directories and `system = "aarch64-linux"` for the Pi.
