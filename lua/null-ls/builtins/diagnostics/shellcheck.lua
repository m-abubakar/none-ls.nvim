local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

if not (vim.g.nonels_suppress_issue58 or vim.g.nonels_supress_issue58) then
    vim.notify_once(
        [[[null-ls] You required a deprecated builtin (diagnostics/shellcheck.lua), which will be removed in March.
Please migrate to alternatives: https://github.com/nvimtools/none-ls.nvim/issues/58]],
        vim.log.levels.WARN
    )
end

return h.make_builtin({
    name = "shellcheck",
    meta = {
        url = "https://www.shellcheck.net/",
        description = "A shell script static analysis tool.",
    },
    method = DIAGNOSTICS,
    filetypes = { "sh" },
    generator_opts = {
        command = "shellcheck",
        args = { "--format", "json1", "--source-path=$DIRNAME", "--external-sources", "-" },
        to_stdin = true,
        format = "json",
        check_exit_code = function(code)
            return code <= 1
        end,
        on_output = function(params)
            local parser = h.diagnostics.from_json({
                attributes = { code = "code" },
                severities = {
                    info = h.diagnostics.severities["information"],
                    style = h.diagnostics.severities["hint"],
                },
            })

            return parser({ output = params.output.comments })
        end,
    },
    factory = h.generator_factory,
})
