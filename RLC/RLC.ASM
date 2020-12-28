;---------------------------------------------------------------------
;  Program:      Run Length Coding
;
;  Function:     Decompresses 1 dimensional run lengths
;                This subroutine links with a C main program
;
;                Takes two pointers pushed to stack as arguments,
;                No meaningful return value, although al will always
;                be 0 on a successful exit.
;
;  Owner:       Alex Lewontin
;
;  Changes:
;  Date          Reason
;  ----          ------
;  05/16/2017    Original version ... coded to spec design
;  04/08/2020    Filled in business logic
;---------------------------------------------------------------------
        .model    small
        .8086
        public    _rlc
;---------------------------------------
        .data                         ;start the data segment
;---------------------------------------

;---------------------------------------
        .code                         ;start the code segnment
;---------------------------------------
; Save the registers ... 'C' requires (bp,si,di)
; Access the input and output lists
;---------------------------------------
_rlc:                                  ;
    push bp                          ;save 'C' register
    mov bp, sp                      ;set bp to point to stack
    sub sp, 4                       ;reserve 8 bytes of stack space
    push si                         ;save 'C' register
    push di                         ;save 'C' register
    mov ax, ds                      ; set es equal to 
    mov es, ax                      ; ds to use string ops
    mov si, [bp + 4]                ;si points to the input compressed data
    mov di, [bp + 6]                ;di points to the empty output buffer

;---------------------------------------
; The local stack vars are as follows
; bp - 2 = pels_left
; bp - 4 = not_cur;

    
    mov byte ptr [bp - 2], 0        ; initialize pels_left to 0 to pretend we just finished a line
    cld                             ; set the direction flag once for the whole program

;---------------------------------------
; loop_a
; This is analgous to the outer while loop in the c code
; It runs unconditionally until a 0-byte triggers the jump to exit
;---------------------------------------

loop_a:                             ; while (1) {
    lodsb                           ; load the first byte from si to al, increment si
    cmp al, 0                       ; if (code == 0)
    je exit                         ; return 0

    mov ah, al                      ; duplicate al in ah, to extract the two parts
    mov cl, 4                       ; set up cl for the shift
    shr ah, cl                      ; extract the first code into ah

    and al, 0Fh                     ; extract the second code into al

    mov bx, ax                      ; put the two pieces in bx (they are reversed in order)
    mov cx, 2                       ; set up for the loop to run twice

;---------------------------------------
; loop_b
; This is analgous to the inner for loop in the c code
; it runs twice, for each byte pulled out of the stream
;---------------------------------------
loop_b:                             ; {
    xchg bh, bl                     ; switch bh and bl (so that we now run on the other code)

    cmp byte ptr [bp - 2], 0        ; if (pels_left == 0)
    jne initialized                 ; then we're already in the middle of a line

    mov byte ptr [bp - 2], 80       ; otherwise, pels_left = 80;
    mov dh, 32                      ; cur = wh;
    mov byte ptr [bp - 4], 0DBh     ; not_cur = black


;---------------------------------------
; initialized
; When the execution gets here, either by jumping or falling 
; through, it means that we're already in the middle of a line
; or we just finsihed a line and then the values have been re-initialized
;---------------------------------------

initialized:                        ; if we were in a line, we're now here. Else, things are properly initialized
    xchg cl, bl                     ; store the old cl in bl, set cl to the length code stored in bl
    cmp cl, 15                      ; if (run[i] == 15)
    jne fill_buf                    ; { go ahead and start filling the buffer
    mov cl, [bp - 2]                ; if the code is 15, then set the length to pels_left


;---------------------------------------
; initialized
; When the execution gets here, either by jumping or falling 
; through, it means that we're already in the middle of a line
; or we just finsihed a line and then the values have been re-initialized
;---------------------------------------
fill_buf:
    sub byte ptr [bp - 2], cl       ; reduce pels_left by the amount we're about to put into the buffer
    mov al, dh                      ; move the current value (black or white) into al for a string op
rep stosb                           ; put al (cur) into di (output buffer) cl (len) times
    xchg cl, bl                     ; restore the original cl (used for for loop)
    xchg dh, byte ptr [bp - 4]      ; if black, switch to white. If white, switch to black
    loop loop_b                     ; for loop check and loop
    jmp loop_a                      ; if loop b doesnt loop, jump

;---------------------------------------
; Restore registers and return
;---------------------------------------
exit:                               ;
    pop di                          ; restore 'C' register
    pop si                          ; restore 'C' register
    add sp, 4                       ; release the 4 bytes of stack space
    pop bp                          ; restore 'C' register
    ret                             ; return
;---------------------------------------
        end

