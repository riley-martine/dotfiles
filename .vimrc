let g:black_virtualenv = '/home/riley/.pyenv/versions/3.7.3/envs/black'
let g:python3_host_prog = '/home/riley/.pyenv/versions/3.7.3/bin/python'
" Silence message from python 3.7 about StopIteration
if has('python3')
  silent! python3 1
endif

" Set 'nocompatible' to ward off unexpected things that your distro might
"  have made, as well as sanely reset options when re-sourcing .vimrc
"set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" " contents. Use this to allow intelligent auto-indenting for each filetype,
" " and for plugins that are filetype specific.
filetype off

syntax on
syntax enable

set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Tmux integration
Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'christoomey/vim-tmux-navigator'
Bundle 'edkolev/tmuxline.vim'

" Theming
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'airblade/vim-gitgutter'
Plugin 'dylanaraps/wal.vim'

" Behavior 
Plugin 'tmhedberg/SimpylFold'
Plugin 'ciaranm/securemodelines'
Plugin 'SirVer/ultisnips'
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'skywind3000/gutentags_plus'
Plugin 'majutsushi/tagbar'

" Make sure you have auxilary linters/fixers installed for ale
Plugin 'w0rp/ale'
Plugin 'ctrlpvim/ctrlp.vim'
Bundle 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
"Plugin 'jiangmiao/auto-pairs'
Plugin 'jreybert/vimagit'
Plugin 'janko-m/vim-test'

" Language Support
Plugin 'lervag/vimtex'
Plugin 'fatih/vim-go'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'sheerun/vim-polyglot'
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

" Sets how many lines of history VIM has to remember
set history=500

set encoding=utf-8
set fileencoding=utf-8

" Use Unix as the standard file type
set fileformats=unix,dos,mac

" Better command-line completion
set wildmenu
set wildmode=longest,full
set wildignorecase
set wildignore+=*.a,*.o
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
set wildignore+=.DS_Store,.git,.hg,.svn
set wildignore+=*~,*.swp,*.tmp,*.pyc

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
set whichwrap+=<,>,h,l

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent
set smartindent
"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use


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

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set timeoutlen=500

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" press <Enter> to continue
set cmdheight=2

" All lines will show their relative number, except for current line, which
" will show its absolute line number, when buffer not focused or in insert.

" Show relative line number
set number
set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Set 7 lines above/below cursor - when moving vertically using j/k
set scrolloff=7

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>

" highlight current line
set cursorline

augroup opening
    autocmd!
    " Return to last edit position when opening files
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

"search as characters are entered
set incsearch

" For regular expressions turn magic on
set magic


"------------------------------------------------------------
" Indentation options {{{1
"

" Indentation settings for representing tabs as 4 spacces.
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set smarttab

"------------------------------------------------------------
" Mappings {{{1

" Remap VIM 0 to first non-blank character
map 0 ^

nmap <F8> :TagbarToggle<CR>

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ','

" Fast saving
nmap <leader>w :w!<cr>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W w !sudo tee % > /dev/null

" Visual mode pressing * or # searches for the current selection
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Close buffer with qq
nnoremap qq :bd<cr>

" Easier buffer switching
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" Ultisnips mappings
let g:UltiSnipsExpandTrigger='<tab>'
let g:UltiSnipsListSnippets='<c-tab>'
let g:UltiSnipsJumpForwardTrigger='<tab>' "<c-j>
let g:UltiSnipsJumpBackwardTrigger='<s-tab>'
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']
let g:snips_author='Riley Martine'

" Teach me to use hjkl
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Enable folding with the spacebar
nnoremap <space> za

" Make j k move by row, not line
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" Wrap on words, not chars
set linebreak

" Substitute all by default
set gdefault

"------------------------------------------------------------
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

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
augroup ignore
    autocmd!
    autocmd BufNewFile,BufRead /home/riley/work_files/* set noundofile
augroup END

" Put swap files away
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

augroup NERDTree
    autocmd!
    " open NERDTree if no files specified
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
    " close vim if only window left open is NERDTree
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" Toggle NERDTree with <C-n>
map <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.pyc$', '__pycache__']

augroup switching
    autocmd!
    " Save on focus lost
    autocmd FocusLost * silent! wa
    autocmd FocusGained,BufEnter * :checktime
augroup END

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

augroup filetype_golang
    autocmd!
    autocmd FileType go nmap <leader>t  <Plug>(go-test)
	autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
    autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
    autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4
augroup END
    

" Set to auto read when a file is changed from the outside
set autoread
set clipboard=unnamed
"set clipboard=unnamedplus

let g:ale_fixers = {
\   'sh': ['shfmt'],
\   'python': ['isort'],
\   'javascript': ['remove_trailing_lines', 'trim_whitespace'],
\   'tex': ['remove_trailing_lines', 'trim_whitespace', 'latexindent'],
\   'text': ['remove_trailing_lines', 'trim_whitespace'],
\   'css': ['prettier', 'remove_trailing_lines', 'stylelint', 'trim_whitespace'],
\   'html': ['remove_trailing_lines', 'trim_whitespace'],
\   'markdown': ['prettier', 'trim_whitespace', 'remove_trailing_lines'],
\   'go': ['trim_whitespace', 'remove_trailing_lines', 'goimports'],
\}

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'tex':['chktex', 'lacheck', 'proselint', 'redpen', 'textlint', 'vale', 'alex'],
\   'text':['proselint', 'redpen', 'textlint', 'vale', 'alex', 'languagetool'],
\   'html':['alex', 'fecs', 'htmlhint', 'stylelint', 'tidy', 'writegood'],
\}

let g:ale_html_tidy_options = '-i -q -language en'

let g:ale_fix_on_save = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_set_highlights = 1
let g:ale_sign_column_always = 1
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_python_flake8_options = '--ignore=E501'
let g:ale_python_pylint_options = '--disable=C0412'
let g:ale_python_mypy_options = '--ignore-missing-imports --strict'
let g:ale_tex_latexindent_options = '-m -l ~/.indentconfig.yaml'
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='wal'
" suggested by vim-gitgutter
set updatetime=100

set foldmethod=indent
set foldlevel=99
let g:SimpylFold_docstring_preview=1

colorscheme wal
let g:tmuxline_preset = {
    \'a'  : '#S',
    \'b'  : '#W',
    \'x'  : '#(ddate +"%%{%%A, %%e %%B%%}, %%Y YOLD%%N: %%H")',
    \'y'  : ['%a %b %d', '%H:%M'],
    \'z'  : '#(whoami)',
    \'win': ['#I', '#W']}

" https://castel.dev/post/lecture-notes-1/
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

" Python Filetype
let python_highlight_all=1

augroup filetype_py
    autocmd!
    au FileType python syn keyword pythonDecorator True None False self
    au BufNewFile,BufRead *.jinja set syntax=htmljinja
    autocmd BufWritePre *.py execute ':Black'
    autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
augroup END

augroup filetype_web
    autocmd!
    au FileType js,html,css set tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup filetype_gitcommit
    autocmd!
    " In Git commit messages, wrap at 72 characters
    autocmd FileType gitcommit set textwidth=72

    " In Git commit messages, also color the 51st column (for titles)
    autocmd FileType gitcommit set colorcolumn+=51
augroup END


map <leader>ss :setlocal spell!<cr>
" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=
augroup spellchecking
    autocmd!
    autocmd FileType tex,markdown,text :setlocal spell
    autocmd FileType tex,markdown,text inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
augroup END

" Go Stuff
let g:go_disable_autoinstall = 0
 
" Highlight
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
 
" Scope and tags for guru in vim-go
let g:go_null_module_warning = 0
let g:go_code_completion_enabled = 0
let g:ale_set_highlights = 0
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
