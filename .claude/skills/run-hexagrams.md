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
| Right-click a yang line | ○ appears centered on the solid line (accent color) |
| Right-click a yin line | × appears in the gap between the two half-lines |
| Right-click again | Marker removed |
| Left-click a marked line | Line type toggles, marker stays (○ becomes × or vice versa) |
| Trigram canvas | Two framed blocks aligned with upper/lower trigrams |
| ☰ → Langue → English | Labels switch to English, trigram translations update |
| ☰ → Langue → 中文 | Labels switch to Chinese (卦 / 重置), trigrams show 天地水火… |
| ☰ → Langue → Français | Returns to French |
| ☰ → Thème → dark | Window goes dark, canvas items redraw in dark palette |
| ☰ → Thème → light | Clean white palette |
| ☰ → Thème → sepia | Warm sepia palette |
| ☰ → Reset | All lines return to yang, all mutations cleared, Hexagramme 1 |

## Troubleshooting
- `wish` not found → `sudo apt install tk`
- CJK chars show as boxes → `sudo apt install fonts-noto-cjk` or `fonts-wqy-microhei`
- No display (Wayland) → `DISPLAY=:0 wish hexagrams.tcl`

## Theme keys (for new themes)
`bg`  `bg_left`  `fg`  `fg2`  `sep`  `line`  `tri_bg`  `tri_border`  `accent`  `btn_bg`  `btn_fg`
