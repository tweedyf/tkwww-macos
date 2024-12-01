tkWWW Version 0.12 beta (joe@mit.edu)
--------------------------------------------
WHAT IS THIS?
-------------
World Wide Web (WWW) is a hypertext project which seeks to build a
world wide network of hypertext links.  There are several different
browsers for this system including a simple tty interface.

Tk is an interpreted toolkit which allows one to build X11 applications
quickly and easily.

tkWWW is a Tk interface to (WWW).

Since the entire user interface is written in an interpreted language,
it is very easy to make modifications and extensions to the system.
tkWWW is the first X11 browser with the ability to edit HTML!!!!!

Requirements
------------
tkWWW requires the installation of the tk and tcl packages which can
be retrieved from sprite.berkely.edu

To display images, tkWWW requires the xli package which can be
retrieved from ftp.x.org

To Install the single executable version of tkWWW
-------------------------------------------------
In this directory

1. Type "./configure"
2. Type "make"
3. Type "make install"

To Install the interpreted version of tkWWW
-------------------------------------------
In this directory

1. Type "./configure"
2. Type "make interp"
3. Type "make interpinstall"

Bug fixes
---------
12 Jun 1994 Added CODE to convert list in edit.tcl
           (lusol@turkey.cc.lehigh.edu)

06 Jun 1994 Broke up binary files 
            Server/Makefile.in: Now deletes libraries when cleaning
            tcl2c: Removed reference to $USER 
                   (reported by ivler@bbs.ug.eds.com)

27 Apr 1994 Changed parse args so that help works correctly
            HText.c: Changed HTML_A tags to HTML_LINK tags to fix core dump
            configure.in: Changed configure script to work 
                (R.Turnbull@csc.liv.ac.uk)
