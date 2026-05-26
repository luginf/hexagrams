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
- `::current_theme` — active theme name
- `lang` — active language ("fr", "en", or "zh")
- `array hexinfo(n,title|bold|italic)` — parsed creole data per hexagram

### Layout
```
.left (info text)  |  .sep  |  .right
                                .right.lbl
                                .right.mid
                                  .right.mid.c   (hexagram canvas 260×310)
                                  .right.mid.tri (trigram canvas 100×310)
                                .right.num
                                .right.btns
                                  Reset | FR/EN | theme▾
```

### Theme system
Identical pattern to `~/src/inspiration_pad/sparkwyrd/src/gui.tcl`:
- `::themes(name)` — dict of color keys per theme
- `T key` — returns current theme value for `key`
- `apply_theme ?name?` — sets theme, reconfigures all widgets, redraws canvases

**Theme keys:** `bg`, `bg_left`, `fg`, `fg2`, `sep`, `line`, `tri_bg`, `tri_border`, `accent`, `btn_bg`, `btn_fg`

**Available themes:** `light`, `dark`, `sepia` (default)

### Language cycle
Button cycles **fr → en → zh → fr**.  
Labels per language: fr=`Hexagramme`/`Réinitialiser`, en=`Hexagram`/`Reset`, zh=`卦`/`重置`.  
The Chinese file title includes the hexagram's Chinese name: `== 1. ䷀ 乾 ==`.  
`tri_zh` list provides the trigram element name in Chinese (天 地 水 火…).

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

## Skills
See `.claude/skills/run-hexagrams.md`.
