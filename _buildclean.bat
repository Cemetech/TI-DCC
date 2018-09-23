@echo off
if not exist "obj" mkdir obj
if not exist "bin" mkdir bin
del /q obj\*
del /q bin\*
python tools\builder.py
_build.bat
