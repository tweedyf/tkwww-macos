# tk.tcl --
#
# Initialization script normally executed in the interpreter for each
# Tk-based application.  Arranges class bindings for widgets.
#
# /mit/tkwww/CVS/WWW/TkWWW/Tcl/binary.tk.tcl,v 1.1 1994/06/09 11:41:41 joe Exp SPRITE (Berkeley)
#
# Copyright (c) 1992-1993 The Regents of the University of California.
# All rights reserved.
#
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in
# all copies of this software.
#
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
# CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

# Insist on running with compatible versions of Tcl and Tk.


# Add Tk's directory to the end of the auto-load search path:

lappend auto_path $tk_library

# Turn off strict Motif look and feel as a default.

set tk_strictMotif 0

# normally auto-loaded files
# button.tcl --
#
# This file contains Tcl procedures used to manage Tk buttons.
#
# /mit/tkwww/CVS/WWW/TkWWW/Tcl/binary.tk.tcl,v 1.1 1994/06/09 11:41:41 joe Exp SPRITE (Berkeley)
#
# Copyright (c) 1992-1993 The Regents of the University of California.
# All rights reserved.
#
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in
# all copies of this software.
#
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
# CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#

# The procedure below is invoked when the mouse pointer enters a
# button widget.  It records the button we're in and changes the
# state of the button to active unless the button is disabled.

proc tk_butEnter w {
    global tk_priv tk_strictMotif
    if {[lindex [$w config -state] 4] != "disabled"} {
	if {!$tk_strictMotif} {
	    $w config -state active
	}
	set tk_priv(window) $w
    }
}

# The procedure below is invoked when the mouse pointer leaves a
# button widget.  It changes the state of the button back to
# inactive.

proc tk_butLeave w {
    global tk_priv tk_strictMotif
    if {[lindex [$w config -state] 4] != "disabled"} {
	if {!$tk_strictMotif} {
	    $w config -state normal
	}
    }
    set tk_priv(window) ""
}

# The procedure below is invoked when the mouse button is pressed in
# a button/radiobutton/checkbutton widget.  It records information
# (a) to indicate that the mouse is in the button, and
# (b) to save the button's relief so it can be restored later.

proc tk_butDown w {
    global tk_priv
    set tk_priv(relief) [lindex [$w config -relief] 4]
    set tk_priv(buttonWindow) $w
    if {[lindex [$w config -state] 4] != "disabled"} {
	$w config -relief sunken
    }
}

# The procedure below is invoked when the mouse button is released
# for a button/radiobutton/checkbutton widget.  It restores the
# button's relief and invokes the command as long as the mouse
# hasn't left the button.

proc tk_butUp w {
    global tk_priv
    if {$w == $tk_priv(buttonWindow)} {
	$w config -relief $tk_priv(relief)
	if {($w == $tk_priv(window))
		&& ([lindex [$w config -state] 4] != "disabled")} {
	    uplevel #0 [list $w invoke]
	}
	set tk_priv(buttonWindow) ""
    }
}
# dialog.tcl --
#
# This file defines the procedure tk_dialog, which creates a dialog
# box containing a bitmap, a message, and one or more buttons.
#
# /mit/tkwww/CVS/WWW/TkWWW/Tcl/binary.tk.tcl,v 1.1 1994/06/09 11:41:41 joe Exp SPRITE (Berkeley)
#
# Copyright (c) 1992-1993 The Regents of the University of California.
# All rights reserved.
#
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in
# all copies of this software.
#
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
# CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#

#
# tk_dialog:
#
# This procedure displays a dialog box, waits for a button in the dialog
# to be invoked, then returns the index of the selected button.
#
# Arguments:
# w -		Window to use for dialog top-level.
# title -	Title to display in dialog's decorative frame.
# text -	Message to display in dialog.
# bitmap -	Bitmap to display in dialog (empty string means none).
# default -	Index of button that is to display the default ring
#		(-1 means none).
# args -	One or more strings to display in buttons across the
#		bottom of the dialog box.

proc tk_dialog {w title text bitmap default args} {
    global tk_priv

    # 1. Create the top-level window and divide it into top
    # and bottom parts.

    catch {destroy $w}
    toplevel $w -class Dialog
    wm title $w $title
    wm iconname $w Dialog
    frame $w.top -relief raised -bd 1
    pack $w.top -side top -fill both
    frame $w.bot -relief raised -bd 1
    pack $w.bot -side bottom -fill both

    # 2. Fill the top part with bitmap and message.

    message $w.msg -width 3i -text $text \
	    -font -Adobe-Times-Medium-R-Normal-*-180-*
    pack $w.msg -in $w.top -side right -expand 1 -fill both -padx 5m -pady 5m
    if {$bitmap != ""} {
	label $w.bitmap -bitmap $bitmap
	pack $w.bitmap -in $w.top -side left -padx 5m -pady 5m
    }

    # 3. Create a row of buttons at the bottom of the dialog.

    set i 0
    foreach but $args {
	button $w.button$i -text $but -command "set tk_priv(button) $i"
	if {$i == $default} {
	    frame $w.default -relief sunken -bd 1
	    raise $w.button$i $w.default
	    pack $w.default -in $w.bot -side left -expand 1 -padx 3m -pady 2m
	    pack $w.button$i -in $w.default -padx 2m -pady 2m \
		    -ipadx 2m -ipady 1m
	    bind $w <Return> "$w.button$i flash; set tk_priv(button) $i"
	} else {
	    pack $w.button$i -in $w.bot -side left -expand 1 \
		    -padx 3m -pady 3m -ipadx 2m -ipady 1m
	}
	incr i
    }

    # 4. Withdraw the window, then update all the geometry information
    # so we know how big it wants to be, then center the window in the
    # display and de-iconify it.

    wm withdraw $w
    update idletasks
    set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx [winfo parent $w]]]
    set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty [winfo parent $w]]]
    wm geom $w +$x+$y
    wm deiconify $w

    # 5. Set a grab and claim the focus too.

    set oldFocus [focus]
    grab $w
    focus $w

    # 6. Wait for the user to respond, then restore the focus and
    # return the index of the selected button.

    tkwait variable tk_priv(button)
    destroy $w
    focus $oldFocus
    return $tk_priv(button)
}
# entry.tcl --
#
# This file contains Tcl procedures used to manage Tk entries.
#
# /mit/tkwww/CVS/WWW/TkWWW/Tcl/binary.tk.tcl,v 1.1 1994/06/09 11:41:41 joe Exp SPRITE (Berkeley)
#
# Copyright (c) 1992-1993 The Regents of the University of California.
# All rights reserved.
#
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in
# all copies of this software.
#
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
# CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#

# The procedure below is invoked to backspace over one character
# in an entry widget.  The name of the widget is passed as argument.

proc tk_entryBackspace w {
    set x [expr {[$w index insert] - 1}]
    if {$x != -1} {$w delete $x}
}

# The procedure below is invoked to backspace over one word in an
# entry widget.  The name of the widget is passed as argument.

proc tk_entryBackword w {
    set string [$w get]
    set curs [expr [$w index insert]-1]
    if {$curs < 0} return
    for {set x $curs} {$x > 0} {incr x -1} {
	if {([string first [string index $string $x] " \t"] < 0)
		&& ([string first [string index $string [expr $x-1]] " \t"]
		>= 0)} {
	    break
	}
    }
    $w delete $x $curs
}

# The procedure below is invoked after insertions.  If the caret is not
# visible in the window then the procedure adjusts the entry's view to
# bring the caret back into the window again.  Also, try to keep at
# least one character visible to the left of the caret.

proc tk_entrySeeCaret w {
    set c [$w index insert]
    set left [$w index @0]
    if {$left >= $c} {
	if {$c > 0} {
	    $w view [expr $c-1]
	} else {
	    $w view $c
	}
	return
    }
    while {([$w index @[expr [winfo width $w]-5]] < $c)
	    && ($left < $c)} {
	set left [expr $left+1]
	$w view $left
    }
}
# listbox.tcl --
#
# This file contains Tcl procedures used to manage Tk listboxes.
#
# /mit/tkwww/CVS/WWW/TkWWW/Tcl/binary.tk.tcl,v 1.1 1994/06/09 11:41:41 joe Exp SPRITE (Berkeley)
#
# Copyright (c) 1992-1993 The Regents of the University of California.
# All rights reserved.
#
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in
# all copies of this software.
#
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
# CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#

# The procedure below may be invoked to change the behavior of
# listboxes so that only a single item may be selected at once.
# The arguments give one or more windows whose behavior should
# be changed;  if one of the arguments is "Listbox" then the default
# behavior is changed for all listboxes.

proc tk_listboxSingleSelect args {
    foreach w $args {
	bind $w <B1-Motion> {%W select from [%W nearest %y]} 
	bind $w <Shift-1> {%W select from [%W nearest %y]}
	bind $w <Shift-B1-Motion> {%W select from [%W nearest %y]}
    }
}
# menu.tcl --
#
# This file contains Tcl procedures used to manage Tk menus and
# menubuttons.  Most of the code here is dedicated to support for
# pulling down menus and menu traversal via the keyboard.
#
# /mit/tkwww/CVS/WWW/TkWWW/Tcl/binary.tk.tcl,v 1.1 1994/06/09 11:41:41 joe Exp SPRITE (Berkeley)
#
# Copyright (c) 1992-1993 The Regents of the University of California.
# All rights reserved.
#
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in
# all copies of this software.
#
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
# CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#

# The procedure below is publically available.  It is used to identify
# a frame that serves as a menu bar and the menu buttons that lie inside
# the menu bar.  This procedure establishes proper "menu bar" behavior
# for all of the menu buttons, including keyboard menu traversal.  Only
# one menu bar may exist for a given top-level window at a time.
# Arguments:
#	
# bar -				The path name of the containing frame.  Must
#				be an ancestor of all of the menu buttons,
#				since it will be be used in grabs.
# additional arguments -	One or more menu buttons that are descendants
#				of bar.  The order of these arguments
#				determines the order of keyboard traversal.
#				If no extra arguments are named then all of
#				the menu bar information for bar is cancelled.

proc tk_menuBar {w args} {
    global tk_priv
    if {$args == ""} {
	if [catch {set menus $tk_priv(menusFor$w)}] {
	    return ""
	}
	return $menus
    }
    if [info exists tk_priv(menusFor$w)] {
	unset tk_priv(menusFor$w)
	unset tk_priv(menuBarFor[winfo toplevel $w])
    }
    if {$args == "{}"} {
	return
    }
    set tk_priv(menusFor$w) $args
    set tk_priv(menuBarFor[winfo toplevel $w]) $w
    bind $w <Any-Alt-KeyPress> {tk_traverseToMenu %W %A}
    bind $w <F10> {tk_firstMenu %W}
    bind $w <Any-ButtonRelease-1> tk_mbUnpost
}

proc tk_menus {w args} {
    error "tk_menus is obsolete in Tk versions 3.0 and later; please change your scripts to use tk_menuBar instead"
}

# The procedure below is publically available.  It takes any number of
# arguments that are names of widgets or classes.  It sets up bindings
# for the widgets or classes so that keyboard menu traversal is possible
# when the input focus is in those widgets or classes.

proc tk_bindForTraversal args {
    foreach w $args {
	bind $w <Any-Alt-KeyPress> {tk_traverseToMenu %W %A}
	bind $w <F10> {tk_firstMenu %W}
    }
}

# The procedure below does all of the work of posting a menu (including
# unposting any other menu that might currently be posted).  The "w"
# argument is the name of the menubutton for the menu to be posted.
# Note:  if $w is disabled then the procedure does nothing.

proc tk_mbPost {w} {
    global tk_priv tk_strictMotif
    if {[lindex [$w config -state] 4] == "disabled"} {
	return
    }
    if {$w == $tk_priv(posted)} {
	grab -global $tk_priv(grab)
	return
    }
    set menu [lindex [$w config -menu] 4]
    if {$menu == ""} {
	return
    }
    if ![string match $w* $menu] {
	error "can't post $menu:  it isn't a descendant of $w (this is a new requirement in Tk versions 3.0 and later)"
    }
    set cur $tk_priv(posted)
    if {$cur != ""} tk_mbUnpost
    set tk_priv(relief) [lindex [$w config -relief] 4]
    $w config -relief raised
    set tk_priv(posted) $w
    if {$tk_priv(focus) == ""} {
	set tk_priv(focus) [focus]
    }
    set tk_priv(activeBg) [lindex [$menu config -activebackground] 4]
    set tk_priv(activeFg) [lindex [$menu config -activeforeground] 4]
    if $tk_strictMotif {
	$menu config -activebackground [lindex [$menu config -background] 4]
	$menu config -activeforeground [lindex [$menu config -foreground] 4]
    }
    $menu activate none
    focus $menu
    $menu post [winfo rootx $w] [expr [winfo rooty $w]+[winfo height $w]]
    if [catch {set grab $tk_priv(menuBarFor[winfo toplevel $w])}] {
	set grab $w
    } else {
	if [lsearch $tk_priv(menusFor$grab) $w]<0 {
	    set grab $w
	}
    }
    set tk_priv(cursor) [lindex [$grab config -cursor] 4]
    $grab config -cursor arrow
    set tk_priv(grab) $grab
    grab -global $grab
}

# The procedure below does all the work of unposting the menubutton that's
# currently posted.  It takes no arguments.  Special notes:
# 1. It's important to unpost the menu before releasing the grab, so
#    that any Enter-Leave events (e.g. from menu back to main
#    application) have mode NotifyGrab.
# 2. Be sure to enclose various groups of commands in "catch" so that
#    the procedure will complete even if the menubutton or the menu
#    or the grab window has been deleted.

proc tk_mbUnpost {} {
    global tk_priv
    set w $tk_priv(posted)
    if {$w != ""} {
	catch {
	    set menu [lindex [$w config -menu] 4]
	    $menu unpost
	    $menu config -activebackground $tk_priv(activeBg)
	    $menu config -activeforeground $tk_priv(activeFg)
	    $w config -relief $tk_priv(relief)
	}
	catch {$tk_priv(grab) config -cursor $tk_priv(cursor)}
	catch {focus $tk_priv(focus)}
	grab release $tk_priv(grab)
	set tk_priv(grab) ""
	set tk_priv(focus) ""
	set tk_priv(posted) {}
    }
}

# The procedure below is invoked to implement keyboard traversal to
# a menu button.  It takes two arguments:  the name of a window where
# a keystroke originated, and the ascii character that was typed.
# This procedure finds a menu bar by looking upward for a top-level
# window, then looking for a window underneath that named "menu".
# Then it searches through all the subwindows of "menu" for a menubutton
# with an underlined character matching char.  If one is found, it
# posts that menu.

proc tk_traverseToMenu {w char} {
    global tk_priv
    if {$char == ""} {
	return
    }
    set char [string tolower $char]

    foreach mb [tk_getMenuButtons $w] {
	if {[winfo class $mb] == "Menubutton"} {
	    set char2 [string index [lindex [$mb config -text] 4] \
		    [lindex [$mb config -underline] 4]]
	    if {[string compare $char [string tolower $char2]] == 0} {
		tk_mbPost $mb
		[lindex [$mb config -menu] 4] activate 0
		return
	    }
	}
    }
}

# The procedure below is used to implement keyboard traversal within
# the posted menu.  It takes two arguments:  the name of the menu to
# be traversed within, and an ASCII character.  It searches for an
# entry in the menu that has that character underlined.  If such an
# entry is found, it is invoked and the menu is unposted.

proc tk_traverseWithinMenu {w char} {
    if {$char == ""} {
	return
    }
    set char [string tolower $char]
    set last [$w index last]
    if {$last == "none"} {
	return
    }
    for {set i 0} {$i <= $last} {incr i} {
	if [catch {set char2 [string index \
		[lindex [$w entryconfig $i -label] 4] \
		[lindex [$w entryconfig $i -underline] 4]]}] {
	    continue
	}
	if {[string compare $char [string tolower $char2]] == 0} {
	    tk_mbUnpost
	    $w invoke $i
	    return
	}
    }
}

# The procedure below takes a single argument, which is the name of
# a window.  It returns a list containing path names for all of the
# menu buttons associated with that window's top-level window, or an
# empty list if there are none.

proc tk_getMenuButtons w {
    global tk_priv
    set top [winfo toplevel $w]
    if [catch {set bar [set tk_priv(menuBarFor$top)]}] {
	return ""
    }
    return $tk_priv(menusFor$bar)
}

# The procedure below is used to traverse to the next or previous
# menu in a menu bar.  It takes one argument, which is a count of
# how many menu buttons forward or backward (if negative) to move.
# If there is no posted menu then this procedure has no effect.

proc tk_nextMenu count {
    global tk_priv
    if {$tk_priv(posted) == ""} {
	return
    }
    set buttons [tk_getMenuButtons $tk_priv(posted)]
    set length [llength $buttons]
    for {set i 0} 1 {incr i} {
	if {$i >= $length} {
	    return
	}
	if {[lindex $buttons $i] == $tk_priv(posted)} {
	    break
	}
    }
    incr i $count
    while 1 {
	while {$i < 0} {
	    incr i $length
	}
	while {$i >= $length} {
	    incr i -$length
	}
	set mb [lindex $buttons $i]
	if {[lindex [$mb configure -state] 4] != "disabled"} {
	    break
	}
	incr i $count
    }
    tk_mbUnpost
    tk_mbPost $mb
    [lindex [$mb config -menu] 4] activate 0
}

# The procedure below is used to traverse to the next or previous entry
# in the posted menu.  It takes one argument, which is 1 to go to the
# next entry or -1 to go to the previous entry.  Disabled entries are
# skipped in this process.

proc tk_nextMenuEntry count {
    global tk_priv
    if {$tk_priv(posted) == ""} {
	return
    }
    set menu [lindex [$tk_priv(posted) config -menu] 4]
    if {[$menu index last] == "none"} {
	return
    }
    set length [expr [$menu index last]+1]
    set i [$menu index active]
    if {$i == "none"} {
	set i 0
    } else {
	incr i $count
    }
    while 1 {
	while {$i < 0} {
	    incr i $length
	}
	while {$i >= $length} {
	    incr i -$length
	}
	if {[catch {$menu entryconfigure $i -state} state] == 0} {
	    if {[lindex $state 4] != "disabled"} {
		break
	    }
	}
	incr i $count
    }
    $menu activate $i
}

# The procedure below invokes the active entry in the posted menu,
# if there is one.  Otherwise it does nothing.

proc tk_invokeMenu {menu} {
    set i [$menu index active]
    if {$i != "none"} {
	tk_mbUnpost
	update idletasks
	$menu invoke $i
    }
}

# The procedure below is invoked to keyboard-traverse to the first
# menu for a given source window.  The source window is passed as
# parameter.

proc tk_firstMenu w {
    set mb [lindex [tk_getMenuButtons $w] 0]
    if {$mb != ""} {
	tk_mbPost $mb
	[lindex [$mb config -menu] 4] activate 0
    }
}

# The procedure below is invoked when a button-1-down event is
# received by a menu button.  If the mouse is in the menu button
# then it posts the button's menu.  If the mouse isn't in the
# button's menu, then it deactivates any active entry in the menu.
# Remember, event-sharing can cause this procedure to be invoked
# for two different menu buttons on the same event.

proc tk_mbButtonDown w {
    global tk_priv
    if {[lindex [$w config -state] 4] == "disabled"} {
	return
    }
    if {$tk_priv(inMenuButton) == $w} {
	tk_mbPost $w
    }
}
# text.tcl --
#
# This file contains Tcl procedures used to manage Tk entries.
#
# /mit/tkwww/CVS/WWW/TkWWW/Tcl/binary.tk.tcl,v 1.1 1994/06/09 11:41:41 joe Exp SPRITE (Berkeley)
#
# Copyright (c) 1992-1993 The Regents of the University of California.
# All rights reserved.
#
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in
# all copies of this software.
#
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
# CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
# ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
# PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#

# The procedure below is invoked when dragging one end of the selection.
# The arguments are the text window name and the index of the character
# that is to be the new end of the selection.

proc tk_textSelectTo {w index} {
    global tk_priv

    case $tk_priv(selectMode) {
	char {
	    if [$w compare $index < anchor] {
		set first $index
		set last anchor
	    } else {
		set first anchor
		set last [$w index $index+1c]
	    }
	}
	word {
	    if [$w compare $index < anchor] {
		set first [$w index "$index wordstart"]
		set last [$w index "anchor wordend"]
	    } else {
		set first [$w index "anchor wordstart"]
		set last [$w index "$index wordend"]
	    }
	}
	line {
	    if [$w compare $index < anchor] {
		set first [$w index "$index linestart"]
		set last [$w index "anchor lineend + 1c"]
	    } else {
		set first [$w index "anchor linestart"]
		set last [$w index "$index lineend + 1c"]
	    }
	}
    }
    $w tag remove sel 0.0 $first
    $w tag add sel $first $last
    $w tag remove sel $last end
}

# The procedure below is invoked to backspace over one character in
# a text widget.  The name of the widget is passed as argument.

proc tk_textBackspace w {
    $w delete insert-1c insert
}

# The procedure below compares three indices, a, b, and c.  Index b must
# be less than c.  The procedure returns 1 if a is closer to b than to c,
# and 0 otherwise.  The "w" argument is the name of the text widget in
# which to do the comparison.

proc tk_textIndexCloser {w a b c} {
    set a [$w index $a]
    set b [$w index $b]
    set c [$w index $c]
    if [$w compare $a <= $b] {
	return 1
    }
    if [$w compare $a >= $c] {
	return 0
    }
    scan $a "%d.%d" lineA chA
    scan $b "%d.%d" lineB chB
    scan $c "%d.%d" lineC chC
    if {$chC == 0} {
	incr lineC -1
	set chC [string length [$w get $lineC.0 $lineC.end]]
    }
    if {$lineB != $lineC} {
	return [expr {($lineA-$lineB) < ($lineC-$lineA)}]
    }
    return [expr {($chA-$chB) < ($chC-$chA)}]
}

# The procedure below is called to reset the selection anchor to
# whichever end is FARTHEST from the index argument.

proc tk_textResetAnchor {w index} {
    global tk_priv
    if {[$w tag ranges sel] == ""} {
	set tk_priv(selectMode) char
	$w mark set anchor $index
	return
    }
    if [tk_textIndexCloser $w $index sel.first sel.last] {
	if {$tk_priv(selectMode) == "char"} {
	    $w mark set anchor sel.last
	} else {
	    $w mark set anchor sel.last-1c
	}
    } else {
	$w mark set anchor sel.first
    }
}
# This file contains a default version of the tkError procedure.  It
# posts a dialog box with the error message and gives the user a chance
# to see a more detailed stack trace.

proc tkerror err {
    global errorInfo
    set info $errorInfo
    if {[tk_dialog .tkerrorDialog "Error in Tcl Script" \
	    "Error: $err" error 0 OK "See Stack Trace"] == 0} {
	return
    }

    set w .tkerrorTrace
    catch {destroy $w}
    toplevel $w -class ErrorTrace
    wm minsize $w 1 1
    wm title $w "Stack Trace for Error"
    wm iconname $w "Stack Trace"
    button $w.ok -text OK -command "destroy $w"
    text $w.text -relief raised -bd 2 -yscrollcommand "$w.scroll set" \
	    -setgrid true -width 40 -height 10
    scrollbar $w.scroll -relief flat -command "$w.text yview"
    pack $w.ok -side bottom -padx 3m -pady 3m -ipadx 2m -ipady 1m
    pack $w.scroll -side right -fill y
    pack $w.text -side left -expand yes -fill both
    $w.text insert 0.0 $info
    $w.text mark set insert 0.0

    # Center the window on the screen.

    wm withdraw $w
    update idletasks
    set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx [winfo parent $w]]]
    set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty [winfo parent $w]]]
    wm geom $w +$x+$y
    wm deiconify $w
}
