
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
userMemPtr           = textshadow ;rolling pointer for compile-time mem alloc
allocRtnCount        = 0          ;for keeping track of allocations for routines
.deflong allocMem(size,labelname)
    labelname = userMemPtr
    labelname{_size} = (size)
    tvar1 = userMemPtr + (size)
    userMemPtr = tvar1
.enddeflong

allocMem(1,cpage)



IMGBANK  .equ 4
TABBANK  .equ 5
HELPBANK .equ 6

.define XLC_BLACK $00
.define XLC_DARKGRAY $4A
.define XLC_LIGHTGRAY $94
.define XLC_RED $E0
.define XLC_GREEN $07
.define XLC_BLUE $18
.define XLC_DARKRED $20
.define XLC_DARKBLUE $08
.define XLC_DARKGREEN $01
.define XLC_WHITE $FF
.define XLC_SEGBLUE $17
.define XLC_SEGRED $E0

