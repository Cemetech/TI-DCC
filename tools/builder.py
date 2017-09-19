import time
_starttime = time.clock()
print "Loading modules..."
from PIL import Image
import os,sys,ctypes

np = os.path.normpath
se = os.path.splitext
bn = os.path.basename
cd = os.getcwd()

curptr = 0xC000
outarr = []

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

def ensure_dir(d):
  if not os.path.isdir(d):
    os.makedirs(d)
  return
    
def readFile(file):
  a = []
  f = open(file,'rb')
  b = f.read(1)
  while b!=b'':
    a.append(ord(b))
    b = f.read(1)
  f.close()
  return a
        
def writeFile(file,a):
  f = open(file,'wb+')
  f.write(bytearray(a))
  f.close()
        
def appendFile(file,a):
  f = open(file,'ab')
  f.write(bytearray(a))
  f.close()
        
def silentremove(file):
  try:
    os.remove(file)
  except:
    pass
    
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# aplib by Ibsen Software

if os.name == 'nt':
  if 4==ctypes.sizeof(ctypes.c_voidp):
    aplib = ctypes.WinDLL(os.path.dirname(__file__)+'\\aplib32.dll')
  else:
    aplib = ctypes.WinDLL(os.path.dirname(__file__)+'\\aplib64.dll')
else:
  # might require LD_LIBRARY_PATH set
  aplib = CDLL("lipaplib.so")
def pack(src):
  slen = len(src)
  if slen<=0: raise ValueError('Invalid input.')
  dlen = aplib.aP_max_packed_size(slen)
  dst = ctypes.create_string_buffer(dlen)
  wmem = ctypes.create_string_buffer(aplib.aP_workmem_size(slen))
  dlen = aplib.aP_pack(src,dst,slen,wmem,None,0)
  if dlen==-1: raise ValueError('Compression error.')
  return buffer(dst,0,dlen)
  
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  
def rgb2xlc(rgb):
  # G5:7 to 0:2   ;   B6:7 to 3:4   ;   R5:7 to 5:7
  a = (rgb[1]>>5)&0b00000111
  a = a | ((rgb[2]>>3)&0b00011000)
  a = a | (rgb[0]&0b11100000)
  return a
  
def img2cse(infile):
  f = Image.open(np(infile))
  i = list(f.convert("RGB").getdata()) if (f.mode != "RGB") else list(f.getdata())
  o = []
  w = f.size[0]
  h = f.size[1]
  for y in range(h):
    for x in range(w):
      o.append(rgb2xlc(i[(y*w)+x]))
  return (w,h,o)
  
def img2bw(infile):
  f = Image.open(np(infile))
  fc = f.convert('1',dither=Image.NONE)
  fd = fc.tobytes()
  fd = [ord(i) for i in fd]
  w = f.size[0]
  h = f.size[1]
  return (w,h,fd)
    
def packimg(infile,flushtofile='',bw=''):
  global curptr
  global outarr
  
  if infile:
    fname = se(bn(infile))[0]
    img = img2bw(infile) if bw else img2cse(infile) 
    outarr.extend(img[2])
    with open("obj/sprites.inc","ab") as f:
      f.write(fname+"_a .equ $"+format(curptr,"04X")+"\n"+
        fname+"_w .equ "+str(img[0])+"\n"+
        fname+"_h .equ "+str(img[1])+"\n"+
        fname+"_s .equ "+str(len(img[2]))+"\n")
    print "Added image '"+fname+"' ("+str(img[0])+","+str(img[1])+") ["+str(len(img[2]))+"] @ 0x"+format(curptr,"04X")
    curptr += len(img[2])
    if curptr > (0xFFFF-400):
      print "ERR: PAGE BANK LENGTH EXCEEDED AT FILE "+str(infile)
      
  if flushtofile:
    fname = se(bn(flushtofile))[0]
    coutdat = pack(''.join(chr(c) for c in outarr))
    with open(np("obj/"+flushtofile),"wb+") as f: f.write(coutdat)
    with open("obj/sprites.z80","ab") as f: f.write(fname+"_c: \n.incbin \"obj/"+flushtofile+"\" ;compressed size: "+str(len(coutdat))+"\n")
    print "Flushed to compressed file '"+fname+"' with size "+str(len(coutdat))
    curptr = 0xC000
    outarr = []
    
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

silentremove("obj/sprites.inc")
silentremove("obj/sprites.z80")

packimg("src/gfx/address.png",'','1')
packimg("src/gfx/throttle.png",'','1')
packimg("src/gfx/lock.png")
packimg("src/gfx/numpadbutton.png",'','1')
packimg("src/gfx/fnums.png")
packimg("src/gfx/uparrowon.png")
packimg("src/gfx/uparrowoff.png")
packimg("src/gfx/downarrowon.png")
packimg("src/gfx/downarrowoff.png")
packimg("src/gfx/help1.png",'','1')
packimg("src/gfx/help2.png",'','1')
packimg("src/gfx/help3.png",'','1')
packimg("src/gfx/help4.png",'','1')
packimg("src/gfx/revfwd.png",'','1')
packimg("","imgbank1.bin")
packimg("src/gfx/tabs.png")
packimg("","imgbank2.bin")
packimg("src/gfx/tabs2.png")
packimg("","imgbank3.bin")



