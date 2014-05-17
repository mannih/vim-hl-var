" Drop this into .vim/plugin.vawa.vim
" if you already have vawa.vim, rename appropriately
" automatically highlights variables under cursor, allowing you to easily see the data flow.

" Vawa Plugin for VIM > 7.3 version 1.00
" Maintainer:  Sandeep.c.r<sandeepcr2@gmail.com>
" Hacked for Perl by Curtis "Ovid" Poe <ovid@allaroundtheworld.fr>
"
" Copyright (c) 2014 Sandeep.C.R <sandeepcr2@gmail.com>
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

function! s:vawa()
    if (exists("s:current_match"))
        call matchdelete(s:current_match)
        unlet s:current_match
    endif

    let s:temp         = getpos('.')
    let s:current_col  = s:temp[2]
    let s:current_line = s:temp[1]
    let s:temp         = searchpos('[>$@%*&]','bcnW')
    let s:sigil_line   = s:temp[0]
    let s:sigil_col    = s:temp[1]
    if (s:sigil_line != s:current_line)
        return
    endif
    let s:temp = getbufline(bufnr('%'),line('.'))
    let s:varend = match(s:temp[0], '[^a-zA-Z0-9_\x7f-\xff]\|\n', s:sigil_col) + 1
    let s:space_col = s:varend
    if (s:varend == 0 || (s:space_col > s:sigil_col && s:space_col < s:current_col))
        return
    endif
    let s:current_char = s:temp[0][s:current_col-1]
    if (s:current_char == '>' || s:current_char == '-')
        return
    endif

    if (exists("g:hlvarhl"))
        exe "highlight VarHl  " . g:hlvarhl
    else
        highlight VarHl  ctermbg=black ctermfg=red guifg=#ff0000 guibg=#000000 ctermfg=LightRed gui=bold
    endif

    let s:str = strpart(s:temp[0], s:sigil_col - 1, s:varend - s:sigil_col)
    let s:prefix = ''
    if (s:str == '$' || s:str == '&' || s:str == '*')
        return
    endif

    if (exists("g:hlvarcurrent") && g:hlvarcurrent == 1)
        let s:lineab = s:current_line - 1
        let s:linebe = s:current_line + 1
        let s:colbf  = s:sigil_col + 1
        let s:prefix = '\(\%>' . s:lineab . 'l.\%<' . s:linebe . 'l.\%>' . s:colbf . 'c\)\@!'
    endif

    let s:match = s:prefix
    if (strpart(s:str, 0, 1) == '>')
        let s:str = strpart(s:str, 1)
        let s:match = s:match . '>\@<='
    endif
    let s:match = s:match . s:str . '\n\{-\}\(\([^a-zA-Z0-9_\x7f-\xff]\)\|$\)\@='
    let s:current_match = matchadd('VarHl', s:match)
endfunction

if (!exists("g:vawanoauto") || g:vawanoauto == 1)
    augroup HighlightVar
        autocmd!
        au CursorHold  *.pl call <sid>vawa()
        au CursorHoldi *.pl call <sid>vawa()
        au CursorHold  *.pm call <sid>vawa()
        au CursorHoldi *.pm call <sid>vawa()
        au CursorHold  *.t  call <sid>vawa()
        au CursorHoldi *.t  call <sid>vawa()
    augroup END
endif

command! Vawa :call <sid>vawa()
