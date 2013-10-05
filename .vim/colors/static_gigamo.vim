" Vim colortheme: gigamo.vim
" Last Change: 26. April 2008
" License: public domain
" Maintainer: Gigamo <gigamo@gmail.com>
" Credit: twilight.vim - Actually this is twilight.vim made to work with
"         256 color terminals
"
" 256 color terminals or gvim only
" set t_Co=256
"
" Options:
"     g:gvim_background
"       If this var is uncommented, terminal will use the background colors like
"       in the scheme. If commented, terminal will use its own background color
"       (useful for transparent terminals)


" Using The Options:
"       To enable a feature add the line
"           let g:gvim_background=1
"       to your ~/.vimrc
"       To disable the feature temporarily run the command
"           :unlet g:gvim_background
"       To  disable the  feature permanently,  simply remove
"       the line from your .vimrc file.
"       Lastly you can also just uncomment the line below here.        

"let g:gvim_background=1

set background=dark
let python_highlight_all = 1
hi clear
if exists("syntax_on")
  syntax reset
endif
let colors_name = "gigamo"

if exists("g:gvim_background") 
  hi Normal     guifg=#f8f8f8   guibg=#141414   ctermfg=255   ctermbg=233
  hi LineNr     guifg=#808080   guibg=#141414   ctermfg=244   ctermbg=233
  hi NonText    guifg=#808080   guibg=#303030   ctermfg=244   ctermbg=236
  hi TabLineSel guifg=black     guibg=#f0f0f0   gui=bold      ctermfg=black   cterm=bold  ctermbg=254
else
  hi Normal     guifg=#f8f8f8   guibg=#141414   ctermfg=255   ctermbg=none
  hi LineNr     guifg=#808080   guibg=#141414   ctermfg=244   ctermbg=none
  hi NonText    guifg=#808080   guibg=#303030   ctermfg=244   ctermbg=none
  hi TabLineSel guifg=black     guibg=#f0f0f0   gui=bold      ctermfg=black   cterm=bold  ctermbg=none
endif

hi Cursor       guifg=none      guibg=#586068   ctermfg=none  ctermbg=240

hi StatusLine   guifg=#f0f0f0   guibg=#4f4a50   ctermfg=254   ctermbg=238
hi StatusLineNC guifg=#c0c0c0   guibg=#5f5a60   ctermfg=251   ctermbg=241

hi VertSplit    guifg=#5f5a60   guibg=#5f5a60   ctermfg=60
hi Folded       guifg=#a0a8b0   guibg=#384048   ctermfg=247   ctermbg=237

hi Comment      guifg=#5f5a60   ctermfg=241
hi Todo         guifg=#808080   guibg=none      gui=bold      ctermfg=244     ctermbg=none    cterm=bold
hi Constant     guifg=#cf6a4c   ctermfg=209
hi String       guifg=#ddf2a4   ctermfg=229
hi Type         ctermfg=83
hi Identifier   guifg=#7587a6   ctermfg=68
hi Structure    guifg=#9b859d   ctermfg=139
hi Function     guifg=#dad085   ctermfg=228
hi Statement    guifg=#dad085   gui=none        ctermfg=228   cterm=none
hi PreProc      guifg=#cda869   ctermfg=221
hi Special      ctermfg=172
hi SpecialKey   guifg=#808080   guibg=#343434   ctermfg=244

if version >= 700
  hi CursorColumn               guibg=#182028   cterm=none    ctermbg=238
  hi CursorLine                 guibg=#182028   cterm=none    ctermbg=235
  hi lCursor                    cterm=none      ctermfg=0     ctermbg=40
  hi MatchParen                 guifg=white     guibg=#80a090 gui=bold        ctermfg=white   cterm=bold
  hi TabLine                    guifg=black     guibg=#b0b8c0 ctermfg=black   ctermbg=248
  hi TabLineFill                guifg=#9098a0   ctermfg=246
  hi Pmenu                      guifg=white     guibg=#808080 ctermfg=white
endif
