" Vim color file
" Converted from Textmate theme Bespin using Coloration v0.3.2 (http://github.com/sickill/coloration)

set background=dark
highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "Bespin"

hi Cursor ctermfg=NONE ctermbg=248 cterm=NONE guifg=NONE guibg=#a7a7a7 gui=NONE
hi Visual ctermfg=NONE ctermbg=59 cterm=NONE guifg=NONE guibg=#4c4a49 gui=NONE
hi CursorLine ctermfg=NONE ctermbg=52 cterm=NONE guifg=NONE guibg=#372f29 gui=NONE
hi CursorColumn ctermfg=NONE ctermbg=52 cterm=NONE guifg=NONE guibg=#372f29 gui=NONE
hi ColorColumn ctermfg=NONE ctermbg=52 cterm=NONE guifg=NONE guibg=#372f29 gui=NONE
hi LineNr ctermfg=59 ctermbg=52 cterm=NONE guifg=#71685d guibg=#372f29 gui=NONE
hi VertSplit ctermfg=59 ctermbg=59 cterm=NONE guifg=#524a42 guibg=#524a42 gui=NONE
hi MatchParen ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi StatusLine ctermfg=145 ctermbg=59 cterm=bold guifg=#baae9e guibg=#524a42 gui=bold
hi StatusLineNC ctermfg=145 ctermbg=59 cterm=NONE guifg=#baae9e guibg=#524a42 gui=NONE
hi Pmenu ctermfg=94 ctermbg=NONE cterm=NONE guifg=#937121 guibg=NONE gui=NONE
hi PmenuSel ctermfg=NONE ctermbg=59 cterm=NONE guifg=NONE guibg=#4c4a49 gui=NONE
hi IncSearch ctermfg=NONE ctermbg=238 cterm=NONE guifg=NONE guibg=#41434a gui=NONE
hi Search ctermfg=NONE ctermbg=238 cterm=NONE guifg=NONE guibg=#41434a gui=NONE
hi Directory ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi Folded ctermfg=241 ctermbg=16 cterm=NONE guifg=#666666 guibg=#28211c gui=NONE

hi Normal ctermfg=145 ctermbg=16 cterm=NONE guifg=#baae9e guibg=#28211c gui=NONE
hi Boolean ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi Character ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi Comment ctermfg=241 ctermbg=NONE cterm=NONE guifg=#666666 guibg=NONE gui=italic
hi Conditional ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi Constant ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi Define ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi ErrorMsg ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi WarningMsg ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi Float ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi Function ctermfg=94 ctermbg=NONE cterm=NONE guifg=#937121 guibg=NONE gui=NONE
hi Identifier ctermfg=228 ctermbg=NONE cterm=NONE guifg=#f9ee98 guibg=NONE gui=NONE
hi Keyword ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi Label ctermfg=70 ctermbg=NONE cterm=NONE guifg=#54be0d guibg=NONE gui=NONE
hi NonText ctermfg=240 ctermbg=16 cterm=NONE guifg=#5e5955 guibg=#2f2823 gui=NONE
hi Number ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi Operator ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi PreProc ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi Special ctermfg=145 ctermbg=NONE cterm=NONE guifg=#baae9e guibg=NONE gui=NONE
hi SpecialKey ctermfg=240 ctermbg=52 cterm=NONE guifg=#5e5955 guibg=#372f29 gui=NONE
hi Statement ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi StorageClass ctermfg=228 ctermbg=NONE cterm=NONE guifg=#f9ee98 guibg=NONE gui=NONE
hi String ctermfg=70 ctermbg=NONE cterm=NONE guifg=#54be0d guibg=NONE gui=NONE
hi Tag ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi Title ctermfg=145 ctermbg=NONE cterm=bold guifg=#baae9e guibg=NONE gui=bold
hi Todo ctermfg=241 ctermbg=NONE cterm=inverse,bold guifg=#666666 guibg=NONE gui=inverse,bold,italic
hi Type ctermfg=94 ctermbg=NONE cterm=NONE guifg=#937121 guibg=NONE gui=NONE
hi Underlined ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=NONE gui=underline
hi rubyClass ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyFunction ctermfg=94 ctermbg=NONE cterm=NONE guifg=#937121 guibg=NONE gui=NONE
hi rubyInterpolationDelimiter ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi rubySymbol ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi rubyConstant ctermfg=103 ctermbg=NONE cterm=NONE guifg=#9b859d guibg=NONE gui=NONE
hi rubyStringDelimiter ctermfg=70 ctermbg=NONE cterm=NONE guifg=#54be0d guibg=NONE gui=NONE
hi rubyBlockParameter ctermfg=103 ctermbg=NONE cterm=NONE guifg=#7587a6 guibg=NONE gui=NONE
hi rubyInstanceVariable ctermfg=103 ctermbg=NONE cterm=NONE guifg=#7587a6 guibg=NONE gui=NONE
hi rubyInclude ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyGlobalVariable ctermfg=103 ctermbg=NONE cterm=NONE guifg=#7587a6 guibg=NONE gui=NONE
hi rubyRegexp ctermfg=179 ctermbg=NONE cterm=NONE guifg=#e9c062 guibg=NONE gui=NONE
hi rubyRegexpDelimiter ctermfg=179 ctermbg=NONE cterm=NONE guifg=#e9c062 guibg=NONE gui=NONE
hi rubyEscape ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi rubyControl ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyClassVariable ctermfg=103 ctermbg=NONE cterm=NONE guifg=#7587a6 guibg=NONE gui=NONE
hi rubyOperator ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyException ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi rubyPseudoVariable ctermfg=103 ctermbg=NONE cterm=NONE guifg=#7587a6 guibg=NONE gui=NONE
hi rubyRailsUserClass ctermfg=103 ctermbg=NONE cterm=NONE guifg=#9b859d guibg=NONE gui=NONE
hi rubyRailsARAssociationMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsARMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsRenderMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi rubyRailsMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi erubyDelimiter ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi erubyComment ctermfg=241 ctermbg=NONE cterm=NONE guifg=#666666 guibg=NONE gui=italic
hi erubyRailsMethod ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi htmlTag ctermfg=137 ctermbg=NONE cterm=NONE guifg=#ac885b guibg=NONE gui=NONE
hi htmlEndTag ctermfg=137 ctermbg=NONE cterm=NONE guifg=#ac885b guibg=NONE gui=NONE
hi htmlTagName ctermfg=137 ctermbg=NONE cterm=NONE guifg=#ac885b guibg=NONE gui=NONE
hi htmlArg ctermfg=137 ctermbg=NONE cterm=NONE guifg=#ac885b guibg=NONE gui=NONE
hi htmlSpecialChar ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi javaScriptFunction ctermfg=228 ctermbg=NONE cterm=NONE guifg=#f9ee98 guibg=NONE gui=NONE
hi javaScriptRailsFunction ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi javaScriptBraces ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
hi yamlKey ctermfg=74 ctermbg=NONE cterm=NONE guifg=#5ea6ea guibg=NONE gui=NONE
hi yamlAnchor ctermfg=103 ctermbg=NONE cterm=NONE guifg=#7587a6 guibg=NONE gui=NONE
hi yamlAlias ctermfg=103 ctermbg=NONE cterm=NONE guifg=#7587a6 guibg=NONE gui=NONE
hi yamlDocumentHeader ctermfg=70 ctermbg=NONE cterm=NONE guifg=#54be0d guibg=NONE gui=NONE
hi cssURL ctermfg=103 ctermbg=NONE cterm=NONE guifg=#7587a6 guibg=NONE gui=NONE
hi cssFunctionName ctermfg=186 ctermbg=NONE cterm=NONE guifg=#dad085 guibg=NONE gui=NONE
hi cssColor ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi cssPseudoClassId ctermfg=94 ctermbg=NONE cterm=NONE guifg=#937121 guibg=NONE gui=NONE
hi cssClassName ctermfg=94 ctermbg=NONE cterm=NONE guifg=#937121 guibg=NONE gui=NONE
hi cssValueLength ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi cssCommonAttr ctermfg=167 ctermbg=NONE cterm=NONE guifg=#cf6a4c guibg=NONE gui=NONE
hi cssBraces ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
