set nu
set smartindent
set tabstop=4
set shiftwidth=4 
set softtabstop=4  
set expandtab  
set autoindent
set cindent
set encoding=utf8
set fileencodings=ucs-bom,utf-8,cp936 
set fileencoding=utf-8
set termencoding=utf-8 
set hlsearch
set nocp
set tags=~/tags
syntax enable 


au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm'\"")|else|exe "norm $"|endif

filetype plugin on
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 0
let OmniCpp_ShowPrototypeInAbbr = 1 " 显示函数参数列表
let OmniCpp_MayCompleteDot = 1   " 输入 .  后自动补全
let OmniCpp_MayCompleteArrow = 1 " 输入 -> 后自动补全
let OmniCpp_MayCompleteScope = 1 " 输入 :: 后自动补全
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
