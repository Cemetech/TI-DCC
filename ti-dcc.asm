.nolist
#include "ti84pcse.inc"
#include "dcse8.inc"
#include "include.inc"

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
 
    ld  hl, InterruptServiceRoutine
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
    ex af,af'
    ld a,2
    ex af,af'
    ei

    
    jp $
    

InterruptServiceRoutine:

    ex af,af'               
        exx
            ld bc,(%00000011 << 8)+pCrstlTmr1Cfg ;
            out (c),b                ;17cc Faster then PushPop
            or a                     ;If != Zero
            jp nz,doWait
            ld a,(dccState.flags)
            ;ld ix,(dccState.msgPTR)
            out (0),a                ;No other flags then bit. 
            bit 1,a                  ;Check period
            ld a,(dccState.curDat)   ;Load A with current data being processed
            jp nz,doPeriodB          ;If Z We are period A   
doPeriodA:
            bit 0,a                  ;Check current data Bit
            jp nz,+                  ;If Z set wait
            ld a,1  
            ld (dccState.waitCTR),a  ;Load Wait
+:  
            ld a,periodB             ;Set period and Output Link Mirror Bit
            ld (dccState.flags),a    ;to %00000010
            jp doIntEnd
doPeriodB:
            bit 0,a                  ;Check current data bit
            jp nz,+                  ;If Z set Wait
            ld a,1                   ;
            ld (dccState.waitCTR),a  ;Load Wait
+:  
            ld a,periodA             ;Set period and Output Link Mirror Bit
            ld (dccState.flags),a    ;to 0
            jp doIntEnd              ;Need todo B specific stuff here
doIntEnd:
        exx
    ex af,af'
    exx
    ei
    ret

doWait:
            dec a
        exx
    ex af',af
    ret
.endrelocate
.end