vim-xmark
=========

Markdown preview on OS X. Uses AppleScript to resize the windows.

Prerequisites
-------------

Xmark requires [pandoc][p] and [Google Chrome][c].

```
brew install pandoc
```

Installation
------------

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'junegunn/vim-xmark'
```

Usage
-----

`:Xmark` command is added for Markdown files. After running the command, the
rendered content will be loaded on the browser every time you save the file.

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

If you see `osascript is not allowed assistive access` message, add your
terminal emulator to the list in `System Preferences` -> `Security & Privacy`
-> `Privacy` -> `Accessibility`. (You can drag and drop the application icon
to the list.)

Known issues
------------

- Resizing may not work if the terminal emulator is in fullscreen mode
- Currently only supports Chrome
- May have issues with multiple displays

Acknowledgment
--------------

CSS is based on: https://gist.github.com/killercup/5917178

License
-------

[MIT](http://opensource.org/licenses/MIT)

[p]: http://johnmacfarlane.net/pandoc/
[c]: http://www.google.com/chrome/
