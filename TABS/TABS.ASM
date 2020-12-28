; **************************************************************************************************
; *		TABS
; *
; *	When run, tabs.exe takes input, translates it, and echoes it. All characters are faithfully
; *	echoed, except tabs, which are replaced with a number of spaces such that the next character
; *	is aligned at a fixed distance from the beginning of the line.
; * 		- After being printed, the EOF character (ASCII 0x1A) ends execution.
; *
; *	The program reads from the standard input and writes to the standard output.
; * 	It can be redirected to a file.
; *
; *	The program takes one optional argument, a number between 1 and 9. If this argument is
; * 	provided, it dictates the number of spaces in a column. If it is not, this defaults to 10.
; *
; *	The program displays no prompts or output other than the echoed characters.
; *
; * 	At termination, the program will return 0.
; *
; *	Written by Alex Lewontin
; *
; * 	2/26/2020
; *
; **************************************************************************************************

	.model small
	.8086

; **************************************************************************************************
; *		start: initialization work (set up bl to contain size of tabstop)
; **************************************************************************************************


	.code
; **************************************************************************************************
; *		start: initialization work (set up bl to contain size of tabstop)
; **************************************************************************************************

start:
		mov	bl, 0Ah			; load default tab value into bl
		cmp	byte ptr es:[80h], 0	; check if command line argument was passed
		je	get_char_full_counter	; if not, initialize the counter and get the first char
		mov	bl, byte ptr es:[82h]	; else, get the ASCII size of a tab
		sub 	bl, 30h			; convert ASCII '1'-'9' to numeric 1-9

; **************************************************************************************************
; * 		get_char_full_counter: reset the counter, then fall through to get_char
; **************************************************************************************************

get_char_full_counter:
		mov	bh, bl			; initialize or reset counter (in bh) to tab size (stored in bl)

; **************************************************************************************************
; * 		get_char: get the character from the input
; **************************************************************************************************

get_char:
		mov	ah, 8			; code to read, no echo
		int	21h			; call DOS, al gets char

; **************************************************************************************************
; * 		check_tab: determine the approprite action depending on what the character is
; **************************************************************************************************

check_tab:
		cmp	al, 9			; check if it's a tab
		jne	put_char		; skip to printing if not

; **************************************************************************************************
; * 		process_tabs: handle a tabs character when it is entered
; **************************************************************************************************

process_tab:
		mov	dl, ' '			; load a space in dl to print
		mov	ah, 2			; code to write to screen
		int	21h			; call DOS
		sub	bh, 1			; decrement tab counter
		jnz	process_tab		; loop until tab counter is empty
		jmp	get_char_full_counter	; when empty, get the next character and reset the counter

; **************************************************************************************************
; * 		put_char: print a character to the output, and update the counter to reflect
; **************************************************************************************************

put_char:
		mov	dl, al			; put character in dl for printing
		mov	ah, 2			; code to write to screen
		int	21h			; call DOS
		sub	bh, 1			; decrement counter after printing
		jnz	check_loop		; if counter isn't fully empty, decide what to do
		mov 	bh, bl			; if it is, reset it and then decide what to do

; **************************************************************************************************
; * 		check_loop: figure out whether to terminate, or go again
; **************************************************************************************************

check_loop:
		cmp	dl, 0Ah			; at the end of the line, the counter should reset
		je	get_char_full_counter	; so we reset it when we see a LF char (which is second in a CRLF sequence)
		cmp	dl, 1Ah			; check if char is EOF
		jne 	get_char		; loop if not, end if so
		mov   	ax, 4c00h   		; ah = service code
		int   	21h         		; al = return code

	end start




