\ $Header: /cvsroot/druidbsd/druidbsd/druidbsd/mdroot/boot/include/shortcuts.4th,v 1.1.1.1 2010/09/15 20:36:29 devinteske Exp $
\ ========================================================== INFORMATION
\ AUTHOR: Devin Teske
\ DATE: June 11th, 2008
\ LAST MODIFIED: June 11th, 2008 09:08:27
\ 
\ PURPOSE:
\ 
\    FICL words intended to be used as shortcuts for carrying out
\    common tasks or producing common results. Generally, words
\    defined here are simply groupings of other custom words that
\    pull from multiple libraries (for example, if you want to
\    define a custom word that uses words defined in three different
\    libraries, this is a good place to define such a word).
\ 
\    This script should be included after you have included any/all
\    other libraries. This will prevent calling a word defined here
\    before any required words have been defined.
\ 
\ 
\ This is quite an odd language, is it not? Elegant though

marker task-shortcuts.4th
\ ========================================================== MAIN SOURCE

\ This "shortcut" word will not be used directly, but is defined here to
\ offer the user a quick way to get back into the interactive PXE menu
\ after they have escaped to the shell (perhaps by accident).

: menu ( -- )

	clear		\ Clear the screen (in screen.4th)
	print_version	\ Print $version at bot-left of screen (in version.4th)
	draw-brand	\ Draw FIS logo at top (in brand.4th)
	menu-init	\ Initialize menu and draw bounding box (in menu.4th)
	draw-beastie	\ Draw FreeBSD logo at right (in beastie.4th)

	menu-display	\ Launch interactive menu (in menu.4th)

;
