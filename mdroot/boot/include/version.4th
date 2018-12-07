\ $Header: /cvsroot/druidbsd/druidbsd/druidbsd/mdroot/boot/include/version.4th,v 1.1.1.1 2010/09/15 20:36:29 devinteske Exp $
\ ========================================================== INFORMATION
\ AUTHOR: Devin Teske
\ DATE: August 30th, 2006
\ LAST MODIFIED: January 4th, 2010 11:10:08
\ 
\ PURPOSE:
\ 
\    To display a version string at a specific location on
\    the screen (helps trouble-shooting over the phone).
\ 
\ This is quite an odd language, is it not? Elegant though

marker task-version.4th
\ ========================================================== INCLUDES

\ Screen manipulation
include boot/include/screen.4th

\ ========================================================== VARIABLES

variable versX
variable versY

\ Initialize text placement to defaults
80 versX !	\ NOTE: this is the ending column (text is right-justified)
24 versY !

\ ========================================================== MAIN SOURCE

: print_version ( -- )

	\ Get the text placement position (if set)
	s" versX" getenv dup -1 <> if
		?number drop versX ! -1
	then drop
	s" versY" getenv dup -1 <> if
		?number drop versY ! -1
	then drop

	\ Exit if a version was not set
	s" version" getenv dup -1 = if
		drop exit
	then

	\ Right justify the text
	dup versX @ swap - versY @ at-xy

	\ Print the version (in cyan)
	." [36m" type ." [37m"
;
