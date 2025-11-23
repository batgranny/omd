# OMD Cartridge - Technical Notes & Tolerances

## Tolerance Tuning (v2)

The following adjustments have been made to ensure FDM printability and smooth operation:

### 1. Tray & Slot Clearances
*   **Slot Height:** Increased to **3.3mm** (from 3.0mm).
    *   *Reasoning:* Standard SD card thickness is 2.1mm. The tray floor is ~0.9mm (2.5mm tray - 1.6mm pocket). Total stack height = ~3.0mm.
    *   A 3.0mm slot would leave 0.0mm clearance, causing binding.
    *   3.3mm provides **0.3mm vertical clearance**, which is ideal for FDM layer irregularities.
*   **Tray Thickness:** Increased to **2.5mm** (from 2.4mm).
    *   *Reasoning:* Provides a slightly more rigid floor (0.9mm vs 0.8mm) for the SD card to sit on, reducing flex during insertion.
*   **Horizontal Clearance:** Maintained at **0.3mm** per side (0.6mm total).
    *   *Reasoning:* Standard "loose fit" for sliding parts.

### 2. Retention Mechanisms
*   **SD Card Lips:** Reduced depth to **0.4mm** (from 0.8mm).
    *   *Reasoning:* 0.8mm is too aggressive for a rigid PLA/PETG snap-fit on such a small scale. 0.4mm provides sufficient retention without risking tray cracking or excessive insertion force.
*   **Side Latches:** Maintained at **0.8mm** depth.
    *   *Reasoning:* These provide the "end stop" and "click" for the tray. 0.8mm is robust enough to prevent the tray from falling out.

## Printing Recommendations

### Orientation
*   **Shell:** Print **underside down** (label side facing UP).
    *   *Why:* The label recess creates a large overhang that cannot be bridged if printed face-down. Printing face-up ensures the label area is formed correctly as the top layer.
    *   *Bridging:* The internal cavity roof (~33mm span) and finger hole roof (~13mm span) will be bridged. These are internal/underside and acceptable.
*   **Tray:** Print **flat** (bottom down).
    *   *Why:* Strongest orientation for the side notches and SD pocket lips.

### Slicer Settings
*   **Layer Height:** 0.2mm recommended.
*   **Walls:** 3 perimeters (for strength around the thin side walls).
*   **Infill:** 15-20% Gyroid.
*   **Supports:** **OFF**. The design is optimized for bridging.

## Known Failure Modes to Watch
1.  **Elephant's Foot:** If the first layer squishes too much, the tray might bind at the very bottom of the shell. *Mitigation:* Use a deburring tool on the tray's bottom edges or tune "Initial Layer Horizontal Expansion" in slicer.
2.  **Bridge Sag:** If the shell's internal bridge sags significantly (>0.3mm), it may rub against the SD card. *Mitigation:* Ensure good part cooling fan settings.
