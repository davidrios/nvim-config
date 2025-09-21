local mu = require("myutils")

vim.keymap.set("n", "<leader>pv", "<cmd>tabnew<cr><cmd>NvimTreeOpen<cr><c-w>l<cmd>bd<cr>", { desc = "Explorer" })
vim.keymap.set("n", "<leader>bd", vim.cmd.bd, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bw", vim.cmd.w, { desc = "Write buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>bd!<cr>", { desc = "Delete buffer without saving" })
vim.keymap.set("n", "<leader>bt", ":tabnew %<cr><c-tab><c-o><c-tab>", { desc = "Move buffer to separate tab" })
vim.keymap.set("n", "<leader>br",
  function()
    local currf = vim.fn.expand('%')
    local escaped = vim.fn.fnameescape(currf)
    mu.feedkeys("mZ:ed ___<cr>:bd " .. escaped .. "<cr>:ed " .. escaped .. "<cr>'Z:bd ___<cr>")
    vim.schedule(function()
      vim.cmd("echom ''")
    end)
  end,
  { desc = "Reload buffer (to activate LSP)" })
vim.keymap.set("n", "<leader>bR", "mZ:w<cr>:bd<cr>`Z", { desc = "Write and reload buffer (to activate LSP)" })
vim.keymap.set("n", "<leader>bA", ":%bd|e#<cr>", { desc = "Close all other buffers" })
vim.keymap.set("n", "<leader>qf", function() vim.cmd("qa!") end, { desc = "Force quit" })
vim.keymap.set("n", "<leader>qa", "<cmd>qa<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>qw", vim.cmd.xa, { desc = "Quit writing all" })
vim.keymap.set("n", "<leader>qq", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>uc", "<cmd>Centerpad 53<cr>", { desc = "Activate Centerpad" })
vim.keymap.set("n", "<leader>ucc", "<cmd>Centerpad 53<cr><cmd>Centerpad 53<cr>", { desc = "Activate Centerpad" })
vim.keymap.set("n", "<leader>uh", vim.cmd.noh, { desc = "Clear highlight" })
vim.keymap.set("n", "<leader>uz", "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>",
  { desc = "Toggle and focus undo tree" })
-- vim.keymap.set("n", "<leader>uus", "<cmd>mksession! " .. mu.SESSION_FILE .. "<cr>", { desc = "Save session to default file" })
vim.keymap.set("n", "<c-s>", function()
  vim.lsp.buf.format(); vim.cmd.w()
end, { desc = "Reformat and write buffer" })
local function on_list_goto_first(options)
  -- the contents of this function were copied from the neovim source code
  local api = vim.api
  vim.fn.setqflist({}, ' ', options)
  local from = vim.fn.getpos('.')
  local bufnr = api.nvim_get_current_buf()
  from[1] = bufnr
  local tagname = vim.fn.expand('<cword>')
  local win = api.nvim_get_current_win()
  local item = vim.fn.getqflist()[1]
  local b = item.bufnr or vim.fn.bufadd(item.filename)
  -- Push a new item into tagstack
  local tagstack = { { tagname = tagname, from = from } }
  vim.fn.settagstack(vim.fn.win_getid(win), { items = tagstack }, 't')
  vim.bo[b].buflisted = true
  local w = win
  w = vim.fn.win_findbuf(b)[1] or w
  if w ~= win then
    api.nvim_set_current_win(w)
  else
    -- Save position in jumplist
    vim.cmd("normal! m'")
  end
  api.nvim_win_set_buf(w, b)
  api.nvim_win_set_cursor(w, { item.lnum, item.col - 1 })
  vim._with({ win = w }, function()
    -- Open folds under the cursor
    vim.cmd('normal! zv')
  end)
end
vim.keymap.set("n", "<C-]>", function()
  vim.lsp.buf.definition({ reuse_win = true, on_list = on_list_goto_first })
end, { desc = "Go to implementation" })
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
vim.keymap.set("x", "<leader>p", "\"_dP", { desc = "Paste without saving" })
vim.keymap.set({ "n", "v" }, "<leader>y", "\"+y", { desc = "Yank to system clipboard" })
-- vim.keymap.set("n", "<leader>Y", "\"+Y")
vim.keymap.set({ "n", "v" }, "<leader>ud", "\"_d", { desc = "Delete to void" })
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "q", "<nop>")
vim.keymap.set("i", "<c-c>", "<esc>")
vim.keymap.set("n", "<leader>sr", ":%s/", { desc = "Search and replace" })
vim.keymap.set("v", "<leader>sr", "y:%s/<c-r>\"/", { desc = "Search and replace" })
vim.keymap.set("v", "<leader>sR", "y:%s/\\<<c-r>\"\\>/", { desc = "Search and replace exact" })
vim.keymap.set("v", "O", "$og0")
vim.keymap.set("n", "<leader>ft", vim.cmd.NvimTreeFindFile, { desc = "Find file in tree" })
vim.keymap.set("n", "<leader>w", "<c-w>w", { desc = "Switch windows" })
vim.keymap.set("n", "]w", "<c-w>l", { desc = "Go to right window" })
vim.keymap.set("n", "[w", "<c-w>h", { desc = "Go to left window" })
vim.keymap.set("i", "<s-bs>", "<c-o>db", { desc = "Delete previous word" })
vim.keymap.set("i", "<s-del>", "<c-o>dw", { desc = "Delete next word" })
vim.keymap.set("i", "<s-cr>", "<c-o>o", { desc = "Add empty line and go to it" })

vim.keymap.set("n", "<leader>1", "1gt", { desc = "Go to tab 1" })
vim.keymap.set("n", "<leader>2", "2gt", { desc = "Go to tab 2" })
vim.keymap.set("n", "<leader>3", "3gt", { desc = "Go to tab 3" })
vim.keymap.set("n", "<leader>4", "4gt", { desc = "Go to tab 4" })
vim.keymap.set("n", "<leader>5", "5gt", { desc = "Go to tab 5" })
vim.keymap.set("n", "<leader>6", "6gt", { desc = "Go to tab 6" })
vim.keymap.set("n", "<leader>7", "7gt", { desc = "Go to tab 7" })
vim.keymap.set("n", "<leader>8", "8gt", { desc = "Go to tab 8" })
vim.keymap.set("n", "<leader>9", "9gt", { desc = "Go to tab 9" })

local dap = mu.prequire("dap")
if dap then
  local dapw = require('dap.ui.widgets')
  vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle breakpoint" })
  vim.keymap.set("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "DAP: REPL" })
  vim.keymap.set({ "n", "i" }, "<F12>", function()
    dap.repl.toggle(); return vim.cmd("wincmd w")
  end, { desc = "DAP: REPL" })
  vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "DAP: Continue" })
  vim.keymap.set({ "n", "i" }, "<F5>", function() dap.continue() end, { desc = "DAP: Continue" })
  vim.keymap.set("n", "<leader>do", function() dap.step_over() end, { desc = "DAP: Step over" })
  vim.keymap.set({ "n", "i" }, "<F10>", function() dap.step_over() end, { desc = "DAP: Step over" })
  vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "DAP: Step into" })
  vim.keymap.set({ "n", "i" }, "<F11>", function() dap.step_into() end, { desc = "DAP: Step into" })
  vim.keymap.set("n", "<leader>du", function() dap.step_out() end, { desc = "DAP: Step out" })
  vim.keymap.set({ "n", "i" }, "<F23>", function() dap.step_out() end, { desc = "DAP: Step out" })
  vim.keymap.set({ "n", "i" }, "<F9>", function() dap.up() end, { desc = "DAP: Frame up" })
  vim.keymap.set({ "n", "i" }, "<F21>", function() dap.down() end, { desc = "DAP: Frame down" })
  vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function() dapw.hover() end, { desc = "DAP: Hover" })
  vim.keymap.set({ 'n', 'v' }, '<Leader>dv', function() dapw.preview() end, { desc = "DAP: Preview" })
  vim.keymap.set('n', '<Leader>df', function() dapw.centered_float(dapw.frames) end, { desc = "DAP: Frames" })
  vim.keymap.set('n', '<Leader>ds', function() dapw.centered_float(dapw.scopes) end, { desc = "DAP: Scopes" })
end

local ls = mu.prequire("luasnip")
if ls then
  -- vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(-1) end, { silent = true })
  vim.keymap.set({ "i", "s" }, "<C-K>", function()
    if ls.choice_active() then
      ls.change_choice(1)
    end
  end, { silent = true })
end

local telescope = mu.prequire("telescope.builtin")

local function yank_call_paste(fn, register)
  local function f()
    if register == nil then
      register = 9
    end
    mu.feedkeys('"' .. register .. 'y')
    vim.schedule(function()
      fn()
      mu.feedkeys('<c-r>' .. register)
    end)
  end
  return f
end

if telescope then
  local live_grep_uu = function()
    return mu.live_grep(2)
  end

  local live_grep_uu_ex = function()
    return mu.live_grep_global_g_args(2)
  end

  vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Telescope find files" })
  vim.keymap.set("v", "<leader>ff", yank_call_paste(telescope.find_files),
    { desc = "Telescope file files with selection in name" })
  vim.keymap.set("n", "<leader>fj", telescope.jumplist, { desc = "Telescope find jumplist" })
  vim.keymap.set("n", "<C-p>", telescope.git_files, { desc = "Telescope find files in git" })
  vim.keymap.set("n", "<leader>fg", mu.live_grep, { desc = "Telescope live grep" })
  vim.keymap.set("v", "<leader>fg", yank_call_paste(mu.live_grep), { desc = "Telescope live grep selection" })
  vim.keymap.set("n", "<leader>fG", live_grep_uu_ex, { desc = "Telescope live grep -uu with excludes" })
  vim.keymap.set("v", "<leader>fG", yank_call_paste(live_grep_uu_ex),
    { desc = "Telescope live grep -uu selection with excludes" })
  vim.keymap.set("n", "<leader>fA", live_grep_uu, { desc = "Telescope live grep -uu" })
  vim.keymap.set("v", "<leader>fA", yank_call_paste(live_grep_uu), { desc = "Telescope live grep -uu selection" })
  vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Telescope buffers" })
  vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Telescope help tags" })
  vim.keymap.set("n", "<leader>fk", telescope.keymaps, { desc = "Telescope keymaps" })
  vim.keymap.set("n", "<leader>fm", telescope.marks, { desc = "Telescope marks" })
  vim.keymap.set("n", "<leader>fr", telescope.resume, { desc = "Telescope resume search" })
  vim.keymap.set("n", "<leader>fi", telescope.builtin, { desc = "Telescope builtins" })
  vim.keymap.set("n", "<leader>cx", telescope.diagnostics, { desc = "Telescope code diagnostics" })
  vim.keymap.set("n", "<leader>cs", telescope.lsp_document_symbols, { desc = "Telescope LSP document symbols" })
  vim.keymap.set("n", "<leader>cr", telescope.lsp_references, { desc = "Telescope LSP references" })
  vim.keymap.set("n", "<leader>ct", telescope.lsp_type_definitions, { desc = "Telescope LSP type definitions" })
  vim.keymap.set("n", "<C-/>", telescope.current_buffer_fuzzy_find, { desc = "Telescope find fuzzy in current buffer" })
end

local otter = mu.prequire("otter")
if otter then
  vim.keymap.set("n", "<leader>uo", function() otter.activate() end, { desc = "Activate Otter" })
end
