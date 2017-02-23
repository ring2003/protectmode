section .boot
[ORG 0x7c00]
jmp go
;-------------------------------
; here we go
;-------------------------------
go:
    mov ax,cs
    mov es,ax
    mov ds,ax
    mov ss,ax
    sub sp,0x400
mov ah,0x03
sub bh,bh
int 0x10
add dh,1
sub bl,bl
mov ax,0x1301
mov bl,0x04
mov bh,0x00
mov bp,welcomemsg
mov cx,welcomelen
int 0x10
mov ax,0x7c00
mov ds,ax
mov ax,0x1000
mov es,ax
lea ax,[PE_MODE]
mov si,ax
mov cx,codepos
sub di,di
cld
rep movsw
;;;;;;;;;;;;;;;;;;;;;;;;;
; print reading fdd...
call get_pos
mov ax,0x0
mov es,ax
mov ax,0x1301
mov bl,0x0e
mov bh,0x00
add dh,1
mov dl,0x0
mov bp,readfdd
mov cx,readlen
int 0x10
mov ah,0x0
mov dl,0x80
int 0x13
; then read
add dh,1
sub bl,bl
mov dx,0x0080
mov cx,0x0001
mov ax,0x4000
mov es,ax
xor bx,bx
mov ah,0x02
mov al,0x1
int 0x13

; start loading GDT
call get_pos
xor ax,ax
mov es,ax
mov bp,loadgdt
mov ax,0x1301
add dh,1
xor dl,dl
mov bh,0x00
mov bl,0x0e
mov cx,loadlen
int 0x10
;------------------------------------
; load GDT table
;-------------------------------------
; first of all, copy GDT to 0x90000XXX
;-------------------------------------
xor ax,ax
mov ds,ax
mov cx,gdtend - gdt
mov ax,gdt
mov si,ax
mov ax,0x9000
mov es,ax
sub di,di
cld
rep movsb
mov ax,cs
mov ds,ax
lgdt [gdtptr]
; enable A20
xor ax,ax
mov al,0xDF
out 0x60,al
;---------------------------------
; ENTER INTO PMODE
;--------------------------------
; print log
;-----------------
call get_pos
xor ax,ax
mov es,ax
mov bp,enterp
mov ax,0x1301
add dh,1
sub dl,dl
mov bl,0x0e
xor bh,bh
mov cx,enterplen
int 0x10
;---------------------------------
; enable PE bit
;---------------------------------
cli
mov eax,cr0
or eax,0x00000001
mov cr0,eax
; immediately far jump
jmp DWORD CODESEL:PE_MODE
;=======================
; PROCDURE:
; get Screen position
;=======================
get_pos:
    mov ah,0x03
    sub bh,bh
    int 0x10
    ret
;--------------------------------------------
; PM MODE
;--------------------------------------------
[BITS 32]
PE_MODE:
jmp NCODESEL:RMDOOR
;---------------------------------------------
; A door lead you to RM
;---------------------------------------------
[BITS 16]
RMDOOR:
    mov ax,NORMALSEL
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
;------------------
; disable intrrupt
;------------------
    cli
;------------------
; Reset PE bit
;------------------
    mov eax,cr0
    and al,0xfe
    mov cr0,eax
;---------------------------
; set CS to real segment
;---------------------------
    jmp 0:.L1
.L1:
;--------------------------
; Disable A20 bus
;--------------------------
    mov ax,0xfe
    out 0x60,ax
;-------------------
; Enable Intrrupt
;-------------------
    sti
;--------------------
; Now we in real mode
;--------------------
    jmp 0x4000:0x0
codepos equ $ - PE_MODE


idtptr:
    dw 0x0
    dw 0x0,0x0

;------------------------------------------
; Definitions of GDT
;------------------------------------------
%include "inc/RMMSG.inc"
%include "inc/segments.inc"

times 510 - ($-$$) db 0
dw 0xaa55