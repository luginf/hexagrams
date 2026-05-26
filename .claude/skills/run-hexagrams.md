# Skill: run-hexagrams

Launch and verify the Yi Jing application — Tcl/Tk desktop or HTML/JS web.

---

## Tcl/Tk desktop app

### Launch
```bash
cd /home/alan/src/yi-jing/hexagrams
wish hexagrams.tcl &
```

### Smoke tests

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
| Mutation panel | Shows the resulting hexagram; label is clickable |
| Click mutation label (nav mode) | Navigates to result; same positions point back to origin |
| **○ × button visible** | Button shown below hex number label |
| **Click ○ × button** | Button turns accent colour (mutation mode active) |
| **Click a line in mutation mode** | Mutation marker toggles; line type unchanged |
| **Click ○ × button again** | Button returns to normal; mutation mode off |
| ☰ → Bouton de mutation (uncheck) | ○ × button hides; mutation mode deactivated |
| Trigram canvas | Two framed blocks aligned with upper/lower trigrams |
| ☰ → Aléatoire | All 6 lines become faint dotted placeholders; coin panel appears |
| Coin panel: click Lancer | 3 coins drawn; one line fills from bottom up |
| Repeated clicks | Each toss fills the next line; old yang/yin show mutation markers |
| After 6th toss | Button disables; "Terminé ✓"; panel hides after 2 s |
| ☰ → Réinitialiser during toss | Coin panel hides immediately, all lines reset to yang |
| ☰ → Hexagramme → ☷ Terre → ☰ Ciel | Navigates to hexagram 11; mutations cleared |
| ☰ → Par numéro… | Modal dialog with slider (1–64) + spinbox; in sync |
| ☰ → À propos… | About dialog: title, description, project link; Esc or button closes |
| ☰ → Trigrammes (uncheck) | Trigram panel hides; saved to hexagrams.ini |
| ☰ → Panneau d'informations (uncheck) | Info panel hides; saved |
| ☰ → Mutation ↔ naviguer (uncheck) | Mutation click replaces current hex (mode 0) |
| ☰ → Réinitialiser | All lines yang, mutations cleared, hexagram 1, mutation mode off |
| ☰ → Langue → English | Labels switch to English |
| ☰ → Langue → 中文 | Labels switch to Chinese |
| ☰ → Thème → dark | Dark palette |
| Relaunch | hexagrams.ini values restored |

### Troubleshooting
- `wish` not found → `sudo apt install tk`
- CJK chars show as boxes → `sudo apt install fonts-noto-cjk` or `fonts-wqy-microhei`
- No display (Wayland) → `DISPLAY=:0 wish hexagrams.tcl`

---

## HTML/JS web app

### Launch
```bash
cd /home/alan/src/yi-jing/hexagrams
xdg-open hexagrams.html
# or: python3 -m http.server 8080  (if local file access is restricted)
```
Published at: https://luginf.github.io/hexagrams/hexagrams.html

### Smoke tests

| Action | Expected result |
|---|---|
| Open in browser | Sepia theme, topbar with ☰, "Hexagramme  1" |
| Left-click any line | Line toggles; hex number updates |
| Right-click a line | Mutation marker toggled; result panel appears |
| **○ × button** | Visible below hex number by default |
| **Click ○ × button** | Button turns accent colour (mutation mode) |
| **Click a line in mutation mode** | Mutation toggles; line type unchanged |
| **Click ○ × again** | Button goes normal; back to regular click mode |
| ☰ → Bouton de mutation (uncheck) | Button hides; mutation mode deactivated |
| ☰ → Aléatoire | Lines become dotted; coin panel appears |
| Coin panel: click Lancer | Coins drawn; one line fills per click |
| After 6th toss | Panel hides; hexagram (with mutations) displayed |
| ☰ → Hexagramme → trigram → sub-trigram | Sub-menu opens to the LEFT (no overflow) |
| ☰ → Par numéro… | Modal with slider + spinbox; OK navigates |
| ☰ → À propos… | About modal: title, description, link opens in new tab; Close/click-outside closes |
| ☰ → Trigrammes | Trigram panel toggles; saved in localStorage |
| ☰ → Panneau d'informations | Info panel toggles |
| ☰ → Thème → dark | Dark theme applied |
| ☰ → Langue → English | All labels switch to English |
| Narrow viewport (< 650 px) | Layout stacks: description on top, hexagram below, mutation below that |
| Text in info panel | Selectable (description text is not user-select:none) |
| Reload page | All preferences restored from localStorage |

### Theme keys (for new themes)
`bg`  `bg_left`  `fg`  `fg2`  `sep`  `line`  `tri_bg`  `tri_border`  `accent`  `btn_bg`  `btn_fg`
