" Silence message from python 3.7 about StopIteration
if has('python3')
  silent! python3 1
endif

" Set 'nocompatible' to ward off unexpected things that your distro might
"  have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" " contents. Use this to allow intelligent auto-indenting for each filetype,
" " and for plugins that are filetype specific.
filetype off

syntax on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'christoomey/vim-tmux-navigator'
Bundle 'edkolev/tmuxline.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'altercation/vim-colors-solarized'
" Make sure you have auxilary linters/fixers installed for ale
Plugin 'w0rp/ale'
Plugin 'tmhedberg/SimpylFold'
Plugin 'The-NERD-Commenter'
Plugin 'ctrlpvim/ctrlp.vim'
Bundle 'scrooloose/nerdtree'
Plugin 'jiangmiao/auto-pairs'
Plugin 'jreybert/vimagit'

Plugin 'fatih/vim-go'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'ambv/black'

call vundle#end()
filetype plugin on

" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

let g:EclimCompletionMethod = 'omnifunc'

"------------------------------------------------------------
"" Must have options {{{1
"
"" These are highly recommended options.

" 'hidden' allows you to re-use the same window and switch from an unsaved buffer
" without saving it first. Also allows you to keep an undo history for multiple
" files when re-using the same window. Note that using persistent undo also lets
" you undo in multiple files even in the same window, but is less efficient and
" is actually designed for keeping undo history after closing Vim entirely. Vim
" will complain if you try to quit without saving, and swap files will keep you
" safe if your computer crashes.
set hidden

set confirm
set autowriteall

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting;
" see the mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security
" vulnerabilities. As such, it may be a good idea to disable them and use the
" securemodelines script, <http://www.vim.org/scripts/script.php?script_id=1876>.
set nomodeline

" redraw only when needed, speeds up macros
set lazyredraw

"------------------------------------------------------------
" Usability options {{{1
"

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent
" set smartindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" Do not flash on visual bell
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" press <Enter> to continue
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>

" highlight current line
set cursorline

"search as characters are entered
set incsearch

"------------------------------------------------------------
" Indentation options {{{1
"

" Indentation settings for representing tabs as 4 spacces.
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

"------------------------------------------------------------
" Mappings {{{1
"

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Easier buffer switching
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" Teach me to use hjkl
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Enable folding with the spacebar
nnoremap <space> za
"------------------------------------------------------------

" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undodir')
    " Create dirs
    call system('mkdir ' . vimDir)
    call system('mkdir ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
endif

" I keep typing :Wq
command! Wq wq

" Save on focus lost
:au FocusLost * silent! wa

set autoread
au FocusGained,BufEnter * :checktime
set clipboard=unnamed

autocmd BufWritePre *.py execute ':Black'
let g:ale_fixers = {
\   'sh': ['shfmt'],
\   'python': ['isort'],
\}
let g:ale_fix_on_save = 1
let g:ale_python_flake8_executable = 'pipenv'
let g:ale_python_flake8_options = '--ignore=E501'
let g:ale_python_pylint_options = '--disable=C0412'
let g:ale_python_mypy_options = '--ignore-missing-imports'
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='solarized'

set foldmethod=indent
set foldlevel=99
let g:SimpylFold_docstring_preview=1

autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2

set encoding=utf-8

let python_highlight_all=1
syntax on
set background=dark
colorscheme solarized
