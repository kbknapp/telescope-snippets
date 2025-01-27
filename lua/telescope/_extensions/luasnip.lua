 --Copyright (C) Maverun 2021
local has_telescope, telescope = pcall(require, "telescope")
local has_snippet, snippet = pcall(require,"luasnip")
if not has_telescope then
    error("This plugins requires nvim-telescope/telescope.nvim")
elseif not has_snippet then
    error("This plugin requires L3MON4D3/LuaSnip")
end

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values
local types = require("luasnip.util.types")

local ls = require("luasnip")

ls.config.set_config({
	history = true,
	-- Update more often, :h events for more info.
	updateevents = "TextChanged,TextChangedI",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "choiceNode", "Comment" } },
			},
		},
	},
	-- treesitter-hl has 100, use something higher (default is 200).
	ext_base_prio = 300,
	-- minimal increase in priority.
	ext_prio_increase = 1,
	enable_autosnippets = true,
})

local function get_snippet_list()

    local snip_list = {}
    local function loopcreate(obj,ft)
        if not ft or ft == '' then return end
	local snip = ls.snippets[ft]
	if not snip or snip == '' then return end
	for k,v in pairs(ls.snippets[ft]) do
	    table.insert(obj,{
		filetype = ft:gsub('_',''),
		name = k,
	    })
	end
    end
    --making sure filetype is there or else error
    if vim.bo.filetype ~= '' and ls.snippets[vim.bo.filetype] ~= nil then
        loopcreate(snip_list,vim.bo.filetype)
    end
    loopcreate(snip_list,'_global')
    return snip_list
end

local function preview_advance(entry)
    --getting current snippets template
    local snip = ls.lookup_snippet(entry.value.filetype,entry.value.name)
    --we will evaulate them and get how many inputs are they need to fill
    local evaluator = ls.parser.parse_snippet(snip.name, snip.value)
    local resolved_inputs = {}
    for i = 0,#evaluator.inputs + 1 do
        local ph  = "Placeholders"
        if i > 1 then
            ph = ph..'_'..i-1
        end
        resolved_inputs[i] = ph
    end
    local text = evaluator.evaluate_structure(resolved_inputs)
    local lines = vim.split(table.concat(text), "\n", true)
    return lines
end

local function show_preview(entry,buf)
    vim.api.nvim_buf_set_option(buf, "filetype", entry.value.filetype)
    local line = preview_advance(entry)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, line)
end

local function make_entry(entry)
    --Create Display Area of telescope
    local displayer = entry_display.create({
        separator = "▏",
        items = { { width = 20 }, { width = 20 }, { remaining = true } },
    })

    local make_display = function(entry_)
        return displayer({ entry_.value.filetype, entry_.value.name})
    end
    return {
        value = entry,
        display = make_display,
        ordinal = entry.filetype .. ' ' .. entry.name .. ' ',
        preview_command = show_preview
    }
end

local snippets = function(opts)
    opts = opts or {}
    local snip_list = get_snippet_list()

    pickers.new(opts, {
        prompt_title = "Snippets",
        finder = finders.new_table({
            results = snip_list,
            entry_maker = make_entry
        }),

        previewer = previewers.display_content.new(opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function()
            actions.select_default:replace(function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.api.nvim_put({selection.value.name }, "", true, true)
                vim.cmd([[lua require('snippets').expand_at_cursor()]])
                vim.fn.feedkeys("i")
            end)
            return true
        end,
    }):find()
end -- end custom function


return telescope.register_extension({ exports = { luasnip = snippets } })
