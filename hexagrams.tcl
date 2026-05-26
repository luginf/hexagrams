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

set ::themes(green) {
    bg          #f0f7f0
    bg_left     #e6f2e6
    fg          #1a2e1a
    fg2         #6a896a
    sep         #a8c8a8
    line        #1a2e1a
    tri_bg      #e0f0e0
    tri_border  #a8c8a8
    accent      #2e6e2e
    btn_bg      #c8dfc8
    btn_fg      #1a2e1a
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

array set lines     {1 1 2 1 3 1 4 1 5 1 6 1}
array set mutations {1 0 2 0 3 0 4 0 5 0 6 0}

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
    fr,trigrams  "Trigrammes"
    fr,show_info "Panneau d'informations"
    fr,hex_nav   "Hexagramme →"
    fr,goto_num  "Par numéro…"
    en,hexagram  "Hexagram"
    en,reset     "Reset"
    en,lang_btn  "中"
    en,trigrams  "Trigrams"
    en,show_info "Info panel"
    en,hex_nav   "Hexagram →"
    en,goto_num  "By number…"
    zh,hexagram  "卦"
    zh,reset     "重置"
    zh,lang_btn  "FR"
    zh,trigrams  "三爻"
    zh,show_info "信息面板"
    zh,hex_nav   "选卦 →"
    zh,goto_num  "按序号…"
    fr,mut_nav   "Mutation ↔ naviguer"
    en,mut_nav   "Mutation ↔ navigate"
    zh,mut_nav   "变卦 ↔ 导航"
    fr,theme     "Thème"
    en,theme     "Theme"
    zh,theme     "主题"
    fr,random    "Aléatoire"
    en,random    "Random"
    zh,random    "随机"
    fr,toss      "Lancer"
    en,toss      "Toss"
    zh,toss      "掷"
}

# --- Visibilité ---
set ::show_trigrams  1
set ::show_info      1
set ::mut_nav_mode   1  ;# 0=remplacer  1=naviguer ↔
set ::rand_line       0  ;# 0=inactif, 1..6=prochaine ligne à tirer
set ::rand_last_coins {} ;# dernier résultat pour redessiner sur changement de thème
set ::rand_last_sum   0

# ==========================================================================
# PERSISTANCE (.ini)
# ==========================================================================
proc ini_file {} {
    return [file join [file dirname [file normalize [info script]]] hexagrams.ini]
}

proc load_ini {} {
    set f [ini_file]
    if {![file exists $f]} return
    set fh [open $f r]
    fconfigure $fh -encoding utf-8
    while {[gets $fh line] >= 0} {
        set line [string trim $line]
        if {[string match "#*" $line] || $line eq ""} continue
        if {[regexp {^(\w+)\s*=\s*(.*)} $line -> key val]} {
            set val [string trim $val]
            switch -- $key {
                theme {
                    if {[info exists ::themes($val)]} { set ::current_theme $val }
                }
                lang {
                    if {$val in {fr en zh}} { global lang; set lang $val }
                }
                show_trigrams { set ::show_trigrams  [expr {$val ? 1 : 0}] }
                show_info     { set ::show_info      [expr {$val ? 1 : 0}] }
                mut_nav_mode  { set ::mut_nav_mode   [expr {$val ? 1 : 0}] }
            }
        }
    }
    close $fh
}

proc save_ini {} {
    global lang
    set fh [open [ini_file] w]
    fconfigure $fh -encoding utf-8
    puts $fh "theme=$::current_theme"
    puts $fh "lang=$lang"
    puts $fh "show_trigrams=$::show_trigrams"
    puts $fh "show_info=$::show_info"
    puts $fh "mut_nav_mode=$::mut_nav_mode"
    close $fh
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
# DESSIN — versions paramétrées
# ==========================================================================
proc y_of {n} { expr {54 + (6 - $n) * 44} }

proc _draw_hexagram_on {c lv mv {blank_from 0}} {
    array set l $lv
    array set m $mv
    $c delete all
    set sep_y [expr {[y_of 4] + 22}]
    $c create line 20 $sep_y 240 $sep_y \
        -fill [T sep] -width 1 -dash {6 3}
    for {set i 1} {$i <= 6} {incr i} {
        set y [y_of $i]
        $c create text 13 $y -text $i \
            -font {Helvetica 9} -fill [T fg2]
        if {$blank_from > 0 && $i >= $blank_from} {
            $c create line 32 $y 228 $y \
                -width 1 -fill [T fg2] -dash {3 6} -capstyle butt
            continue
        }
        if {$l($i)} {
            $c create line 32 $y 228 $y \
                -width 14 -fill [T line] -capstyle butt
        } else {
            $c create line  32 $y 108 $y \
                -width 14 -fill [T line] -capstyle butt
            $c create line 152 $y 228 $y \
                -width 14 -fill [T line] -capstyle butt
        }
        if {$m($i)} {
            set cx 130
            if {$l($i)} {
                $c create oval \
                    [expr {$cx-9}] [expr {$y-9}] \
                    [expr {$cx+9}] [expr {$y+9}] \
                    -fill [T bg] -outline [T accent] -width 2
            } else {
                $c create line \
                    [expr {$cx-9}] [expr {$y-9}] \
                    [expr {$cx+9}] [expr {$y+9}] \
                    -fill [T accent] -width 2 -capstyle round
                $c create line \
                    [expr {$cx-9}] [expr {$y+9}] \
                    [expr {$cx+9}] [expr {$y-9}] \
                    -fill [T accent] -width 2 -capstyle round
            }
        }
    }
}

proc draw_hexagram {} {
    global lines mutations
    set bf [expr {$::rand_line > 0 ? $::rand_line : 0}]
    _draw_hexagram_on .right.mid.c [array get lines] [array get mutations] $bf
}

proc get_hexagram {} {
    global lines hex_table
    set lo [expr {$lines(1) + $lines(2)*2 + $lines(3)*4}]
    set hi [expr {$lines(4) + $lines(5)*2 + $lines(6)*4}]
    return [lindex $hex_table [expr {$hi * 8 + $lo}]]
}

proc _draw_tri_block_on {c yc idx} {
    global lang tri_pinyin tri_hanzi tri_symbol tri_fr tri_en tri_zh
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

proc _draw_trigrams_on {c lv} {
    array set l $lv
    $c delete all
    $c create line 0 [expr {[y_of 4] + 22}] 100 [expr {[y_of 4] + 22}] \
        -fill [T sep] -width 1 -dash {6 3}
    set lo [expr {$l(1) + $l(2)*2 + $l(3)*4}]
    set hi [expr {$l(4) + $l(5)*2 + $l(6)*4}]
    _draw_tri_block_on $c 98  $hi
    _draw_tri_block_on $c 230 $lo
}

proc draw_trigrams {} {
    global lines
    _draw_trigrams_on .right.mid.tri [array get lines]
}

# ==========================================================================
# PANNEAU INFO
# ==========================================================================
proc _update_info_widget {t num} {
    global hexinfo
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

proc update_info {num} {
    _update_info_widget .left.txt $num
}

# ==========================================================================
# VISIBILITÉ
# ==========================================================================
proc apply_trigrams_visibility {} {
    if {$::show_trigrams} {
        pack .right.mid.tri -side left -padx {4 0}
        catch {
            if {[winfo manager .mut] ne ""} {
                pack .mut.mid.tri -side left -padx {4 0}
            }
        }
    } else {
        pack forget .right.mid.tri
        catch { pack forget .mut.mid.tri }
    }
    save_ini
}

proc apply_info_visibility {} {
    if {$::show_info} {
        pack .left -side left -fill both -padx {12 4} -pady 12 -before .right
        pack .sep  -side left -fill y    -pady 8       -before .right
    } else {
        pack forget .left
        pack forget .sep
    }
    save_ini
}

# ==========================================================================
# NAVIGATION DIRECTE PAR TRIGRAMMES
# ==========================================================================
# Decode trigram index (0..7) → line values for lines 1-3 or 4-6
# Encoding: lo = l1 + l2*2 + l3*4
proc set_hexagram_from_trigrams {hi lo} {
    global lines mutations
    set lines(1) [expr { $lo       & 1}]
    set lines(2) [expr {($lo >> 1) & 1}]
    set lines(3) [expr {($lo >> 2) & 1}]
    set lines(4) [expr { $hi       & 1}]
    set lines(5) [expr {($hi >> 1) & 1}]
    set lines(6) [expr {($hi >> 2) & 1}]
    for {set i 1} {$i <= 6} {incr i} { set mutations($i) 0 }
    refresh
}

# Construit (ou reconstruit) les sous-menus de navigation.
# Entrée principale = trigramme du BAS ; sous-menu = trigramme du HAUT.
# Doit être appelé après load_hexagrams et à chaque changement de langue.
proc build_hex_menu {} {
    global tri_symbol tri_fr tri_en tri_zh hex_table hexinfo lang

    set tlist [expr {$lang eq "fr" ? $tri_fr : ($lang eq "zh" ? $tri_zh : $tri_en)}]

    for {set lo 0} {$lo <= 7} {incr lo} {
        set lo_sym  [lindex $tri_symbol $lo]
        set lo_name [lindex $tlist      $lo]

        # Libellé du cascade dans .hex = trigramme inférieur
        .topbar.mb.m.hex entryconfigure $lo -label "$lo_sym $lo_name"

        # Sous-menu = trigrammes supérieurs possibles
        .topbar.mb.m.hex.h$lo delete 0 end
        for {set hi 0} {$hi <= 7} {incr hi} {
            set num    [lindex $hex_table [expr {$hi * 8 + $lo}]]
            set hi_sym  [lindex $tri_symbol $hi]
            set hi_name [lindex $tlist      $hi]
            set title  [expr {[info exists hexinfo($num,title)] \
                              ? $hexinfo($num,title) : "#$num"}]
            .topbar.mb.m.hex.h$lo add command \
                -label "$hi_sym $hi_name — $title" \
                -command [list set_hexagram_from_trigrams $hi $lo]
        }
    }
}

# ==========================================================================
# NAVIGATION PAR NUMÉRO
# ==========================================================================
proc ask_hexagram_num {} {
    global lang hex_table

    set d .numask
    catch { destroy $d }
    toplevel $d
    wm title $d ""
    wm resizable $d 0 0
    wm transient $d .

    # Variable partagée entre le slider et la spinbox — ils se synchronisent
    set ::_num_val 1

    frame $d.f -padx 20 -pady 14
    pack $d.f

    set prompt [expr {$lang eq "fr" ? "Numéro (1 – 64) :" \
                    : ($lang eq "zh" ? "序号 (1 – 64) :" \
                    : "Number (1 – 64) :")}]
    label $d.f.lbl -text $prompt -font {Helvetica 12}
    pack $d.f.lbl -pady {0 8}

    # Slider horizontal
    scale $d.f.sc -from 1 -to 64 -orient horizontal \
        -variable ::_num_val -length 240 \
        -showvalue 0 -sliderlength 16 -highlightthickness 0
    pack $d.f.sc

    # Spinbox synchronisé via la même variable
    spinbox $d.f.sp -from 1 -to 64 -width 5 \
        -justify center -font {Helvetica 15 bold} \
        -textvariable ::_num_val
    pack $d.f.sp -pady {6 0}

    frame $d.f.btns
    pack $d.f.btns -pady {12 0}

    set ok_lbl     [expr {$lang eq "zh" ? "确定"  : "OK"}]
    set cancel_lbl [expr {$lang eq "fr" ? "Annuler" \
                        : ($lang eq "zh" ? "取消" : "Cancel")}]

    button $d.f.btns.ok -text $ok_lbl -width 7 \
        -command { set ::_num_result $::_num_val; destroy .numask }
    button $d.f.btns.cancel -text $cancel_lbl -width 7 \
        -command { set ::_num_result ""; destroy .numask }
    pack $d.f.btns.ok $d.f.btns.cancel -side left -padx 4

    bind $d.f.sp <Return> { set ::_num_result $::_num_val; destroy .numask }
    bind $d <Escape>      { set ::_num_result ""; destroy .numask }

    # Appliquer le thème
    $d        configure -bg [T bg]
    $d.f      configure -bg [T bg]
    $d.f.lbl  configure -bg [T bg] -fg [T fg]
    $d.f.sc   configure -bg [T bg] -fg [T fg] \
                  -troughcolor [T btn_bg] \
                  -activebackground [T sep] -highlightthickness 0
    $d.f.sp   configure -bg [T btn_bg] -fg [T fg] \
                  -buttonbackground [T btn_bg] \
                  -relief flat -highlightthickness 0
    $d.f.btns configure -bg [T bg]
    foreach btn {ok cancel} {
        $d.f.btns.$btn configure -bg [T btn_bg] -fg [T btn_fg] \
            -relief flat -activebackground [T sep] -activeforeground [T fg]
    }

    # Centrer sur la fenêtre principale
    update idletasks
    set px [expr {[winfo rootx .] + ([winfo width .]  - [winfo reqwidth  $d]) / 2}]
    set py [expr {[winfo rooty .] + ([winfo height .] - [winfo reqheight $d]) / 2}]
    wm geometry $d "+$px+$py"

    grab $d
    focus $d.f.sp
    $d.f.sp selection range 0 end
    tkwait window $d

    set n $::_num_result
    if {$n eq "" || ![string is integer -strict $n]} return
    set n [expr {int($n)}]
    if {$n < 1 || $n > 64} return

    set idx [lsearch -exact $hex_table $n]
    if {$idx < 0} return
    set hi [expr {$idx / 8}]
    set lo [expr {$idx % 8}]
    set_hexagram_from_trigrams $hi $lo
}

# ==========================================================================
# LANCER DES PIÈCES (tirage aléatoire)
# ==========================================================================
# pile = 2 (yin), face = 3 (yang) — méthode traditionnelle des 3 pièces
# Sommes : 6=vieux yin (mut), 7=jeune yang, 8=jeune yin, 9=vieux yang (mut)

proc line_type_desc {sum} {
    global lang
    switch $sum {
        6 { return [expr {$lang eq "fr" ? "6 · vieux yin"  : ($lang eq "zh" ? "6·老阴" : "6 · old yin")}] }
        7 { return [expr {$lang eq "fr" ? "7 · jeune yang" : ($lang eq "zh" ? "7·少阳" : "7 · young yang")}] }
        8 { return [expr {$lang eq "fr" ? "8 · jeune yin"  : ($lang eq "zh" ? "8·少阴" : "8 · young yin")}] }
        9 { return [expr {$lang eq "fr" ? "9 · vieux yang" : ($lang eq "zh" ? "9·老阳" : "9 · old yang")}] }
        default { return "" }
    }
}

proc draw_coin_canvas {coins} {
    global lang
    set c .left.coins.top.c
    $c delete all
    set cy 15
    set i 0
    foreach val $coins {
        set cx [expr {15 + $i * 30}]
        set lbl [expr {$val == 2 \
            ? ($lang eq "zh" ? "字" : ($lang eq "en" ? "T" : "P")) \
            : ($lang eq "zh" ? "花" : ($lang eq "en" ? "H" : "F"))}]
        if {$val == 3} {
            $c create oval \
                [expr {$cx-11}] [expr {$cy-11}] \
                [expr {$cx+11}] [expr {$cy+11}] \
                -fill [T accent] -outline [T accent]
            $c create text $cx $cy -text $lbl \
                -fill [T bg] -font {Helvetica 8 bold} -anchor center
        } else {
            $c create oval \
                [expr {$cx-11}] [expr {$cy-11}] \
                [expr {$cx+11}] [expr {$cy+11}] \
                -fill [T bg_left] -outline [T accent] -width 2
            $c create text $cx $cy -text $lbl \
                -fill [T accent] -font {Helvetica 8 bold} -anchor center
        }
        incr i
    }
}

proc update_coins_ui {coins sum} {
    global lang
    set ::rand_last_coins $coins
    set ::rand_last_sum   $sum
    draw_coin_canvas $coins
    if {$sum > 0} {
        .left.coins.top.sum configure -text [line_type_desc $sum]
    } else {
        .left.coins.top.sum configure -text ""
    }
    if {$::rand_line > 6} {
        set done [expr {$lang eq "fr" ? "Terminé ✓" \
                      : ($lang eq "zh" ? "完成 ✓" : "Done ✓")}]
        .left.coins.prog configure -text $done
    } else {
        set n $::rand_line
        set prog [expr {$lang eq "fr" ? "Ligne $n / 6" \
                      : ($lang eq "zh" ? "第${n}爻" : "Line $n / 6")}]
        .left.coins.prog configure -text $prog
    }
}

proc hide_coins_panel {} {
    set ::rand_line       0
    set ::rand_last_coins {}
    set ::rand_last_sum   0
    catch { pack forget .left.coins }
    apply_info_visibility
}

proc start_random {} {
    global lines mutations lang ui_labels
    for {set i 1} {$i <= 6} {incr i} {
        set lines($i)     0
        set mutations($i) 0
    }
    set ::rand_line 1
    set ::rand_last_coins {}
    set ::rand_last_sum   0
    refresh
    if {[winfo manager .left] eq ""} {
        pack .left -side left -fill both -padx {12 4} -pady 12 -before .right
        pack .sep  -side left -fill y    -pady 8       -before .right
    }
    if {[winfo manager .left.coins] eq ""} {
        pack .left.coins -fill x -padx 12 -pady {4 10}
    }
    .left.coins.top.btn configure \
        -text $ui_labels($lang,toss) -state normal
    update_coins_ui {} 0
}

proc toss_coins {} {
    global lines mutations
    if {$::rand_line < 1 || $::rand_line > 6} return
    expr {srand([clock clicks])}
    set coins {}
    set sum 0
    for {set i 0} {$i < 3} {incr i} {
        set v [expr {int(rand() * 2) == 0 ? 2 : 3}]
        lappend coins $v
        incr sum $v
    }
    set n $::rand_line
    switch $sum {
        6 { set lines($n) 0; set mutations($n) 1 }
        7 { set lines($n) 1; set mutations($n) 0 }
        8 { set lines($n) 0; set mutations($n) 0 }
        9 { set lines($n) 1; set mutations($n) 1 }
    }
    incr ::rand_line
    update_coins_ui $coins $sum
    refresh
    if {$::rand_line > 6} {
        .left.coins.top.btn configure -state disabled
        after 2000 hide_coins_panel
    }
}

# ==========================================================================
# MUTATION
# ==========================================================================
proc get_mutated_lines {} {
    global lines mutations
    array set ml {}
    for {set i 1} {$i <= 6} {incr i} {
        set ml($i) [expr {$lines($i) ^ $mutations($i)}]
    }
    return [array get ml]
}

proc get_hexagram_from {lv} {
    global hex_table
    array set l $lv
    set lo [expr {$l(1) + $l(2)*2 + $l(3)*4}]
    set hi [expr {$l(4) + $l(5)*2 + $l(6)*4}]
    return [lindex $hex_table [expr {$hi * 8 + $lo}]]
}

proc has_mutations {} {
    global mutations
    for {set i 1} {$i <= 6} {incr i} {
        if {$mutations($i)} { return 1 }
    }
    return 0
}

proc refresh_mutation_panel {} {
    global hexinfo
    set lv  [get_mutated_lines]
    set num [get_hexagram_from $lv]
    set nm  {1 0 2 0 3 0 4 0 5 0 6 0}
    _draw_hexagram_on .mut.mid.c   $lv $nm
    _draw_trigrams_on .mut.mid.tri $lv
    set title [expr {[info exists hexinfo($num,title)] ? $hexinfo($num,title) : $num}]
    .mut.num configure -text "→  $title"
}

# Mode A : le résultat devient le courant, mutations effacées
proc apply_mutation_replace {} {
    global lines mutations
    array set ml [get_mutated_lines]
    for {set i 1} {$i <= 6} {incr i} {
        set lines($i)     $ml($i)
        set mutations($i) 0
    }
    refresh
}

# Mode B : navigue vers le muté en gardant les mêmes positions de mutation.
# Les positions sont symétriques : elles pointent en retour vers l'original.
proc apply_mutation_navigate {} {
    global lines mutations
    array set ml [get_mutated_lines]
    for {set i 1} {$i <= 6} {incr i} {
        set lines($i) $ml($i)
        # mutations($i) inchangé — même positions, sens inverse
    }
    refresh
}

proc apply_mutation {} {
    if {$::mut_nav_mode} {
        apply_mutation_navigate
    } else {
        apply_mutation_replace
    }
}

proc update_mutation_visibility {} {
    if {[has_mutations]} {
        if {[winfo manager .mutsep] eq ""} {
            pack .mutsep -side left -fill y -pady 8 -after .right
            pack .mut    -side left -fill y -padx {4 12} -pady 12 -after .mutsep
            if {!$::show_trigrams} { pack forget .mut.mid.tri }
        }
        refresh_mutation_panel
    } else {
        pack forget .mutsep
        pack forget .mut
    }
}

# ==========================================================================
# APPLICATION DU THÈME
# ==========================================================================
proc apply_theme {{theme ""}} {
    if {$theme ne ""} { set ::current_theme $theme }

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

    . configure -bg [T bg]

    .topbar       configure -bg [T bg]
    .topbar.title configure -bg [T bg] -fg [T fg2]
    .topbar.mb    configure -bg [T bg] -fg [T fg] \
        -activebackground [T sep] -activeforeground [T fg]
    .topbar.sep   configure -bg [T sep]
    catch { .topbar.mb.m       configure -bg [T btn_bg] -fg [T fg] }
    catch { .topbar.mb.m.lang  configure -bg [T btn_bg] -fg [T fg] }
    catch { .topbar.mb.m.theme configure -bg [T btn_bg] -fg [T fg] }
    catch { .topbar.mb.m.hex   configure -bg [T btn_bg] -fg [T fg] }
    for {set _lo 0} {$_lo <= 7} {incr _lo} {
        catch { .topbar.mb.m.hex.h$_lo configure -bg [T btn_bg] -fg [T fg] }
    }

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

    .sep configure -bg [T sep]

    .right         configure -bg [T bg]
    .right.mid     configure -bg [T bg]
    .right.mid.c   configure -bg [T bg]
    .right.mid.tri configure -bg [T bg]
    .right.num     configure -bg [T bg] -fg [T accent]

    .mutsep         configure -bg [T sep]
    .mut            configure -bg [T bg]
    .mut.mid        configure -bg [T bg]
    .mut.mid.c      configure -bg [T bg]
    .mut.mid.tri    configure -bg [T bg]
    .mut.num        configure -bg [T bg] -fg [T accent]

    catch {
        .left.coins         configure -bg [T bg_left]
        .left.coins.top     configure -bg [T bg_left]
        .left.coins.top.btn configure -bg [T btn_bg] -fg [T btn_fg] \
            -activebackground [T sep] -activeforeground [T fg] -relief flat
        .left.coins.top.c   configure -bg [T bg_left]
        .left.coins.top.sum configure -bg [T bg_left] -fg [T fg2]
        .left.coins.prog    configure -bg [T bg_left] -fg [T fg2]
        draw_coin_canvas $::rand_last_coins
    }

    draw_hexagram
    draw_trigrams
    if {[has_mutations]} { refresh_mutation_panel }

    if {$theme ne ""} { save_ini }
}

# ==========================================================================
# ACTIONS
# ==========================================================================
proc update_ui_labels {} {
    global lang ui_labels
    if {$::rand_line > 0 && $::rand_line <= 6} {
        .right.num configure -text ""
    } else {
        set h [get_hexagram]
        .right.num configure -text "$ui_labels($lang,hexagram)  $h"
    }
    # Indices : 0=HexNav 1=ParNuméro 2=sep 3=Random 4=Reset
    #           5=sep 6=Trigr 7=Info 8=MutNav
    #           9=sep 10=Langue 11=Thème(end)
    catch {
        set lang_label [expr {$lang eq "fr" ? "Langue" \
                            : ($lang eq "zh" ? "语言" : "Language")}]
        .topbar.mb.m entryconfigure 0   -label $ui_labels($lang,hex_nav)
        .topbar.mb.m entryconfigure 1   -label $ui_labels($lang,goto_num)
        .topbar.mb.m entryconfigure 3   -label $ui_labels($lang,random)
        .topbar.mb.m entryconfigure 4   -label $ui_labels($lang,reset)
        .topbar.mb.m entryconfigure 6   -label $ui_labels($lang,trigrams)
        .topbar.mb.m entryconfigure 7   -label $ui_labels($lang,show_info)
        .topbar.mb.m entryconfigure 8   -label $ui_labels($lang,mut_nav)
        .topbar.mb.m entryconfigure 10  -label $lang_label
        .topbar.mb.m entryconfigure end -label $ui_labels($lang,theme)
    }
    if {[winfo manager .left.coins] ne ""} {
        .left.coins.top.btn configure -text $ui_labels($lang,toss)
        update_coins_ui $::rand_last_coins $::rand_last_sum
    }
}

proc refresh {} {
    draw_hexagram
    draw_trigrams
    if {$::rand_line > 0 && $::rand_line <= 6} {
        _update_info_widget .left.txt 0
    } else {
        update_info [get_hexagram]
    }
    update_ui_labels
    update_mutation_visibility
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

proc on_rclick {y_click} {
    global mutations
    for {set i 1} {$i <= 6} {incr i} {
        if {abs($y_click - [y_of $i]) <= 20} {
            set mutations($i) [expr {1 - $mutations($i)}]
            refresh
            return
        }
    }
}

proc reset_all {} {
    global lines mutations
    for {set i 1} {$i <= 6} {incr i} {
        set lines($i)     1
        set mutations($i) 0
    }
    hide_coins_panel
    refresh
}

proc set_lang {l} {
    global lang
    set lang $l
    load_hexagrams
    build_hex_menu
    draw_trigrams
    update_info [get_hexagram]
    update_ui_labels
    if {[has_mutations]} { refresh_mutation_panel }
    save_ini
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
# Indices : 0=HexNav 1=ParNuméro 2=sep 3=Random 4=Reset
#           5=sep 6=Trigr 7=Info 8=MutNav 9=sep 10=Langue 11=Thème
menubutton .topbar.mb -text "☰" -font {Helvetica 15} \
    -relief flat -padx 10 -pady 4 -cursor hand2
pack .topbar.mb -side right -padx 4

menu .topbar.mb.m -tearoff 0

# Navigation par trigrammes (bas → haut)
# Peuplé par build_hex_menu ; entrée principale = trigramme du bas
menu .topbar.mb.m.hex -tearoff 0
for {set _lo 0} {$_lo <= 7} {incr _lo} {
    menu .topbar.mb.m.hex.h$_lo -tearoff 0
    .topbar.mb.m.hex add cascade -label "" -menu .topbar.mb.m.hex.h$_lo
}
.topbar.mb.m add cascade -label "Hexagramme →" -menu .topbar.mb.m.hex  ;# 0

# Navigation par numéro
.topbar.mb.m add command -label "Par numéro…" \
    -command ask_hexagram_num                                            ;# 1

.topbar.mb.m add separator                                               ;# 2

.topbar.mb.m add command -label "Aléatoire" \
    -command start_random                                                ;# 3
.topbar.mb.m add command -label "Réinitialiser" -command reset_all      ;# 4

.topbar.mb.m add separator                                               ;# 5

# Toggles d'affichage
.topbar.mb.m add checkbutton -label "Trigrammes" \
    -variable ::show_trigrams -onvalue 1 -offvalue 0 \
    -command apply_trigrams_visibility                                   ;# 6

.topbar.mb.m add checkbutton -label "Panneau d'informations" \
    -variable ::show_info -onvalue 1 -offvalue 0 \
    -command apply_info_visibility                                       ;# 7

.topbar.mb.m add checkbutton -label "Mutation ↔ naviguer" \
    -variable ::mut_nav_mode -onvalue 1 -offvalue 0 \
    -command save_ini                                                    ;# 8

.topbar.mb.m add separator                                               ;# 9

# Langue et Thème en bas
menu .topbar.mb.m.lang -tearoff 0
.topbar.mb.m.lang add command -label "Français" -command {set_lang fr}
.topbar.mb.m.lang add command -label "English"  -command {set_lang en}
.topbar.mb.m.lang add command -label "中文"      -command {set_lang zh}
.topbar.mb.m add cascade -label "Langue" -menu .topbar.mb.m.lang       ;# 10

menu .topbar.mb.m.theme -tearoff 0
foreach th {light dark sepia green} {
    .topbar.mb.m.theme add command -label $th -command [list apply_theme $th]
}
.topbar.mb.m add cascade -label "Thème" -menu .topbar.mb.m.theme       ;# 11

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

# ── Panneau tirage (créé mais non packé ; apparaît sur Aléatoire) ─────────
frame .left.coins
frame .left.coins.top
pack .left.coins.top -fill x

button .left.coins.top.btn -text "Lancer" -command toss_coins \
    -font {Helvetica 11} -relief flat -cursor hand2 -padx 8 -pady 4
pack .left.coins.top.btn -side left

canvas .left.coins.top.c -width 92 -height 30 -highlightthickness 0
pack .left.coins.top.c -side left -padx {8 4}

label .left.coins.top.sum -text "" -font {Helvetica 10}
pack .left.coins.top.sum -side left

label .left.coins.prog -text "" -font {Helvetica 10 italic}
pack .left.coins.prog -anchor w -padx 4 -pady {2 0}

# Séparateur vertical
frame .sep -width 1
pack .sep -side left -fill y -pady 8

# Panneau droit — hexagramme courant
frame .right
pack .right -side left -fill y -padx {4 12} -pady 12

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

bind .right.mid.c <Button-1> {on_click  %y}
bind .right.mid.c <Button-3> {on_rclick %y}

# ── Panneau mutation (créé mais non packé ; apparaît automatiquement) ─────

frame .mutsep -width 1

frame .mut

frame .mut.mid
pack .mut.mid -pady {10 4}

canvas .mut.mid.c -width 260 -height 310 \
    -highlightthickness 0
pack .mut.mid.c -side left

canvas .mut.mid.tri -width 100 -height 310 \
    -highlightthickness 0
pack .mut.mid.tri -side left -padx {4 0}

label .mut.num -text "" -font {Helvetica 14 bold} -wraplength 360 -cursor hand2
pack .mut.num -pady {4 14}
bind .mut.num <Button-1> apply_mutation

# ==========================================================================
# INITIALISATION
# ==========================================================================
load_ini                   ;# restaure theme/lang/visibilité avant tout
load_hexagrams
build_hex_menu
apply_theme                ;# utilise ::current_theme chargé depuis l'ini
update_ui_labels
update_info [get_hexagram]
apply_trigrams_visibility  ;# applique show_trigrams chargé depuis l'ini
apply_info_visibility      ;# applique show_info chargé depuis l'ini
