-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- quit fast files
keymap.set({ "n", "v" }, "<leader>q", ":q<CR>", { desc = "Exit file" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- move selected text around
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- append above line to current line and maintain cursor where it is
keymap.set("n", "J", "mzJ`z")

-- half page jumping remaining cursor in the middle (u -> up ; d -> down)
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- remain cursor in the middle during keyword search
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- substitute seleted range with copy
keymap.set("x", "<leader>p", '"_dp')

--
keymap.set({ "n", "v" }, "<leader>y", '"+y')
keymap.set({ "n", "v" }, "<leader>Y", '"+Y')

-- deleting without copying
keymap.set({ "n", "v" }, "d", '"_d')
