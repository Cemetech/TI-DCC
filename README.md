# TI-DCC
Is a z80 ASM NMRA-DCC throttle implementation for the TI-84 Plus C Silver Edition.

## Features
* Custom DCC throttle interface.  
* FL-F26 Function support with momentary/locking functions  
* 14/28/128 step speed modes  
* 2 Digit and 4 Digit addressing
 
## ToDo
* Analog/DC throttle mode - To be implmented.
* Verify 14/128 step speed modes
* Verify Long addresses work
* Finish Reccomended schematic

## Requirements
### Building
* Python 2.* and the python launcher. (comes with py3...)
* Pillow
### Use
* Motor driver - A motor driver/H-bridge and circuit used to generate the on rail signals for the train.
* Power supply for the motor driver. Voltage is based off of the scale train you plan on controlling. See the NMRA Standards linked at the bottom of this readme


## Known good motor drivers
* LMD18200 using this circuit [MiniDCC](http://www.minidcc.com/minibooster.gif)

## Installation 
1) run _buildclean.bat
2) Transfer application to calculator using TI-Connect or TILP

## Controls
### Configuration View
* NumberPad: Set Addresss
* F1-F3: set Speed steps mode
* F4: Set DC Controll mode
* F5: Save Changes
### Controller View
* Left/Right: Set Forward or Reverse movement
* Up/Down: Adjust throttle
* Number Pad: Control functions
* F1-F3: Switch between function banks
* CFG: Open configuration view
* Lock: Allows changing of function type
* Math: Quit
* Enter: E-Stop
* SIN: Change read out colors


## References
* Forum Topic: http://cemete.ch/p261712
* NMRA Documentation: https://www.nmra.org/index-nmra-standards-and-recommended-practices	
