set background=dark

hi clear

if exists('syntax_on')
  syntax reset
endif

let colors_name = 'jellybeans'

if version >= 700
  hi CursorLine guibg=#1c1c1c ctermbg=236 cterm=none
  hi CursorColumn guibg=#1c1c1c ctermbg=236
  hi MatchParen guifg=white guibg=#80a090 gui=bold ctermfg=255 ctermbg=29 cterm=bold

  "Tabpages
  hi TabLine guifg=black guibg=#b0b8c0 gui=none ctermbg=235 ctermfg=250 cterm=italic
  hi TabLineFill guifg=#9098a0 ctermfg=243
  hi TabLineSel guifg=black guibg=#f0f0f0 gui=bold ctermbg=232 ctermfg=254 cterm=italic,bold

  "P-Menu (auto-completion)
  hi Pmenu guifg=white guibg=#000000 ctermfg=255 ctermbg=232
  hi PmenuSel guifg=#101010 guibg=#eeeeee ctermfg=233 ctermbg=254
  "PmenuSbar
  "PmenuThumb
endif

hi Visual guibg=#404040 ctermbg=238

"hi Cursor guifg=NONE guibg=#586068
hi Cursor guibg=#b0d0f0 ctermbg=250

hi Normal guifg=#e8e8d3 guibg=#151515 ctermfg=254 ctermbg=232
"hi LineNr guifg=#808080 guibg=#e0e0e0
hi LineNr guifg=#605958 guibg=#151515 ctermfg=242 ctermbg=233
"hi Comment guifg=#5f5a60 gui=italic
hi Comment guifg=#888888 gui=none ctermfg=245 cterm=none
hi Todo guifg=#808080 gui=bold ctermfg=244 ctermbg=none cterm=none

hi StatusLine guifg=#f0f0f0 guibg=#101010 ctermfg=254 ctermbg=233 cterm=italic
hi StatusLineNC guifg=#a0a0a0 guibg=#18181c ctermfg=247 ctermbg=234 cterm=italic
hi VertSplit guifg=#181818 guibg=#18181c ctermfg=247 ctermbg=234 cterm=italic

hi Folded guibg=#384048 guifg=#a0a8bc ctermfg=248 ctermbg=238
hi FoldColumn guibg=#384048 guifg=#a0a8b0 ctermfg=248 ctermbg=248
hi SignColumn guibg=#384048 guifg=#a0a8b0 ctermfg=248 ctermbg=248

hi Title guifg=#70b950 gui=bold ctermfg=71 cterm=bold

hi Constant guifg=#cf6a4c ctermfg=209
hi String guifg=#799d6a ctermfg=71
hi Delimiter guifg=#668799 ctermfg=24
hi Special guifg=#99ad6a ctermfg=84
"hi Number guifg=#ff00fc
"hi Float
"hi Identifier guifg=#7587a6
hi Identifier guifg=#c6b6ee
" Type d: 'class'
"hi Structure guifg=#9B859D gui=underline
hi Structure guifg=#8fbfdc gui=none ctermfg=75 cterm=none
hi Function guifg=#fad07a ctermfg=222
" dylan: method, library, ... d: if, return, ...
"hi Statement guifg=#7187a1 gui=NONE
hi Statement guifg=#8197bf gui=none ctermfg=67 cterm=none
" Keywords  d: import, module...
hi PreProc guifg=#8fbfdc ctermfg=111

hi link Operator Normal

hi Type guifg=#ffb964 gui=none ctermfg=215 cterm=none
hi NonText guifg=#808080 guibg=#151515 ctermfg=244 ctermbg=234

"hi Macro guifg=#a0b0c0 gui=underline

"Tabs, trailing spaces, etc (lcs)
hi SpecialKey guifg=#808080 guibg=#343434 ctermfg=244 ctermbg=237

"hi TooLong guibg=#ff0000 guifg=#f8f8f8

hi Search guifg=#f0a0c0 guibg=#302028 gui=underline ctermfg=213 ctermbg=235 cterm=underline

hi Directory guifg=#dad085 gui=none ctermfg=228 cterm=none
hi Error guibg=#602020 ctermbg=88

" Diff

hi link diffRemoved Constant
hi link diffAdded String

" VimDiff

hi DiffAdd guibg=#032218 ctermbg=233
hi DiffChange guibg=#100920 ctermbg=232
hi DiffDelete guibg=#220000 ctermbg=232
hi DiffText guibg=#000940 ctermbg=232

" PHP

"hi phpFunctions guifg=#c676be
hi link phpFunctions Function
hi StorageClass guifg=#c59f6f ctermfg=223

" Ruby

hi link rubySharpBang Comment
hi rubyClass guifg=#447799 ctermfg=67
hi rubyIdentifier guifg=#c6b6fe ctermfg=147

hi rubyInstanceVariable guifg=#c6b6fe ctermfg=181
"hi rubySymbol guifg=#6677ff
hi rubySymbol guifg=#7697d6 ctermfg=74
hi link rubyGlobalVariable rubyInstanceVariable
hi link rubyClassVariable rubyInstanceVariable
hi link rubyModule rubyClass
hi rubyControl guifg=#7597c6 ctermfg=74

"hi link rubyString Special
hi rubyStringDelimiter guifg=#556633 ctermfg=64
hi link rubyInterpolationDelimiter Identifier

hi rubyRegexpDelimiter guifg=#540063 ctermfg=179
hi rubyRegexp guifg=#dd0093 ctermfg=223
hi rubyRegexpSpecial guifg=#a40073 ctermfg=179

hi rubyPredefinedIdentifier guifg=#de5577 ctermfg=204

" Tag list
hi link TagListFileName Directory
