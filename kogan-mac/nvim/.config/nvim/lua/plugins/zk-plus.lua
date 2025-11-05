return {
	dir = "~/repos/zk-plus.nvim",
	config = function()
		require("zk-plus").setup()

		-- Open notes.
		vim.api.nvim_set_keymap(
			"n",
			"<leader>zow",
			"<Cmd>ZkNotes { sort = { 'modified' } , excludeHrefs = { './Personal', './Organisations/Origin Energy' } }<CR>",
			{ noremap = true, silent = false, desc = "Open Work Note" }
		)
		vim.api.nvim_set_keymap(
			"n",
			"<leader>zop",
			"<Cmd>ZkNotes { sort = { 'modified' }, excludeHrefs = { './Organisations' } }<CR>",
			{ noremap = true, silent = false, desc = "Open Personal Note" }
		)
	end,
}
