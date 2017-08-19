@echo off
if not exist "obj" mkdir obj
if not exist "bin" mkdir bin
tools\brass src\main.z80 obj\main.hex -L obj\main.html
tools\rabbitsign -k tools\010F.key -g -o bin\main.8xk obj\main.hex
tools\replace.py obj\main.hex.inc bin\main.lab

