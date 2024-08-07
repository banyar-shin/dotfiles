-- Full spec: https://www.lazyvim.org/plugins/editor#neo-treenvim

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      width = 25,
    },
    filesystem = {
      filtered_items = {
        visible = true,
      },
    },
  },
}
