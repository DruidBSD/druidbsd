\ $Header: /cvsroot/druidbsd/druidbsd/druidbsd/mdroot/boot/include/chkpasswd.4th,v 1.1.1.1 2010/09/15 20:36:29 devinteske Exp $
\ ========================================================== INFORMATION
\ AUTHOR: Devin Teske
\ DATE: February 27th, 2006
\ LAST MODIFIED: August 30th, 2006 12:14:17
\ 
\ PURPOSE:
\ 
\    To prompt the user to enter a password. Once the `chkpasswd'
\    function is called, the user cannot continue until the correct
\    password is entered. If, the user enters the correct password,
\    subsequent calls will not require entry again.
\    
\    To set the password, simply set the `password' environment
\    variable (within `loader.rc').
\ 
\ 
\ This is quite an odd language, is it not? Elegant though

marker task-chkpasswd.4th
\ ========================================================== INCLUDES

\ Screen manipulation
include boot/include/screen.4th

\ ========================================================== VARIABLES

13 constant enter_key	\ The decimal ASCII value for Enter key
8  constant bs_key	\ The decimal ASCII value for Backspace key
16 constant readmax	\ Maximum number of characters for the password

variable readX		\ Current X offset (column)(used by read)
variable read-start	\ Starting X offset (column)(used by read)

create readval 16 allot	\ input obtained (maximum 16 characters)
variable readlen	\ input length

\ ========================================================== FUNCTIONS

\ This function blocks program flow (loops forever) until a key is pressed.
\ The key that was pressed is added to the top of the stack in the form of its
\ decimal ASCII representation. Note: the stack cannot be empty when this
\ function starts or an underflow exception will occur. Simplest way to prevent
\ this is to pass 0 as a stack parameter (ie. `0 getkey'). This function is
\ called by the menu-display function. You need not call it directly. NOTE:
\ arrow keys show as 0 on the stack

: sgetkey ( -- )

   begin	\ Loop forever
      key? if	\ Was a key pressed? (see loader(8))

         drop	\ Remove stack-cruft
         key	\ Get the key that was pressed

         \ Check key pressed (see loader(8)) and input limit
         dup 0<> if ( and ) readlen @ readmax < if

            \ Echo an asterisk (unless Backspace/Enter)
            dup bs_key <> if ( and ) dup enter_key <> if
                  ." *"	\ Echo an asterisk
            then then

            exit	\ Exit from the function
         then then

         \ Always allow Backspace and Enter
         dup bs_key = if exit then
         dup enter_key = if exit then

      then
      50 ms   \ Sleep for 50 milliseconds (see loader(8))
   again
;

: read ( -- String prompt )

	0 25 at-xy		\ Move the cursor to the bottom-left
	dup 1+ read-start !	\ Store X offset after the prompt
	read-start @ readX !	\ copy value to the current X offset
	0 readlen !		\ Initialize the read length
	type			\ Print the prompt

	begin	\ Loop forever

		0 sgetkey	\ Block here, waiting for a key to be pressed

		\ We are not going to echo the password to the screen (for
		\ security reasons). If Enter is pressed, we process the
		\ password, otherwise augment the key to a string.

		\ If the key that was entered was not Enter, advance
		dup enter_key <> if
			readX @ 1+ readX !	\ Advance the column
			readlen @ 1+ readlen !	\ Increment input length
		then

		\ Handle backspacing
		dup bs_key = if
			readX @ 2 - readX !	\ Set new cursor position
			readlen @ 2 - readlen !	\ Decrement input length

			\ Don't move behind starting position
			readX @ read-start @ < if
				read-start @ readX !
			then
			readlen @ 0< if
				0 readlen !
			then

			\ Reposition cursor and erase character
			readX @ 25 at-xy 1 spaces readX @ 25 at-xy
		then

		dup enter_key = if
			drop	\ Clean up stack cruft
			10 emit	\ Echo new line
			exit
		then

		\ If not Backspace or Enter, store the character
		dup bs_key <> if ( and ) dup enter_key <> if

			\ store the character in our buffer
			dup readval readlen @ 1- + c!

		then then

		drop	\ drop the last key that was entered

	again   \ Enter was not pressed; repeat
;


\ ========================================================== MAIN SOURCE

: chkpasswd ( -- )

	\ Exit if a password was not set
	s" password" getenv dup -1 = if
		drop exit
	then

	begin	\ Loop as long as it takes to get the right password

		s" Password: "	\ Output a prompt for a password
		read		\ Read the user's input until Enter

		2dup readval readlen @ compare 0= if
			2drop exit	\ Correct password
		then

		\ Bad Password
		3000 ms
		." pxeboot: incorrect password" 10 emit

	again	\ Not the right password; repeat

;
