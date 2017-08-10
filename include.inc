#include "ti84pcse.inc"
#include "dcse8.inc"


IvtLocation	.equ	080h ; vector table at 8000h
IsrLocation	.equ	85h ; ISR at TextShadPtrs

periodA .equ 0 
periodB .equ 1 << 1

;.varloc appData,256 ; Used by IVT
.varloc plotSScreen,768
.varloc saveSScreen,768
;.varloc statVars,531 ; Let us shoot to not use this, Also BCALL(_DelRes)

.struct dccStateStruct      ;Digital Command Station State Vars
    .var 2, msgPTR    ;pointer to current message being processed
    .var 1, count     ;current bit "count"
    .var 1, curDat    ;Current shifted data byte
    .var 1, flags     ;bit mask
                      ; b0 = Output Link Mirror Bit
                      ; b1 = Period A/B
    .var 1, waitCTR   ;Set to 255 for pausing between packets ~15ms
    
.endstruct 


.struct dccPacketStruct   ;https://www.nmra.org/sites/default/files/s-9.2.1_2012_07.pdf
    .var 1, size     ;number of data bits in this packet
    .var 1, data1     ;packet bytes
    .var 1, data2     ;
    .var 1, data3     ;
    .var 1, data4     ;
    .var 1, data5     ;
    .var 1, data6     ; error == address ^ data
.endstruct


.var dccStateStruct, dccState
