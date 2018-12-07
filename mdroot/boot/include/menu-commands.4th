\ $Header: /cvsroot/druidbsd/druidbsd/druidbsd/mdroot/boot/include/menu-commands.4th,v 1.1.1.1 2010/09/15 20:36:29 devinteske Exp $
\ ========================================================== INFORMATION
\ AUTHOR: Devin Teske
\ DATE: January 19th, 2006
\ LAST MODIFIED: March 2nd, 2010 08:04:13
\ 
\ This is quite an odd language, is it not? Elegant though

marker task-menu-commands.4th
\ ========================================================== VARIABLES

\ Boolean option status variables
variable toggle_state1
variable toggle_state2
variable toggle_state3
variable toggle_state4
variable toggle_state5
variable toggle_state6
variable toggle_state7
variable toggle_state8

\ Array option status variables
variable cycle_state1
variable cycle_state2
variable cycle_state3
variable cycle_state4
variable cycle_state5
variable cycle_state6
variable cycle_state7
variable cycle_state8

\ Containers for storing the initial caption text
create init_text1 255 allot
create init_text2 255 allot
create init_text3 255 allot
create init_text4 255 allot
create init_text5 255 allot
create init_text6 255 allot
create init_text7 255 allot
create init_text8 255 allot

\ ========================================================== FUNCTIONS

: toggle_menuitem ( N -- N )

	\ ASCII numeral equal to user-selected menu item must be on the stack.
	\ We do not modify the stack, so the ASCII numeral is left on top.

	s" init_textN"		\ base name of buffer
	-rot 2dup 9 + c! rot	\ replace 'N' with ASCII num

	evaluate c@ 0= if
		\ NOTE: no need to check toggle_stateN since the first time we
		\ are called, we will populate init_textN. Further, we don't
		\ need to test whether menu_caption[x] is available since we
		\ would not have been called if the caption was NULL.

		s" menu_caption[x]"	\ base name of environment variable
		-rot 2dup 13 + c! rot	\ replace 'x' with ASCII numeral

		getenv dup -1 <> if

			s" init_textN"		\ base name of buffer
			4 pick			\ copy ASCII num to top
			rot tuck 9 + c! swap	\ replace 'N' with ASCII num
			evaluate

			\ now we have the buffer c-addr on top
			\ ( followed by c-addr/u of current caption )

			\ Copy the current caption into our buffer
			2dup c! -rot \ store strlen at first byte
			begin
				rot 1+	\ bring alt addr to top and increment
				-rot -rot	\ bring buffer addr to top
				2dup c@ swap c!	\ copy current character
				1+	\ increment buffer addr
				rot 1-	\ bring buffer len to top and decrement
				dup 0=	\ exit loop if buffer len is zero
			until
			2drop	\ buffer len/addr
			drop	\ alt addr

		else
			drop
		then
	then

	\ Now we are certain to have init_textN populated with the initial
	\ value of menu_caption[x]. We can now use init_textN as the untoggled
	\ caption and toggled_text[x] as the toggled caption and store the
	\ appropriate value into menu_caption[x]. Last, we'll negate the
	\ toggled state so that we reverse the flow on subsequent calls.

	s" toggle_stateN @"	\ base name of toggle state var
	-rot 2dup 12 + c! rot	\ replace 'N' with ASCII numeral

	evaluate 0= if
		\ state is OFF, toggle to ON

		s" toggled_text[x]"	\ base name of toggled text var
		-rot 2dup 13 + c! rot	\ replace 'x' with ASCII num

		getenv dup -1 <> if
			\ Assign toggled text to menu caption

			s" menu_caption[x]"	\ base name of caption var
			4 pick			\ copy ASCII num to top
			rot tuck 13 + c! swap	\ replace 'x' with ASCII num

			setenv	\ set new caption
		else
			\ No toggled text, keep the same caption

			drop
		then

		true	\ new value of toggle state var (to be stored later)
	else
		\ state is ON, toggle to OFF

		s" init_textN"		\ base name of initial text buffer
		-rot 2dup 9 + c! rot	\ replace 'N' with ASCII numeral
		evaluate		\ convert string to c-addr
		count			\ convert c-addr to c-addr/u

		s" menu_caption[x]"	\ base name of caption var
		4 pick			\ copy ASCII num to top
		rot tuck 13 + c! swap	\ replace 'x' with ASCII numeral

		setenv	\ set new caption

		false	\ new value of toggle state var (to be stored below)
	then

	\ now we'll store the new toggle state (on top of stack)
	s" toggle_stateN"	\ base name of toggle state var
	3 pick			\ copy ASCII numeral to top
	rot tuck 12 + c! swap	\ replace 'N' with ASCII numeral
	evaluate		\ convert string to addr
	!			\ store new value
;



: cycle_menuitem ( N -- N )

	\ ASCII numeral equal to user-selected menu item must be on the stack.
	\ We do not modify the stack, so the ASCII numeral is left on top.

	s" cycle_stateN"	\ base name of array state var
	-rot 2dup 11 + c! rot	\ replace 'N' with ASCII numeral

	evaluate	\ we now have a pointer to the proper variable
	dup @		\ resolve the pointer (but leave it on the stack)
	1+		\ increment the value

	\ Before assigning the (incremented) value back to the pointer,
	\ let's test for the existence of this particular array element.
	\ If the element exists, we'll store index value and move on.
	\ Otherwise, we'll loop around to zero and store that.

	dup 48 + \ duplicate Array index and convert to ASCII numeral

	s" menu_caption[x][y]"		\ base name of array caption text
	-rot tuck 16 + c! swap		\ replace 'y' with Array index
	4 pick rot tuck 13 + c! swap	\ replace 'x' with menu choice

	\ Now test for the existence of our incremented array index in the
	\ form of $menu_caption[x][y] as set in loader.rc(5), et. al.

	getenv dup -1 = if
		\ No caption set for this array index. Loop back to zero.

		drop	( getenv cruft )
		drop	( incremented array index )
		0	( new array index that will be stored later )

		s" menu_caption[x][0]"		\ base name of caption var
		4 pick rot tuck 13 + c! swap	\ replace 'x' with menu choice

		getenv dup -1 = if
			\ This is highly unlikely to occur, but to make
			\ sure that things move along smoothly, allocate
			\ a temporary NULL string

			s" "
		then
	then

	\ At this point, we should have the following on the stack (in order,
	\ from bottom to top):
	\ 
	\    N      - Ascii numeral representing the menu choice (inherited)
	\    Addr   - address of our internal cycle_stateN variable
	\    N      - zero-based number we intend to store to the above
	\    C-Addr - string value we intend to store to menu_caption[x]
	\ 
	\ Let's perform what we need to with the above.

	s" menu_caption[x]"		\ base name of menuitem caption var
	6 pick rot tuck 13 + c! swap	\ replace 'x' with menu choice
	setenv				\ set the new caption

	swap ! \ update array state variable
;



: cycle_kernel ( N -- N TRUE )
	cycle_menuitem
	menu-redraw

	\ Now we're going to make the change effective

	s" cycle_stateN"	\ base name of array state var
	-rot 2dup 11 + c! rot	\ replace 'N' with ASCII numeral
	evaluate		\ translate name into address
	@			\ dereference address into value
	48 +			\ convert to ASCII numeral

	\ Since we are [in this file] going to override the standard `boot'
	\ routine with a custom one, you should know that we use $kernel
	\ when referencing the desired kernel. Set $kernel below.

	s" set kernel=${kernel_prefix}${kernel[N]}${kernel_suffix}"
				\ command to assemble full kernel-path
	-rot tuck 36 + c! swap	\ replace 'N' with array index value
	evaluate		\ sets $kernel to full kernel-path

	TRUE \ loop menu again
;

: toggle_keyboard ( N -- N TRUE )
	toggle_menuitem
	menu-redraw

	\ Now we're going to make the change effective

	s" toggle_stateN @"	\ base name of toggle state var
	-rot 2dup 12 + c! rot	\ replace 'N' with ASCII numeral

	evaluate 0= if
		s" hint.atkbd.0.flags" unsetenv
	else
		s" 0x1" s" hint.atkbd.0.flags" setenv
	then

	TRUE \ loop menu again
;

: toggle_verbose ( N -- N TRUE )
	toggle_menuitem
	menu-redraw

	\ Now we're going to make the change effective

	s" toggle_stateN @"	\ base name of toggle state var
	-rot 2dup 12 + c! rot	\ replace 'N' with ASCII numeral

	evaluate 0= if
		s" boot_verbose" unsetenv
	else
		s" YES" s" boot_verbose" setenv
	then

	TRUE \ loop menu again
;

: toggle_acpi ( N -- N TRUE )
	toggle_menuitem
	menu-redraw

	\ Now we're going to make the change effective

	s" toggle_stateN @"	\ base name of toggle state var
	-rot 2dup 12 + c! rot	\ replace 'N' with ASCII numeral

	evaluate 0= if
		s" acpi_load" unsetenv
		s" 1" s" hint.acpi.0.disabled" setenv
		s" 1" s" loader.acpi_disabled_by_user" setenv
	else
		s" YES" s" acpi_load" setenv
		s" 0" s" hint.acpi.0.disabled" setenv
		s" loader.acpi_disabled_by_user" unsetenv
	then

	TRUE \ loop menu again
;

: cycle_root ( N -- N TRUE )
	cycle_menuitem
	menu-redraw

	\ Now we're going to make the change effective

	s" cycle_stateN"	\ base name of array state var
	-rot 2dup 11 + c! rot	\ replace 'N' with ASCII numeral
	evaluate		\ translate name into address
	@			\ dereference address into value
	48 +			\ convert to ASCII numeral

	\ Since we are [in this file] going to override the standard `boot'
	\ routine with a custom one, you should know that we use $root when
	\ booting. Set $root below.

	s" set root=${root_prefix}${root[N]}${root_prefix}"
				\ command to assemble full kernel-path
	-rot tuck 30 + c! swap	\ replace 'N' with array index value
	evaluate		\ sets $kernel to full kernel-path

	TRUE \ loop menu again
;

: goto_prompt ( N -- N FALSE )

	cr
	." To get back to the menu, type `menu' and press ENTER" cr
	." or type `boot' and press ENTER to begin installation" cr
	cr

	FALSE \ exit the menu
;

: boot ( -- )

	\ Overloading the standard `boot' command with custom one

	." [37;44mBooting...[0m" cr

	\ Load the kernel (must be loaded before loading additional files)
	s" load /${kernel}" evaluate

	\ Load mfsroot
	s" load -t mfs_root ${loader_boot}/${root}" evaluate

	\ The default mount root is `ufs:/dev/md0c'. Redefine it to the
	\ correct value for our configuration (given above mfsroot)
	s" ufs:/dev/md0" s" vfs.root.mountfrom" setenv

	\ The default action is to mount the root in read-only mode. Define
	\ that we would instead prefer to mount in read-write mode
	s" rw" s" vfs.root.mountfrom.options" setenv

	\ Boot the system by calling the FICL word: boot ( state -- )
	0 boot

;

\ ========================================================== MAIN SOURCE

\ Initialize our boolean state variables
0 toggle_state1 !
0 toggle_state2 !
0 toggle_state3 !
0 toggle_state4 !
0 toggle_state5 !
0 toggle_state6 !
0 toggle_state7 !
0 toggle_state8 !

\ Initialize our array state variables
0 cycle_state1 !
0 cycle_state2 !
0 cycle_state3 !
0 cycle_state4 !
0 cycle_state5 !
0 cycle_state6 !
0 cycle_state7 !
0 cycle_state8 !

\ Initialize string containers
0 init_text1 c!
0 init_text2 c!
0 init_text3 c!
0 init_text4 c!
0 init_text5 c!
0 init_text6 c!
0 init_text7 c!
0 init_text8 c!
