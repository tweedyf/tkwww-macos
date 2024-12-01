## binary.sed initialization file for binary tkWWW  user interface
## ==============
## Copyright (C) 1992-1993
## Globewide Network Academy
## Macvicar Institute for Educational Software Development
##
## See the file COPYRIGHT for conditions 

# This file is only executed when tkWWW is running as a single executable
# It sets up some tkWWW variables and then executes the default tk/tcl
# startup scripts

if ![info exists env(TK_WWW_HOME_PAGE)] {
    set env(TK_WWW_HOME_PAGE) tk_www_home_page
}

if ![info exists env(TK_WWW_START_PAGE)] {
    set env(TK_WWW_START_PAGE) tk_www_start_page
}

if ![info exists env(TK_WWW_MAIL)] {
    set env(TK_WWW_MAIL) tk_www_mail_page
}
set tkW3BinaryInBinary 1
set tkW3Version "0.12"
