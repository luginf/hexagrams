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
| Launch | Window opens in sepia theme, "Hexagramme  1" (all yang) |
| Click any line | Line toggles solid↔broken, hexagram number updates |
| All lines yin | "Hexagramme  2" |
| Lines 1–3 yang, 4–6 yin | "Hexagramme  11" |
| Lines 1–3 yin, 4–6 yang | "Hexagramme  12" |
| Trigram canvas | Two framed blocks aligned with upper/lower trigrams |
| Click EN | Labels switch to English, trigram translations update |
| Theme menu → dark | Window goes dark, canvas items redraw in dark palette |
| Theme menu → light | Clean white palette |
| Theme menu → sepia | Warm sepia palette (default) |
| Réinitialiser / Reset | All lines return to yang, Hexagramme/Hexagram 1 |

## Troubleshooting
- `wish` not found → `sudo apt install tk`
- CJK chars show as boxes → `sudo apt install fonts-noto-cjk` or `fonts-wqy-microhei`
- No display (Wayland) → `DISPLAY=:0 wish hexagrams.tcl`

## Theme keys (for new themes)
`bg`  `bg_left`  `fg`  `fg2`  `sep`  `line`  `tri_bg`  `tri_border`  `accent`  `btn_bg`  `btn_fg`
