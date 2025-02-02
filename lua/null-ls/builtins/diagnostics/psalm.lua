local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (diagnostics/psalm.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "psalm",
    meta = {
        url = "https://psalm.dev/",
        description = "A static analysis tool for finding errors in PHP applications.",
    },
    method = DIAGNOSTICS,
    filetypes = { "php" },
    generator_opts = {
        command = "psalm",
        args = { "--output-format=json", "--no-progress", "$FILENAME" },
        format = "json_raw",
        from_stderr = true,
        to_temp_file = true,
        check_exit_code = function(code)
            return code <= 1
        end,

        on_output = h.diagnostics.from_json({
            attributes = {
                severity = "severity",
                row = "line_from",
                end_row = "line_to",
                col = "column_from",
                end_col = "column_to",
                code = "shortcode",
            },
            severities = {
                info = h.diagnostics.severities["information"],
                error = h.diagnostics.severities["error"],
            },
        }),
    },
    factory = h.generator_factory,
})
