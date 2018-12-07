\ $Header: /cvsroot/druidbsd/druidbsd/druidbsd/mdroot/boot/include/dc_execute.4th,v 1.1.1.1 2010/09/15 20:36:29 devinteske Exp $
\ ========================================================== INFORMATION
\ AUTHOR: Devin Teske
\ DATE: June 4th, 2008
\ LAST MODIFIED: January 4th, 2010 10:12:14
\ 
\ PURPOSE:
\ 
\    To introduce a delay (in seconds) before executing a specific task,
\    allowing the user to cancel said task by pressing any key within the
\    allotted time (or pressing ENTER to bypass the delay).
\     
\    This is useful if you need to be able to escape to the loader prompt
\    before executing further scripts. For example, if you are developing a
\    custom CD/DVD installer that is automated, this can provide a mechanism
\    for preempting those scripts for debugging purposes.
\    
\    You must set the variable "dc_command" to the FICL command that you wish
\    to evaluate/execute. In the event that Ctrl-C is NOT pressed during the
\    waiting period, the command will be executed. Otherwise, the command is
\    not executed and execution is returned to the calling sub-routine.
\    
\    Setting a numeric value to the variable "dc_seconds" will change the
\    duration of the wait. Default is five (5) seconds.
\ 
\ 
\ This is quite an odd language, is it not? Elegant though

marker task-dc_execute.4th
\ ========================================================== VARIABLES

5  constant dc_default	\ Default delay (in seconds)
3  constant etx_key	\ End-of-Text character produced by Ctrl+C
13 constant enter_key	\ Carriage-Return character produce by ENTER
27 constant esc_key	\ Escape character produced by ESC or Ctrl+[

variable dc_tstart	\ state variable used for delay timing
variable dc_delay	\ determined configurable delay duration
variable dc_cancelled	\ state variable for user cancellation
variable dc_showdots	\ whether continually print dots while waiting

\ ========================================================== MAIN SOURCE

: dc_execute ( -- )

	\ make sure that we have a command to execute
	s" dc_command" getenv dup -1 = if
		drop exit 
	then

	\ read custom time-duration (if set)
	s" dc_seconds" getenv dup -1 = if
		drop \ no custom duration (remove dup'd bunk -1)
		dc_default \ use default setting (replacing bunk -1)
	else
		\ make sure custom duration is a number
		?number 0= if
			dc_default \ use default if otherwise
		then
	then

	\ initialize state variables
	dc_delay !		\ stored value is on the stack from above
	seconds dc_tstart !	\ store the time we started
	0 dc_cancelled !	\ boolean flag indicating user-cancelled event

	false dc_showdots !	\ reset to zero and read from environment
	s" dc_showdots" getenv dup -1 <> if
		2drop		\ don't need the value, just existance
		true dc_showdots !
	else
		drop
	then


	\ Loop until we have exceeded the desired time duration
	begin
		25 ms \ sleep for 25 milliseconds (40 iterations/sec)

		\ throw some dots up on the screen if desired
		dc_showdots @ if
			." ." \ dots visually aid in the perception of time
		then

		\ was a key depressed?
		key? if
			key \ obtain ASCII value for keystroke
			dup enter_key = if
				-1 dc_delay ! \ break loop
			then
			dup etx_key = swap esc_key = OR if
				-1 dc_delay ! \ break loop
				-1 dc_cancelled ! \ set cancelled flag
			then
		then

		\ if the time duration is set to zero, loop forever
		\ waiting for either ENTER or Ctrl-C/Escape to be pressed
		dc_delay @ 0> if
			\ calculate elapsed time
			seconds dc_tstart @ - dc_delay @ >
		else
			-1 \ break loop
		then
	until

	\ if we were throwing up dots, throw up a line-break
	dc_showdots @ if
		cr
	then

	\ did the user press either Ctrl-C or Escape?
	dc_cancelled @ if
		2drop \ we don't need the command string anymore
	else
		evaluate \ evaluate/execute the command string
 	then

;
