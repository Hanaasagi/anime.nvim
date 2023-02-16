<h1 align="center"> anime.nvim 🪶 </h1>

<p align="center"> 𝓢𝓶𝓪𝓵𝓵 𝓐𝓷𝓲𝓶𝓮 𝓦𝓲𝓭𝓰𝓮𝓽 𝓕𝓸𝓻 𝓝𝓮𝓸𝓿𝓲𝓶 </p>

<div align="center">
  <video src="https://user-images.githubusercontent.com/9482395/219360571-e4334893-38d6-443c-818a-698174ad6d2c.mp4
" width=400/></video>
</div>
<p align="center">ᴾˡᵉᵃˢᵉ ˢᵉᵉ ᵗʰᵉ ᵈʳᵃᵍᵒⁿ ᵐᵃᶦᵈ ᵃᵗ ᵗʰᵉ ᵗᵒᵖʳᶦᵍʰᵗ ᶜᵒʳⁿᵉʳ</p>
<br>

**Warning: This plugin is using [Sixel](vector) graphics. So your terminal must support Sixel graphics.**

# Install

## [Lazy](https://github.com/folke/lazy.nvim)

```Lua
require("lazy").setup(
  {
    "Hanaasagi/anime.nvim",
    config=function()
      require('anime').setup({})
    end
  },
  opt
)
```

# Configuration

```Lua
require('anime').setup({
  -- Anime data path
  anime_dir = "/home/xx/yy/",
  -- Where to start rendering
  -- `"topright"`, `"bottomright"` or a table `{col=0, row=0}`
  position = "bottomright",
  -- Control frame speed
  fps = {
    -- Dsipaly 16 frames per second
    base = 16,
    -- When your typing speed exceeds the threshold,
    -- it will enter fast mode, otherwise it will enter slow mode
    slow = 8,
    fast = 24,
    -- Or you can set a function that return fps
    -- If you set `handler`, `base`/`slow`/`fast` will take no effect
    -- handler = function() return 16 end
  },
})
```

# Generate anime files

A simple Bash script to convert gif to sixel format.
Copy and execute `bash <script_name> <your gif absolute path>`.
A `data` directory will be created in your current work directory.

```Bash
#!/bin/bash
set -e

GIF_PATH=$1
TARGET_PATH="./data"

if [ -d "$TARGET_PATH" ];
then
    echo "$TARGET_PATH directory exists."
    exit 1
fi

# Create target dir and copy source file
mkdir $TARGET_PATH
cd $TARGET_PATH
cp $GIF_PATH "./anime.gif"

# Split gif to png
convert ./anime.gif anime.png
rm ./anime.gif

# Generate for every file
for file in *.png; do
    img2sixel < $file > "${file%.*}.sixel"
    rm $file
done
```

# SIXEL compatible terminals

- [alacritty-sixel](https://github.com/microo8/alacritty-sixel)
- [wezterm](https://wezfurlong.org/wezterm/)
- xterm, run with `-ti vt340` parameter

# Incompatible

- tmux, see [tmux#1613](https://github.com/tmux/tmux/issues/1613)
- kitty, it has its own image protocol

# License

BSD 3-Clause License. Copyright (c) 2023, 秋葉.
