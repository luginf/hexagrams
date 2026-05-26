# Yi Jing — Hexagram Identifier

## Run
```bash
cd hexagrams
wish hexagrams.tcl
```

## Files
| File | Role |
|---|---|
| `hexagrams.tcl` | Main application (single file) |
| `hexagrams.ini` | Persisted preferences (auto-created on first run) |
| `hexagrams.fr.creole` | Hexagram data in French (creole markup) |
| `hexagrams.creole` | Hexagram data in English (creole markup) |
| `hexagrams.zh.creole` | Hexagram data in Chinese — simplified, title includes Chinese name |

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
- `::show_trigrams` — 1=trigram panel visible, 0=hidden
- `::show_info` — 1=left info panel visible, 0=hidden
- `::mut_nav_mode` — 0=click mutation label replaces current hex, 1=navigates and keeps mutations for return (default 1)

### Layout
```
.topbar  (Yi Jing label + ☰ hamburger menu top-right)
.topbar.sep  (1px separator)
.left (info text)  |  .sep  |  .right  [  .mutsep  |  .mut  ]
                                .right.mid               .mut.mid
                                  .right.mid.c              .mut.mid.c   (260×310)
                                  .right.mid.tri            .mut.mid.tri (100×310)
                                .right.num               .mut.num  (clickable →)
```
`.mutsep` and `.mut` are created at startup but not packed. They appear automatically when any mutation is marked, disappear when all mutations are cleared.

Clicking `.mut.num` applies the mutation per `::mut_nav_mode`:
- Mode 0: mutated lines become `lines`, all mutations cleared
- Mode 1: `lines` become mutated lines, `mutations` unchanged (same positions now point back)

### Hamburger menu (.topbar.mb.m)
```
Hexagramme →   ▶  ☷ Terre ▶ [☰ Ciel — 11. …] …   (lower trigram → upper trigram)
Par numéro…       (dialog: slider 1–64 + spinbox)
─────────────────────────────────────────────
✓ Trigrammes
✓ Panneau d'informations
✓ Mutation ↔ naviguer
─────────────────────────────────────────────
Réinitialiser
─────────────────────────────────────────────
Langue / Language / 语言  ▶  Français | English | 中文
Thème / Theme / 主题       ▶  light | dark | sepia | green
```
All dynamic labels are updated via `update_ui_labels` using `entryconfigure` by index.

### Persistence (`hexagrams.ini`)
Created next to `hexagrams.tcl` on first run. Keys: `theme`, `lang`, `show_trigrams`, `show_info`, `mut_nav_mode`.  
`load_ini` is called before `load_hexagrams` at startup. `save_ini` is called on every preference change.

### Theme system
- `::themes(name)` — dict of color keys per theme
- `T key` — returns current theme value for `key`
- `apply_theme ?name?` — sets theme, reconfigures all widgets, redraws canvases, saves ini

**Theme keys:** `bg`, `bg_left`, `fg`, `fg2`, `sep`, `line`, `tri_bg`, `tri_border`, `accent`, `btn_bg`, `btn_fg`

**Available themes:** `light`, `dark`, `sepia` (default), `green`

### Key procs
| Proc | Role |
|---|---|
| `refresh` | Redraws everything and updates mutation panel visibility |
| `toggle n` | Flips line n, calls `refresh` |
| `on_rclick y` | Toggles mutation marker on nearest line, calls `refresh` |
| `get_hexagram` | Returns hexagram number from current `lines` |
| `get_hexagram_from lv` | Returns hexagram number from an arbitrary lines dict |
| `get_mutated_lines` | Returns `array get` of lines with mutations applied |
| `has_mutations` | Returns 1 if any mutation is marked |
| `update_mutation_visibility` | Packs/unpacks `.mutsep` and `.mut` |
| `refresh_mutation_panel` | Redraws `.mut` content |
| `apply_mutation` | Dispatches to `apply_mutation_replace` or `apply_mutation_navigate` |
| `set_hexagram_from_trigrams hi lo` | Sets lines from trigram indices, clears mutations |
| `build_hex_menu` | Populates the 8×8 trigram navigation submenus; call after `load_hexagrams` and on lang change |
| `ask_hexagram_num` | Modal dialog with slider + spinbox, navigates to chosen number |
| `_draw_hexagram_on c lv mv` | Draws hexagram on arbitrary canvas |
| `_draw_trigrams_on c lv` | Draws trigrams on arbitrary canvas |
| `_update_info_widget t num` | Fills a text widget with hexagram info |
| `apply_trigrams_visibility` | Shows/hides trigram canvases, saves ini |
| `apply_info_visibility` | Shows/hides left panel, saves ini |
| `load_ini` / `save_ini` | Read/write `hexagrams.ini` |

### Mutations (changing lines)
`array mutations(1..6)` — independent of `lines`. Right-click toggles.  
- **○** old yang (`lines=1, mut=1`): oval over solid line, filled `bg`, outlined `accent`
- **×** old yin (`lines=0, mut=1`): two diagonal lines in the gap, color `accent`

The mutation result panel shows the hexagram after all mutations are applied, with no markers.  
Clicking `.mut.num` navigates to the result (behavior depends on `::mut_nav_mode`).

### Language selection
Menu → Langue submenu. Labels per language defined in `array ui_labels`.  
`set_lang` calls `load_hexagrams` + `build_hex_menu` + redraws + saves ini.

### Adding a theme
```tcl
set ::themes(mytheme) {
    bg #... bg_left #... fg #... fg2 #... sep #... line #...
    tri_bg #... tri_border #... accent #... btn_bg #... btn_fg #...
}
# In the theme submenu loop:
foreach th {light dark sepia green mytheme} { ... }
```

## Skills
See `.claude/skills/run-hexagrams.md`.
