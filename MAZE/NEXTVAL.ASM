;---------------------------------------------------------------------
; Program:   nextval subroutine
;
; Function:  Find next mouse move in an array 15 by 30.
;            We can move into a position if its contents is blank ( 20h ).
;
; Input:     Calling sequence is:
;            x    pointer   si
;            y    pointer   di
;            dir  pointer   bx
;            maze pointer   bp
;
; Output:    x,y,dir modified in caller's data segment
;
; Owner:     Dana A. Lasher
; Modified by Alex C. Lewontin
;
; Date:      Update Reason
; --------------------------
; 11/06/2016 Original version
; 03/28/2020 Implementation added
;
;
;---------------------------------------
         .model    small               ;64k code and 64k data
         .8086                         ;only allow 8086 instructions
         public    nextval             ;allow extrnal programs to call
;---------------------------------------


;---------------------------------------
         .data                         ;start the data segment
;---------------------------------------
; this table gets the relative offset from the 1d index for any move, given the current direction
; new direction is    L      F      R      B
ndx_table     dw    0FFE2h, 00001h, 0001Eh, 0FFFFh, ; current direction is E
                    00001h, 0001Eh, 0FFFFh, 0FFE2h, ; current direction is S
                    0001Eh, 0FFFFh, 0FFE2h, 00001h, ; current direction is W
                    0FFFFh, 0FFE2h, 00001h, 0001Eh  ; current direction is N

; This is the same as above but experimenting with a different algorithm

; ndx_table     dw    00001h, 0FFE2h, 0001Eh, 0FFFFh, ; current direction is E
;                     00001h, 0001Eh, 0FFFFh, 0FFE2h, ; current direction is S
;                     0FFE2h, 0FFFFh, 0001Eh, 00001h, ; current direction is W
;                     00001h, 0FFFFh, 0FFE2h, 0001Eh  ; current direction is N

; delta_y = hibyte(word), delta_x = lobyte(word)
; NOTE: all values also include a decrement by one, to convert from 1-based indexing to 0-based indexing
; new direction is     L       F       R       B
delta_table dw      0FF00h, 00001h, 00100h, 000FFh, 
                    00001h, 00100h, 000FFh, 0FF00h, 
                    00100h, 000FFh, 0FF00h, 00001h, 
                    000FFh, 0FF00h, 00001h, 00100h 
; delta_table dw        00102h, 00001h, 00201h, 00100h, 
;                       00102h, 00201h, 00100h, 00001h, 
;                       00001h, 00100h, 00201h, 00102h, 
;                       00102h, 00100h, 00001h, 00201h 

; ; new direction is    L      F      R      B
dir_table dw        0004h, 0001h, 0002h, 0003h, ; current direction is E
                    0001h, 0002h, 0003h, 0004h, ; current direction is S
                    0002h, 0003h, 0004h, 0001h, ; current direction is W
                    0003h, 0004h, 0001h, 0002h  ; current direction is N

;                     ; new direction is    L      F      R      B
; dir_table dw        0001h, 0004h, 0002h, 0003h, ; current direction is E
;                     0001h, 0002h, 0003h, 0004h, ; current direction is S
;                     0004h, 0003h, 0002h, 0001h, ; current direction is W
;                     0001h, 0003h, 0004h, 0002h  ; current direction is N
; new direction is   L        F        R       B
;abs_dir_table db    0x0004, 0x0001, 0x0002, 0x0003, 0x0001, 0x0002, 0x0003, 0x0004, 0x0002, 0x0003, 0x0004, 0x0001, 0x0003, 0x0004, 0x0001, 0x0002 
;---------------------------------------
         .code                         ;start the code segment
;---------------------------------------
; Save any modified registers
;---------------------------------------
nextval:                               ;
    push ax                                     ; store original ax
    push cx                                     ; store original cx
    push si                                     ; store original si
    push bx                                     ; store original bx

;---------------------------------------
; Code to make 1 move in the maze
;---------------------------------------
    mov bl, [bx]                                ; current move direction unsigned byte to bl
    mov bh, 00                                  ; zero extend bl to fill all of bx, for use as index
    mov cx, 03h                                 ; need the 03h in cl to shift, and the 00 in ch for a later word operation
    shl bx, cl                                   ; shift left 3 times, essentially multiplying by 8
    sub bx, 0Ah                                 ; this does two things: 
                    ; converts move direction from 1, 2, 3, 4 -> 0, 1, 2, 3, for use as index (subtracting 8 after multiplication is like subtracting 1 before) 
                    ; and then subtracts 2 extra This way the index "starts" at 0xFFFE, and then is incremented by 2 first thing in the loop to be 0. This is because we can't
                    ; easily increment it at the end of the loop, as that would destroy the condition code set by the compare instruction.

    mov al, 1Eh                                  ;prep for multiplying by 30
    mul byte ptr [di]                           ; ax = current y value * 30
    sub ax, 1Fh                                 ; unified conversion to 0 based indexing
    mov cl, [si]                                ; because unfortunately we need to get a byte here, and do word math with it
    add ax, cx                                  ; here, ax is 1d index into maze array

;---------------------------------------
; We loop here until we find a successful direction
;---------------------------------------
try_dir:
    add bx, 2                                   ; bx is now index for the next item in table (0 the first time around, cuz it starts at 0xFFFE)
    mov si, [ndx_table + bx]                    ; cx is now the offset of the next thing to try
    add si, ax                                  ; cx is now index of item in array to try
    cmp byte ptr ds:[bp + si], 020h             ; is that spot empty?
    jne try_dir                                 ; if the spot is not empty, try the next direction

;---------------------------------------
; If we've fallen through to here, bx is the index for the next move
;---------------------------------------

    mov ax, [dir_table + bx]                           ; ax now contains the new direction: ah is 00, al is the relevant byte
    mov cx, [delta_table + bx]                           ; dh is now delta y, dl is delta x
    pop bx                                      ; restore bx to pointing to the caller's direction value
    pop si                                       ; restore si to pointing to original x value
    mov [bx], al                                ; update the caller's direction value
    add [di], ch                                ; update the caller's y value
    add [si], cl                                ; update the caller's x value

;---------------------------------------
; Restore other registers and return
;---------------------------------------
exit:                                  ;
    pop cx                                      ; restore original cx
    pop ax                                      ; restore original ax
    ret                           ;return
;---------------------------------------


        end

