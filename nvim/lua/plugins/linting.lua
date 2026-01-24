return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "golangci-lint-langserver",
        "gofumpt",
        "goimports",
        "gomodifytags",
      })
    end,
  },
}
