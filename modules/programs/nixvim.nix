{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Colorscheme
    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "night";
        transparent = true;
        terminal_colors = true;
        styles = {
          comments = { italic = true; };
          keywords = { italic = true; };
          sidebars = "transparent";
          floats = "transparent";
        };
      };
    };

    # Options
    opts = {
      # Visuals
      number = true;
      relativenumber = true;
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;

      # Indentation
      autoindent = true;
      smartindent = true;

      # Tabs & Spaces
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;

      # Searching
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

      # Better experience
      mouse = "a";
      clipboard = "unnamedplus";
      undofile = true;
      swapfile = false;
      backup = false;
      writebackup = false;
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      scrolloff = 8;
      sidescrolloff = 8;
      wrap = false;
      showmode = false;
      completeopt = "menuone,noselect";

      # Code folding (for nvim-ufo)
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };

    # Leader key
    globals.mapleader = " ";
    globals.maplocalleader = " ";

    # Keymaps
    keymaps = [
      # Better window navigation
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left window"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to lower window"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to upper window"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right window"; }

      # Resize windows
      { mode = "n"; key = "<C-Up>"; action = ":resize -2<CR>"; options.silent = true; }
      { mode = "n"; key = "<C-Down>"; action = ":resize +2<CR>"; options.silent = true; }
      { mode = "n"; key = "<C-Left>"; action = ":vertical resize -2<CR>"; options.silent = true; }
      { mode = "n"; key = "<C-Right>"; action = ":vertical resize +2<CR>"; options.silent = true; }

      # Buffer navigation
      { mode = "n"; key = "<S-l>"; action = ":bnext<CR>"; options.silent = true; options.desc = "Next buffer"; }
      { mode = "n"; key = "<S-h>"; action = ":bprevious<CR>"; options.silent = true; options.desc = "Previous buffer"; }

      # Buffer management
      { mode = "n"; key = "<leader>bd"; action = ":bdelete<CR>"; options.silent = true; options.desc = "Delete buffer"; }
      { mode = "n"; key = "<leader>bn"; action = ":bnext<CR>"; options.silent = true; options.desc = "Next buffer"; }
      { mode = "n"; key = "<leader>bp"; action = ":bprevious<CR>"; options.silent = true; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<leader>bb"; action = "<cmd>Telescope buffers<CR>"; options.desc = "List buffers"; }
      { mode = "n"; key = "<leader>bo"; action = ":%bdelete|edit#|bdelete#<CR>"; options.silent = true; options.desc = "Close other buffers"; }

      # Better indenting
      { mode = "v"; key = "<"; action = "<gv"; }
      { mode = "v"; key = ">"; action = ">gv"; }

      # Move lines up/down
      { mode = "n"; key = "<A-j>"; action = ":m .+1<CR>=="; options.silent = true; }
      { mode = "n"; key = "<A-k>"; action = ":m .-2<CR>=="; options.silent = true; }
      { mode = "v"; key = "<A-j>"; action = ":m '>+1<CR>gv=gv"; options.silent = true; }
      { mode = "v"; key = "<A-k>"; action = ":m '<-2<CR>gv=gv"; options.silent = true; }

      # Clear search highlight
      { mode = "n"; key = "<Esc>"; action = ":nohlsearch<CR>"; options.silent = true; }

      # File explorer
      { mode = "n"; key = "<leader>e"; action = ":NvimTreeToggle<CR>"; options.silent = true; options.desc = "Toggle file explorer"; }
      { mode = "n"; key = "<C-n>"; action = ":NvimTreeToggle<CR>"; options.silent = true; options.desc = "Toggle file explorer"; }

      # Telescope
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>"; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>"; options.desc = "Find buffers"; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>"; options.desc = "Help tags"; }
      { mode = "n"; key = "<leader>fo"; action = "<cmd>Telescope oldfiles<CR>"; options.desc = "Recent files"; }
      { mode = "n"; key = "<leader>fw"; action = "<cmd>Telescope grep_string<CR>"; options.desc = "Find word under cursor"; }
      { mode = "n"; key = "<leader>gc"; action = "<cmd>Telescope git_commits<CR>"; options.desc = "Git commits"; }
      { mode = "n"; key = "<leader>gs"; action = "<cmd>Telescope git_status<CR>"; options.desc = "Git status"; }

      # LSP
      { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<CR>"; options.desc = "Go to definition"; }
      { mode = "n"; key = "gD"; action = "<cmd>lua vim.lsp.buf.declaration()<CR>"; options.desc = "Go to declaration"; }
      { mode = "n"; key = "gi"; action = "<cmd>lua vim.lsp.buf.implementation()<CR>"; options.desc = "Go to implementation"; }
      { mode = "n"; key = "gr"; action = "<cmd>Telescope lsp_references<CR>"; options.desc = "Find references"; }
      { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<CR>"; options.desc = "Hover documentation"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; options.desc = "Code action"; }
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; options.desc = "Rename symbol"; }
      { mode = "n"; key = "<leader>lf"; action = "<cmd>lua vim.lsp.buf.format()<CR>"; options.desc = "Format buffer"; }
      { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<CR>"; options.desc = "Previous diagnostic"; }
      { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<CR>"; options.desc = "Next diagnostic"; }
      { mode = "n"; key = "<leader>ld"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; options.desc = "Line diagnostics"; }

      # Terminal
      { mode = "n"; key = "<leader>th"; action = ":ToggleTerm direction=horizontal<CR>"; options.desc = "Horizontal terminal"; }
      { mode = "n"; key = "<leader>tv"; action = ":ToggleTerm direction=vertical size=80<CR>"; options.desc = "Vertical terminal"; }
      { mode = "n"; key = "<leader>tf"; action = ":ToggleTerm direction=float<CR>"; options.desc = "Floating terminal"; }
      { mode = "t"; key = "<Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }

      # Git (lazygit integration)
      { mode = "n"; key = "<leader>gg"; action = "<cmd>lua require('toggleterm.terminal').Terminal:new({cmd='lazygit', direction='float'}):toggle()<CR>"; options.desc = "Lazygit"; }

      # Code folding (UFO)
      { mode = "n"; key = "zR"; action = "<cmd>lua require('ufo').openAllFolds()<CR>"; options.desc = "Open all folds"; }
      { mode = "n"; key = "zM"; action = "<cmd>lua require('ufo').closeAllFolds()<CR>"; options.desc = "Close all folds"; }
    ];

    # Plugins
    plugins = {
      # File explorer
      nvim-tree = {
        enable = true;
        settings = {
          git.enable = true;
          view.width = 30;
          renderer = {
            highlight_git = true;
            icons.show = {
              git = true;
              folder = true;
              file = true;
            };
          };
          filters.dotfiles = false;
          # Auto-reload on external changes (like VSCode)
          reload_on_bufenter = true;
          filesystem_watchers = {
            enable = true;
            debounce_delay = 50;
            ignore_dirs = [ ".git" "node_modules" ];
          };
          sync_root_with_cwd = true;
          respect_buf_cwd = true;
          update_focused_file = {
            enable = true;
            update_root = true;
          };
          actions = {
            open_file = {
              quit_on_open = false;
              window_picker.enable = true;
            };
          };
        };
      };

      # Fuzzy finder
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
        settings = {
          defaults = {
            file_ignore_patterns = [ "node_modules" ".git/" ];
            preview = {
              filesize_limit = 1;
              timeout = 250;
              hide_on_startup = false;
              treesitter = false;
            };
            layout_config = {
              preview_cutoff = 120;
            };
            mappings.i = {
              "<C-j>" = {
                __raw = "require('telescope.actions').move_selection_next";
              };
              "<C-k>" = {
                __raw = "require('telescope.actions').move_selection_previous";
              };
            };
          };
          pickers = {
            find_files = {
              hidden = true;
            };
          };
        };
      };

      # Syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          auto_install = false;
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          c
          cpp
          css
          go
          html
          java
          javascript
          json
          lua
          markdown
          nix
          python
          rust
          toml
          typescript
          yaml
        ];
      };

      # LSP
      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          # Nix
          nil_ls = {
            enable = true;
            settings.formatting.command = [ "nixpkgs-fmt" ];
          };

          # Python
          pyright.enable = true;

          # JavaScript/TypeScript
          ts_ls.enable = true;

          # C/C++
          clangd.enable = true;

          # Go
          gopls.enable = true;

          # Rust
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };

          # Java
          jdtls.enable = true;

          # Lua
          lua_ls = {
            enable = true;
            settings.Lua = {
              diagnostics.globals = [ "vim" ];
              workspace.checkThirdParty = false;
            };
          };

          # HTML/CSS
          html.enable = true;
          cssls.enable = true;

          # JSON
          jsonls.enable = true;

          # YAML
          yamlls.enable = true;

          # Bash
          bashls.enable = true;

          # Typst
          tinymist.enable = true;
        };
      };

      # Autocompletion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; priority = 1000; }
            { name = "luasnip"; priority = 750; }
            { name = "buffer"; priority = 500; }
            { name = "path"; priority = 250; }
          ];
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
          };
          window = {
            completion.border = "rounded";
            documentation.border = "rounded";
          };
        };
      };

      # Snippets
      luasnip = {
        enable = true;
        settings = {
          enable_autosnippets = true;
        };
      };
      friendly-snippets.enable = true;

      # Autopairs
      nvim-autopairs = {
        enable = true;
        settings = {
          check_ts = true;
        };
      };

      # Comments
      comment.enable = true;

      # Surround
      nvim-surround.enable = true;

      # Git signs
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "_";
            topdelete.text = "‾";
            changedelete.text = "~";
          };
          current_line_blame = true;
        };
      };

      # Status line
      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "tokyonight";
            component_separators = { left = "|"; right = "|"; };
            section_separators = { left = ""; right = ""; };
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" "diff" "diagnostics" ];
            lualine_c = [ "filename" ];
            lualine_x = [ "encoding" "fileformat" "filetype" ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
        };
      };

      # Buffer line (tabs)
      bufferline = {
        enable = true;
        settings.options = {
          mode = "buffers";
          diagnostics = "nvim_lsp";
          offsets = [
            {
              filetype = "NvimTree";
              text = "File Explorer";
              highlight = "Directory";
              separator = true;
            }
          ];
        };
      };

      # Which-key (keybinding hints)
      which-key = {
        enable = true;
        settings = {
          spec = [
            { __unkeyed-1 = "<leader>f"; group = "Find"; }
            { __unkeyed-1 = "<leader>g"; group = "Git"; }
            { __unkeyed-1 = "<leader>l"; group = "LSP"; }
            { __unkeyed-1 = "<leader>t"; group = "Terminal"; }
            { __unkeyed-1 = "<leader>c"; group = "Code"; }
            { __unkeyed-1 = "<leader>r"; group = "Rename"; }
            { __unkeyed-1 = "<leader>b"; group = "Buffers"; }
          ];
        };
      };

      # Indent guides
      indent-blankline = {
        enable = true;
        settings = {
          scope.enabled = true;
        };
      };

      # Terminal
      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<C-\\>]]";
          direction = "float";
          float_opts.border = "curved";
        };
      };

      # Better UI
      noice = {
        enable = true;
        settings = {
          lsp.override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
          presets = {
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
            inc_rename = false;
            lsp_doc_border = true;
          };
        };
      };

      # Web devicons
      web-devicons.enable = true;

      # Lastplace (restore cursor position)
      lastplace.enable = true;

      # Todo comments
      todo-comments.enable = true;

      # Illuminate (highlight word under cursor)
      illuminate.enable = true;

      # Colorizer (show colors inline for hex/rgb codes)
      nvim-colorizer = {
        enable = true;
        userDefaultOptions = {
          RGB = true;
          RRGGBB = true;
          names = false;
          RRGGBBAA = true;
          rgb_fn = true;
          hsl_fn = true;
          css = true;
          css_fn = true;
          mode = "background";
        };
      };

      # Auto-session (automatic session management)
      auto-session = {
        enable = true;
        settings = {
          auto_restore_enabled = true;
          auto_save_enabled = true;
          auto_session_suppress_dirs = [ "~/" "/tmp" ];
        };
      };

      # UFO (better code folding)
      nvim-ufo = {
        enable = true;
        settings = {
          provider_selector = ''
            function(bufnr, filetype, buftype)
              return {'treesitter', 'indent'}
            end
          '';
        };
      };

      # Auto-detect indentation
      guess-indent = {
        enable = true;
        settings = {
          auto_cmd = true;
        };
      };

      # Dashboard
      alpha = {
        enable = true;
        settings.layout = [
          {
            type = "padding";
            val = 4;
          }
          {
            type = "text";
            opts = {
              hl = "AlphaHeader";
              position = "center";
            };
            val = [
              "███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗"
              "████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║"
              "██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║"
              "██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║"
              "██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║"
              "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
            ];
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "group";
            val = [
              {
                type = "button";
                val = "  Find File";
                on_press.__raw = "function() require('telescope.builtin').find_files() end";
                opts = {
                  shortcut = "f";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                  hl_shortcut = "AlphaShortcut";
                  keymap = [ "n" "f" ":Telescope find_files<CR>" { silent = true; } ];
                };
              }
              {
                type = "button";
                val = "  Recent Files";
                on_press.__raw = "function() require('telescope.builtin').oldfiles() end";
                opts = {
                  shortcut = "r";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                  hl_shortcut = "AlphaShortcut";
                  keymap = [ "n" "r" ":Telescope oldfiles<CR>" { silent = true; } ];
                };
              }
              {
                type = "button";
                val = "  Find Word";
                on_press.__raw = "function() require('telescope.builtin').live_grep() end";
                opts = {
                  shortcut = "w";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                  hl_shortcut = "AlphaShortcut";
                  keymap = [ "n" "w" ":Telescope live_grep<CR>" { silent = true; } ];
                };
              }
              {
                type = "button";
                val = "  New File";
                on_press.__raw = "function() vim.cmd('ene') end";
                opts = {
                  shortcut = "n";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                  hl_shortcut = "AlphaShortcut";
                  keymap = [ "n" "n" ":ene<CR>" { silent = true; } ];
                };
              }
              {
                type = "button";
                val = "  Quit";
                on_press.__raw = "function() vim.cmd('qa') end";
                opts = {
                  shortcut = "q";
                  position = "center";
                  cursor = 3;
                  width = 50;
                  align_shortcut = "right";
                  hl_shortcut = "AlphaShortcut";
                  keymap = [ "n" "q" ":qa<CR>" { silent = true; } ];
                };
              }
            ];
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "text";
            opts = {
              hl = "AlphaFooter";
              position = "center";
            };
            val = "NixVim - Configured with Nix";
          }
        ];
      };
    };

    # Extra packages
    extraPackages = with pkgs; [
      imagemagick
      curl
      file
    ];

    extraLuaPackages = ps: [ ps.magick ];

    # Extra plugins
    extraPlugins = with pkgs.vimPlugins; [
      image-nvim
    ];

    # Extra config
    extraConfigLua = ''
      -- Ensure transparent background (works with terminal blur)
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

      -- Brighter line numbers
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#737aa2", bg = "none" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#a9b1d6", bg = "none", bold = true })

      -- Telescope: Custom previewer for binary files
      local previewers = require("telescope.previewers")
      local putils = require("telescope.previewers.utils")

      -- Image extensions
      local image_extensions = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "ico", "svg" }

      -- Binary extensions to skip
      local binary_extensions = {
        "pdf", "zip", "tar", "gz", "bz2", "xz", "7z", "rar",
        "mp4", "avi", "mkv", "mov", "mp3", "wav", "flac",
        "exe", "dll", "so", "dylib", "bin", "o", "a"
      }

      local function get_extension(filepath)
        return filepath:match("^.+%.(.+)$")
      end

      local function is_image(filepath)
        local ext = get_extension(filepath)
        if not ext then return false end
        ext = ext:lower()
        for _, img_ext in ipairs(image_extensions) do
          if ext == img_ext then return true end
        end
        return false
      end

      local function is_binary(filepath)
        local ext = get_extension(filepath)
        if not ext then return false end
        ext = ext:lower()
        for _, bin_ext in ipairs(binary_extensions) do
          if ext == bin_ext then return true end
        end
        return false
      end

      local function get_file_info(filepath)
        local stat = vim.loop.fs_stat(filepath)
        if not stat then return nil end

        local size = stat.size
        local size_str
        if size < 1024 then
          size_str = size .. " B"
        elseif size < 1024 * 1024 then
          size_str = string.format("%.1f KB", size / 1024)
        else
          size_str = string.format("%.1f MB", size / (1024 * 1024))
        end

        return size_str
      end

      local new_maker = function(filepath, bufnr, opts)
        opts = opts or {}

        -- Check if it's an image file
        if is_image(filepath) then
          local size = get_file_info(filepath)
          local ext = get_extension(filepath) or "unknown"
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "                           🖼️  Image File",
              "",
              "                           Type: " .. ext:upper(),
              "                           Size: " .. (size or "Unknown"),
              "",
              "",
              "                         Preview not available",
            })
            vim.api.nvim_buf_set_option(bufnr, 'filetype', 'text')
          end)
        -- Check if it's a known binary file
        elseif is_binary(filepath) then
          local size = get_file_info(filepath)
          local ext = get_extension(filepath) or "unknown"
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "                    📦 Binary File",
              "",
              "                    Type: " .. ext:upper(),
              "                    Size: " .. (size or "Unknown"),
              "",
              "",
              "                    Preview not available",
            })
            vim.api.nvim_buf_set_option(bufnr, 'filetype', 'text')
          end)
        else
          -- Use default previewer for text files
          previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end
      end

      require("telescope").setup({
        defaults = {
          buffer_previewer_maker = new_maker,
        },
      })

      require("image").setup({
        backend = "kitty",
        integrations = {
          markdown = { enabled = true, clear_in_insert_mode = true },
        },
        max_width = 100,
        max_height = 12,
        max_height_window_percentage = 40,
        max_width_window_percentage = nil,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      })

      -- Highlight on yank
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
        end,
      })

      -- Remove trailing whitespace on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
          local save_cursor = vim.fn.getpos(".")
          vim.cmd([[%s/\s\+$//e]])
          vim.fn.setpos(".", save_cursor)
        end,
      })

      vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
          vim.cmd("tabdo wincmd =")
        end,
      })

      -- Close some filetypes with q
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "qf", "lspinfo", "man", "checkhealth" },
        callback = function(event)
          vim.bo[event.buf].buflisted = false
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
        end,
      })
    '';
  };
}
