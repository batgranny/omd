// OMD-C MiniDisc-style SD shell
// 1-piece outer shell, cantilevered captive slider

// Overall body dimensions
body_w          = 68;
body_h          = 72;
body_t          = 5;

// Corner radii
corner_r_outer = 2;
corner_r_inner = 2;

// Label recess
label_margin_x = 4;
label_margin_y = 9;
label_d        = 0.3;

// Top grips
grip_w       = 30;
grip_h       = 0.8;
grip_d       = 0.6;
grip_spacing = 1.2;
grip_count   = 3;

_grip_total_h = grip_count*grip_h + (grip_count-1)*grip_spacing;
_grip_top_margin = (label_margin_y - _grip_total_h) / 2;
grip_offset_y = _grip_top_margin + grip_h;

// Prusa Mini Mode (adds bridging slack and slight expansion)
prusa_mini_mode = true; 

// Clearances
slot_height_base = 3.3; // vertical clearance for slider + SD card (SD is ~2.1)
bridge_sag_allowance = prusa_mini_mode ? 0.2 : 0;
slot_height = slot_height_base + bridge_sag_allowance;

slot_clearance_base = 0.3; // horizontal clearance each side
slot_clearance = slot_clearance_base + (prusa_mini_mode ? 0.05 : 0);

// SD Card dimensions
sd_w = 24.0;
sd_l = 32.0;

// Slider dimensions
slider_grip_l = 10.0; // How much of the SD card is gripped by the slider pocket
slider_w = sd_w + 3.0; // 1.5mm walls on each side
slider_h = 13.0; // Total length of slider block (very compact)
slider_t = 2.5; // Thickness of the base of the slider
pocket_d = 1.6; // depth of the pocket in the slider for the SD card

// Cavity dimensions (Internal space in the shell)
cav_w = slider_w + 2*slot_clearance;
cav_t = slot_height;
cavity_x = (body_w - cav_w)/2;

// The cavity needs to be long enough to house the slider + the remaining length of the SD card when retracted.
// When retracted, the front of the slider is at y = 24, tip of SD card at y = 2.
cav_h = 42; 

// Latch / Locking mechanism
latch_depth_x = 0.8;
latch_height_z = slot_height;
latch_len_y = 3.0;

latch_1_y = 3.0;  // Position of latch that locks extended state
latch_2_y = 23.0; // Position of latch that locks retracted state

notch_depth_x = latch_depth_x + 0.3;
notch_height_z = 1.6;
notch_len_y = 3.2;

// Notch position on the slider (only one pair of notches needed now!)
notch_from_front = 2.0;


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

// ---------- helper: double-sided latch ramp ----------
module shell_latch() {
    linear_extrude(height = cav_t)
        polygon([
            [0,0],
            [latch_depth_x, latch_len_y*0.3],
            [latch_depth_x, latch_len_y*0.7],
            [0, latch_len_y]
        ]);
}

// ---------- SHELL ----------
module miniDiscShell() {
    union() {
        difference() {
            // 1) OUTER BODY
            linear_extrude(height = body_t)
                rounded_rect_2d(body_w, body_h, corner_r_outer);

            // 2) INTERNAL TRAY CAVITY
            // Add a small chamfer on the opening edges to ease first insertion.
            slot_chamfer = 0.6;
            hull() {
                translate([
                    cavity_x + slot_chamfer,
                    -3,
                    (body_t - cav_t)/2 + slot_chamfer
                ])
                    cube([cav_w - 2*slot_chamfer, cav_h, cav_t - 2*slot_chamfer], center=false);
                translate([
                    cavity_x,
                    -3 - slot_chamfer,
                    (body_t - cav_t)/2
                ])
                    cube([cav_w, cav_h, cav_t], center=false);
            }

            // 2b) FINGER/THUMB CUTOUT in the bottom edge (top and bottom shell halves)
            // To allow grabbing the SD card / slider
            thumb_w = 22;
            thumb_h = 10;
            translate([(body_w - thumb_w)/2, -thumb_h/2, -1])
               linear_extrude(height=body_t+2)
                  rounded_rect_2d(thumb_w, thumb_h, 3);


            // 3) BIG LABEL RECESS
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

            // 5) SMALL ARROW ENGRAVED BOTTOM-RIGHT
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
                
            // 6) "OMD" TEXT RECESS BOTTOM-LEFT
            text_d = 0.4; // Depth of recess
            translate([5.5, 3.5, body_t - text_d])
                linear_extrude(height = text_d + 0.1)
                    text("OMD", size = 4.0, font = "Arial:style=Bold");

            // 7) SIDE GRIP VENTS (both sides)
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

             // 7) BOTTOM-LEFT DIAGONAL CUTOUT
            chamfer_size = 4;
            translate([0,0,-1])
                linear_extrude(height=body_t+2)
                    polygon(points=[
                        [-5, -5],
                        [chamfer_size, -5],
                        [chamfer_size, 0],
                        [0, chamfer_size],
                        [-5, chamfer_size]
                    ]);
        }

        // 7) SIDE LATCHES INSIDE SLOT
        // Left latches
        translate([cavity_x, latch_1_y, (body_t - cav_t)/2])
            shell_latch();
        translate([cavity_x, latch_2_y, (body_t - cav_t)/2])
            shell_latch();

        // Right latches
        translate([cavity_x + cav_w, latch_1_y, (body_t - cav_t)/2])
            mirror([1,0,0]) shell_latch();
        translate([cavity_x + cav_w, latch_2_y, (body_t - cav_t)/2])
            mirror([1,0,0]) shell_latch();
        
        // 8) FRONT STOP RIB ON ROOF
        // Prevents the slider from pulling entirely out of the shell
        front_stop_h = 0.8;
        translate([
            cavity_x,
            latch_1_y + latch_len_y + 1.0,
            (body_t + cav_t)/2 - front_stop_h
        ])
            cube([cav_w, 1.0, front_stop_h], center=false);
            
        // 9) REAR STOP RIB
        translate([
            cavity_x,
            cav_h - 1.5,
            (body_t - cav_t)/2
        ])
            cube([cav_w, 1.5, cav_t], center=false);
    }
}

// ---------- SLIDER ----------
module sdSlider() {
    difference() {
        union() {
            // Main slider body
            cube([slider_w, slider_h, slider_t], center=false);
            
            // Hook bump on the roof to catch the front stop rib
            // Total height must be < slot_height (3.3mm). slider_t is 2.5mm.
            // 2.5 + 0.6 = 3.1mm (0.2mm clearance under roof)
            translate([0, slider_h - 2.0, slider_t])
                cube([slider_w, 2.0, 0.6], center=false);
        }

        // SD card pocket 
        // We pocket the FRONT of the slider so the SD card sticks out towards y=0
        translate([
            (slider_w - sd_w)/2,
            -1,
            slider_t - pocket_d
        ])
            cube([sd_w, slider_grip_l + 1.1, pocket_d + 1], center=false);

        // Side notches for shell latches
        // Only one pair of notches needed on the slider now
        translate([0, notch_from_front, slider_t - notch_height_z])
            cube([notch_depth_x, notch_len_y, notch_height_z + 1], center=false);
        translate([slider_w - notch_depth_x, notch_from_front, slider_t - notch_height_z])
            cube([notch_depth_x, notch_len_y, notch_height_z + 1], center=false);
            
        // Add a slight taper to the REAR of the slider to help it guide into the shell on first insertion
        translate([-1, slider_h + 1, -1])
            linear_extrude(height=slider_t+2)
                polygon([
                    [0, -3],
                    [2, 0],
                    [slider_w - 2, 0],
                    [slider_w, -3],
                    [slider_w + 1, -3],
                    [slider_w + 1, 1],
                    [0, 1]
                ]);
    }

    // Internal retaining lips (print-friendly ramps) to hold SD card
    lip_depth  = 0.6; 
    lip_height = 0.8;
    lip_len    = 3.0;

    innerL = (slider_w - sd_w)/2;
    innerR = slider_w - innerL;
    
    lip_y_pos = 1.0;

    // Left lip
    translate([
        innerL,
        lip_y_pos,
        slider_t
    ])
        printable_lip(lip_depth, lip_len, lip_height);

    // Right lip 
    translate([
        innerR,
        lip_y_pos,
        slider_t
    ])
        mirror([1,0,0])
            printable_lip(lip_depth, lip_len, lip_height);

    // Friction bumps
    bump_w = 1.0;
    bump_l = 3.0;
    bump_h = 1.0;

    translate([0, slider_h/2 - bump_l/2, (slider_t - bump_h)/2])
        cube([bump_w, bump_l, bump_h], center = false);
    translate([slider_w - bump_w, slider_h/2 - bump_l/2, (slider_t - bump_h)/2])
        cube([bump_w, bump_l, bump_h], center = false);
}

// ===== PREVIEW / EXPORT =====

// miniDiscShell();
// translate([40, 0, 0])
//    sdSlider();

// Combined preview
miniDiscShell();

// Show in EXTENDED position (Comment out to hide)
//translate([ cavity_x + slot_clearance, latch_1_y - notch_from_front, (body_t - slider_t)/2 ]) {
//    color("red") sdSlider();
    // Mock SD Card
//    translate([ (slider_w - sd_w)/2, slider_grip_l - sd_l, slider_t - pocket_d])
//        color("blue") cube([sd_w, sd_l, 2.1]);
//}

// Show in RETRACTED position
 translate([ cavity_x + slot_clearance, latch_2_y - notch_from_front, (body_t - slider_t)/2 ]) {
     color("green") sdSlider();
//     // Mock SD Card
     translate([ (slider_w - sd_w)/2, slider_grip_l - sd_l, slider_t - pocket_d])
         color("purple") cube([sd_w, sd_l, 2.1]);
 }
