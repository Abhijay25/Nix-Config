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

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        export ZSH_DISABLE_COMPFIX="true"
        setopt AUTO_MENU
        zstyle ':completion:*' menu select=2
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
        # Must be set before zsh-autosuggestions is sourced (it reads this at source time).
        ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-add-eol)
      '')
      ''
        # Move fzf file-search from Ctrl+T (taken by ghostty new-tab) to Ctrl+F
        bindkey -r '^T'
        bindkey '^F' fzf-file-widget
      ''
      (lib.mkAfter ''
        # Rebind Tab after fzf's zsh integration, which sources last and would
        # otherwise leave '^I' bound to fzf-completion instead of our widget.
        # zsh-autosuggestions rewraps whatever is bound to a key on the next
        # precmd, so binding last here also makes it the widget autosuggestions wraps.
        autosuggest-accept-or-complete() {
          if [[ -n "$POSTDISPLAY" ]]; then
            zle autosuggest-accept
          else
            zle expand-or-complete
          fi
        }
        zle -N autosuggest-accept-or-complete
        bindkey '^I' autosuggest-accept-or-complete
      '')
    ];
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
