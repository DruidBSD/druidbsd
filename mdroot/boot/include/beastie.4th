\ $Header: /cvsroot/druidbsd/druidbsd/druidbsd/mdroot/boot/include/beastie.4th,v 1.1.1.1 2010/09/15 20:36:29 devinteske Exp $
\ ========================================================== INFORMATION
\ AUTHOR: Devin Teske
\ DATE: January 25th, 2006
\ LAST MODIFIED: March 11th, 2010 07:00:52
\ 
\ PURPOSE:
\ 
\    Custom boot loader script designed to be used with the FreeBSD
\    boot loader.
\ 
\    Module for creating and drawing the ASCII art FreeBSD mascot known
\    simply as `beastie'. Use the `include' directive in `loader.rc'
\    with this file and call the `draw-beastie' function.
\
\    Optional environment variables are `blogoX' and `blogoY' for the
\    placement of `beastie' as well as `logo' (which can be set to
\    one of `beastiebw' or `beastie'; default is `beastie').

marker task-beastie.4th
\ ========================================================== VARIABLES

variable blogoX
variable blogoY

\ Initialize logo placement to defaults
46 blogoX !
4  blogoY !

\ ========================================================== FUNCTIONS

\ This function prints the color BSD mascot (19 rows x 34 columns). This
\ function is called by the draw-beastie function. You need not call it
\ directly.

: beastie-logo ( x y -- )

2dup at-xy ."               [31m,        ," 1+
2dup at-xy ."              /(        )`" 1+
2dup at-xy ."              \ \___   / |" 1+
2dup at-xy ."              /- [37m_[31m  `-/  '" 1+
2dup at-xy ."             ([37m/\/ \[31m \   /\" 1+
2dup at-xy ."             [37m/ /   |[31m `    \" 1+
2dup at-xy ."             [34mO O   [37m) [31m/    |" 1+
2dup at-xy ."             [37m`-^--'[31m`<     '" 1+
2dup at-xy ."            (_.)  _  )   /" 1+
2dup at-xy ."             `.___/`    /" 1+
2dup at-xy ."               `-----' /" 1+
2dup at-xy ."  [33m<----.[31m     __ / __   \" 1+
2dup at-xy ."  [33m<----|====[31mO)))[33m==[31m) \) /[33m====|" 1+
2dup at-xy ."  [33m<----'[31m    `--' `.__,' \" 1+
2dup at-xy ."               |        |" 1+
2dup at-xy ."                \       /       /\" 1+
2dup at-xy ."           [36m______[31m( (_  / \______/" 1+
2dup at-xy ."         [36m,'  ,-----'   |" 1+
     at-xy ."         `--{__________)[37m"

	\ Put the cursor back at the bottom
	0 25 at-xy

;




\ This function prints the B/W BSD mascot (19 rows x 34 columns). This function
\ is called by the draw-beastie function. You need not call it directly.

: beastiebw-logo ( x y -- )

	2dup at-xy ."               ,        ," 1+
	2dup at-xy ."              /(        )`" 1+
	2dup at-xy ."              \ \___   / |" 1+
	2dup at-xy ."              /- _  `-/  '" 1+
	2dup at-xy ."             (/\/ \ \   /\" 1+
	2dup at-xy ."             / /   | `    \" 1+
	2dup at-xy ."             O O   ) /    |" 1+
	2dup at-xy ."             `-^--'`<     '" 1+
	2dup at-xy ."            (_.)  _  )   /" 1+
	2dup at-xy ."             `.___/`    /" 1+
	2dup at-xy ."               `-----' /" 1+
	2dup at-xy ."  <----.     __ / __   \" 1+
	2dup at-xy ."  <----|====O)))==) \) /====|" 1+
	2dup at-xy ."  <----'    `--' `.__,' \" 1+
	2dup at-xy ."               |        |" 1+
	2dup at-xy ."                \       /       /\" 1+
	2dup at-xy ."           ______( (_  / \______/" 1+
	2dup at-xy ."         ,'  ,-----'   |" 1+
	     at-xy ."         `--{__________)"

	\ Put the cursor back at the bottom
	0 25 at-xy

;



\ This function prints the "FreeBSD" logo in B/W (13 rows x 21 columns). This
\ function is called by the draw-beastie function. You need not call it
\ directly.

: fbsdbw-logo ( x y -- )

	5 + swap 6 + swap

	2dup at-xy ."  ______" 1+
	2dup at-xy ." |  ____| __ ___  ___ " 1+
	2dup at-xy ." | |__ | '__/ _ \/ _ \" 1+
	2dup at-xy ." |  __|| | |  __/  __/" 1+
	2dup at-xy ." | |   | | |    |    |" 1+
	2dup at-xy ." |_|   |_|  \___|\___|" 1+
	2dup at-xy ."  ____   _____ _____" 1+
	2dup at-xy ." |  _ \ / ____|  __ \" 1+
	2dup at-xy ." | |_) | (___ | |  | |" 1+
	2dup at-xy ." |  _ < \___ \| |  | |" 1+
	2dup at-xy ." | |_) |____) | |__| |" 1+
	2dup at-xy ." |     |      |      |" 1+
	     at-xy ." |____/|_____/|_____/"

	\ Put the cursor back at the bottom
	0 25 at-xy

;



\ This function prints the "FreeBSD (Wide)" logo in B/W (7 rows x 42 columns).
\ This function is called by the draw-beastie function. You need not call it
\ directly.

: fbsdbw-wide-logo ( x y -- )

	2dup at-xy ."  ______               ____   _____ _____  " 1+
	2dup at-xy ." |  ____|             |  _ \ / ____|  __ \ " 1+
	2dup at-xy ." | |___ _ __ ___  ___ | |_) | (___ | |  | |" 1+
	2dup at-xy ." |  ___| '__/ _ \/ _ \|  _ < \___ \| |  | |" 1+
	2dup at-xy ." | |   | | |  __/  __/| |_) |____) | |__| |" 1+
	2dup at-xy ." | |   | | |    |    ||     |      |      |" 1+
	     at-xy ." |_|   |_|  \___|\___||____/|_____/|_____/ "

	\ Put the cursor back at the bottom
	0 25 at-xy

;



\ This function draws Beastie at (blogoX,blogoY) if defined, or (2,1) if not
\ defined.

: draw-beastie ( -- )

	s" blogoX" getenv dup -1 <> if
		?number 1 = if blogoX ! then
	else
		drop
	then
	s" blogoY" getenv dup -1 <> if
		?number 1 = if blogoY ! then
	else
		drop
	then

	s" logo" getenv dup -1 = if
		blogoX @ blogoY @ beastie-logo
		drop exit
	then

	2dup s" beastie" compare 0= if
		blogoX @ blogoY @ beastie-logo
		2drop exit
	then
	2dup s" beastiebw" compare 0= if
		blogoX @ blogoY @ beastiebw-logo
		2drop exit
	then
	2dup s" fbsdbw" compare 0= if
		blogoX @ blogoY @ fbsdbw-logo
		2drop exit
	then
	2dup s" fbsdbw-wide" compare 0= if
		blogoX @ blogoY @ fbsdbw-wide-logo
		2drop exit
	then

	2drop

;



\ This function clears beastie from the screen

: clear-beastie ( -- )

	blogoX @ blogoY @
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces 1+		2dup at-xy 34 spaces 1+
	2dup at-xy 34 spaces		2drop

	\ Put the cursor back at the bottom
	0 25 at-xy

;
