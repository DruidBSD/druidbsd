\ $Header: /cvsroot/druidbsd/druidbsd/druidbsd/mdroot/boot/include/brand.4th,v 1.1.1.1 2010/09/15 20:36:29 devinteske Exp $
\ ========================================================== INFORMATION
\ AUTHOR: Devin Teske
\ DATE: January 25th, 2006
\ LAST MODIFIED: September 10th, 2010 11:55:00
\ 
\ PURPOSE:
\ 
\    Custom boot loader script designed to be used with the FreeBSD
\    boot loader.
\ 
\    Module for creating and drawing an ASCII art company logo. Simply
\    use the `include' directive in `loader.rc' with this file and call
\    the `draw-brand' function.

marker task-brand.4th
\ ========================================================== CONSTANTS

34 constant quot	\ ASCII definition of a quotation mark (decimal)

\ ========================================================== VARIABLES

variable vlogoX
variable vlogoY

\ Initialize logo placement
1 vlogoX !
1 vlogoY !

\ ========================================================== FUNCTIONS

\ This function prints an approximation of the DRUID logo (7 rows x 33
\ columns). This function is called by the draw-brand function. You need not
\ call it directly.

: druid-logo ( x y -- )

	\ The Druid Logo:
	\ ============================================= \
	\         88                      88         88 \
	\         88                      ""         88 \
	\  ,adPYb,88 8b,dPYba, 88      88 88  ,adPYb,88 \
	\ a8"   `Y88 88P'  "Y8 88      88 88 a8"   `Y88 \
	\ 8b      88 88        88      88 88 8b      88 \
	\ "8a,  ,d88 88        "8a,  ,a88 88 "8a,  ,d88 \
	\  `"8bdP"Y8 88         `"YbdP'Y8 88  `"8bdP"Y8 \
	\ ============================================= \

	." [34m" \ switch foreground text color to blue

	   2dup at-xy ."         88                      88         88"
	1+ 2dup at-xy ."         88                                 88"
	1+ 2dup at-xy ."  ,adPYb,88 8b,dPYba, 88      88 88  ,adPYb,88"
	1+ 2dup at-xy ." a8    `Y88 88P'   Y8 88      88 88 a8    `Y88"
	1+ 2dup at-xy ." 8b      88 88        88      88 88 8b      88"
	1+ 2dup at-xy ."  8a,  ,d88 88         8a,  ,a88 88  8a,  ,d88"
	1+ 2dup at-xy ."  ` 8bdP Y8 88         ` YbdP'Y8 88  ` 8bdP Y8"

	\ print quotation marks
	2dup 5 - swap 32 + swap at-xy quot emit
	2dup 5 - swap 33 + swap at-xy quot emit
	2dup 3 - swap  2 + swap at-xy quot emit
	2dup 3 - swap 17 + swap at-xy quot emit
	2dup 3 - swap 37 + swap at-xy quot emit
	2dup 1 -                at-xy quot emit
	2dup 1 - swap 21 + swap at-xy quot emit
	2dup 1 - swap 35 + swap at-xy quot emit
	2dup     swap  2 + swap at-xy quot emit
	2dup     swap  7 + swap at-xy quot emit
	2dup     swap 23 + swap at-xy quot emit
	2dup     swap 37 + swap at-xy quot emit
	         swap 42 + swap at-xy quot emit

	." [37m" \ switch foreground text color back to white
;



\ This function draws any number of company logos at (vlogoX,vlogoY) if
\ defined, or (1,1) (absolute top-left) if not defined. To choose your logo,
\ set the variable "vlogo" to the respective logo name.
\ 
\ Currently available logos:
\
\ Name		Description
\ vicor		The Vicor logo (deprecated)
\ metavante	Vicor was bought by Metavante (deprecated)
\ fisvbu	FNIS and Metavante merged into FIS (deprecated)
\ fis		An approximation of the FIS logo (default)

: draw-brand ( -- )

	s" vlogoX" getenv dup -1 <> if
		?number 1 = if
			vlogoX !
		then
	else
		drop
	then

 	s" vlogoY" getenv dup -1 <> if
 		?number 1 = if
			vlogoY !
		then
 	else
		drop
	then

	s" vlogo" getenv dup -1 = if
		vlogoX @ vlogoY @ druid-logo
		drop exit
	then

	2dup s" druid" compare 0= if
		vlogoX @ vlogoY @ druid-logo
		2drop exit
	then

	2drop

;
