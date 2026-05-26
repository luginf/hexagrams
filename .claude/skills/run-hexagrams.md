# Skill: run-hexagrams

Launch and verify the Yi Jing Tcl/Tk application.

## Launch
```bash
cd /home/alan/src/yi-jing/hexagrams
wish hexagrams.tcl &
```

## Smoke tests

| Action | Expected result |
|---|---|
| Launch | Sepia theme, topbar with ☰, "Hexagramme  1" (all yang, no mutations) |
| Left-click any line | Line toggles solid↔broken, hexagram number updates |
| All lines yin | "Hexagramme  2" |
| Lines 1–3 yang, 4–6 yin | "Hexagramme  11" |
| Lines 1–3 yin, 4–6 yang | "Hexagramme  12" |
| Right-click a yang line | Mutation panel appears; ○ on solid line (accent color) |
| Right-click a yin line | × in the gap between the two half-lines |
| Right-click again | Marker removed; mutation panel hides if no markers remain |
| Left-click a marked line | Line type toggles, marker stays (○ becomes × or vice versa) |
| Mutation panel | Shows the resulting hexagram after applying all mutations; label is clickable |
| Click mutation label (nav mode) | Navigates to mutation result; same mutation positions now point back to origin |
| Trigram canvas | Two framed blocks aligned with upper/lower trigrams |
| ☰ → Hexagramme → ☷ Terre → ☰ Ciel | Navigates to hexagram 11; mutations cleared |
| ☰ → Par numéro… | Modal dialog with slider (1–64) + spinbox; slider and spinbox stay in sync |
| Par numéro dialog: drag slider | Spinbox updates; OK navigates to chosen hexagram |
| ☰ → Trigrammes (uncheck) | Trigram panel hides; preference saved to hexagrams.ini |
| ☰ → Panneau d'informations (uncheck) | Left info panel hides; preference saved |
| ☰ → Mutation ↔ naviguer (uncheck) | Mutation click now replaces current hex (mode 0) |
| ☰ → Réinitialiser | All lines return to yang, mutations cleared, hexagram 1 |
| ☰ → Langue → English | Labels switch to English, trigram translations update |
| ☰ → Langue → 中文 | Labels switch to Chinese (卦 / 重置) |
| ☰ → Langue → Français | Returns to French |
| ☰ → Thème → dark | Window goes dark, canvas items redraw in dark palette |
| ☰ → Thème → light | Clean white palette |
| ☰ → Thème → sepia | Warm sepia palette |
| ☰ → Thème → green | Soft green palette |
| Relaunch after changing prefs | hexagrams.ini values restored (theme, lang, panel visibility, nav mode) |

## Troubleshooting
- `wish` not found → `sudo apt install tk`
- CJK chars show as boxes → `sudo apt install fonts-noto-cjk` or `fonts-wqy-microhei`
- No display (Wayland) → `DISPLAY=:0 wish hexagrams.tcl`

## Theme keys (for new themes)
`bg`  `bg_left`  `fg`  `fg2`  `sep`  `line`  `tri_bg`  `tri_border`  `accent`  `btn_bg`  `btn_fg`
