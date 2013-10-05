" Maintainer:	Lars H. Nielsen (dengmao@gmail.com)
" Last Change:	January 22 2007

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "wombat"


" Vim >= 7.0 specific colors
if version >= 700
  hi CursorLine guibg=#2d2d2d ctermbg=236 cterm=none
  hi CursorColumn guibg=#2d2d2d ctermbg=236
  hi MatchParen guifg=#f6f3e8 guibg=#857b6f gui=bold ctermfg=230 ctermbg=144 cterm=bold
  hi Pmenu 		guifg=#f6f3e8 guibg=#444444 ctermfg=230 ctermbg=238
  hi PmenuSel 	guifg=#000000 guibg=#cae682 ctermfg=232 ctermbg=191
endif

" General colors
hi Cursor 		guifg=NONE    guibg=#656565 gui=none ctermfg=NONE ctermbg=242  cterm=none
hi Normal 		guifg=#f6f3e8 guibg=#242424 gui=none ctermfg=252  ctermbg=235  cterm=none
hi NonText 		guifg=#808080 guibg=#303030 gui=none ctermfg=244  ctermbg=236  cterm=none
hi LineNr 		guifg=#857b6f guibg=#000000 gui=none ctermfg=240  ctermbg=232  cterm=none
hi StatusLine 	guifg=#f6f3e8 guibg=#444444 gui=none ctermfg=230  ctermbg=238  cterm=none
hi StatusLineNC guifg=#857b6f guibg=#444444 gui=none ctermfg=144  ctermbg=238  cterm=none
hi VertSplit 	guifg=#444444 guibg=#444444 gui=none ctermfg=238  ctermbg=238  cterm=none
hi Folded 		guibg=#384048 guifg=#a0a8b0 gui=none ctermfg=237  ctermbg=247  cterm=none
hi Title		guifg=#f6f3e8 guibg=NONE	gui=bold ctermfg=230  ctermbg=NONE cterm=bold
hi Visual		guifg=#f6f3e8 guibg=#444444 gui=none ctermfg=230  ctermbg=238  cterm=none
hi SpecialKey	guifg=#808080 guibg=#343434 gui=none ctermfg=244  ctermbg=236  cterm=none

" Syntax highlighting
hi Comment 		guifg=#99968b gui=none ctermfg=246 cterm=none
hi Todo 		guifg=#8f8f8f gui=none ctermfg=245 cterm=none ctermbg=238
hi Constant 	guifg=#e5786d gui=none ctermfg=167 cterm=none
hi String 		guifg=#95e454 gui=none ctermfg=113 cterm=none ctermbg=237
hi Identifier 	guifg=#cae682 gui=none ctermfg=150 cterm=none
hi Function 	guifg=#cae682 gui=none ctermfg=150 cterm=none
hi Type 		guifg=#cae682 gui=none ctermfg=150 cterm=none
hi Statement 	guifg=#8ac6f2 gui=none ctermfg=111 cterm=none
hi Keyword		guifg=#8ac6f2 gui=none ctermfg=111 cterm=none
hi PreProc 		guifg=#e5786d gui=none ctermfg=167 cterm=none
hi Number		guifg=#e5786d gui=none ctermfg=167 cterm=none
hi Special		guifg=#e7f6da gui=none ctermfg=225 cterm=none
