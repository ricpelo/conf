-- ~/.config/nvim/lua/plugins/snacks.lua
return {
  "folke/snacks.nvim",
  opts = {
    scroll = {
      filter = function(_)
        return false
      end,
    },
  },
}
