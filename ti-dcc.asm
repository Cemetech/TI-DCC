.nolist
.binarymode TI8X
#include "ti84pcse.inc"
#include "dcse8.inc"
.module main
.export


IvtLocation	.equ	080h ; vector table at 8000h
IsrLocation	.equ	85h ; ISR at TextShadPtrs

periodA .equ 1 
periodB .equ 1 << 1

;.varloc appData,256 ; Used by IVT
.varloc plotSScreen,768
.varloc saveSScreen,768
;.varloc statVars,531 ; Let us shoot to not use this, Also BCALL(_DelRes)
.local
.struct dccStateStruct      ;Digital Command Station State Vars
    .var 2, msgPTR    ;pointer to current message being processed
    .var 1, size     ;current bit "count" 
    .var 1, curDat    ;Current shifted data byte
    .var 1, flags     ;bit mask
                      ; b0 = Output Link Mirror Bit
                      ; b1 = Period A/B
    .var 1, waitCTR   ;Set to 255 for pausing between packets ~15ms   
    .var 1, repeat    ; 0-254 times, 255 until changed
.endstruct 
;Default initializations for queueing message
; <ptr>
; 0 
; Preferabbly 0xFF
; 0
; 0 

.struct dccPacketStruct   ;https://www.nmra.org/sites/default/files/s-9.2.1_2012_07.pdf
    .var 1, size      ;number of data bits in this packet-1
    .var 1, data1     ;packet bytes
    .var 1, data2     ;
    .var 1, data3     ;
    .var 1, data4     ;
    .var 1, data5     ;
    .var 1, data6     ; error == address ^ data
.endstruct
.var dccStateStruct, dccstate
.var dccPacketStruct, dccIdlePacket
.var dccPacketStruct, dccUserPacket
.endlocal
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
    xor a
    out (pIntMask), a
    out (pCrstlTmr1Freq), a
    out (pCrstlTmr2Freq), a
    out (pCrstlTmr3Freq), a
    out (pLnkAstSeEnable), a
    ; And kill USB ~Copied from KermM
    out (57h), a
    out (5Bh), a
    out (4Ch), a
    ld  a, 2
    out (54h), a
    
    ; Custom Interrupts
    ld  hl, IvtLocation*256
    ld  de, IvtLocation*256+1
    ld  bc, 256
    ld  a, IvtLocation
    ld  i, a
    ld  a, IsrLocation
    ld  (hl), a
    ldir
 
    ld  hl, InterruptServiceRoutineEnter
    ld  de, IsrLocation*256+IsrLocation
    ld  bc, 3
    ldir
    
    ld a,82h                ; Set to CPU_FREQ/4 to Port $30
    out (pCrstlTmr1Freq),a
    ld a,%00000011          ; Set timer interrupt + loop to Port $31
    out (pCrstlTmr1Cfg),a
    ld a,218                ; Set loop period for ~58us at 15MHz to Port $32
    out (pCrstlTmr1Count),a

    im 2
                            ;Testing initializers
    
    ld de,dataLLUT
    call genLUT             ;set up lut for interrupts
    
    ex af,af'
    xor a
    ex af,af'
    xor a
    ld (dccState.flags),a
    ld (dccState.size),a
    ld hl,idlePacket
    ld (dccState.msgPTR),hl
    ld a,255
    ld (dccState.waitCTR),a
    ld (dccState.repeat),a
    ld (dccState.curDat),a
    ei

    
    jp $
    
genLUT:  ;DE=starting address. Must be 256-byte aligned.
	ld a,e
	rrca \ rrca \ rrca
	and 7
	ld (de),a
	ld a,e
	inc d
	and 7
	ld b,a
	ld a,1
	jr z,$+5
	rlca
	djnz $-1
	ld (de),a
	dec d
	inc e
	jr nz,genLUT
	ret
InterruptServiceRoutineEnter:
    jp InterruptServiceRoutine
InterruptServiceRoutine:

    ex af,af'               
        exx
            ld bc,(%00000011 << 8)+pCrstlTmr1Cfg ;
            out (c),b                ;17cc Faster then PushPop
            
            or a                     ;If != Zero.
            jp nz,doWait
            
            ld a,(dccState.flags)
            out (0),a                ;Output bits to port 
            bit 1,a                  ;Check period
            ld a,(dccState.curDat)   ;Load A with current data being processed
            jp nz,doPeriodB          ;If Z We are period A   
doPeriodA:
            or a                  ;Check current data Bit
            jp nz,_notZeroBit1                 ;If Z set wait
            ld a,1  
            ld (dccState.waitCTR),a  ;Load Wait
_notZeroBit1:  
            ld a,periodB             ;Set period and Output Link Mirror Bit
            ld (dccState.flags),a    ;to %00000010
            jp doIntEnd
doPeriodB:
            or a                     ;Check current data bit
            jp nz,_notZeroBit2                  ;If Z set Wait
            ld a,1                   ;
            ld (dccState.waitCTR),a  ;Load Wait
_notZeroBit2:  
            ld a,periodA             ;Set period and Output Link Mirror Bit
            ld (dccState.flags),a    ;to %00000001
stateBEnd:
.endasm
            ;Ok time to load the next bit
            ld hl,(dccState.msgPTR)    ;10
            inc hl
            ld a,(dccState.size)     ;13
            ld b,a                   ;4
            rrca \ rrca \ rrca       ;12
            and %00011111            ;4   bitcount // 8
            add a,l                  ;4   
            ld l,a                   ;4   Offset HL by ^
            ld a,b                   ;4  
            and %00000111            ;4   bitcount % 8
            ld b,a                   ;4   loop counter
            ld a,(hl)                ;7   ld a with byte
            jp z,_bitZero                   ;10  85
_loop:          
            rrca                     ;4 * b    w28
            djnz _loop                   ;13 * b   w91  Shift to bit 1
_bitZero:     
            and 1
.asm

            ld hl,(dccState.msgPTR)
            inc hl
            ld a,(dccState.size)
            ld e,a
            ld d,dataLLUT>>8
            ld a,(de) \	inc d  ;First LUT is for(i=0;i<256;i++) arr1[i] = (i>>3)&7;
            add a,L
            ld L,a
            jr nc,$+3
            inc h
            ld a,(de)          ;Second LUT is for(i=0;i<256;i++) arr2[i] = 1<<(i&7);
            and (hl)
           
            ld (dccState.curDat),a
            
            ld hl,(dccState.msgPTR)  
            ld a,(dccState.size)
            cp (hl)                     ;sub max from current
            ;if zero
            jp z,checkRepeat            ;If 0 we have sent the packet
            inc a
            ld (dccState.size),a        ;Store the size back for next call
doIntEnd:   
            ld a,(dccState.waitCTR)     ;waitCTR is set in loop or at last wait count
        exx
    ex af,af'
    ei
    ret
checkRepeat:                            ;If repeat !=0 repeat packet send
            ld a,(dccState.repeat)
            cp 255
            jp z,repeatEntry            ;If repeat is 255 requeue
            or a                        
            jp loadIdleAfterRepeat      ;If repeat is zero load idle packet
            dec a
            ld (dccState.repeat),a      ;Else Dec and store repeat
repeatEntry:
            xor a
            ld (dccState.size),a        ;reset packet
            ld (dccState.flags),a
            ld a,255
            ld (dccState.waitCTR),a     ;Wait ~14ms for sanity
            jp doWait                   ;no need to rest curdat is already 1
            
            
loadIdleAfterRepeat:
            xor a
            ld (dccState.flags),a
            ld (dccState.size),a
            ld hl,idlePacket
            ld (dccState.msgPTR),hl
            ld a,255
            ld (dccState.waitCTR),a
            ld (dccState.repeat),a
            ld (dccState.curDat),a
doWait:
            dec a
            ld (dccState.waitCTR),a ;Save wait
        exx
    ex af,af'
    ei
    ret
.align 16
idlePacket:
.db 43
.db %11111111
.db %01111111
.db %11111111
.db %00000000
.db %11111110
.db %00000011
.align 256
dataLLut:
.fill 512,0         ;I know this is bad should move this to saferam. But meh
.endmodule
.endrelocate
.global
.end