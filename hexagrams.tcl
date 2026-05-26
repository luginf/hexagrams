#!/usr/bin/env wish
# Yi Jing — Hexagram identifier

# ── Langue par défaut : "fr", "en" ou "zh" ───────────────────────────────
set lang "fr"
# ── Thème par défaut : "light", "dark" ou "sepia" ─────────────────────────
set ::current_theme "sepia"
# ──────────────────────────────────────────────────────────────────────────

# ==========================================================================
# THÈMES
# ==========================================================================
array set ::themes {}

set ::themes(light) {
    bg          #ffffff
    bg_left     #fafafa
    fg          #1a1a1a
    fg2         #999999
    sep         #dddddd
    line        #1a1a1a
    tri_bg      #f9f9f9
    tri_border  #cccccc
    accent      #8B1A1A
    btn_bg      #ebebeb
    btn_fg      #1a1a1a
}

set ::themes(dark) {
    bg          #1e1e1e
    bg_left     #252525
    fg          #d4d4d4
    fg2         #666666
    sep         #3a3a3a
    line        #c8c8c8
    tri_bg      #2a2a2a
    tri_border  #484848
    accent      #c8965a
    btn_bg      #333333
    btn_fg      #d4d4d4
}

set ::themes(sepia) {
    bg          #fdf6e3
    bg_left     #f5efe0
    fg          #3b2e1e
    fg2         #8a7060
    sep         #c8b89a
    line        #3b2e1e
    tri_bg      #faf0d8
    tri_border  #c8b89a
    accent      #7a4f28
    btn_bg      #d8c9a8
    btn_fg      #3b2e1e
}

proc T {key} { return [dict get $::themes($::current_theme) $key] }

# ==========================================================================
# TABLE DES HEXAGRAMMES
# ==========================================================================
# Indexée par [trigramme_sup * 8 + trigramme_inf]
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

# --- Données des 8 trigrammes (index 0..7 : Kun Zhen Kan Dui Gen Li Xun Qian) ---
set tri_pinyin  {Kūn   Zhèn  Kǎn   Duì   Gèn   Lí    Xùn   Qián}
set tri_hanzi   {坤    震    坎    兌    艮    離    巽    乾  }
set tri_symbol  {☷    ☳    ☵    ☱    ☶    ☲    ☴    ☰  }
set tri_fr      {Terre Tonnerre Eau  Lac  Montagne Feu  Vent  Ciel}
set tri_en      {Earth Thunder  Water Lake Mountain Fire Wind  Heaven}
set tri_zh      {地    雷      水   泽   山       火   风   天  }

# --- Libellés selon la langue ---
array set ui_labels {
    fr,hexagram  "Hexagramme"
    fr,reset     "Réinitialiser"
    fr,lang_btn  "EN"
    en,hexagram  "Hexagram"
    en,reset     "Reset"
    en,lang_btn  "中"
    zh,hexagram  "卦"
    zh,reset     "重置"
    zh,lang_btn  "FR"
}

# ==========================================================================
# DONNÉES
# ==========================================================================
proc data_file {} {
    global lang
    if {$lang eq "fr"} { return "hexagrams.fr.creole" }
    if {$lang eq "zh"} { return "hexagrams.zh.creole" }
    return "hexagrams.creole"
}

proc load_hexagrams {} {
    global hexinfo lang
    foreach key [array names hexinfo] { unset hexinfo($key) }
    set f [open [data_file] r]
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

# ==========================================================================
# DESSIN
# ==========================================================================
proc y_of {n} { expr {54 + (6 - $n) * 44} }

proc draw_hexagram {} {
    global lines
    .right.mid.c delete all
    set sep_y [expr {[y_of 4] + 22}]
    .right.mid.c create line 20 $sep_y 240 $sep_y \
        -fill [T sep] -width 1 -dash {6 3}
    for {set i 1} {$i <= 6} {incr i} {
        set y [y_of $i]
        if {$lines($i)} {
            .right.mid.c create line 32 $y 228 $y \
                -width 14 -fill [T line] -capstyle butt
        } else {
            .right.mid.c create line  32 $y 108 $y \
                -width 14 -fill [T line] -capstyle butt
            .right.mid.c create line 152 $y 228 $y \
                -width 14 -fill [T line] -capstyle butt
        }
        .right.mid.c create text 13 $y -text $i \
            -font {Helvetica 9} -fill [T fg2]
    }
}

proc get_hexagram {} {
    global lines hex_table
    set lo [expr {$lines(1) + $lines(2)*2 + $lines(3)*4}]
    set hi [expr {$lines(4) + $lines(5)*2 + $lines(6)*4}]
    return [lindex $hex_table [expr {$hi * 8 + $lo}]]
}

proc draw_tri_block {yc idx} {
    global lang tri_pinyin tri_hanzi tri_symbol tri_fr tri_en tri_zh
    set c .right.mid.tri
    set cx 50

    set symbol [lindex $tri_symbol  $idx]
    set hanzi  [lindex $tri_hanzi   $idx]
    set pinyin [lindex $tri_pinyin  $idx]
    set tlist  [expr {$lang eq "fr" ? $tri_fr : ($lang eq "zh" ? $tri_zh : $tri_en)}]
    set trans  [lindex $tlist $idx]

    $c create rectangle 5 [expr {$yc-40}] 95 [expr {$yc+40}] \
        -outline [T tri_border] -fill [T tri_bg] -width 1

    $c create text $cx [expr {$yc - 22}] -text $symbol \
        -font {Helvetica 17 bold} -fill [T accent] -anchor center

    $c create text $cx [expr {$yc - 2}] -text $hanzi \
        -font {Helvetica 15} -fill [T fg] -anchor center

    $c create text $cx [expr {$yc + 15}] -text $pinyin \
        -font {Helvetica 11} -fill [T fg2] -anchor center

    $c create text $cx [expr {$yc + 31}] -text $trans \
        -font {Helvetica 10 italic} -fill [T fg2] -anchor center
}

proc draw_trigrams {} {
    global lines
    set c .right.mid.tri
    $c delete all
    $c create line 0 [expr {[y_of 4] + 22}] 100 [expr {[y_of 4] + 22}] \
        -fill [T sep] -width 1 -dash {6 3}
    set lo [expr {$lines(1) + $lines(2)*2 + $lines(3)*4}]
    set hi [expr {$lines(4) + $lines(5)*2 + $lines(6)*4}]
    draw_tri_block 98  $hi
    draw_tri_block 230 $lo
}

# ==========================================================================
# PANNEAU INFO GAUCHE
# ==========================================================================
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

# ==========================================================================
# APPLICATION DU THÈME
# ==========================================================================
proc apply_theme {{theme ""}} {
    if {$theme ne ""} { set ::current_theme $theme }

    # Option database pour les futurs widgets
    option add *Background        [T bg]      interactive
    option add *Foreground        [T fg]      interactive
    option add *Button.Background [T btn_bg]  interactive
    option add *Button.Foreground [T btn_fg]  interactive
    option add *Label.Background  [T bg]      interactive
    option add *Label.Foreground  [T fg]      interactive
    option add *Menubutton.Background [T btn_bg] interactive
    option add *Menubutton.Foreground [T btn_fg] interactive
    option add *Menu.Background   [T btn_bg]  interactive
    option add *Menu.Foreground   [T btn_fg]  interactive

    if {![winfo exists .left]} return

    # Fenêtre principale
    . configure -bg [T bg]

    # Barre du haut
    .topbar       configure -bg [T bg]
    .topbar.title configure -bg [T bg] -fg [T fg2]
    .topbar.mb    configure -bg [T bg] -fg [T fg] \
        -activebackground [T sep] -activeforeground [T fg]
    .topbar.sep   configure -bg [T sep]
    catch { .topbar.mb.m          configure -bg [T btn_bg] -fg [T fg] }
    catch { .topbar.mb.m.lang     configure -bg [T btn_bg] -fg [T fg] }
    catch { .topbar.mb.m.theme    configure -bg [T btn_bg] -fg [T fg] }

    # Panneau gauche
    .left configure -bg [T bg_left]
    .left.txt configure -bg [T bg_left] -fg [T fg]
    .left.txt tag configure title \
        -font {Helvetica 17 bold} -justify center \
        -foreground [T accent] -spacing1 4 -spacing3 10
    .left.txt tag configure bold \
        -font {Helvetica 12 bold} -justify center \
        -foreground [T fg] -spacing3 6
    .left.txt tag configure italic \
        -font {Helvetica 12 italic} -justify center \
        -foreground [T fg2]

    # Séparateur vertical
    .sep configure -bg [T sep]

    # Panneau droit
    .right         configure -bg [T bg]
    .right.mid     configure -bg [T bg]
    .right.mid.c   configure -bg [T bg]
    .right.mid.tri configure -bg [T bg]
    .right.num     configure -bg [T bg] -fg [T accent]

    # Redessiner les canvas avec les nouvelles couleurs
    draw_hexagram
    draw_trigrams
}

# ==========================================================================
# ACTIONS
# ==========================================================================
proc update_ui_labels {} {
    global lang ui_labels
    set h [get_hexagram]
    .right.num configure -text "$ui_labels($lang,hexagram)  $h"
    # Met à jour le libellé dynamique Reset dans le menu sandwich
    catch {
        set lang_label [expr {$lang eq "fr" ? "Langue" : ($lang eq "zh" ? "语言" : "Language")}]
        .topbar.mb.m entryconfigure 0 -label $lang_label
        .topbar.mb.m entryconfigure end -label $ui_labels($lang,reset)
    }
}

proc refresh {} {
    draw_hexagram
    draw_trigrams
    update_info [get_hexagram]
    update_ui_labels
}

proc toggle {n} {
    global lines
    set lines($n) [expr {1 - $lines($n)}]
    refresh
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
    refresh
}

proc set_lang {l} {
    global lang
    set lang $l
    load_hexagrams
    draw_trigrams
    update_info [get_hexagram]
    update_ui_labels
}

# ==========================================================================
# INTERFACE
# ==========================================================================
wm title . "Yi Jing"
wm resizable . 0 0

# ── Barre supérieure ──────────────────────────────────────────────────────
frame .topbar
pack .topbar -fill x -side top

label .topbar.title -text "Yi Jing" -font {Helvetica 13} -padx 12 -pady 6
pack .topbar.title -side left

# Menu sandwich ☰
menubutton .topbar.mb -text "☰" -font {Helvetica 15} \
    -relief flat -padx 10 -pady 4 -cursor hand2
pack .topbar.mb -side right -padx 4

menu .topbar.mb.m -tearoff 0

# Sous-menu Langue
menu .topbar.mb.m.lang -tearoff 0
.topbar.mb.m.lang add command -label "Français" -command {set_lang fr}
.topbar.mb.m.lang add command -label "English"  -command {set_lang en}
.topbar.mb.m.lang add command -label "中文"      -command {set_lang zh}
.topbar.mb.m add cascade -label "Langue" -menu .topbar.mb.m.lang

# Sous-menu Thème
menu .topbar.mb.m.theme -tearoff 0
foreach th {light dark sepia} {
    .topbar.mb.m.theme add command -label $th -command [list apply_theme $th]
}
.topbar.mb.m add cascade -label "Thème" -menu .topbar.mb.m.theme

.topbar.mb.m add separator
.topbar.mb.m add command -label "Reset" -command reset_all

.topbar.mb configure -menu .topbar.mb.m

# Séparateur sous la topbar
frame .topbar.sep -height 1
pack .topbar.sep -fill x -side bottom

# ── Contenu principal ─────────────────────────────────────────────────────

# Panneau gauche — informations
frame .left
pack .left -side left -fill both -padx {12 4} -pady 12

text .left.txt -width 38 -height 16 -wrap word \
    -font {Helvetica 12} -relief flat \
    -highlightthickness 0 -state disabled \
    -padx 12 -pady 8 -cursor {}
pack .left.txt -fill both -expand 1

# Séparateur vertical
frame .sep -width 1
pack .sep -side left -fill y -pady 8

# Panneau droit
frame .right
pack .right -side left -fill y -padx {4 12} -pady 12

# Rangée centrale : hexagramme + trigrammes
frame .right.mid
pack .right.mid -pady {10 4}

canvas .right.mid.c -width 260 -height 310 -cursor hand2 \
    -highlightthickness 0
pack .right.mid.c -side left

canvas .right.mid.tri -width 100 -height 310 \
    -highlightthickness 0
pack .right.mid.tri -side left -padx {4 0}

label .right.num -text "" -font {Helvetica 22 bold}
pack .right.num -pady {4 14}

bind .right.mid.c <Button-1> {on_click %y}

# ==========================================================================
# INITIALISATION
# ==========================================================================
load_hexagrams
apply_theme
update_ui_labels
update_info [get_hexagram]
