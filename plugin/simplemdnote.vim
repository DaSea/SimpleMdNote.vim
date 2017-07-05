if exists("loaded_simple_mdnote")
    finish
endif
let loaded_simple_mdnote = 1

" default configure {{{
function! s:initVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction
" 要发布的note的地址，主要对应hexo的_posts和_drafts
call s:initVariable("g:simplemdnote_posts_path", "~/simplenote/posts")
call s:initVariable("g:simplemdnote_draft_path", "~/simplenote/draft")
call s:initVariable("g:simplemdnote_win_size", 30)
call s:initVariable("g:simplemdnote_win_pos", "left")
" }}}

" commands {{{
" 创建要发布或草稿笔记
command! SNNewDraftNote call simplemdnote#new_note(1)
command! SNNewPostsNote call simplemdnote#new_note(2)
" 将当前的草稿发布出去（即从草稿文件夹移动到发布文件夹）
command! SNPublishNOte call simplemdnote#publicsh_note()
" 在左侧窗口显示已经存在的note
command! SNListNote call simplemdnote#list_note()
" }}}

call ex#register_plugin('snote', {} )

" key mappings {{

" }}

