local h = require("null-ls.helpers")
local cmd_resolver = require("null-ls.helpers.command_resolver")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (diagnostics/puglint.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "puglint",
    meta = {
        url = "https://github.com/pugjs/pug-lint",
        description = [[An unopinionated and configurable linter and style checker for Pug.]],
    },
    method = DIAGNOSTICS,
    filetypes = { "pug" },
    generator_opts = {
        command = "pug-lint",
        args = {
            "--reporter=inline",
            "$FILENAME",
        },
        to_stdin = true,
        from_stderr = true,
        format = "line",
        check_exit_code = function(code)
            return code <= 2
        end,
        on_output = h.diagnostics.from_patterns({
            {
                pattern = [[([^:]+):(%d+) (.+)]],
                groups = { "filename", "row", "message" },
            },
            {
                pattern = [[([^:]+):(%d+):(%d+) (.+)]],
                groups = { "filename", "row", "col", "message" },
            },
        }),
        dynamic_command = cmd_resolver.from_node_modules(),
    },
    factory = h.generator_factory,
})
