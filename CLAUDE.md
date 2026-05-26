# Yi Jing — Hexagram Identifier

## Run
```
wish hexagrams.tcl
# or
./hexagrams.tcl
```

## Files
| File | Role |
|---|---|
| `hexagrams.tcl` | Main application (single file) |
| `hexagrams.fr.creole` | Hexagram data in French (creole markup) |
| `hexagrams.creole` | Hexagram data in English (creole markup) |
| `hexagrams.zh.creole` | Hexagram data in Chinese — simplified, title includes Chinese name (creole markup) |

## Architecture

**Single-file Tcl/Tk app.** All logic and UI live in `hexagrams.tcl`.

### Hexagram lookup
64-entry flat list `hex_table`, indexed by `upper_trigram * 8 + lower_trigram`.  
Trigram value = `l1 + l2*2 + l3*4` (yang=1, lines bottom→top).  
Codes: Kun=0, Zhen=1, Kan=2, Dui=3, Gen=4, Li=5, Xun=6, Qian=7.

### State
- `array lines(1..6)` — current line states: 1=yang, 0=yin
- `array mutations(1..6)` — changing-line markers: 1=marked, 0=none (independent of `lines`)
- `::current_theme` — active theme name
- `lang` — active language ("fr", "en", or "zh")
- `array hexinfo(n,title|bold|italic)` — parsed creole data per hexagram

### Layout
```
.topbar  (Yi Jing label + ☰ hamburger menu top-right)
.topbar.sep  (1px separator)
.left (info text)  |  .sep  |  .right
                                .right.mid
                                  .right.mid.c   (hexagram canvas 260×310)
                                  .right.mid.tri (trigram canvas 100×310)
                                .right.num
```

### Hamburger menu (.topbar.mb.m)
```
Langue / Language / 语言  ▶  Français | English | 中文
Thème / Theme             ▶  light | dark | sepia
────────────────────────────
Reset / Réinitialiser / 重置
```
The cascade label and Reset label are updated dynamically via `entryconfigure` in `update_ui_labels`.

### Theme system
Identical pattern to `~/src/inspiration_pad/sparkwyrd/src/gui.tcl`:
- `::themes(name)` — dict of color keys per theme
- `T key` — returns current theme value for `key`
- `apply_theme ?name?` — sets theme, reconfigures all widgets, redraws canvases

**Theme keys:** `bg`, `bg_left`, `fg`, `fg2`, `sep`, `line`, `tri_bg`, `tri_border`, `accent`, `btn_bg`, `btn_fg`

**Available themes:** `light`, `dark`, `sepia` (default)

### Language selection
Menu → Langue submenu, direct selection (no cycling).  
Labels per language: fr=`Hexagramme`/`Réinitialiser`, en=`Hexagram`/`Reset`, zh=`卦`/`重置`.  
The Chinese file title includes the hexagram's Chinese name: `== 1. ䷀ 乾 ==`.  
`tri_zh` list provides the trigram element name in Chinese (天 地 水 火…).

### Mutations (changing lines)
`array mutations(1..6)` — independent of `lines`. Right-click toggles.  
- **○** old yang (`lines=1, mut=1`): oval drawn over the solid line, filled `bg`, outlined `accent`  
- **×** old yin (`lines=0, mut=1`): two diagonal lines in the gap, color `accent`  
`reset_all` clears both `lines` and `mutations`.

### Adding a theme
Add a new entry to `::themes` with all 11 keys, then add it to the menubutton loop:
```tcl
set ::themes(mytheme) { bg #... fg #... ... }
# in the foreach loop:
foreach th {light dark sepia mytheme} { ... }
```

### Creole data format
```
== N. ䷀ ==        ← title  (== … ==)
**bold keywords**  ← bold   (** … **)
//italic desc//    ← italic (// … //)
```

## HTML/JS port (future)

Tcl/Tk has no browser runtime and no viable WASM path. The recommended approach is a **clean rewrite** as a single self-contained `hexagrams.html` file — no server, no build step.

### What stays identical
- `hexagrams.fr.creole`, `hexagrams.creole`, `hexagrams.zh.creole` — same format, loaded with `fetch()` or embedded as JS template literals
- `hex_table` — copy-paste as a JS array literal
- `tri_*` data lists — copy-paste as JS arrays
- All hexagram logic (`get_hexagram`, trigram index math) — trivial JS port

### Mapping Tcl/Tk → HTML/JS

| Tcl/Tk | HTML/JS equivalent |
|---|---|
| `canvas` (hexagram) | `<canvas>` + `CanvasRenderingContext2D` |
| `canvas` (trigrams) | `<canvas>` or CSS flexbox cards |
| `array lines/mutations` | Plain JS object `{1:1, 2:1, …}` |
| `T key` theme accessor | CSS custom properties (`--accent`, `--bg`, …) on `:root` |
| Text widget + tags | `<div>` + `<span class="bold/italic/title">` |
| `bind <Button-1>` | `canvas.addEventListener('click', …)` |
| `bind <Button-3>` | `canvas.addEventListener('contextmenu', …)` + `e.preventDefault()` |
| Hamburger menu | `<details>`/`<summary>` or a `<div>` dropdown |
| `apply_theme` | Update CSS variables on `:root`, redraw canvases |
| `load_hexagrams` | `fetch()` + same regex parser in JS |

### Mobile note
Right-click (mutations) has no equivalent on touch screens. Options:
- Long-press (`touchstart` + 500 ms timer)
- A dedicated small tap zone to the right of each line (Option C from earlier discussion)

### Estimated scope
~350 lines of vanilla HTML/CSS/JS. No framework needed.  
Deliverable: a single `hexagrams.html` that works offline from the file system.

## Skills
See `.claude/skills/run-hexagrams.md`.
