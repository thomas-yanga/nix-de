syntax enable
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set showmode
set cursorline
set clipboard=unnamed,unnamedplus
set selectmode=mouse,key
set nu

" 显示特殊字符（制表符、行尾符等）
set listchars=tab:→\ 
set list

" 额外高亮行尾空格（红色）
highlight link ExtraWhitespace SpellBad
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/

if has('wayland')
  set clipboard=unnamedplus,wl-clipboard
endif
