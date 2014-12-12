" Copyright (c) 2014 Junegunn Choi
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if exists('g:loaded_xmark')
  finish
endif
let g:loaded_xmark = 1

let s:cpo_save = &cpo
set cpo&vim

let s:dir = expand('<sfile>:p:h')
let s:files = {
\ 'css':    s:dir . '/css/pandoc.css',
\ 'update': s:dir . '/applescript/update.scpt',
\ 'close':  s:dir . '/applescript/close.scpt',
\ 'xsize':  s:dir . '/ext/xsize'
\ }
let s:app = 'Google Chrome'
let s:tmp = {}

function! s:init_templates()
  if !exists('s:template')
    let s:template = {}
    let s:template.update = join(
    \ [ 'pandoc -f markdown_github-hard_line_breaks -t html5 -s -M "title:{{ title }} / xmark" -H "{{ css }}" "{{ src }}" > "{{ out }}" &&',
      \ 'osascript -e "$(cat << EOF',
      \ join(readfile(s:files.update), "\n"),
      \ 'EOF', ')"' ], "\n")
    let s:template.close = join(
    \ [ 'osascript -e "$(cat << EOF',
      \ join(readfile(s:files.close), "\n"),
      \ 'EOF', ')"' ], "\n")
  endif
endfunction

function! s:warn(msg)
  echohl WarningMsg
  echom a:msg
  echohl None
endfunction

function! s:tempname()
  if filewritable(expand('%:p:h'))
    return fnamemodify('.xmark.'.expand('%:t').'.html', ':p')
  else
    return tempname() . '.html'
  endif
endfunction

function! s:xmark(resize, bang)
  let grp = '_xmark_buffer_' . bufnr('%') . '_'
  if a:bang
    execute 'augroup' grp
      autocmd!
    augroup END
    execute 'augroup!' grp
    silent! call system(s:render('close', { 'app': s:app, 'out': s:tmp[bufnr('%')] }))
    return
  endif

  if !executable('osascript')
    call s:warn('osascript is not found')
    return
  endif

  if !executable('pandoc')
    if executable('brew')
      call s:warn('pandoc is not found. Installing it with Homebrew ..')
      sleep 1
      silent !brew install pandoc
      redraw!
      if v:shell_error
        call s:warn('Failed to install pandoc with Homebrew')
        return
      endif
    else
      call s:warn('pandoc is not found. Install Homebrew and try `brew install pandoc`.')
      return
    endif
  endif

  if !executable(s:files.xsize)
    if executable('make')
      call s:warn('Building required executable ..')
      sleep 1
      cd s:dir
      silent !make
      redraw!
      cd -
      if v:shell_error
        call s:warn('Build failure')
        return
      endif
    else
      call s:warn('Try `make` to build the required executable')
      return
    endif
  endif

  call s:init_templates()

  if !has_key(s:tmp, bufnr('%'))
    let s:tmp[bufnr('%')] = s:tempname()
  endif

  execute 'augroup' grp
    autocmd!
    " BufUnload is triggered twice for some reason so we simply put silent!
    autocmd BufUnload    <buffer> silent! call delete(remove(s:tmp, expand('<abuf>')))
    autocmd BufWritePost <buffer> call s:reload()
  augroup END
  let b:xmark_resize = a:resize
endfunction

function! s:render(template, vars)
  let output = s:template[a:template]
  for [k, v] in items(a:vars)
    let output = substitute(output, '{{ *'.k.' *}}', escape(v, '"'."'"), 'g')
  endfor
  return output
endfunction

function! s:reload()
  if !empty(b:xmark_resize)
    silent! set nofullscreen
  endif

  let output = substitute(system(s:files.xsize), '\n$', '', '')
  if v:shell_error
    echoerr output
    return
  endif

  let [x, y, w, h] = split(output)[0:3]
  let script = s:render('update', {
        \ 'app':    s:app,
        \ 'title':  expand('%:t'),
        \ 'src':    expand('%:p'),
        \ 'out':    s:tmp[bufnr('%')],
        \ 'resize': b:xmark_resize,
        \ 'x':      x,
        \ 'y':      y,
        \ 'w':      w,
        \ 'h':      h,
        \ 'css':    s:files.css })
  redraw
  echon 'Rendering the page'
  let output = system(script)
  redraw
  if v:shell_error
    echo 'Failed to reload the page: ' . output
  else
    echo 'Reloaded the page'
  endif
endfunction

augroup _xmark_filetype_
  autocmd!
  autocmd FileType mkd,markdown command! -buffer -bar -bang -nargs=? Xmark call s:xmark(<q-args>, <bang>0)
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save

