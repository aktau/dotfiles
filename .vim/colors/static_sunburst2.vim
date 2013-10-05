" Vim color file
" Converted from Textmate theme Upstream Sunburst using Coloration v0.3.2 (http://github.com/sickill/coloration)

set background=dark
highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "Upstream Sunburst"

hi Cursor ctermfg=NONE ctermbg=15 cterm=NONE guifg=NONE guibg=#ffffff gui=NONE
hi Visual ctermfg=NONE ctermbg=60 cterm=NONE guifg=NONE guibg=#3e5586 gui=NONE
hi CursorLine ctermfg=NONE ctermbg=234 cterm=NONE guifg=NONE guibg=#191919 gui=NONE
hi CursorColumn ctermfg=NONE ctermbg=234 cterm=NONE guifg=NONE guibg=#191919 gui=NONE
hi ColorColumn ctermfg=NONE ctermbg=234 cterm=NONE guifg=NONE guibg=#191919 gui=NONE
hi LineNr ctermfg=244 ctermbg=234 cterm=NONE guifg=#7c7c7c guibg=#191919 gui=NONE
hi VertSplit ctermfg=238 ctermbg=238 cterm=NONE guifg=#484848 guibg=#484848 gui=NONE
hi MatchParen ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi StatusLine ctermfg=231 ctermbg=238 cterm=bold guifg=#f8f8f8 guibg=#484848 gui=bold
hi StatusLineNC ctermfg=231 ctermbg=238 cterm=NONE guifg=#f8f8f8 guibg=#484848 gui=NONE
hi Pmenu ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi PmenuSel ctermfg=NONE ctermbg=60 cterm=NONE guifg=NONE guibg=#3e5586 gui=NONE
hi IncSearch ctermfg=NONE ctermbg=23 cterm=NONE guifg=NONE guibg=#0c3348 gui=NONE
hi Search ctermfg=NONE ctermbg=23 cterm=NONE guifg=NONE guibg=#0c3348 gui=NONE
hi Directory ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi Folded ctermfg=237 ctermbg=0 cterm=NONE guifg=#3d3d3d guibg=#000000 gui=NONE

hi Normal ctermfg=231 ctermbg=0 cterm=NONE guifg=#f8f8f8 guibg=#000000 gui=NONE
hi Boolean ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi Character ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi Comment ctermfg=237 ctermbg=NONE cterm=NONE guifg=#3d3d3d guibg=NONE gui=italic
hi Conditional ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi Constant ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi Define ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi ErrorMsg ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi WarningMsg ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi Float ctermfg=148 ctermbg=NONE cterm=NONE guifg=#b2d72c guibg=NONE gui=NONE
hi Function ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi Identifier ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi Keyword ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi Label ctermfg=148 ctermbg=NONE cterm=NONE guifg=#b2d72c guibg=NONE gui=NONE
hi NonText ctermfg=16 ctermbg=232 cterm=NONE guifg=#16191c guibg=#0c0c0c gui=NONE
hi Number ctermfg=148 ctermbg=NONE cterm=NONE guifg=#b2d72c guibg=NONE gui=NONE
hi Operator ctermfg=15 ctermbg=NONE cterm=NONE guifg=#ffffff guibg=NONE gui=NONE
hi PreProc ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi Special ctermfg=231 ctermbg=NONE cterm=NONE guifg=#f8f8f8 guibg=NONE gui=NONE
hi SpecialKey ctermfg=16 ctermbg=234 cterm=NONE guifg=#16191c guibg=#191919 gui=NONE
hi Statement ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi StorageClass ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi String ctermfg=148 ctermbg=NONE cterm=NONE guifg=#b2d72c guibg=NONE gui=NONE
hi Tag ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi Title ctermfg=231 ctermbg=NONE cterm=bold guifg=#f8f8f8 guibg=NONE gui=bold
hi Todo ctermfg=237 ctermbg=NONE cterm=inverse,bold guifg=#3d3d3d guibg=NONE gui=inverse,bold,italic
hi Type ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi Underlined ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=NONE gui=underline
hi rubyClass ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi rubyFunction ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi rubyInterpolationDelimiter ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi rubySymbol ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi rubyConstant ctermfg=103 ctermbg=NONE cterm=NONE guifg=#9b859d guibg=NONE gui=NONE
hi rubyStringDelimiter ctermfg=148 ctermbg=NONE cterm=NONE guifg=#b2d72c guibg=NONE gui=NONE
hi rubyBlockParameter ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi rubyInstanceVariable ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi rubyInclude ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi rubyGlobalVariable ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi rubyRegexp ctermfg=179 ctermbg=NONE cterm=NONE guifg=#e9c062 guibg=NONE gui=NONE
hi rubyRegexpDelimiter ctermfg=179 ctermbg=NONE cterm=NONE guifg=#e9c062 guibg=NONE gui=NONE
hi rubyEscape ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi rubyControl ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi rubyClassVariable ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi rubyOperator ctermfg=15 ctermbg=NONE cterm=NONE guifg=#ffffff guibg=NONE gui=NONE
hi rubyException ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi rubyPseudoVariable ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi rubyRailsUserClass ctermfg=103 ctermbg=NONE cterm=NONE guifg=#9b859d guibg=NONE gui=NONE
hi rubyRailsARAssociationMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsARMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsRenderMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi erubyDelimiter ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi erubyComment ctermfg=237 ctermbg=NONE cterm=NONE guifg=#3d3d3d guibg=NONE gui=italic
hi erubyRailsMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi htmlTag ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi htmlEndTag ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi htmlTagName ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi htmlArg ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi htmlSpecialChar ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi javaScriptFunction ctermfg=95 ctermbg=NONE cterm=NONE guifg=#89725b guibg=NONE gui=NONE
hi javaScriptRailsFunction ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi javaScriptBraces ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi yamlKey ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi yamlAnchor ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi yamlAlias ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi yamlDocumentHeader ctermfg=148 ctermbg=NONE cterm=NONE guifg=#b2d72c guibg=NONE gui=NONE
hi cssURL ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi cssFunctionName ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi cssColor ctermfg=32 ctermbg=NONE cterm=NONE guifg=#259adb guibg=NONE gui=NONE
hi cssPseudoClassId ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi cssClassName ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi cssValueLength ctermfg=148 ctermbg=NONE cterm=NONE guifg=#b2d72c guibg=NONE gui=NONE
hi cssCommonAttr ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi cssBraces ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
