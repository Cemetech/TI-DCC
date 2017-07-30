.nolist
#include "ti84pcse.inc"
#include "dcse8.inc"
IvtLocation	.equ	080h ; vector table at 8000h
IsrLocation	.equ	85h ; ISR at $D0D0D0
.list

	.org UserMem
BinaryStart:
	.db $EF,$11     ;OpenLib(                                    2    2
	.db "D",$BB,$BF,$BB,$BF,$BB,$C2,$BB,$C3,"CSE",$11,$3F  ;    14   16
	.db $EF,$12,$3F ;ExecLib                                     3   19
	.db $D5,$3F     ;Return                                      2   21
	.db tExtTok,tAsm84CPrgm,$3F ;                                3   24 bytes total
HeaderStart:
	.dw ASMStart-HeaderStart ;offset to code
	
	.dw 10
	.db 3
	.db "DoorsCSE",8,0
	
	.dw Header_Author_End-Header_Author_Start
	.db 2
Header_Author_Start:
	.db "Not Me",0
Header_Author_End:

	.dw Header_Desc_End-Header_Desc_Start
	.db 0
Header_Desc_Start:
	.db "Ti-DCC",0
Header_Desc_End:

	.dw 0
	.db $ff
ASMStart:
	.relocate UserMem
ProgramStart:
SetUpInterrupt:
	di
	xor	a
	out	(pIntMask), a
	out	(pCrstlTmr1Freq), a
	out	(pCrstlTmr2Freq), a
	out	(pCrstlTmr3Freq), a
	out	(pLnkAstSeEnable), a
	; And kill USB ~Copied from KermM
	out	(57h), a
	out	(5Bh), a
	out	(4Ch), a
	ld	a, 2
	out	(54h), a
    
	; Custom Interrupts
	ld	hl, IvtLocation*256
	ld	de, IvtLocation*256+1
	ld	bc, 256
	ld	a, IvtLocation
	ld	i, a
	ld	a, IsrLocation
	ld	(hl), a
	ldir
 
	ld	hl, InterruptServiceRoutine
	ld	de, IsrLocation*256+IsrLocation
	ld	bc, 3
	ldir

        
    ld a,82h ; set to CPU_FREQ/4
    out (30h),a
    ld a,3 ; Set timer interrupt, + Loop
    out (31h),a
    ld a,218  ; Set loop Period
    out (32h),a

	im 2
    
    ;Testing initializers
    ex af,af'
    ld a,2
    ex af,af'
    ei
    
	jp $
    
 
InterruptServiceRoutine:
    exx
        ex af,af'    ;Save Regs
        cpl          ;Alternate bits for wave
        out (0),a    ;Send to port
        push af    
            ld a,3   ;Reset interrupt
            out (31h),a ; Move this to beginning 
        pop af
        ex af,af'
    exx
    ei
    ret
.endrelocate
.end