-- Full spec: https://www.lazyvim.org/plugins/editor#neo-treenvim

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      width = 28,
    },
    filesystem = {
      filtered_items = {
        visible = true,
      },
    },
  },
}
