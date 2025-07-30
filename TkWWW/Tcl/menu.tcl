## menu.tcl: make menu out of list of node names
## ==============
## Copyright (C) 1992-1993
## Globewide Network Academy
## Macvicar Institue for Educational Software Development
##
## See the file COPYRIGHT for conditions

## Conventions:
## All procedures in this file begin with tkW3Menu

# tkW3MenuMakeMenus 
# Add items to the menu bar to allow direct access of
# some information
# The format for the input list is
# {{menuname1 title1} {{title1 address1} {title2 address2}}} 
#  {menuname2 title2} {{title1 address1}}}}
#
# returns a list of menus created

proc tkW3MenuMakeMenus {menubar list} {
    # Create a single continuous menu bar frame with Motif styling
    frame $menubar -relief raised -borderwidth 2 -background gray -height 25
    
    set menu_list ""
    foreach menu_item $list {
        set menu [lindex $menu_item 0]
        set menu_name $menubar.[lindex $menu 0]
        set menu_title [lindex $menu 1]
        set menu_underline [lindex $menu 2]
        set menu_command [lindex $menu 3]
        
        if {$menu_command == "right"} {
	    set position "right"
	} {
	    set position "left"
	}

	# Create a Motif-style menu header (text label with underline)
	label $menu_name -text $menu_title -background gray -foreground black \
		-relief flat -borderwidth 0 -padx 8 -pady 4 \
		-font "-adobe-helvetica-medium-r-normal--12-*-*-*-*-*-*-*"
	
	# Bind mouse events for Motif-style behavior
	bind $menu_name <Button-1> "tkW3MenuShowPopup $menu_name $menu_name.m"
	bind $menu_name <Enter> "$menu_name configure -background lightgray -foreground black"
	bind $menu_name <Leave> "$menu_name configure -background gray -foreground black"
	
	pack $menu_name -side $position -fill y
        
        if {$menu_underline != ""} {
	    $menu_name configure -underline $menu_underline
	}

        # Create the popup menu
        tkW3MenuMakeMenuPane $menu_name.m [lindex $menu_item 1]
        lappend menu_list $menu_name
    }
    return $menubar
}

# Custom procedure to show popup menus for our Motif-style menu system
proc tkW3MenuShowPopup {button menu} {
    # Get the button's position
    set x [winfo rootx $button]
    set y [expr [winfo rooty $button] + [winfo height $button]]
    
    # Show the popup menu at the button's position
    $menu post $x $y
    
    # Set focus to the menu for keyboard navigation
    focus $menu
}


proc tkW3MenuMakeMenuPane {w menu_list} {
    menu $w -background gray -foreground black \
             -activebackground lightgray -activeforeground black \
             -relief raised -borderwidth 2
    
    # Force configure the menu styling after creation
    $w configure -background gray -foreground black \
                 -activebackground lightgray -activeforeground black \
                 -relief raised -borderwidth 2
    foreach item $menu_list {
       if {[llength $item] == 0} {
	   $w add separator
       } { 
	   set name [lindex $item 0]
	   switch -exact -- [lindex $item 1] {
	       "cascade_external" {
		   $w add cascade -label $name -menu $w.[lindex $item 2]
		   menu $w.[lindex $item 2]
	       } 
	       "cascade" {
		   $w add cascade -label $name \
		       -menu [tkW3MenuMakeMenuPane $w.m [lindex $item 2]]
	       } 
	       default {
		   $w add command -label $name -command [lindex $item 1]
		   if {[lindex $item 2] != ""} {
		       $w entryconfigure last -underline [lindex $item 2]
		   }
		   if {[lindex $item 3] != ""} {
		       $w entryconfigure last -accelerator [lindex $item 3]
		       bind Text [lindex $item 3] [lindex $item 1] 
		   }
	       }
	   }
       }
    }
    return $w
}
