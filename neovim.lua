return {
  {
    "bjarneo/aether.nvim",
    name = "aether",
    priority = 1000,
    opts = {
      disable_italics = false,
      colors = {
        -- Base shades — Aurelia Dark neutral palette
        base00 = "#181B25", -- Default background      (Neutral 900)
        base01 = "#222530", -- Lighter background       (Neutral 800)
        base02 = "#F05629", -- Selection background     (Orange 500 accent)
        base03 = "#525866", -- Comments, invisibles     (Neutral 600)
        base04 = "#99A0AE", -- Dark foreground          (Neutral 400)
        base05 = "#E1E4EA", -- Default foreground       (Neutral 200)
        base06 = "#E1E4EA", -- Light foreground
        base07 = "#99A0AE", -- Light background

        -- Accent colors — orange-warm palette
        base08 = "#E8778A", -- Variables, errors        (soft rose)
        base09 = "#F05629", -- Integers, constants      (Orange 500 accent)
        base0A = "#F5936A", -- Classes, types           (warm amber)
        base0B = "#72C9A0", -- Strings                  (muted sage)
        base0C = "#5EC9D6", -- Support, regex           (glacier teal)
        base0D = "#7EB8FA", -- Functions, keywords      (periwinkle)
        base0E = "#BF90F5", -- Keywords, storage        (soft violet)
        base0F = "#FAA98A", -- Deprecated               (lighter amber)
      },
    },
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")

      local function set_selection()
        local selection_bg = "#F05629"
        local selection_fg = "#181B25"
        vim.api.nvim_set_hl(0, "Visual",    { bg = selection_bg, fg = selection_fg })
        vim.api.nvim_set_hl(0, "VisualNOS", { bg = selection_bg, fg = selection_fg })
      end
      set_selection()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "aether",
        callback = set_selection,
      })

      require("aether.hotreload").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
