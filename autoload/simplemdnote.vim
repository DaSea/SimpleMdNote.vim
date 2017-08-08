let s:win_title = "snote"
let s:division_linenumber=0

" public function {{{
function! simplemdnote#new_note(type) abort "  {{{
    call s:checkCachePath(a:type)
    let notename = s:getNoteName()
    if strlen(notename)==0
        echohl Error | echo "Invalid name, Please inuput again!" | echohl None
        return
    endif

    if a:type==1
        " 生成草稿
        execute 'e ' . g:simplemdnote_draft_path . '/' . notename
    elseif a:type==2
        " 生成_posts文件夹的笔记
        execute 'e ' . g:simplemdnote_posts_path . '/' . notename
    else
        return
    endif
endfunction " }}}

function! simplemdnote#publicsh_note() abort "  {{{
    " 先判断当前文件文件是不是已经在posts里面，如果是不用理睬，如不是，则移到posts里面
    let fullpath = expand('%:p')
    let notename = expand('%:t')
    " 判断路径在posts里面还是drafts里面
    let fulldraftpath = expand(g:simplemdnote_draft_path)
    if stridx(fullpath, fulldraftpath) == -1
        echohl Error | echo "Has published!" | echohl None
        return
    endif

    " 草稿，需要移动: 先关闭已经打开的，如果移动成功后再打开
    if exists(':Bdelete')
        execute 'Bdelete'
    else
        execute 'bdelete'
    endif
    call system('mv '.fullpath . ' ' .g:simplemdnote_posts_path)
    if v:shell_error==0
        execute 'e '.g:simplemdnote_posts_path .'/'.notename
    else
        execute 'e '.g:simplemdnote_draft_path .'/'.notename
    endif
endfunction " }}}

function! simplemdnote#list_note() abort " {{{
    if !exists("*ex#window#open")
        echohl Error | echo "Please install ex-utility plugin!" | echohl None
        return
    endif

    if g:iswindows
        call ex#window#open(s:win_title, g:simplemdnote_win_size,
                    \ g:simplemdnote_win_pos, 0, 1,
                    \ function('simplemdnote#init_win_buffer'))
    else
        call ex#window#open(s:win_title, g:simplemdnote_win_size,
                    \ g:simplemdnote_win_pos, 0, 1,
                    \ function('simplemdnote#init_linux_buffer'))
    endif

endfunction " }}}

function! simplemdnote#init_win_buffer() abort " 初始化窗口里面的内容 {{{
    set filetype=snote
    set foldmethod=syntax

    " 清空缓冲区
    normal! ggdG

    " 先用python 进行查找文件
    if has("python3")==0
        echohl Error | echo "This plugin need python3 support!" | echohl None
        return
    endif

    " draft 列表
    call append(0, "## Drafts {")
    normal! dd
    call simplemdnote#py_fill_buffer(g:simplemdnote_draft_path)
    call append(line('$'), '}')

    " 保存drafts 与 posts的分割行号，便于打开文件
    let s:division_linenumber = line('$')

    " posts 列表
    call append(line('$'), "## Posts {")
    call simplemdnote#py_fill_buffer(g:simplemdnote_posts_path)
    call append(line('$'), '}')
endfunction " }}}

function! simplemdnote#py_fill_buffer(path) abort " 用python查找文件 {{{
python3 << EOF
import vim
import glob
cb = vim.current.buffer
path = vim.eval("a:path")
list = os.listdir(path)
for i in range(0, len(list)):
    fullpath = os.path.join(path, list[i])
    if os.path.isfile(fullpath):
        item = "    |-" + list[i]
        cb.append(item)
EOF
endfunction " }}}

function! simplemdnote#init_linux_buffer() abort " 初始化窗口里面的内容 {{{
    set filetype=snote
    set foldmethod=syntax

    " 清空缓冲区
    normal! ggdG

    " draft 列表
    let fulldraftpath = g:simplemdnote_draft_path . '/'
    call append(0, "## Drafts {")
    let filecmd = 'find ' . g:simplemdnote_draft_path . ' -maxdepth 1 -type f'
    let cmdret = system(filecmd)
    let s:draffiles = split(cmdret, '[\x0]')
    for s:sfile in s:draffiles
        call append(line('$')-1, '  |-' . substitute(s:sfile, fulldraftpath, "", ""))
    endfor
    call append(line('$')-1, '}')

    " 保存drafts 与 posts的分割行号，便于打开文件
    let s:division_linenumber = line('$')

    " posts 列表
    let fullpostspath = g:simplemdnote_posts_path . '/'
    call append(line('$'), "## Posts {")
    let filecmd1 = 'find ' . g:simplemdnote_posts_path . ' -maxdepth 1 -type f'
    let cmdret1 = system(filecmd1)
    let s:postfiles = split(cmdret1, '[\x0]')
    for s:sfile in s:postfiles
        call append(line('$'), '  |-' . substitute(s:sfile, fullpostspath, "", ""))
    endfor
    call append(line('$'), '}')
endfunction " }}}

function! simplemdnote#bind_mappings() abort " 按键绑定 {{{
    " Define <cr> action
    silent exec 'nnoremap <silent> <buffer> <CR> :call simplemdnote#select_item()<CR>'
    " Define exit action
    silent exec 'nnoremap <silent> <buffer> q :call simplemdnote#close_window()<CR>'
    " Define other action
endfunction " }}}

function! simplemdnote#close_window() abort "{{{
    let winnr = bufwinnr(s:win_title)
    if -1 != winnr
        " jump to the window
        exe winnr . 'wincmd w'
        " if this is not the only window, close it
        try
            close
        catch /E444:/
            echo 'Can not close the last window!'
        endtry

        doautocmd BufEnter
    endif
endfunction "}}}

function! simplemdnote#select_item() abort "{{{
    " Get context of current line
    let currline = line('.')
    let filename = getline('.')
    " call simplemdnote#close_window()
    call ex#window#goto_edit_window()

    let index = stridx(filename, '-') + 1
    let name = strpart(filename, index)
    if s:division_linenumber < currline
        let fullpath = g:simplemdnote_posts_path . '/' . name
        execute ' silent edit ' . escape(fullpath, ' ')
    else
        let fullpath = g:simplemdnote_draft_path . '/' . name
        execute ' silent edit ' . escape(fullpath, ' ')
    endif
endfunction "}}}
" }}}
"
" private function{{{
function! s:getNoteName() abort "  {{{
    call inputsave()
    let notename = input("Please enter your new note name:")
    call inputrestore()
    return notename
endfunction " }}}

function! s:checkCachePath(type) abort "  {{{
    let path=fnamemodify(expand(g:simplemdnote_posts_path), ':p')
    if a:type==1
        let path = fnamemodify(expand(g:simplemdnote_draft_path), ':p')
    endif
    if !isdirectory(path)
        call mkdir(path, 'p')
    endif
endfunction " }}}
" }}}
