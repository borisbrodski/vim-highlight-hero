" highlight-hero.vim - Highlight stuff
" Maintainer:   Boris Brodski <brodsky_boris@yahoo.com>
" Version:      0.2

if exists("g:loaded_vim_highligh_hero") || v:version < 800
  finish
endif
let g:loaded_vim_highligh_hero = 1

" Global configuration
let g:highlight_hero_smart_spaces = get(g:, 'highlight_hero_smart_spaces', 1)

let g:highlight_hero_ignorecase_strong = get(g:, 'highlight_hero_ignorecase_strong', '&&')
let g:highlight_hero_ignorecase_weak = get(g:, 'highlight_hero_ignorecase_weak', '1')

let g:highlight_hero_debug = get(g:, 'highlight_hero_debug', 0)
let g:highlight_hero_match_id_offset = get(g:, 'highlight_hero_match_id_offset', 1001)
let g:highlight_hero_match_id_current = get(g:, 'highlight_hero_match_id_current', 1000)

let s:highlight_cmds_dark = []
let s:highlight_cmds_light = []

fun! s:get_case_option(is_strong)
  if a:is_strong
    let l:value = get(b:, 'highlight_hero_ignorecase_strong', '')
  else
    let l:value = get(b:, 'highlight_hero_ignorecase_weak', '')
  endif
  if l:value == ''
    if a:is_strong
      let l:value = g:highlight_hero_ignorecase_strong
    else
      let l:value = g:highlight_hero_ignorecase_weak
    endif
  endif
  if index([0, '0', 1, '1', '&', '&&'], l:value) == -1
    if a:is_strong
      let l:var_name = 'g:highlight_hero_ignorecase_strong'
    else
      let l:var_name = 'g:highlight_hero_ignorecase_weak'
    endif
    throw "'" . l:value . "' - invalid value for " . l:var_name . ". Only 0, 1 or & are allowed"
  endif
  if ('' . l:value) == '&'
    let l:value = &l:ignorecase
  elseif ('' . l:value) == '&&'
    let l:value = ! &l:smartcase
  endif
  if str2nr(l:value)
    return "\\c"
  endif
  return "\\C"
endfun

fun! s:add_highlight(highlight_dark_cmd, ...) abort
  let l:highlight_light_cmd = a:0 >= 1 ? a:1 : a:highlight_dark_cmd
  if strlen(a:highlight_dark_cmd) > 0
    call add(s:highlight_cmds_dark, a:highlight_dark_cmd)
  endif
  if strlen(l:highlight_light_cmd)
    call add(s:highlight_cmds_light, l:highlight_light_cmd)
  endif
endfun

fun! s:set_highlight() abort
  if &background == 'dark'
    for cmd in s:highlight_cmds_dark
      execute cmd
    endfor
  else
    for cmd in s:highlight_cmds_light
      execute cmd
    endfor
  endif
endfun

" Return visually selected text preserving vim view and registers. 
function! s:get_visual_selection() abort
  let l:winview = winsaveview()

  let l:quot_save = getreg('"')
  let l:quot_save_type = getregtype('"')

  let l:zero_save = getreg("0")
  let l:zero_save_type = getregtype("0")
  try
    normal! ygv
    return @"
  finally
    call setreg("0", l:zero_save, l:zero_save_type)
    call setreg('"', l:quot_save, l:quot_save_type)
    call winrestview(l:winview)
  endtry
endfunction

function! s:match_spaces_smart(pattern) abort
  if !g:highlight_hero_smart_spaces == 1
    return a:pattern
  endif
  if match(a:pattern, "\\n") != -1

    let l:pattern = substitute(a:pattern, '\v^\s*',       '\\s\\*',    '')
    let l:pattern = substitute(l:pattern, '\v\s*\n',      '\\s\\*\n',  'g')
    let l:pattern = substitute(l:pattern, '\v\n\s*\ze\S', '\\n\\s\\*', 'g')
    let l:pattern = substitute(l:pattern, '\v\n$',        '\\$',       '')
    return l:pattern
  endif
  return a:pattern
endfunction

fun! s:get_word_under_cursor()
  let l:word = expand('<cword>')
  let l:char = strcharpart(strpart(getline('.'), col('.') - 1), 0, 1)
  if stridx(l:word, l:char) == -1
    return ""
  endif
  return l:word
endfun

function! s:highlight_current() abort
  if !get(b:, 'highlight_current_on', 0)
    return
  endif
  let l:prefix = s:get_case_option(1)
  let l:match_word = 0
  if mode() ==? "v"
    let l:text = s:get_visual_selection()
  elseif mode() ==# "n"
    let l:text = s:get_word_under_cursor()
    let l:match_word = 1
  else
    let l:text = ''
  endif
  if len(l:text) > 0
    let l:pattern = s:match_spaces_smart(escape(l:text, '/\'))
    if l:match_word
      let l:pattern = '\<' . l:pattern . '\>'
    endif
    let l:pattern = '\V' . l:prefix . l:pattern
    if g:highlight_hero_debug == 1
      let @a = l:pattern
    endif
    call s:highlight_off(g:highlight_hero_match_id_current)
    call matchadd("HighlightHeroCurrent", l:pattern, 100, g:highlight_hero_match_id_current)
  else
    call s:highlight_off(g:highlight_hero_match_id_current)
  endif
endfunction

fun! s:highlight_current_timer(id) abort
  let b:highlight_old_mode = get(b:, 'highlight_old_mode', '')
  let b:visual_start = get(b:, 'visual_start', [0,0,0,0])
  let b:visual_end = get(b:, 'visual_end', [0,0,0,0])
  if b:highlight_old_mode !=# mode()
        \ || b:visual_start != getpos("'<'")
        \ || b:visual_end != getpos("'>'")
    silent call s:highlight_current()
    let b:highlight_old_mode = mode()
    let b:visual_start = getpos("'<'")
    let b:visual_end = getpos("'>'")
  endif
endfun

function! s:highlight_current_toggle() abort
  let b:highlight_current_on = !get(b:, 'highlight_current_on', 0)
  if b:highlight_current_on
    let b:highlight_timer_id = timer_start(100, function('<SID>highlight_current_timer'), {'repeat': -1})
    call s:highlight_current()
  else
    call timer_stop(b:highlight_timer_id)
    call s:highlight_off(g:highlight_hero_match_id_current)
  endif
endfunction

augroup HIGHLIGHT_HERO_GROUP
  autocmd!
  autocmd CursorMoved * silent call <SID>highlight_current()
augroup END

function! s:highlight_regex(index, pattern)
  call s:highlight_off(g:highlight_hero_match_id_offset + a:index)
  if g:highlight_hero_debug == 1
    let @a = a:pattern
  endif
  call matchadd("HighlightHero" . a:index, a:pattern, a:index, g:highlight_hero_match_id_offset + a:index)
endfunction

function! s:highlight_off_cmd(index, bang)
  if a:bang == '!'
    call s:highlight_off_all()
  else
    call s:highlight_off(g:highlight_hero_match_id_offset + a:index)
  endif
endfunction

function! s:highlight_off(index)
  try
    call matchdelete(a:index)
  catch /^Vim\%((\a\+)\)\=:E803/
  endtry
endfunction

function! s:highlight_off_all()
  for i in range(0, 9)
    call s:highlight_off(g:highlight_hero_match_id_offset + i)
  endfor
endfunction

fun! s:highlight(group_id, bang, visual, text)
  if a:group_id > 9
    echo "Please, use groups 0..9"
    return
  endif
  if len(a:text) > 0
    let l:text = a:text
  else
    if a:visual
      normal gv
      let l:text = s:get_visual_selection()
    else
      let l:text = s:get_word_under_cursor()
    endif
  endif
  if len(l:text) > 0
    let l:pattern = s:match_spaces_smart(escape(l:text, '/\'))
    let l:case = s:get_case_option(a:bang != '!')
    if a:bang == '!'
      call s:highlight_regex(a:group_id, '\V' . l:case . l:text)
    else
      call s:highlight_regex(a:group_id, '\V' . l:case . '\<' . l:text . '\>')
    endif
  endif
endfun

fun! s:highlight_hero_print()
  let l:original_mode = &background
  let l:first = 1
  for l:mode in ['dark', 'light']
    let &background = l:mode
    redraw
    call s:set_highlight()

    echohl None
    echo "All colors in '" . l:mode . "' mode:"

    echohl HighlightHeroCurrent
    echo "HighlightHeroCurrent  -  Color GROUP auto / under cursor"
    for l:i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      execute "echohl HighlightHero" . l:i
      echo "HighlightHero" . l:i . "  -  Color GROUP " . l:i
    endfor
    echohl None

    call input("Press ENTER to continue")
  endfor
  echohl None
  let &background = l:original_mode
  redraw
endfun


noremap <unique> <silent> <Plug>(HighlightHeroToggle)     :<C-U>call <SID>highlight_current_toggle()<cr>

noremap <unique> <silent> <Plug>(HighlightHero)           :<C-U>call <SID>highlight(v:count, '', 0, '')<CR>
noremap <unique> <silent> <Plug>(HighlightHeroVisual)     :<C-U>call <SID>highlight(v:count, '', 1, '')<CR><ESC>
noremap <unique> <silent> <Plug>(HighlightHeroBang)       :<C-U>call <SID>highlight(v:count, '!', 0, '')<CR>
noremap <unique> <silent> <Plug>(HighlightHeroVisualBang) :<C-U>call <SID>highlight(v:count, '!', 1, '')<CR><ESC>
noremap <unique> <silent> <Plug>(HighlightHeroOff)        :<C-U>call <SID>highlight_off(g:highlight_hero_match_id_offset + v:count)<CR>
noremap <unique> <silent> <Plug>(HighlightHeroOffAll)     :<C-U>call <SID>highlight_off_all()<CR>


command! -bar                         HighlightHeroAuto   call s:highlight_current_toggle()
command! -bar                         HHauto              call s:highlight_current_toggle()
command! -bar -bang -count=0 -nargs=? HighlightHero       call s:highlight(<count>, "<bang>", 0, "<args>")
command! -bar -bang -count=0 -nargs=? HH                  call s:highlight(<count>, "<bang>", 0, "<args>")
command! -bar -bang -count=0 -nargs=0 HighlightHeroOff    call s:highlight_off_cmd(v:count, "<bang>")
command! -bar -bang -count=0 -nargs=0 HHoff               call s:highlight_off_cmd(v:count, "<bang>")
command!                              HighlightHeroPrint  call s:highlight_hero_print()
command!                              HHprint             call s:highlight_hero_print()


"
" Toggle highlight current word
nmap <leader>ht <Plug>(HighlightHeroToggle)

" HighlightHero
nmap <leader>hh <Plug>(HighlightHero)
vmap <leader>hh <Plug>(HighlightHeroVisual)

" HighlightHero
nmap <leader>HH <Plug>(HighlightHeroBang)
vmap <leader>HH <Plug>(HighlightHeroVisualBang)

nmap <leader>ho <Plug>(HighlightHeroOff)
nmap <leader>hO <Plug>(HighlightHeroOffAll)


" Define highlighting colors
call s:add_highlight('highlight HighlightHeroCurrent ctermbg=8 guibg=#08414f',
                   \ 'highlight HighlightHeroCurrent ctermbg=8 guibg=LightGrey')

call s:add_highlight('highlight HighlightHero0 ctermbg=195 guibg=#ff2c4b',
                   \ 'highlight HighlightHero0 ctermfg=0 ctermbg=7 guibg=#AAAAAA')

call s:add_highlight('highlight HighlightHero1 ctermbg=blue guibg=blue',
                   \ 'highlight HighlightHero1 term=reverse gui=reverse guifg=#268bd2')

call s:add_highlight('highlight HighlightHero2 term=bold,reverse cterm=bold ctermfg=0 ctermbg=10 gui=bold guifg=Black guibg=LightGreen')
call s:add_highlight('highlight HighlightHero3 ctermbg=darkgreen guibg=darkgreen')
call s:add_highlight('highlight HighlightHero4 term=reverse ctermfg=0 ctermbg=14 gui=reverse guifg=#eee8d5 guibg=#073642')
call s:add_highlight('highlight HighlightHero5 term=reverse gui=reverse guifg=#586e75')
call s:add_highlight('highlight HighlightHero6 term=bold gui=bold guifg=#93a1a1 guibg=#002b36')
call s:add_highlight('highlight HighlightHero7 term=standout gui=standout guifg=#6c71c4')
call s:add_highlight('highlight HighlightHero8 term=bold cterm=bold ctermfg=241 ctermbg=136 gui=bold guifg=#282828 guibg=#b16286')
call s:add_highlight('highlight HighlightHero9 term=bold ctermfg=14 gui=bold,underline guifg=Yellow')

call s:set_highlight()

" vim: set ts=2 sts=2 sw=2 expandtab:
