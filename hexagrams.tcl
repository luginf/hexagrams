#!/usr/bin/env wish
# Yi Jing — Hexagram identifier

# ── Langue par défaut : "fr" ou "en" ──────────────────────────────────────
set lang "fr"
# ──────────────────────────────────────────────────────────────────────────

# Table des 64 hexagrammes indexée par [trigramme_sup * 8 + trigramme_inf]
# Encodage trigramme: l1 + l2*2 + l3*4  (yang=1, lignes de bas en haut)
# Kun=0 Zhen=1 Kan=2 Dui=3 Gen=4 Li=5 Xun=6 Qian=7
set hex_table {
     2 24  7 19 15 36 46 11
    16 51 40 54 62 55 32 34
     8  3 29 60 39 63 48  5
    45 17 47 58 31 49 28 43
    23 27  4 41 52 22 18 26
    35 21 64 38 56 30 50 14
    20 42 59 61 53 37 57  9
    12 25  6 10 33 13 44  1
}

array set lines {1 1 2 1 3 1 4 1 5 1 6 1}

# --- Libellés selon la langue ---
array set ui_labels {
    fr,hexagram  "Hexagramme"
    fr,reset     "Réinitialiser"
    fr,lang_btn  "EN"
    en,hexagram  "Hexagram"
    en,reset     "Reset"
    en,lang_btn  "FR"
}

proc data_file {} {
    global lang
    if {$lang eq "fr"} { return "hexagrams.fr.creole" }
    return "hexagrams.creole"
}

# --- Chargement des données hexagrammes ---
proc load_hexagrams {} {
    global hexinfo lang
    # Vider les données précédentes
    foreach key [array names hexinfo] { unset hexinfo($key) }

    set filename [data_file]
    set f [open $filename r]
    fconfigure $f -encoding utf-8
    set data [read $f]
    close $f

    set num 0
    foreach line [split $data "\n"] {
        set line [string trim $line]
        if {[regexp {^== (\d+)\. (.+) ==$} $line -> n rest]} {
            set num [expr {int($n)}]
            set hexinfo($num,title) "$n. $rest"
            set hexinfo($num,bold)   ""
            set hexinfo($num,italic) ""
        } elseif {$num > 0 && [regexp {^\*\*(.+)\*\*$} $line -> t]} {
            set hexinfo($num,bold) $t
        } elseif {$num > 0 && [regexp {^//(.+)//$} $line -> t]} {
            set hexinfo($num,italic) $t
        }
    }
}

# --- Hexagramme ---
proc y_of {n} { expr {54 + (6 - $n) * 44} }

proc draw_hexagram {} {
    global lines
    .right.c delete all
    set sep_y [expr {[y_of 4] + 22}]
    .right.c create line 20 $sep_y 240 $sep_y \
        -fill "#bbbbbb" -width 1 -dash {6 3}
    for {set i 1} {$i <= 6} {incr i} {
        set y [y_of $i]
        if {$lines($i)} {
            .right.c create line 32 $y 228 $y \
                -width 14 -fill black -capstyle butt
        } else {
            .right.c create line  32 $y 108 $y \
                -width 14 -fill black -capstyle butt
            .right.c create line 152 $y 228 $y \
                -width 14 -fill black -capstyle butt
        }
        .right.c create text 13 $y -text $i \
            -font {Helvetica 9} -fill "#aaaaaa"
    }
}

proc get_hexagram {} {
    global lines hex_table
    set lo [expr {$lines(1) + $lines(2)*2 + $lines(3)*4}]
    set hi [expr {$lines(4) + $lines(5)*2 + $lines(6)*4}]
    return [lindex $hex_table [expr {$hi * 8 + $lo}]]
}

# --- Panneau info gauche ---
proc update_info {num} {
    global hexinfo
    set t .left.txt
    $t configure -state normal
    $t delete 1.0 end
    if {[info exists hexinfo($num,title)]} {
        $t insert end "\n" {}
        $t insert end $hexinfo($num,title) title
        $t insert end "\n\n" {}
        $t insert end $hexinfo($num,bold) bold
        $t insert end "\n\n" {}
        $t insert end $hexinfo($num,italic) italic
        $t insert end "\n" {}
    }
    $t configure -state disabled
}

proc update_ui_labels {} {
    global lang ui_labels
    set h [get_hexagram]
    .right.num    configure -text "$ui_labels($lang,hexagram)  $h"
    .right.reset  configure -text $ui_labels($lang,reset)
    .right.langbtn configure -text $ui_labels($lang,lang_btn)
}

proc toggle {n} {
    global lines
    set lines($n) [expr {1 - $lines($n)}]
    draw_hexagram
    update_info [get_hexagram]
    update_ui_labels
}

proc on_click {y_click} {
    for {set i 1} {$i <= 6} {incr i} {
        if {abs($y_click - [y_of $i]) <= 20} {
            toggle $i
            return
        }
    }
}

proc reset_all {} {
    global lines
    for {set i 1} {$i <= 6} {incr i} { set lines($i) 1 }
    draw_hexagram
    update_info [get_hexagram]
    update_ui_labels
}

proc switch_lang {} {
    global lang
    set lang [expr {$lang eq "fr" ? "en" : "fr"}]
    load_hexagrams
    update_info [get_hexagram]
    update_ui_labels
}

# === Interface ===
wm title . "Yi Jing"
wm resizable . 0 0
. configure -bg white

# Panneau gauche — informations
frame .left -bg white
pack .left -side left -fill both -padx {12 4} -pady 12

text .left.txt -width 38 -height 16 -wrap word \
    -font {Helvetica 12} -bg white -relief flat \
    -highlightthickness 0 -state disabled \
    -padx 12 -pady 8 -cursor {}
pack .left.txt -fill both -expand 1

.left.txt tag configure title \
    -font {Helvetica 17 bold} -justify center \
    -foreground "#8B1A1A" -spacing1 4 -spacing3 10
.left.txt tag configure bold \
    -font {Helvetica 12 bold} -justify center \
    -spacing3 6
.left.txt tag configure italic \
    -font {Helvetica 12 italic} -justify center \
    -foreground "#444444"

# Séparateur vertical
frame .sep -bg "#dddddd" -width 1
pack .sep -side left -fill y -pady 8

# Panneau droit — hexagramme
frame .right -bg white
pack .right -side left -fill y -padx {4 12} -pady 12

label .right.lbl -text "Yi Jing" \
    -font {Helvetica 13} -fg "#888888" -bg white
pack .right.lbl -pady {10 2}

canvas .right.c -width 260 -height 310 -bg white -cursor hand2 \
    -highlightthickness 0
pack .right.c -padx 15 -pady {4 2}

label .right.num -text "" \
    -font {Helvetica 22 bold} -fg "#8B1A1A" -bg white
pack .right.num -pady 6

frame .right.btns -bg white
pack .right.btns -pady {0 14}

button .right.reset -text "" -command reset_all \
    -font {Helvetica 11} -relief groove -padx 12 -pady 3 -bg white
pack .right.reset -in .right.btns -side left -padx {0 6}

button .right.langbtn -text "" -command switch_lang \
    -font {Helvetica 11 bold} -relief groove -padx 10 -pady 3 -bg white
pack .right.langbtn -in .right.btns -side left

bind .right.c <Button-1> {on_click %y}

# Initialisation
load_hexagrams
draw_hexagram
update_info [get_hexagram]
update_ui_labels
