" Vim color file
" Name: DarkTango
" Maintainer: Panos Laganakos <panos.laganakos@gmail.com>
" Version: 0.3


set background=dark
if version > 580
	" no guarantees for version 5.8 and below, but this makes it stop
	" complaining
	hi clear
	if exists("syntax_on")
		syntax reset
	endif
endif

let g:colors_name="darktango"

hi Normal	guibg=#1c1c1c guifg=#d3d7cf ctermfg=252

" {{{ syntax
hi Comment	guifg=#555753 ctermfg=244
hi Title	guifg=#eeeeec ctermfg=255
hi Underlined	guifg=#20b0eF gui=none ctermfg=38 gui=none
hi Statement	guifg=#888a85 ctermfg=245
hi Type		guifg=#ce5c00 ctermfg=202
hi PreProc	guifg=#eeeeec ctermfg=255
hi Constant	guifg=#babdb6 ctermfg=250
hi Identifier	guifg=#ce5c00 ctermfg=202
hi Special	guifg=#eeeeec ctermfg=255
hi Ignore	guifg=#f57900 ctermfg=187
hi Todo		guibg=#ce5c00 guifg=#eeeeec ctermbg=202 ctermfg=255
"hi Error
"}}}

" {{{ groups
hi Cursor	guibg=#babdb6 guifg=#2e3436 ctermbg=250 ctermfg=236
"hi CursorIM
hi Directory	guifg=#bbd0df ctermfg=251
"hi DiffAdd
"hi DiffChange
"hi DiffDelete
"hi DiffText
"hi ErrorMsg
hi VertSplit	guibg=#555753 guifg=#2e3436 gui=none ctermbg=240 ctermfg=236 cterm=none
hi Folded	guibg=#555753 guifg=#eeeeec ctermbg=240 ctermfg=255
hi FoldColumn	guibg=#2e3436 guifg=#555753 ctermbg=236 ctermfg=240
hi LineNr	guibg=#2e3436 guifg=#555753 ctermfg=240
hi MatchParen	guibg=#babdb6 guifg=#2e3436 ctermbg=250 ctermfg=236
hi ModeMsg	guifg=#ce5c00 ctermfg=202
hi MoreMsg	guifg=#ce5c00 ctermfg=202
hi NoText	guibg=#060606 guifg=#555753 ctermbg=none ctermfg=240
hi Question	guifg=#aabbcc ctermfg=249
hi Search	guibg=#fce94f guifg=#c4a000 ctermfg=220 ctermbg=240
hi IncSearch	guibg=#c4a000 guifg=#fce94f ctermfg=227
hi SpecialKey	guifg=#ce5c00 ctermfg=202
hi StatusLine	guibg=#555753 guifg=#eeeeec gui=none ctermbg=240 ctermfg=255 cterm=none
hi StatusLineNC	guibg=#555753 guifg=#272334 gui=none ctermbg=240 ctermfg=235 cterm=none
hi Visual	guibg=#fcaf3e guifg=#ce5c00 ctermfg=202
"hi VisualNOS
hi WarningMsg	guifg=salmon ctermfg=209
"hi WildMenu
"hi Menu
"hi Scrollbar  guibg=grey30 guifg=tan
"hi Tooltip
hi Pmenu	guibg=#babdb6 guifg=#555753 ctermbg=250 ctermfg=240
hi PmenuSel	guibg=#eeeeec guifg=#2e3436 ctermbg=244 ctermfg=236
hi CursorLine	guibg=#212628 ctermbg=233 cterm=none
" }}}

"  {{{ terminal
" TODO
" }}}

"vim: sw=4
