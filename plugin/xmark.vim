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
\ 'css':    s:dir . '/css/github-markdown.css',
\ 'header': s:dir . '/header/header.html',
\ 'update': s:dir . '/applescript/update.scpt',
\ 'resize': s:dir . '/applescript/resize.scpt',
\ 'close':  s:dir . '/applescript/close.scpt',
\ 'access': s:dir . '/applescript/accessibility.scpt',
\ 'xsize':  s:dir . '/ext/xsize'
\ }
let s:app = 'Google Chrome'
let s:tmp = {}

function! s:osawrap(...)
  let lines = ['osascript -e "$(cat << EOF']
  call extend(lines, map(copy(a:000), 'join(readfile(v:val), "\n")'))
  call extend(lines, ['EOF', ')"'])
  return join(lines, "\n")
endfunction

function! s:init_templates()
  if !exists('s:template')
    let pandoc_prefix = 'pandoc -f markdown_github-hard_line_breaks -t html5 -s -M "title:{{ title }} / xmark" -H "{{ css }}" -H "{{ header }}" "{{ src }}" > "{{ out }}" &&'
    let s:template = {
        \ 'refresh': pandoc_prefix . s:osawrap(s:files.update, s:files.resize),
        \ 'update':  pandoc_prefix . s:osawrap(s:files.update),
        \ 'close':   s:osawrap(s:files.close) }
  endif
endfunction

function! s:warn(msg)
  echohl WarningMsg
  echom a:msg
  echohl None
endfunction

function! s:tempname()
  if filewritable(expand('%:p:h'))
    return expand('%:p:h').'/.xmark.'.expand('%:t').'.html'
  else
    return tempname() . '.html'
  endif
endfunction

function! s:grp(buf)
  return '_xmark_buffer_' . a:buf . '_'
endfunction

if has('python')
  function! s:urlencode(input)
    python << EOF
import vim
import urllib
vim.command('return "{0}"'.format(urllib.quote(vim.eval('a:input'), safe = ':/')))
EOF
  endfunction
elseif has('ruby')
  function! s:urlencode(input)
    ruby << EOF
    require 'uri'
    VIM.command %[return "#{URI.encode VIM.evaluate('a:input')}"]
EOF
  endfunction
else
  function! s:urlencode(input)
    return substitute(a:input, '[^a-zA-Z0-9_./-]', '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  endfunction
endif

function! s:xmark(resize, bang)
  let grp = s:grp(bufnr('%'))
  if a:bang
    execute 'augroup' grp
      autocmd!
    augroup END
    execute 'augroup!' grp
    if has_key(s:tmp, bufnr('%'))
      let tmp = remove(s:tmp, bufnr('%'))
      silent! call system(s:render('close', { 'app': s:app, 'outurl': s:urlencode(tmp) }))
      silent! call delete(tmp)
    endif
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
      execute 'cd' s:dir.'/ext'
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
          \| silent! execute 'autocmd!' s:grp(expand('<abuf>'))
    autocmd BufWritePost <buffer> call s:queue(0, 1)
    if has('job') && has('timers')
      autocmd TextChanged,TextChangedI <buffer> call s:queue(250, 0)
    endif
  augroup END
  let b:xmark_resize = a:resize

  if s:update_screen_size()
    call s:reload(1)
  endif
endfunction

function! s:queue(timeout, verbose)
  if exists('s:timer')
    call timer_stop(s:timer)
  endif
  let s:timer = timer_start(a:timeout, {_ -> s:reload(a:verbose)})
endfunction

function! s:render(template, vars)
  let output = s:template[a:template]
  for [k, v] in items(a:vars)
    let output = substitute(output, '{{ *'.k.' *}}', escape(v, '"'."'"), 'g')
  endfor
  return output
endfunction

function! s:exit_cb(exit, verbose, temps)
  if a:verbose
    redraw
  endif

  if a:exit
    if a:verbose
      call s:warn(printf('Failed to reload the page (exit status: %d / script: %s)',
            \ a:exit, a:temps.script))
    endif
  else
    if a:verbose
      echo 'Reloaded the page'
    endif
    for temp in values(a:temps)
      if filereadable(temp)
        call delete(temp)
      endif
    endfor
  endif
endfunction

function! s:update_screen_size()
  let output = substitute(system(s:files.xsize), '\n$', '', '')
  if v:shell_error
    call s:warn(output)
    if stridx(output, '(-1719)') >= 0
      call system('osascript '.s:files.access)
    endif
    unlet! s:screen_size
    return 0
  endif
  let s:screen_size = split(output)
  return 1
endfunction

function! s:reload(verbose)
  unlet! s:timer

  if !empty(b:xmark_resize)
    silent! set nofullscreen
  endif

  if !exists('s:screen_size') && !s:update_screen_size()
    return
  endif
  let [x, y, w, h] = s:screen_size
  let path = s:tmp[bufnr('%')]
  let temps = { 'script': tempname() }
  let src = expand('%:p')
  if &modified
    let temps.src = tempname()
    call writefile(getline(1, '$'), temps.src)
    let src = temps.src
  endif
  let script = s:render(a:verbose ? 'refresh' : 'update', {
        \ 'app':    s:app,
        \ 'title':  expand('%:t'),
        \ 'src':    src,
        \ 'out':    path,
        \ 'outurl': s:urlencode(path),
        \ 'resize': b:xmark_resize,
        \ 'bg':     a:verbose ? '' : '-- ',
        \ 'x':      x,
        \ 'y':      y,
        \ 'w':      w,
        \ 'h':      h,
        \ 'css':    s:files.css,
        \ 'header':    s:files.header })

  if a:verbose
    redraw
    echon 'Rendering the page'
  endif

  call writefile(split(script, "\n"), temps.script)
  if has('job')
    call job_start('sh '.temps.script,
          \ {'exit_cb': {_job, exit -> s:exit_cb(exit, a:verbose, temps)}})
  else
    let output = system('sh '.temps.script)
    call s:exit_cb(v:shell_error, 1, temps)
  endif
endfunction

augroup _xmark_filetype_
  autocmd!
  autocmd FileType mkd,markdown command! -buffer -bar -bang -nargs=? Xmark call s:xmark(<q-args>, <bang>0)
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save

