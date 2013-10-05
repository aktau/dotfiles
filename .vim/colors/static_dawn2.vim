" Vim color file
" Converted from Textmate theme Dawn using Coloration v0.2.4 (http://github.com/sickill/coloration)

set background=dark
highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "dawn2"

hi Cursor  guifg=NONE guibg=#000000 gui=NONE
hi Visual  guifg=NONE guibg=#bacbfb gui=NONE
hi CursorLine  guifg=NONE guibg=#dfe7f1 gui=NONE
hi CursorColumn  guifg=NONE guibg=#dfe7f1 gui=NONE
hi LineNr  guifg=#818181 guibg=#f9f9f9 gui=NONE
hi VertSplit  guifg=#cbcbcb guibg=#cbcbcb gui=NONE
hi MatchParen  guifg=#794938 guibg=NONE gui=NONE
hi StatusLine  guifg=#080808 guibg=#cbcbcb gui=bold
hi StatusLineNC  guifg=#080808 guibg=#cbcbcb gui=NONE
hi Pmenu  guifg=#bf4f24 guibg=NONE gui=NONE
hi PmenuSel  guifg=NONE guibg=#bacbfb gui=NONE
hi IncSearch  guifg=NONE guibg=#b2bfd9 gui=NONE
hi Search  guifg=NONE guibg=#b2bfd9 gui=NONE
hi Directory  guifg=#811f24 guibg=NONE gui=bold
hi Folded  guifg=#5a525f guibg=#f9f9f9 gui=NONE

hi Normal  guifg=#080808 guibg=#f9f9f9 gui=NONE
hi Boolean  guifg=#811f24 guibg=NONE gui=bold
hi Character  guifg=#811f24 guibg=NONE gui=bold
hi Comment  guifg=#5a525f guibg=NONE gui=italic
hi Conditional  guifg=#794938 guibg=NONE gui=NONE
hi Constant  guifg=#811f24 guibg=NONE gui=bold
hi Define  guifg=#794938 guibg=NONE gui=NONE
hi ErrorMsg  guifg=NONE guibg=NONE gui=NONE
hi WarningMsg  guifg=NONE guibg=NONE gui=NONE
hi Float  guifg=#811f24 guibg=NONE gui=bold
hi Function  guifg=#bf4f24 guibg=NONE gui=NONE
hi Identifier  guifg=#a71d5d guibg=NONE gui=italic
hi Keyword  guifg=#794938 guibg=NONE gui=NONE
hi Label  guifg=NONE guibg=NONE gui=NONE
hi NonText  guifg=#a2a2bc guibg=#dfe7f1 gui=NONE
hi Number  guifg=#811f24 guibg=NONE gui=bold
hi Operator  guifg=#794938 guibg=NONE gui=NONE
hi PreProc  guifg=#794938 guibg=NONE gui=NONE
hi Special  guifg=#080808 guibg=NONE gui=NONE
hi SpecialKey  guifg=#a2a2bc guibg=#dfe7f1 gui=NONE
hi Statement  guifg=#794938 guibg=NONE gui=NONE
hi StorageClass  guifg=#a71d5d guibg=NONE gui=italic
hi String  guifg=NONE guibg=NONE gui=NONE
hi Tag  guifg=#bf4f24 guibg=NONE gui=NONE
hi Title  guifg=#080808 guibg=NONE gui=bold
hi Todo  guifg=#5a525f guibg=NONE gui=inverse,bold,italic
hi Type  guifg=#bf4f24 guibg=NONE gui=NONE
hi Underlined  guifg=NONE guibg=NONE gui=underline
hi rubyClass  guifg=#794938 guibg=NONE gui=NONE
hi rubyFunction  guifg=#bf4f24 guibg=NONE gui=NONE
hi rubyInterpolationDelimiter  guifg=NONE guibg=NONE gui=NONE
hi rubySymbol  guifg=#811f24 guibg=NONE gui=bold
hi rubyConstant  guifg=#691c97 guibg=NONE gui=NONE
hi rubyStringDelimiter  guifg=NONE guibg=NONE gui=NONE
hi rubyBlockParameter  guifg=#234a97 guibg=NONE gui=NONE
hi rubyInstanceVariable  guifg=#234a97 guibg=NONE gui=NONE
hi rubyInclude  guifg=#794938 guibg=NONE gui=NONE
hi rubyGlobalVariable  guifg=#234a97 guibg=NONE gui=NONE
hi rubyRegexp  guifg=#cf5628 guibg=NONE gui=NONE
hi rubyRegexpDelimiter  guifg=#cf5628 guibg=NONE gui=NONE
hi rubyEscape  guifg=#811f24 guibg=NONE gui=bold
hi rubyControl  guifg=#794938 guibg=NONE gui=NONE
hi rubyClassVariable  guifg=#234a97 guibg=NONE gui=NONE
hi rubyOperator  guifg=#794938 guibg=NONE gui=NONE
hi rubyException  guifg=#794938 guibg=NONE gui=NONE
hi rubyPseudoVariable  guifg=#234a97 guibg=NONE gui=NONE
hi rubyRailsUserClass  guifg=#691c97 guibg=NONE gui=NONE
hi rubyRailsARAssociationMethod  guifg=#693a17 guibg=NONE gui=NONE
hi rubyRailsARMethod  guifg=#693a17 guibg=NONE gui=NONE
hi rubyRailsRenderMethod  guifg=#693a17 guibg=NONE gui=NONE
hi rubyRailsMethod  guifg=#693a17 guibg=NONE gui=NONE
hi erubyDelimiter  guifg=NONE guibg=NONE gui=NONE
hi erubyComment  guifg=#5a525f guibg=NONE gui=italic
hi erubyRailsMethod  guifg=#693a17 guibg=NONE gui=NONE
hi htmlTag  guifg=#bf4f24 guibg=NONE gui=NONE
hi htmlEndTag  guifg=#bf4f24 guibg=NONE gui=NONE
hi htmlTagName  guifg=#bf4f24 guibg=NONE gui=NONE
hi htmlArg  guifg=#bf4f24 guibg=NONE gui=NONE
hi htmlSpecialChar  guifg=#811f24 guibg=NONE gui=bold
hi javaScriptFunction  guifg=#a71d5d guibg=NONE gui=italic
hi javaScriptRailsFunction  guifg=#693a17 guibg=NONE gui=NONE
hi javaScriptBraces  guifg=NONE guibg=NONE gui=NONE
hi yamlKey  guifg=#bf4f24 guibg=NONE gui=NONE
hi yamlAnchor  guifg=#234a97 guibg=NONE gui=NONE
hi yamlAlias  guifg=#234a97 guibg=NONE gui=NONE
hi yamlDocumentHeader  guifg=NONE guibg=NONE gui=NONE
hi cssURL  guifg=#234a97 guibg=NONE gui=NONE
hi cssFunctionName  guifg=#693a17 guibg=NONE gui=NONE
hi cssColor  guifg=#811f24 guibg=NONE gui=bold
hi cssPseudoClassId  guifg=#bf4f24 guibg=NONE gui=NONE
hi cssClassName  guifg=#bf4f24 guibg=NONE gui=NONE
hi cssValueLength  guifg=#811f24 guibg=NONE gui=bold
hi cssCommonAttr  guifg=#b4371f guibg=NONE gui=NONE
hi cssBraces  guifg=NONE guibg=NONE gui=NONE
