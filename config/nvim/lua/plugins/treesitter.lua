return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- the main branch does not support lazy-loading
    build = ':TSUpdate',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    -- NOTE: the main branch needs `tree-sitter-cli` (0.26.1+) and a C compiler to install parsers
    config = function()
        local ts = require 'nvim-treesitter'

        ts.install { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language here.
        local regex_indent = { ruby = true }

        local function start(buf, lang)
            if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
                return
            end
            if regex_indent[lang] then
                vim.bo[buf].syntax = 'on' -- keep regex highlighting alongside treesitter
            else
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end

        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if not lang then
                    return
                end
                if vim.list_contains(ts.get_installed 'parsers', lang) then
                    start(args.buf, lang)
                elseif vim.list_contains(ts.get_available(), lang) then
                    -- Autoinstall languages that are not installed
                    ts.install(lang):await(function(err)
                        if not err then
                            vim.schedule(function()
                                start(args.buf, lang)
                            end)
                        end
                    end)
                end
            end,
        })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects (use its `main` branch)
}
