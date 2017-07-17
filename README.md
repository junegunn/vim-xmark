vim-xmark
=========

Markdown preview on OS X. Uses AppleScript to resize the windows.

Vim 8 is required for asynchronous rendering.

Screenshot
----------

### `Xmark>` on iTerm2

![](https://cloud.githubusercontent.com/assets/700826/6095309/75bd9c24-af99-11e4-8624-6f709a68a731.png)

### `Xmark<` on MacVim

![](https://cloud.githubusercontent.com/assets/700826/6095308/751f5d84-af99-11e4-8902-c60805fa1ea6.png)

Prerequisites
-------------

Xmark requires [Homebrew][b] and [Google Chrome][c].

Installation
------------

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'junegunn/vim-xmark', { 'do': 'make' }
```

Usage
-----

`:Xmark` command is added for Markdown files. After running the command, the
rendered content will be reloaded on the browser every time you save the file.

```vim
" Does not resize nor move the windows
:Xmark

" Vim on the left, browser on the right
:Xmark>

" On the left
:Xmark<

" On the top
:Xmark+

" On the bottom
:Xmark-

" Reload the page and resize the windows by saving it
:w

" Turn off Xmark
:Xmark!
```

If you see an error (e.g. `osascript is not allowed assistive access`), make
sure that your terminal emulator (or MacVim) is in the list in `System
Preferences` -> `Security & Privacy` -> `Privacy` -> `Accessibility`. (You can
drag and drop the application icon to the list.)

Known issues
------------

- Resizing does not work if the terminal emulator is in fullscreen mode

Acknowledgment
--------------

- [GitHub style CSS][css] is based on [github-markdown-css][gmc] by [Sindre Sorhus][s] licensed under MIT
- Previous version of CSS was based on: https://gist.github.com/killercup/5917178

License
-------

MIT

[b]: http://brew.sh/
[p]: http://johnmacfarlane.net/pandoc/
[c]: http://www.google.com/chrome/
[gmc]: https://github.com/sindresorhus/github-markdown-css
[s]: https://github.com/sindresorhus
[css]: plugin/css/github-markdown.css
