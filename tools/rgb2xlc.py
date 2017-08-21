def rgb2xlc(rgb):
  # G5:7 to 0:2   ;   B6:7 to 3:4   ;   R5:7 to 5:7
  a = (rgb[1]>>5)&0b00000111
  a = a | ((rgb[2]>>3)&0b00011000)
  a = a | (rgb[0]&0b11100000)
  return format(a,"04X")