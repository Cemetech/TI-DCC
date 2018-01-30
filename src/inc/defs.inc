
.define INCR 1
.define DECR 0
.define VERT 0
.define HORIZ 1
.define incmode(x) (x<<4)+0
.define wrapmode(x) (x<<5)+0
.define movemode(x) (x<<3)+0
.define bgrmode(x) (x<<12)+0
.define origin(x) (x<<7)+0
.define msb(adr) ((adr>>8)&$FF)+0
.define lsb(adr) (adr&$FF)+0
.define combhilo(hi,lo) (256*hi)+lo

.define wh(w,h) (256*((h)-1))+((w)-1)+0

;//textShadow on 84+CSE is 260 bytes. Don't go overboard.
userMemPtr           = savesscreen ;rolling pointer for compile-time mem alloc
allocRtnCount        = 0           ;for keeping track of allocations for routines
.deflong allocMem(size,labelname)
    labelname = userMemPtr
    labelname{_size} = (size)
    tvar1 = userMemPtr + (size)
    userMemPtr = tvar1
.enddeflong

allocMem(1,cpage)

allocMem(1,ap_bits)
allocMem(1,ap_byte)
allocMem(1,lwm)
allocMem(1,r_0)

allocMem(2,temp)
allocMem(1,curbank)
allocMem(1,throttlemode)   ;0: 0-14, 1: 0-28, 2:0-128
allocMem(1,throttle)       ;unsigned.
allocMem(1,direction)      ;0=forward 1=backward -1:emergency stop triggered
allocMem(1,tabflags)       ;b0=bank1 b1=bank2 [...] b4=[MODE]
allocMem(2,curaddress)     ;0-32767 (signed 16 bit value, sign unused)
allocMem((27*1),bankdata)  ;.db state.
allocMem((03*2),gutterdat) ;prevent buffer overrun wrt reading above
allocMem(1,menumode)       ;0=setup, 1=controller
allocMem(1,enableDCmode)   ;0=disabled 1=DC mode enabled
allocMem(1,dispDigits)
allocMem(1,cursorcycle)
allocMem(1,keytemp)
;---
;insert any new normal memory allocs for ctrl.z80 here.
;---
allocMem(2,e_numpad)
allocMem(2,e_updown)
allocMem(2,e_leftright)
allocMem(2,e_cfgack)
allocMem(2,e_estop)
allocMem(2,e_dcmode)
;---
;insert any new events for ctrl.z80 here.
;---
allocMem(2,segcolors)
allocMem(1,curcolor)
allocMem(2,e_nullevent)
allocMem(2,xtemp)
allocMem(2,atemp)
allocMem(1,ytemp)

allocMem(1,gs_keymem)

allocMem(2,fillsegtemp)

IMGBANK  .equ 4
TABBANK  .equ 5
HELPBANK .equ 4

.define XLC_BLACK $00
.define XLC_DARKGRAY $4A
.define XLC_LIGHTGRAY $94
.define XLC_RED $E0
.define XLC_GREEN $07
.define XLC_BLUE $18
.define XLC_DARKRED $40
.define XLC_DARKBLUE $10
.define XLC_DARKGREEN $01
.define XLC_DARKYELLOW $41
.define XLC_WHITE $FF
.define XLC_SEGBLUE $17
.define XLC_SEGRED $E1
.define XLC_SEGGREEN $66
.define XLC_SEGAMBER $E5


