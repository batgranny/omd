# OMD Cartridges

The OMD cartridge is a 3D-printable, MiniDisc-inspired digital storage cartridge designed to hold an SD card inside a slide-out tray.

## Overview

- **Format**: SD Card Holder
- **Aesthetics**: MiniDisc / Physical Media
- **Printability**: FDM optimised, no supports required.

## Files

- `omd_minidisc.scad`: The OpenSCAD source file.
- `omd_shell.stl`: The outer shell (print underside down).
- `omd_tray.stl`: The inner tray (print flat).

## Printing Instructions

### 

- Export to STL
- Import STL to Prusaslicer
- Choose Generic PLA 
- Choose Original Prusa Mini and Mini +
- Slice Export G Code

### Shell
- **Orientation**: Print with the large flat face (underside) on the build plate. The label recess will be on top.
- **Supports**: None. The internal cavity is bridged.
- **Layer Height**: 0.2mm or finer.
- **Infill**: 15-20%.

### Tray
- **Orientation**: Print flat on the build plate.
- **Supports**: None.
- **Layer Height**: 0.1mm or 0.12mm recommended for the SD card retention lips and smooth sliding.

## Assembly

1. Insert the tray into the shell from the bottom opening.
2. Push it past the internal latches. It should click or slide past with some resistance.
3. Once installed, the tray is captive. It slides up and down but cannot be removed without significant force.
4. Insert an SD card into the tray. It should snap into place.

## Development Notes

- **Clearances**: The design assumes a 0.3mm clearance around the tray. If the tray is too tight, adjust `slot_clearance` in the SCAD file.
- **Latches**: The side latches are designed to flex slightly or rely on plastic deformation during the first insertion.

## License

[Insert License Here]
