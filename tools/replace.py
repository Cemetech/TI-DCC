import sys
import os.path

infile = sys.argv[1]
outfile = sys.argv[2]

if os.path.exists(infile)==True:
    with open(outfile,"w") as outfileh, open(infile,"r") as infileh:
        lines = infileh.readlines()
        for line in lines:
            if "noname." not in line:
                outfileh.write(line.replace("\t.equ\t","\t=\t"))

