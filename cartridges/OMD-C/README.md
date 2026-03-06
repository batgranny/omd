# OMD-C Cartridges

The OMD-C cartridge is a 3D-printable, MiniDisc-inspired digital storage cartridge designed to hold an SD card. It uses a cantilevered slider design, maximizing the exposed length of the SD card to allow insertion into deep SD card readers (like those on MacBooks).

## Overview

- **Format**: SD Card Holder
- **Aesthetics**: MiniDisc / Physical Media
- **Printability**: FDM optimised, 1-piece shell, no supports required.

## Files

- `omd_c_minidisc.scad`: The OpenSCAD source file.

## Printing Instructions

### Shell
- **Orientation**: Print with the large flat face (underside) on the build plate. The label recess will be on top.
- **Supports**: None. The internal cavity is bridged.
- **Layer Height**: 0.2mm or finer.
- **Infill**: 15-20%.

### Slider
- **Orientation**: Print flat on the build plate.
- **Supports**: None.
- **Layer Height**: 0.1mm or 0.12mm recommended for the SD card retention lips and smooth sliding.

## Assembly

1. Slide the slider into the shell from the bottom opening.
2. Push it past the internal latches. 
3. Snap an SD card into the rear pocket of the slider. The slider only grips the rear ~10mm of the card.
