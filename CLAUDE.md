# Yi Jing — Hexagram Identifier

## Run

### Tcl/Tk desktop app
```bash
cd hexagrams
wish hexagrams.tcl
```

### Web app
Open `hexagrams.html` in a browser (no server required).
Published at: https://luginf.github.io/hexagrams/hexagrams.html

## Files
| File | Role |
|---|---|
| `hexagrams.tcl` | Main Tcl/Tk application (single file) |
| `hexagrams.html` | Standalone HTML/JS/CSS web app (single file) |
| `hexagrams.ini` | Persisted Tcl/Tk preferences (auto-created on first run) |
| `hexagrams.fr.creole` | Hexagram data in French (creole markup) |
| `hexagrams.creole` | Hexagram data in English (creole markup) |
| `hexagrams.zh.creole` | Hexagram data in Chinese — simplified, title includes Chinese name |

## Architecture

### Tcl/Tk (`hexagrams.tcl`)

**Single-file Tcl/Tk app.** All logic and UI live in `hexagrams.tcl`.

#### Hexagram lookup
64-entry flat list `hex_table`, indexed by `upper_trigram * 8 + lower_trigram`.  
Trigram value = `l1 + l2*2 + l3*4` (yang=1, lines bottom→top).  
Codes: Kun=0, Zhen=1, Kan=2, Dui=3, Gen=4, Li=5, Xun=6, Qian=7.

#### State
- `array lines(1..6)` — current line states: 1=yang, 0=yin
- `array mutations(1..6)` — changing-line markers: 1=marked, 0=none (independent of `lines`)
- `::current_theme` — active theme name
- `lang` — active language ("fr", "en", or "zh")
- `array hexinfo(n,title|bold|italic)` — parsed creole data per hexagram
- `::show_trigrams` — 1=trigram panel visible, 0=hidden
- `::show_info` — 1=left info panel visible, 0=hidden
- `::mut_nav_mode` — 0=click mutation label replaces current hex, 1=navigates and keeps mutations for return (default 1)
- `::show_mut_btn` — 1=mutation mode button visible, 0=hidden
- `::mut_mode` — 0=normal click behaviour, 1=click on line toggles mutation marker
- `::rand_line` — 0=inactive, 1..6=next line to fill during coin-toss mode, 7=all done
- `::rand_last_coins` / `::rand_last_sum` — last toss result, kept for theme-change redraws

#### Layout
```
.topbar  (Yi Jing label + ☰ hamburger menu top-right)
.topbar.sep  (1px separator)
.left (info text)  |  .sep  |  .right  [  .mutsep  |  .mut  ]
  .left.txt                          .right.mid               .mut.mid
  .left.coins (coin panel, hidden)     .right.mid.c              .mut.mid.c   (260×310)
    .left.coins.top                    .right.mid.tri            .mut.mid.tri (100×310)
      .left.coins.top.btn (Lancer)   .right.num               .mut.num  (clickable →)
      .left.coins.top.c  (92×30)     .right.mutbtn (○ ×)
      .left.coins.top.sum
    .left.coins.prog
```
`.mutsep` and `.mut` are created at startup but not packed. They appear automatically when any mutation is marked, disappear when all mutations are cleared.  
`.right.mutbtn` is packed/unpacked by `apply_mut_btn_visibility`.

Clicking `.mut.num` applies the mutation per `::mut_nav_mode`:
- Mode 0: mutated lines become `lines`, all mutations cleared
- Mode 1: `lines` become mutated lines, `mutations` unchanged (same positions now point back)

#### Hamburger menu (.topbar.mb.m)
```
Hexagramme →   ▶  ☷ Terre ▶ [☰ Ciel — 11. …] …   (lower trigram → upper trigram)
Par numéro…       (dialog: slider 1–64 + spinbox)
─────────────────────────────────────────────
Aléatoire         (coin-toss mode)
Réinitialiser
─────────────────────────────────────────────
✓ Trigrammes
✓ Panneau d'informations
✓ Mutation ↔ naviguer
✓ Bouton de mutation
─────────────────────────────────────────────
Langue / Language / 语言  ▶  Français | English | 中文
Thème / Theme / 主题       ▶  light | dark | sepia | green
─────────────────────────────────────────────
À propos… / About… / 关于…
```
Indices: 0=HexNav 1=ParNum 2=sep 3=Random 4=Reset 5=sep 6=Trigrams 7=Info 8=MutNav 9=MutBtn 10=sep 11=Langue 12=Thème 13=sep 14=About  
All dynamic labels are updated via `update_ui_labels` using `entryconfigure` by index.

#### Persistence (`hexagrams.ini`)
Created next to `hexagrams.tcl` on first run.  
Keys: `theme`, `lang`, `show_trigrams`, `show_info`, `mut_nav_mode`, `show_mut_btn`.  
`load_ini` is called before `load_hexagrams` at startup. `save_ini` is called on every preference change.

#### Theme system
- `::themes(name)` — dict of color keys per theme
- `T key` — returns current theme value for `key`
- `apply_theme ?name?` — sets theme, reconfigures all widgets, redraws canvases, saves ini

**Theme keys:** `bg`, `bg_left`, `fg`, `fg2`, `sep`, `line`, `tri_bg`, `tri_border`, `accent`, `btn_bg`, `btn_fg`

**Available themes:** `light`, `dark`, `sepia` (default), `green`

#### Key procs
| Proc | Role |
|---|---|
| `refresh` | Redraws everything and updates mutation panel visibility |
| `toggle n` | Flips line n, calls `refresh` |
| `on_click y` | Left-click: toggles line or mutation depending on `::mut_mode` |
| `on_rclick y` | Right-click: toggles mutation marker on nearest line, calls `refresh` |
| `toggle_mut_mode` | Toggles `::mut_mode`, updates `.right.mutbtn` style |
| `apply_mut_btn_visibility` | Packs/unpacks `.right.mutbtn`, saves ini |
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
| `show_about` | Modal dialog with brief description and project link |
| `_draw_hexagram_on c lv mv` | Draws hexagram on arbitrary canvas |
| `_draw_trigrams_on c lv` | Draws trigrams on arbitrary canvas |
| `_update_info_widget t num` | Fills a text widget with hexagram info |
| `apply_trigrams_visibility` | Shows/hides trigram canvases, saves ini |
| `apply_info_visibility` | Shows/hides left panel, saves ini |
| `load_ini` / `save_ini` | Read/write `hexagrams.ini` |
| `start_random` | Clears lines, sets `rand_line=1`, shows coin panel |
| `toss_coins` | Re-seeds PRNG from `clock clicks`, rolls 3 coins, fills next line |
| `update_coins_ui coins sum` | Redraws coin canvas + sum label + progress |
| `draw_coin_canvas coins` | Draws 3 coin circles on `.left.coins.top.c` |
| `hide_coins_panel` | Hides coin panel, resets rand state, calls `apply_info_visibility` |
| `line_type_desc sum` | Returns localised description for sum 6–9 |
| `clamp_menu_left m` | Repositions cascade submenu to the left if it would overflow the screen |

#### Coin-toss mode
`start_random` clears all lines and enters coin-toss mode (`rand_line=1`).  
`draw_hexagram` passes `blank_from=rand_line` to `_draw_hexagram_on`, so unfilled lines render as faint dotted placeholders.  
`toss_coins` re-seeds the PRNG with `srand [clock clicks]` (microsecond timestamp), rolls 3 coins (pile=2, face=3), sums them:

| Sum | Line type | `lines($n)` | `mutations($n)` |
|-----|-----------|-------------|-----------------|
| 6 | old yin ×  | 0 | 1 |
| 7 | young yang | 1 | 0 |
| 8 | young yin  | 0 | 0 |
| 9 | old yang ○ | 1 | 1 |

Coin visuals: FR=P/F, EN=T/H, ZH=字/花. Filled circle=face/heads/花, outline=pile/tails/字.  
After 6 tosses, button disables and `after 2000 hide_coins_panel` fires.  
`reset_all` calls `hide_coins_panel` immediately and resets `::mut_mode` to 0.

#### Mutations (changing lines)
`array mutations(1..6)` — independent of `lines`. Right-click toggles; in `::mut_mode` left-click also toggles.  
- **○** old yang (`lines=1, mut=1`): oval over solid line, filled `bg`, outlined `accent`
- **×** old yin (`lines=0, mut=1`): two diagonal lines in the gap, color `accent`

#### Language selection
Menu → Langue submenu. Labels per language defined in `array ui_labels`.  
`set_lang` calls `load_hexagrams` + `build_hex_menu` + redraws + saves ini.

#### Adding a theme
```tcl
set ::themes(mytheme) {
    bg #... bg_left #... fg #... fg2 #... sep #... line #...
    tri_bg #... tri_border #... accent #... btn_bg #... btn_fg #...
}
# In the theme submenu loop:
foreach th {light dark sepia green mytheme} { ... }
```

---

### HTML/JS web app (`hexagrams.html`)

**Single self-contained file.** All CSS, JS and hexagram data embedded inline. No build step, no server.

#### Architecture
- HTML5 `<canvas>` for hexagram and trigram drawing (`drawHex`, `drawTris`, `drawMutPanel`)
- CSS custom properties (`--bg`, `--accent`, …) on `body[data-theme=X]` for theming
- `<div id="left">` for info text (creole rendered inline)
- `click` / `contextmenu` events on `#hex-canvas`
- Custom dropdown menu (`#menu-drop`) built by `buildMenu()` — rebuilt on language change
- Second-level cascade submenus positioned with `position:fixed` + `getBoundingClientRect()` to avoid overflow

#### State variables
| Variable | Role |
|---|---|
| `lines[1..6]` | Current line states: 1=yang, 0=yin |
| `muts[1..6]` | Mutation markers |
| `lang` | Active language: `'fr'`, `'en'`, `'zh'` |
| `theme` | Active theme name |
| `showTrigrams` | Trigram panel visibility |
| `showInfo` | Left info panel visibility |
| `mutNavMode` | true=navigate on mutation click, false=replace |
| `showMutBtn` | Mutation mode button visibility |
| `mutMode` | true=click on line toggles mutation instead of line type |
| `randLine` | 0=inactive, 1..6=next coin-toss line, 7=done |
| `randCoins` / `randSum` | Last coin toss result (for redraws on theme change) |

#### Persistence (`localStorage`)
| Key | Content |
|---|---|
| `yi_theme` | Theme name |
| `yi_lang` | Language code |
| `yi_st` | `1`/`0` — show trigrams |
| `yi_si` | `1`/`0` — show info panel |
| `yi_mn` | `1`/`0` — mutation nav mode |
| `yi_smb` | `1`/`0` — show mutation button |

#### Key functions
| Function | Role |
|---|---|
| `refresh()` | Redraws hex, trigrams, info, mutation panel visibility |
| `drawHex()` | Draws main hexagram on `#hex-canvas` |
| `drawTris()` | Draws trigrams on `#tri-canvas` |
| `drawMutPanel()` | Draws mutation result hexagram |
| `updateMutVis()` | Shows/hides `#mutsep` and `#mut` |
| `applyMut()` | Applies mutation per `mutNavMode` |
| `toggleMutMode()` | Toggles `mutMode`, updates button style |
| `applyMutBtnVis()` | Shows/hides `#mut-mode-btn`, saves prefs |
| `applyTheme(name)` | Sets theme CSS, redraws, saves prefs |
| `setLang(l)` | Sets language, rebuilds menu, redraws, saves prefs |
| `applyTriVis()` / `applyInfoVis()` | Toggle panel visibility, save prefs |
| `buildMenu()` | Rebuilds `#menu-drop` DOM — called on lang change |
| `openNumDialog()` | Shows the Go-to-number modal |
| `showAbout()` | Shows the About modal |
| `startRandom()` | Enters coin-toss mode |
| `tossCoins()` | Rolls 3 coins, fills next line, re-seeds xorshift32 PRNG from `performance.now()` |
| `hideCoinPanel()` | Hides coin panel, resets rand state |
| `resetAll()` | Resets all lines and state incl. `mutMode` |

#### Responsive layout
Media query at `max-width: 650px` switches `#main` from `flex-direction:row` to `flex-direction:column`.  
Vertical separators (`#vsep`, `#mutsep`) become 1px horizontal lines.  
Order in the DOM: description → hexagram → mutation (already correct for both orientations).

#### PRNG for coin toss
Custom xorshift32 (`rngSeed` / `rngNext`) re-seeded each toss from `performance.now() + Date.now()`,
since `Math.random()` provides no public seed API.

## Skills
See `.claude/skills/run-hexagrams.md`.
