"
" ~/.vimrc
"
" This is your Vim initialization file. It is read on Vim startup.
"
" Change this file to customize your Vim settings.
" 
" Vim treats lines beginning with " as comments.
"
" EXAMPLES are available in /usr/local/doc/startups.
"

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax on
filetype on

execute pathogen#infect()

" Enable syntax highlighting in redo's *.do files
au BufNewFile,BufRead *.do set filetype=sh

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
set background=dark

" Have Vim jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

" Have Vim load indentation rules according to the detected filetype. Per
" default Debian Vim only load filetype specific plugins.
"if has("autocmd")
"  filetype indent on
"endif

set showcmd            " Show (partial) command in status line.
set showmatch          " Show matching brackets.
set ignorecase         " Do case insensitive matching
set smartcase          " Do smart case matching
set incsearch          " Incremental search
set hlsearch
set autowrite          " Automatically save before commands like :next and :make
set hidden             " Hide buffers when they are abandoned
set mouse=a            " Enable mouse usage (all modes) in terminals
set expandtab
set tabstop=4
set shiftwidth=4
set smartindent
set ruler
set hls
set colorcolumn=80
"set cursorline        " Highlight current line
set wildmenu           " Enable menu for tab completion in cmd mode
set wildmode=list,longest
set textwidth=80       " Used to line break comments (and text if :set fo+=t)
set formatoptions=rocq " Line break comments and understand how to 'gqap' comments
set linebreak          " Only break lines at word boundaries
set number
set cursorline
set so=20


"--------------------------------"
"---Stolen from andrew's vimrc---"
set history=128     " Remember last 128 commands
set report=0        " Always report number of lines altered
"set vb t_vb=       " No bell or visual bell
set undolevels=4096 " Lots of undo
set nomodeline      " Mode lines are scary (arbitrary command execution!)
"--------------------------------"

filetype plugin indent on 
autocmd FileType python setlocal smartindent shiftwidth=4 ts=4 softtabstop=4 et cinwords=if,elif,else,for,while,try,except,finally,def,class


if &term =~ "xterm"
  "256 color --
  let &t_Co=256
  colorscheme solarized
  " restore screen after quitting
  " set t_ti=ESC7ESC[rESC[?47h t_te=ESC[?47lESC8
  if has("terminfo")
    let &t_Sf="\ESC[3%p1%dm"
    let &t_Sb="\ESC[4%p1%dm"
  else
    let &t_Sf="\ESC[3%dm"
    let &t_Sb="\ESC[4%dm"
  endif
endif

"setlocal spell spelllang=en_us

if has("cscope")

""""""""""""" Standard cscope/vim boilerplate

" use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
set cscopetag
 
" check cscope for definition of a symbol before checking ctags: set to 1
"          " if you want the reverse search order.
set csto=0

if filereadable("cscope.out")
    cs add cscope.out
elseif $CSCOPE_DB != ""
    cs add $CSCOPE_DB
endif

set cscopeverbose


nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>

endif
