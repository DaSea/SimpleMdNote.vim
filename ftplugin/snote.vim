" local settings {{{1
silent! setlocal buftype=nofile
silent! setlocal bufhidden=hide
silent! setlocal noswapfile
silent! setlocal nobuflisted

silent! setlocal cursorline
silent! setlocal nonumber
silent! setlocal norelativenumber
silent! setlocal nowrap
silent! setlocal statusline=

silent! setlocal foldenable
silent! setlocal foldmethod=syntax
" }}}1

" Key Mappings {{{1
call simplemdnote#bind_mappings()
" }}}

" vim:ts=4:sw=4:sts=4 et fdm=marker:
