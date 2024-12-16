**FOR NeoVim SEE**: https://github.com/borisbrodski/neonvim-highlight-hero

# vim-highlight-hero

The highlight-hero highlights multiple words and visual selections. On the fly and statically.
It is particularly useful for

- spotting typos
- finding variable usages
- resolving merge conflicts (see `:help highlight-hero-merge-conflicts`)

Quick start  >>  `:HHauto` or `:HH`, `:1HH!`, ...

![Highlight-Hero Screenshot](https://github.com/borisbrodski/vim-highlight-hero/raw/master/screenshot.png)


## Installation

<details>
<summary>Pathogen</summary>

1. In the terminal,
    ```bash
    git clone https://github.com/borisbrodski/vim-highlight-hero ~/.vim/bundle/vim-highlight-hero
    ```
1. In `vimrc`,
    ```vim
    call pathogen#infect()
    syntax on
    filetype plugin indent on
    ```
1. Restart Vim, and run `:helptags ~/.vim/bundle/vim-highlight-hero/doc/` or `:Helptags`.
</details>

<details>
  <summary>Vundle</summary>

1. Add the following text to your `vimrc`.
    ```vim
    call vundle#begin()
      Plugin 'borisbrodski/vim-highlight-hero'
    call vundle#end()
    ```
1. Restart Vim, and run the `:PluginInstall` statement to install your plugins.
</details>

<details>
  <summary>Vim-Plug</summary>

1. Add the following text to your `vimrc`.
```vim
call plug#begin()
  Plug 'borisbrodski/vim-highlight-hero'
call plug#end()
```
1. Restart Vim, and run the `:PlugInstall` statement to install your plugins.
</details>

<details>
  <summary>Dein</summary>

1. Add the following text to your `vimrc`.
    ```vim
    call dein#begin()
      call dein#add('borisbrodski/vim-highlight-hero')
    call dein#end()
    ```
1. Restart Vim, and run the `:call dein#install()` statement to install your plugins.
</details>

<details>
<summary>Vim 8+ packages</summary>

From Vim 8+ you can use its own built-in package management. See `:help packages` for details.

Execute the following in your console:

```bash
git clone https://github.com/borisbrodski/vim-highlight-hero ~/.vim/pack/vendor/start/vim-highlight-hero
vim -u NONE -c "helptags ~/.vim/pack/vendor/start/vim-highlight-hero/doc" -c q
```
</details>

## Getting started

```vim
" Turn on auto-highlighing! (Navigate around to see the impact)
:HHauto
```

```vim
" Highlight current word with color 0
:HH
```

```vim
" Highlight another word with color 1
:1HH
```

```vim
" Highlight "String args" color 2
:2HH String args
```

```vim
" Turn all highlights OFF
:HHoff!
```

## Documentation

```vim
" Open comprehensive docs
:help highlight-hero 
```

## Frequently Asked Questions

### Why are the default colors so weird?

Well, getting decent foreground and background colors is the most challenging part.
The foreground and the background colors should work well for

- different color schemes
- different terminals & UIs
- for color-blind people

Please, help me with it and contribute your colors!

1. Call `:HHprint` to see all the colors
1. Go to the bottom of `plugin/highlighter.vim`
1. Enter your color values for both dark and light modes
1. Create a push request.

Defining colors in the `plugin/highlighter.vim`:

```vim
call s:add_highlight('highlight HighlightHeroCurrent <<<DARK>>>',
                   \ 'highlight HighlightHeroCurrent <<<LIGHT>>>')
```

TODO: Support different color configurations and providing simple commands to change individual colors.

## License

Copyright (c) Boris Brodski.
Distributed under the same terms as Vim itself.
See `:help license`.

