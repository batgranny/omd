// MSD MiniDisc-style SD shell – WORKING VERSION WITH ROUNDED EDGES + VISIBLE BOTTOM SLOT
// with captive tray using side latches + tray notches

// Overall body
body_w = 68;
body_h = 72;
body_t = 5;

// Corner radii
corner_r_outer = 2;   // outer shell corners
corner_r_inner = 2;   // inner window corners

// Label recess (big window)
label_margin_x = 4;
label_margin_y = 9;
label_d        = 0.3;

// Top grips
grip_w       = 30;
grip_h       = 0.8;
grip_d       = 0.6;
grip_spacing = 1.2;
grip_count   = 3;

// Center grips in the top margin (label_margin_y)
// Total height of grips = count*h + (count-1)*spacing
_grip_total_h = grip_count*grip_h + (grip_count-1)*grip_spacing;
_grip_top_margin = (label_margin_y - _grip_total_h) / 2;
grip_offset_y = _grip_top_margin + grip_h;

// Tray + SD parameters
tray_w   = 33;
tray_h   = 25;    // shorter than SD card so contacts stick out
tray_t   = 2.5;   // thickened slightly for strength

sd_w       = 24;
sd_l       = 32;
pocket_w   = sd_w + 1.0;
nose_buf   = 4;

// pocket fills from the back of the tray up to the "nose"
pocket_l   = tray_h - nose_buf;   // 25 - 4 = 21mm
pocket_d   = 1.6;

// Slot / cavity sizing
slot_height    = 3.3;       // increased for SD clearance (stack is ~3.0mm)
slot_clearance = 0.3;       // clearance each side in X

// We want the SD card (length sd_l) + tray back to sit slightly recessed
// inside the shell when fully inserted.
// The cavity starts at y = -3 and goes to y = -3 + cav_h,
// so internal depth from the bottom edge is (cav_h - 3).
recess_margin  = 2;                      // how far inside the shell the card sits
cav_depth_int  = sd_l + recess_margin;   // internal depth from bottom edge
cav_h          = cav_depth_int + 3;      // +3 because slot starts at y = -3

cav_w          = tray_w + 2*slot_clearance;  // snug slot around tray
cav_t          = slot_height;
cavity_x       = (body_w - cav_w)/2;    // centre slot under label

// Finger access hole in underside (to push tray)
finger_hole_w       = tray_w - 20;   // a bit narrower than tray
finger_hole_len     = 18;           // how far up into the body
finger_hole_marginY = 4;            // gap from bottom edge
finger_hole_depth   = 2.0;          // depth from underside (must be < body_t)

// Tray captive system – shell latches + tray notches
latch_depth_x   = 0.8;   // how far latches protrude into slot from each side
latch_height_z  = slot_height;   // full height of slot
latch_len_y     = 3.0;   // length along travel direction
latch_offset_y  = 2.0;   // how far inside from slot opening (y=0)

// Tray notches (matching latches)
notch_depth_x     = latch_depth_x + 0.3; // a touch deeper than latch for clearance
notch_height_z    = 1.6;
notch_len_y       = 3.2;
notch_from_front  = 6.0;         // distance back from tray front edge

// ---------- helper: 2D rounded rectangle ----------
module rounded_rect_2d(w,h,r){
    r = min(r, min(w,h)/2);
    translate([r,r])
    minkowski(){
        square([w-2*r, h-2*r], center=false);
        circle(r=r, $fn=40);
    }
}

// ---------- helper: print-friendly ramp lip ----------
module printable_lip(depth, length, height) {
    polyhedron(
        points = [
            [0,0,0],                       // 0 bottom inside
            [depth,0,0],                   // 1 bottom outer
            [0,length,0],                  // 2 bottom inside front
            [depth,length,0],              // 3 bottom outer front

            [0,0,height],                  // 4 top inside
            [depth*0.2,0,height],          // 5 angled top
            [0,length,height],             // 6 top inside front
            [depth*0.2,length,height]      // 7 angled top front
        ],
        faces = [
            [0,1,3,2],    // bottom
            [0,2,6,4],    // inside wall
            [1,5,7,3],    // outside sloped wall
            [4,6,7,5],    // top
            [0,4,5,1],    // back
            [2,3,7,6]     // front
        ]
    );
}

// ---------- SHELL ----------
module miniDiscShell() {
    union() {
        // Main body with all subtractions
        difference() {
            // 1) OUTER BODY WITH ROUNDED CORNERS
            linear_extrude(height = body_t)
                rounded_rect_2d(body_w, body_h, corner_r_outer);

            // 2) INTERNAL TRAY CAVITY – centred slot, open at bottom edge only
            translate([
                cavity_x,                    // centre in X
                -3,                          // extend a bit below bottom edge to open it
                (body_t - cav_t)/2           // centre vertically: plastic above and below
            ])
                cube([cav_w, cav_h, cav_t], center=false);

            // 2b) RECTANGULAR FINGER HOLE IN UNDERSIDE
            translate([
                (body_w - finger_hole_w)/2,  // centred left–right under the tray
                finger_hole_marginY,         // a few mm up from bottom edge
                0                            // start at underside
            ])
                cube([finger_hole_w, finger_hole_len, finger_hole_depth], center=false);

            // 3) BIG LABEL RECESS, CENTRED, ALSO ROUNDED
            label_w = body_w - 2*label_margin_x;
            label_h = body_h - 2*label_margin_y;
            translate([
                label_margin_x,
                label_margin_y,
                body_t - label_d
            ])
                linear_extrude(height = label_d + 0.1)
                    rounded_rect_2d(label_w, label_h, corner_r_inner);

            // 4) TOP GRIP GROOVES
            for (i = [0:grip_count-1]) {
                translate([
                    (body_w - grip_w)/2,
                    body_h - grip_offset_y - (i * (grip_h + grip_spacing)),
                    body_t - grip_d
                ])
                    cube([grip_w, grip_h, grip_d + 0.1], center=false);
            }

            // 5) SMALL ARROW ENGRAVED BOTTOM-RIGHT (pointing DOWN)
            arrow_d = 0.4;
            arrow_w = 4;
            arrow_h = 6;

            translate([body_w-9, 4.5, body_t - arrow_d])
                linear_extrude(height = arrow_d + 0.1) {
                    union() {
                        square([arrow_w, arrow_h-3], center=false);
                        translate([arrow_w/2, 0, 0])
                            polygon([
                                [-arrow_w/2, 0],
                                [ arrow_w/2, 0],
                                [0, -(arrow_h-3)]
                            ]);
                    }
                }

            // 6) SIDE GRIP VENTS (both sides)
            side_grip_count   = 3;
            side_grip_w       = 1;   // along Y
            side_grip_h       = 4.0;   // along Z
            side_grip_gap     = 0.8;
            side_grip_x_depth = 2.5;   // into body (enough to cut fully)
            side_grip_y_offset = 62;    // up from bottom edge
            side_grip_z_offset = 0.5;  // up from underside

            for (i = [0:side_grip_count-1]) {
                // Right side
                translate([
                    body_w - side_grip_x_depth,
                    side_grip_y_offset + i*(side_grip_w + side_grip_gap),
                    side_grip_z_offset
                ])
                    cube([side_grip_x_depth, side_grip_w, side_grip_h], center=false);

                // Left side
                translate([
                    0,
                    side_grip_y_offset + i*(side_grip_w + side_grip_gap),
                    side_grip_z_offset
                ])
                    cube([side_grip_x_depth, side_grip_w, side_grip_h], center=false);
            }

            // 9) BOTTOM-LEFT DIAGONAL CUTOUT
            // Cut a 45-degree chamfer at [0,0] using a polygon
            // The cut line will be roughly x + y = chamfer_size
            chamfer_size = 4;
            translate([0,0,-1])
                linear_extrude(height=body_t+2)
                    polygon(points=[
                        [-5, -5],           // outside corner
                        [chamfer_size, -5], // bottom edge point
                        [chamfer_size, 0],  // start of chamfer on X
                        [0, chamfer_size],  // end of chamfer on Y
                        [-5, chamfer_size]  // left edge point
                    ]);
        } // end difference()

        // 7) SIDE LATCHES INSIDE SLOT – currently disabled while we debug fit
        /*
        // Left latch
        translate([
            cavity_x,                      // flush with left cavity wall
            latch_offset_y,                // inside from opening
            (body_t - cav_t)/2             // centred vertically in slot
        ])
            cube([latch_depth_x, latch_len_y, cav_t], center=false);

        // Right latch
        translate([
            cavity_x + cav_w - latch_depth_x,  // flush with right cavity wall
            latch_offset_y,
            (body_t - cav_t)/2
        ])
            cube([latch_depth_x, latch_len_y, cav_t], center=false);
        */
        // No inner stop rib any more – cavity depth is controlling fully-in position
    }
}

// ---------- TRAY ----------
module sdTray() {
    // Base tray with SD pocket carved out + side notches for latches
    difference() {
        union() {
            // main tray body
            cube([tray_w, tray_h, tray_t], center = false);

            // thumb tab at the front
            tab_w = 20;
            tab_l = 3;
            translate([ (tray_w - tab_w)/2,
                        tray_h - tab_l,
                        0 ])
                cube([tab_w, tab_l, tray_t], center = false);
        }

        // SD card pocket: starts at back (y=0), stops at nose_buf from front
        translate([
            (tray_w - pocket_w)/2,
            0,
            tray_t - pocket_d
        ])
            cube([pocket_w, pocket_l, pocket_d], center = false);

        // Side notches for shell latches (one each side, near front)
        notch_y = tray_h - notch_from_front - notch_len_y;

        // Left notch
        translate([
            0,
            notch_y,
            tray_t - notch_height_z
        ])
            cube([notch_depth_x, notch_len_y, notch_height_z], center=false);

        // Right notch
        translate([
            tray_w - notch_depth_x,
            notch_y,
            tray_t - notch_height_z
        ])
            cube([notch_depth_x, notch_len_y, notch_height_z], center=false);
    }

    // Internal retaining lips (print-friendly ramps) – hold SD card in
    lip_depth  = 1.4;   // reduced for smoother snap (tweak after test)
    lip_height = 0.8;   // vertical size (Z)
    lip_len    = 3.0;   // length along Y

    innerL = (tray_w - pocket_w)/2;   // inner left wall X
    innerR = tray_w - innerL;         // inner right wall X

    // Left lip – attached to left inner wall, ramp inward
    translate([
        innerL,
        pocket_l - lip_len - 0.5,     // near front of pocket
        tray_t - lip_height           // up at pocket roof
    ])
        printable_lip(lip_depth, lip_len, lip_height);

    // Right lip – mirrored, attached to right inner wall, ramp inward
    translate([
        innerR,
        pocket_l - lip_len - 0.5,
        tray_t - lip_height
    ])
        mirror([1,0,0])
            printable_lip(lip_depth, lip_len, lip_height);

    // Side bumps for tray friction in shell
    bump_w = 1.5;
    bump_l = 3;
    bump_h = 1.5;

    translate([0, 4, (tray_t - bump_h)/2])
        cube([bump_w, bump_l, bump_h], center = false);

    translate([tray_w - bump_w, 4, (tray_t - bump_h)/2])
        cube([bump_w, bump_l, bump_h], center = false);
}

// ===== PREVIEW / EXPORT =====

// Shell only:
//miniDiscShell();

// Tray only:
 sdTray();

// Combined preview (shell + tray):
// miniDiscShell();
// translate([ (body_w - tray_w)/2, 0, (body_t - tray_t)/2 ])
//     color("red") sdTray();