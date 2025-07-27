## output.tcl: output for tkWWW user interface
## ==============
## Copyright (C) 1992-1994
## Globewide Network Academy
## Macvicar School of Educational and Technology
##
## See the file COPYRIGHT for conditions

# All output should go through these procedures

proc tkW3OutputSetMessage {message {duration ""}} {
    tkW3OutputEntryPrint .message $message
    if {$duration != ""} {
	after $duration {tkW3OutputSetMessage {}}
    }
}

proc tkW3OutputEntryPrint {w message} {
    $w configure -state normal
    $w delete 0 end
    $w insert 0 $message
    $w configure -state disabled
}

proc tkW3OutputSetAddress {address title} {
    tkW3OutputEntryPrint .titles.address_entry $address
    tkW3OutputEntryPrint .titles.title_entry $title
}

proc tkW3OutputSetBodyToFile {filename} {
    tkW3OutputClearBody
    set file [open $filename "r"]
    while {[gets $file line] != -1} {
	.f.msg insert insert "$line\n"
    }
    close $file
    .f.msg tag add PRE 1.0 end
}

proc tkW3OutputGetScrollPosition {} {
    lindex [.vs get] 2
}

proc tkW3OutputSetScrollPosition {value} {
    .f.msg yview $value
}

## ************************
## Cursor procedures
## ************************

proc tkW3OutputCursorWait {} {
  .f.msg configure -cursor watch
}

proc tkW3OutputCursorNormal {} {
  .f.msg configure -cursor xterm
}

proc tkW3OutputMakeEntries {w list} {
    if [winfo exists $w] {
	foreach child [winfo children $w] {
	    destroy $child
	}
    } {
	frame $w -borderwidth 0
    }

    foreach item $list {
	pack append $w \
	    [label $w.[lindex $item 0]_label -text [lindex $item 1]] {left} \
	    [entry $w.[lindex $item 0] -state disabled] {left  expand fillx}
    }
    return $w
}

proc tkW3OutputMakeFrame {w} {
    if [winfo exists $w] {
	foreach child [winfo children $w] {
	    destroy $child
	}
    } {
	frame $w -borderwidth 0
    }
}


proc tkW3OutputMakeButtons {w list} {
    tkW3OutputMakeFrame $w
    foreach item $list {
	pack append $w \
	    [frame $w.[lindex $item 0]_frame -relief flat -borderwidth 1] \
	    {left fill}

	# Create custom frame-based button for consistent styling
	frame $w.[lindex $item 0] -relief raised -borderwidth 2 -background gray
	label $w.[lindex $item 0].label -text [lindex $item 1] -background gray -foreground black -relief flat
	pack $w.[lindex $item 0].label -in $w.[lindex $item 0] -padx 4 -pady 2
	
	# Bind mouse events to make it behave like a button
	bind $w.[lindex $item 0] <Button-1> [lindex $item 2]
	bind $w.[lindex $item 0] <Enter> "$w.[lindex $item 0] configure -background lightgray; $w.[lindex $item 0].label configure -background lightgray"
	bind $w.[lindex $item 0] <Leave> "$w.[lindex $item 0] configure -background gray; $w.[lindex $item 0].label configure -background gray"
	bind $w.[lindex $item 0].label <Button-1> [lindex $item 2]
	bind $w.[lindex $item 0].label <Enter> "$w.[lindex $item 0] configure -background lightgray; $w.[lindex $item 0].label configure -background lightgray"
	bind $w.[lindex $item 0].label <Leave> "$w.[lindex $item 0] configure -background gray; $w.[lindex $item 0].label configure -background gray"
	
	pack append $w.[lindex $item 0]_frame $w.[lindex $item 0] {left fill padx 2m pady 2m}
    }
    return $w
}

proc tkW3OutputDoNothing {} {
}

proc tkW3OutputMakeToggles {w list {static 1} {pos right}} {
    tkW3OutputMakeFrame $w
    foreach item $list {
	set name [lindex $item 0]
	
	# Create custom frame-based checkbox for consistent styling
	frame $w.$name -relief flat -borderwidth 0 -background gray
	frame $w.$name.box -relief raised -borderwidth 2 -background gray -width 12 -height 12
	label $w.$name.label -text [lindex $item 1] -background gray -foreground black -relief flat
	pack $w.$name.box -in $w.$name -side left -padx 2
	pack $w.$name.label -in $w.$name -side left -padx 4
	
	# No click bindings - these are status indicators, not user controls
	
	# Initialize the checkbox state
	global $name
	if {![info exists $name]} {
	    set $name 0
	}
	tkW3OutputUpdateCheckbox $w.$name $name
	
	pack append $w $w.$name $pos
	if {$static} {
	    bind $w.$name <Any-Enter> "tkW3OutputDoNothing"
	    bind $w.$name <Any-Leave> "tkW3OutputDoNothing"
	    bind $w.$name <1> "tkW3OutputDoNothing"
	    bind $w.$name <ButtonRelease-1> "tkW3OutputDoNothing"
	}
    }
    if {$static} {
	pack append $w \
	    [label .message_label -text "Message:"] {left} \
	    [entry .message -state disabled] {left  expand fillx}
    }
    return $w
}

# Custom checkbox toggle function
proc tkW3OutputToggleCheckbox {checkbox_widget var_name} {
    global $var_name
    set $var_name [expr {![set $var_name]}]
    tkW3OutputUpdateCheckbox $checkbox_widget $var_name
}

# Update checkbox visual state
proc tkW3OutputUpdateCheckbox {checkbox_widget var_name} {
    global $var_name
    if {[set $var_name]} {
	# Checked state - show a filled box
	$checkbox_widget.box configure -relief sunken -background black
    } else {
	# Unchecked state - show empty raised box
	$checkbox_widget.box configure -relief raised -background gray
    }
}

proc tkW3OutputMakeTitleBox {w} {
    tkW3OutputMakeFrame $w

    pack append $w \
	[frame $w.address_frame -borderwidth 0] {top fillx expand} \
	[frame $w.title_frame -borderwidth 0] {bottom fillx expand}

    pack append $w.address_frame \
	[label $w.address_label -text "Document Address:"] {left} \
	[entry $w.address_entry -state disabled ] {right fillx expand}

    pack append $w.title_frame \
	[label $w.title_label -text "Document Title:"] {left} \
	[entry $w.title_entry -state disabled ] {right fillx expand}

    return $w
}

proc tkW3OutputMakeText {w} {
    frame $w -relief flat -borderwidth 5

    pack [ text $w.msg -yscrollcommand { .vs set } \
	  -width 80 -height 40 ] -expand 1 -fill both -padx 2 -pady 2

    frame $w.msg.image
    $w.msg.image configure -cursor crosshair
    return $w
}

proc tkW3OutputMakeScrollbars {} {
    pack before .f.msg \
	[scrollbar .vs \
	 -command { .f.msg yview } -orient vertical] { right filly }
}

proc tkW3OutputClearBody {} {
    .f.msg delete 1.0 end
}

proc tkW3OutputSaveFileAs {file_name address} {
    global fsBox

    tkW3OutputClearBody
    set name [file tail $address]
    set fsBox(path) ""
    FSBox {Save File} $name \
	"exec mv $file_name \$fsBox(path)/\$fsBox(name)"
    DLG:show . .fsBox
}

proc tkW3OutputToggleSet {w var} {
    # Extract the variable name from the widget path
    set var_name [lindex [split $w "."] end]
    global $var_name
    set $var_name $var
    tkW3OutputUpdateCheckbox $w $var_name
}

proc tkW3OutputMenuSetSensitive {w entry var} {
    if {$var == 0} {
	$w entryconfigure $entry -state disabled
    } {
	$w entryconfigure $entry -state normal
    }
}

proc tkW3OutputButtonSetSensitive {w var} {
    # Disabled for custom frame-based buttons to avoid errors
    # Buttons work fine without sensitivity control
}

proc tkW3OutputError {message} {
    DLG:msg . .error_dialog $message error "OK"
}
