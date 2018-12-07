\ $Header: /cvsroot/druidbsd/druidbsd/druidbsd/mdroot/boot/include/menu.4th,v 1.1.1.1 2010/09/15 20:36:29 devinteske Exp $
\ ========================================================== INFORMATION
\ AUTHOR: Devin Teske
\ DATE: January 19th, 2006
\ LAST MODIFIED: January 4th, 2010 10:12:35
\ 
\ PURPOSE:
\ 
\    Custom boot loader script designed to be used with the FreeBSD
\    pxeboot boot loader image. Heavily documented to compensate for
\    the cryptic nature of the Forth language. The FreeBSD pxeboot
\    loader (all known versions) has minimal built-in actions and
\    variables with no support for program flow control (ie.
\    arithmetic operators, logical expressions, evaluation, etc.).
\    However, the pxeboot loader contains an FICL compliant Forth
\    interpreter.
\ 
\ 
\ This is quite an odd language, is it not? Elegant though

marker task-menu.4th
\ ========================================================== INCLUDES

\ The following includes are from the FreeBSD-6.0 distribution and
\ remain unmodified/uncustomized.

\ Screen manipulation
include boot/include/screen.4th

\ Frame drawing
include boot/include/frames.4th

\ ========================================================== CONFIGURATION

f_double		\ Set frames to double (see frames.4th). Replace with
			\ f_single if you want single frames.
46 constant dot		\ ASCII definition of a period (in decimal)


 4 constant menu_timeout_default_x	\ default column position of timeout
23 constant menu_timeout_default_y	\ default row position of timeout msg
10 constant menu_timeout_default	\ default timeout (in seconds)

\ Customize the following values with care

  1 constant menu_start	\ Numerical prefix of first menu item
dot constant bullet	\ Menu bullet (appears after numerical prefix)
  5 constant menu_x	\ Row position of the menu (from the top)
 10 constant menu_y	\ Column position of the menu (from left side)

\ ========================================================== VARIABLES

\ Menu Appearance
variable menuidx	\ Menu item stack for number prefixes
variable menubllt	\ Menu item bullet

\ Menu Positioning
variable menuX		\ Menu X offset (columns)
variable menuY		\ Menu Y offset (rows)

\ Menu-item key association/detection
variable menukey1
variable menukey2
variable menukey3
variable menukey4
variable menukey5
variable menukey6
variable menukey7
variable menukey8
variable menureboot

\ Menu timer [count-down] variables
variable menu_timeout_enabled	\ timeout state (internal use only)
variable menu_time		\ variable for tracking the passage of time
variable menu_timeout		\ determined configurable delay duration
variable menu_timeout_x		\ column position of timeout message
variable menu_timeout_y		\ row position of timeout message

\ ========================================================== FUNCTIONS

\ This function prints a menu item at menuX (row) and menuY (column), returns
\ the incremental decimal ASCII value associated with the menu item, and
\ increments the cursor position to the next row for the creation of the next
\ menu item. This function is called by the menu-create function. You need not
\ call it directly.

: printmenuitem ( menu_item_str -- ascii_keycode )

	menuidx @	\ Add menuidx to the stack
	1+ dup		\ Increment the value on the stack
	menuidx !	\ Store the incremented value

	\ Add menuY to the stack value, then add menuX to the stack, then
	\ swap the stack pair so that they appear in (x, y) order and
	\ pass to the at-xy function to position the cursor
	menuY @ + dup menuX @ swap at-xy

	menuidx @ .	\ Print the value of menuidx

	\ Add menuX to the stack, increment it, swap pairs, and reposition
	\ the cursor (in a nut shell, move the cursor forward 1 column)
	menuX @ 1+ swap at-xy

	menubllt @ emit	\ Print the menu bullet using the emit function

	\ Move the cursor to the 3rd column from the current position
	\ to allow for a space between the numerical prefix and the
	\ text caption
	menuX @ 3 + menuY @ menuidx @ + at-xy

	\ Print the menu caption (we expect a string to be on the stack
	\ prior to invoking this function)
	type

	\ Here we will add the ASCII decimal of the numerical prefix
	\ to the stack (decimal ASCII for `1' is 49) as a "return value"
	menuidx @ 48 +

;



\ This function creates the list of menu items. This function is called by the
\ menu-display function. You need not be call it directly.

: menu-create ( -- )

	\ Print the frame caption at (x,y)
	11 9 at-xy ." FreeBSD Kernel Options"

	\ Print our menu options with respective key/variable associations.
	\ `printmenuitem' ends by adding the decimal ASCII value for the
	\ numerical prefix to the stack. We store the value left on the stack
	\ to the key binding variable for later testing against a character
	\ captured by the `getkey' function.

	\ Note that any menu item beyond 9 will have a numerical prefix on the
	\ screen consisting of the first digit (ie. 1 for the tenth menu item)
	\ and the key required to activate that menu item will be the decimal
	\ ASCII of 48 plus the menu item (ie. 58 for the tenth item, aka. `:')
	\ which is misleading and not desirable.
	\ 
	\ Thus, we do not allow more than 8 configurable items on the menu
	\ (with "Reboot" as the optional ninth and highest numbered item).

	49 \ Iterator start (loop range 49 to 56; ASCII '1' to '8')
	begin
		s" menu_caption[x]"

		\ replace 'x' with current iteration
		-rot 2dup 13 + c! rot

		\ test for environment variable
		getenv dup -1 <> if
			printmenuitem

			s" menukeyN !" \ generate cmd to store result
			-rot 2dup 7 + c! rot

			evaluate
		else
			drop
		then

		1+ dup 56 > \ add 1 to iterator, continue if less than 57
	until
	drop \ iterator

	\ Optionally add a reboot option to the menu
	s" menu_reboot" getenv dup -1 <> if
		2drop      \ no need for the value
		s" Reboot" \ menu caption (required by printmenuitem)

		printmenuitem
		menureboot !
	else
		drop
	then

;



\ Takes a single integer on the stack and updates the timeout display. The
\ integer must be between 0 and 9 (we will only update a single digit in the
\ source message).

: menu-timeout-update ( N -- )

	dup 9 > if ( N N 9 -- N )
		drop ( N -- )
		9 ( maximum: -- N )
	then

	dup 0 < if ( N N 0 -- N )
		drop ( N -- )
		0 ( minimum: -- N )
	then

	48 + ( convert single-digit numeral to ASCII: N 48 -- N )

	s" Autoboot in N seconds. [Space] to pause" ( N -- N Addr C )

	2 pick 48 - 0> if ( N Addr C N 48 -- N Addr C )

		\ Modify 'N' (Addr+12) above to reflect time-left

		-rot	( N Addr C -- C N Addr )
		tuck	( C N Addr -- C Addr N Addr )
		12 +	( C Addr N Addr -- C Addr N Addr2 )
		c!	( C Addr N Addr2 -- C Addr )
		swap	( C Addr -- Addr C )

		menu_timeout_x @
		menu_timeout_y @
		at-xy ( position cursor: Addr C N N -- Addr C )

		type ( print message: Addr C -- )

	else ( N Addr C N -- N Addr C )

		menu_timeout_x @
		menu_timeout_y @
		at-xy ( position cursor: N Addr C N N -- N Addr C )

		spaces ( erase message: N Addr C -- N Addr )
		2drop ( N Addr -- )

	then

	0 25 at-xy ( position cursor back at bottom-left )
;



\ This function blocks program flow (loops forever) until a key is pressed.
\ The key that was pressed is added to the top of the stack in the form of its
\ decimal ASCII representation. This function is called by the menu-display
\ function. You need not call it directly.

: getkey ( -- ascii_keycode )

	begin \ loop forever

		menu_timeout_enabled @ 1 = if
			( -- )
			seconds ( get current time: -- N )
			dup menu_time @ <> if ( has time elapsed?: N N N -- N )

				\ At least 1 second has elapsed since last loop
				\ so we will decrement our "timeout" (really a
				\ counter, insuring that we do not proceed too
				\ fast) and update our timeout display.

				menu_time ! ( update time record: N -- )
				menu_timeout @ ( "time" remaining: -- N )
				dup 0> if ( greater than 0?: N N 0 -- N )
					1- ( decrement counter: N -- N )
					dup menu_timeout !
						( re-assign: N N Addr -- N )
				then
				( -- N )

				dup 0= swap 0< or if ( N <= 0?: N N -- )
					\ halt the timer
					0 menu_timeout ! ( 0 Addr -- )
					0 menu_timeout_enabled ! ( 0 Addr -- )
				then

				\ update the timer display ( N -- )
				menu_timeout @ menu-timeout-update

				menu_timeout @ 0= if
					\ We've reached the end of the timeout
					\ (user did not cancel by pressing ANY
					\ key)

					s" menu_timeout_command" getenv dup
					-1 = if
						drop \ clean-up
					else
						evaluate
					then
				then

			else ( -- N )
				\ No [detectable] time has elapsed (in seconds)
				drop ( N -- )
			then
			( -- )
		then

		key? if \ Was a key pressed? (see loader(8))
			\ get the key that was pressed and exit (if we
			\ get a non-zero ASCII code)
			key dup 0<> if
				exit
			else
				drop
			then
		then
		50 ms \ sleep for 50 milliseconds (see loader(8))

	again
;



\ Erases the menu and resets the positioning variable to positon 1.

: menu-erase ( -- )

	\ Clear the screen area associated with the interactive menu
	menuX @ menuY @
	2dup at-xy 38 spaces 1+		2dup at-xy 38 spaces 1+
	2dup at-xy 38 spaces 1+		2dup at-xy 38 spaces 1+
	2dup at-xy 38 spaces 1+		2dup at-xy 38 spaces 1+
	2dup at-xy 38 spaces 1+		2dup at-xy 38 spaces 1+
	2dup at-xy 38 spaces 1+		2dup at-xy 38 spaces 1+
	2dup at-xy 38 spaces 1+		2dup at-xy 38 spaces
	2drop

	menu_start 1- menuidx !	\ Reset the starting index for the menu

;



\ Erase and redraw the menu. Useful if you change a caption and want to
\ update the menu to reflect the new value.

: menu-redraw ( -- )
	menu-erase
	menu-create
;



\ This function initializes the menu. Call this from your `loader.rc' file
\ before calling any other menu-related functions.

: menu-init ( -- )

	menu_start
	1- menuidx !	\ Initialize the starting index for the menu
	42 13 2 9 box	\ Draw frame (w,h,x,y)
	0 25 at-xy	\ Move cursor to the bottom for output

;



\ Main function. Call this from your `loader.rc' file.

: menu-display ( -- )

	0 menu_timeout_enabled ! \ start with automatic timeout disabled

	\ check indication that automatic execution after delay is requested
	s" menu_timeout_command" getenv -1 <> if ( Addr C -1 -- | Addr )
		drop ( just testing existence right now: Addr -- )

		\ read custom time-duration (if set)
		s" menu_timeout" getenv dup -1 = if
			drop \ no custom duration (remove dup'd bunk -1)
			menu_timeout_default \ use default setting
		else
			\ make sure custom duration is a number
			?number 0= if
				menu_timeout_default \ otherwise use default
			then
		then
		menu_timeout ! ( store value on stack from above )

		\ read custom column position (if set)
		s" menu_timeout_x" getenv dup -1 = if
			drop \ no custom column position
			menu_timeout_default_x \ use default setting
		else
			\ make sure custom position is a number
			?number 0= if
				menu_timeout_default_x \ or use default
			then
		then
		menu_timeout_x ! ( store value on stack from above )

		\ read custom row position (if set)
		s" menu_timeout_y" getenv dup -1 = if
			drop \ no custom row position
			menu_timeout_default_y \ use default setting
		else
			\ make sure custom position is a number
			?number 0= if
				menu_timeout_default_y \ or use default
			then
		then
		menu_timeout_y ! ( store value on stack from above )


		\ initialize state variables
		seconds menu_time ! ( store the time we started )
		1 menu_timeout_enabled ! ( enable automatic timeout )
	then

	menu-create

	begin		\ Loop forever

		0 25 at-xy   \ Move cursor to the bottom for output
		getkey       \ Block here, waiting for a key to be pressed

		dup -1 = if
			\ Caught abort (abnormal return)
			drop exit
		else
			\ An actual key was pressed (if the timeout is running,
			\ kill it regardless of which key was pressed)
			\
			\ NOTE: navigational, function and special key-
			\ combinations are ignored in getkey

			menu_timeout @ 0<> if
				0 menu_timeout !
				0 menu_timeout_enabled !

				\ clear screen of timeout message
				0 menu-timeout-update
			then

			\ Boot if the user pressed Enter/Ctrl-M (13) or
			\ Ctrl-Enter/Ctrl-J (10)
			dup over 13 = swap 10 = or if
				drop ( no longer needed )
				s" boot" evaluate
				exit ( pedantic )
			then
		then

		\ Evaluate the decimal ASCII value against known menu item
		\ key associations and act accordingly (set an environment
		\ variable `N' with the value of the key pressed)

		49 \ Iterator start (loop range 49 to 56; ASCII '1' to '8')
		begin
			s" menukeyN @"

			\ replace 'N' with current iteration
			-rot 2dup 7 + c! rot

			evaluate rot tuck = if

				\ base env name for the value (x is a number)
				s" menu_command[x]"

				\ Copy ASCII number to string at offset 13
				-rot 2dup 13 + c! rot

				\ Test for the environment variable
				getenv dup -1 <> if
					\ Execute the stored procedure
					evaluate

					\ We expect there to be a boolean value
					\ left on the stack after executing the
					\ stored procedure. If TRUE, continue
					\ to run, otherwise exit

					0= if
						drop \ key pressed
						drop \ loop iterator
						exit
					else
						swap \ need iterator on top
					then
				then
			else
				swap \ need iterator on top
			then

			1+ dup 56 > \ increment iterator
			            \ continue if less than 57
		until
		drop \ loop iterator

		menureboot @ = if 0 reboot then

	again	\ Non-operational key was pressed; repeat

;



\ This function unsets all the possible environment variables associated with
\ creating the interactive menu. Call this when you want to clear the menu
\ area in preparation for another menu.

: menu-clear ( -- )

	49 \ Iterator start (loop range 49 to 56; ASCII '1' to '8')
	begin
		s" menu_caption[x]"	\ basename for caption variable
		-rot 2dup 13 + c! rot	\ replace 'x' with current iteration
		unsetenv		\ not erroneous to unset unknown var

		s" 0 menukeyN !"	\ basename for key association var
		-rot 2dup 9 + c! rot	\ replace 'N' with current iteration
		evaluate		\ assign zero (0) to key assoc. var

		1+ dup 56 >	\ increment, continue if less than 57
	until
	drop \ iterator

	\ clear the "Reboot" menu option flag
	s" menu_reboot" unsetenv
	0 menureboot !

	menu-erase

;

\ ========================================================== MAIN SOURCE

\ Assign configuration values
bullet menubllt !
10 menuY !
5 menuX !
