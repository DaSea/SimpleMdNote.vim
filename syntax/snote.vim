if version < 700
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" fold
syntax region snote_fold start="{" end="}" transparent fold

" syntax highlight
syntax match snote_name '\<[a-zA-Z_][a-zA-Z0-9_-]*\>\.\<md\>'hs=s,he=e

hi default link snote_name KeyWord

let b:current_syntax = "snote"

" vim:ts=4:sw=4:sts=4 et fdm=marker:
