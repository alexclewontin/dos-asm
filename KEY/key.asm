; **************************************************************************************************
; *		KEY
; * 	
; * 	When run, key takes input from the keyboard, translates it, and echoes it to the screen.
; *			- Lower case letters are converted to their upper case equivalent
; *-		- Upper case letters, spaces and the '.' are left as is.
; *		After being printed, the'.' ends execution.
; *		
; *		The program reads from the standard input and writes to the standard output. It can be 
; *		It can be redirected to a file.
; *
; *		The program displays no prompts or output other than the echoed characters.
; *
; * 	At termination, the program will return 0.
; *
; *		Written by Alex Lewontin
; *		
; * 	2/16/2019
; * 
; **************************************************************************************************

	.model small
	.8086

	.data
tran		db		20h	dup (0)						; Setting up translation table,
			db		' '								; a block of 256 continuous bytes
			db		0Dh	dup (0)						; it maps 20h, 2Eh, and the uppercase
			db		'.'								; characters to themselves
			db		12h	dup (0)						; and the lowercase characters to 
			db		'ABCDEFGHIJKLMNOPQRSTUVWXYZ'	; the uppercase characters. Everything else
			db		0,0,0,0,0,0						; is mapped to null bytes.
			db		'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
			db		133 dup (0)

	.code

; **************************************************************************************************
; *		start: initialization work (setting up DS register, translation table address)
; **************************************************************************************************
start:
			mov		ax, @data						; loading address of data segment
			mov		ds, ax							; into DS register
			mov		bx, offset tran					; loading address of translation table into bx
													; as required by the xlat instruction

; **************************************************************************************************
; * 		get_char: get the character from the input
; **************************************************************************************************
get_char:
			mov		ah, 8							; code to read no echo
			int		21h								; call DOS, al gets char

; **************************************************************************************************
; * 		process_char: convert the character, and figure out what to do with it
; **************************************************************************************************

process_char:
			xlat									; translate al to tran[al]
			cmp 	al, 0							; check if tran[al] is 0
			je		get_char						; if so, we discard and move on

; **************************************************************************************************
; * 		put_char: write the character to the output
; **************************************************************************************************
put_char:
			mov		dl, al							; otherwise, put it in dl to print
			mov		ah, 2							; code to write to stdout
			int		21h								; call DOS

; **************************************************************************************************
; * 		check_loop: figure out whether to terminate, or go again
; **************************************************************************************************

check_loop:
			cmp		dl, '.'							; check if char is dot
			jne		get_char						; loop if not, end if so
			mov   	ax, 4c00h   					; ah = service code
			int   	21h         					; al = return code

	end start




