;-----------------------------------------------------------
;
; Program: Linkhll
;
; Function: This program takes four unsigned 16-bit integers, 
;   identifies the largest two, and multiplies them together. 
;   It can be called from a C program.
;
; Input: This program takes 4 parameters pushed on the stack,
;       and returns a 32-bit unsigned integer in the register
;       pair ax:dx.
;
; Owner: Alex Lewontin
;
; Date:
; 04/01/2020   Original Version
;
;
;---------------------------------------
        .model    small               ;
        .8086                         ;
        public    _linkhll            ;
;---------------------------------------


        .code
;---------------------------------------
;
; Code Segment
;
;---------------------------------------
_linkhll:

    push bp           ; convention dictates bp must be saved
    mov bp, sp        ; they both point to the `bp` entry on stack
    mov ax, [bp + 4]  ; ax contains the value of v1
    mov bx, [bp + 6]  ; bx contains the value of v2
    cmp ax, bx        ; need to know which one is bigger
    ja check_v3        ; if the one in ax is bigger, do nothing and move on
    xchg bx, ax       ; if the one in bx is bigger, put it in ax
;---------------------------------------
;
; This section checks if v3 is bigger than either of
; the first two parameters, and puts it in the appropriate
; register (ax if it's the biggest, bx if it's the second biggest)
;
;---------------------------------------
check_v3:
    cmp bx, [bp + 8]  ; compare the smaller of v1 and v2 to v3
    ja check_v4        ; if v3 is smaller, move on to v4
    mov bx, [bp + 8]    ; if v3 is bigger, swap it with the smaller
    cmp ax, bx        ; check again which is bigger
    ja check_v4        ; if the one in ax is bigger, do nothing and move on
    xchg bx, ax       ; if the one in bx is bigger, put it in ax

;---------------------------------------
;
; This section checks if v4 is bigger than either of
; the first three parameters, and swaps it with the second biggest if it is
; You don't need to compare it with the biggest.
;
;---------------------------------------

check_v4:
    cmp bx, [bp + 10]  ; compare the middle value of v1, v2, and v3 to v4
    ja multiply         ; if the one in the register is bigger, move on to multiplication
    mov bx, [bp + 10]   ; otherwise, stick the bigger value into bx.

;---------------------------------------
;
; Now we have the biggest two parameters in ax and bx
; let's multiply and return.
;
;---------------------------------------
multiply:
    mul bx            ; now ax:dx contains the appropriate result
    pop bp            ; restore the original bp
    ret               ; return from subroutine call

        end                           ; end source code
;---------------------------------------



; cmp bx, ax -> bx - ax
; ja loc means jump if CF = 0 and ZF = 0
