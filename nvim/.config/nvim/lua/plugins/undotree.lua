return {
  "mbbill/undotree",
  config = function()
    vim.g.undotree_SetFocusWhenToggle = true
    vim.keymap.set("n", "<leader>U", vim.cmd.UndotreeToggle, { desc = "Undotree" })
  end,
}
