/*
 * ArloBot - 3D Printed Wheels
 *
 * Parametric OpenSCAD design for robot wheels
 * Compatible with standard hobby DC motors
 *
 * To generate STL files:
 * 1. Open in OpenSCAD
 * 2. Set 'part' variable to the part you want to export
 * 3. Press F6 to render, then Export as STL
 */

// Include MCAD library for proper involute gears
include </usr/share/openscad/libraries/MCAD/involute_gears.scad>

// ===== CONFIGURATION PARAMETERS =====

// Which part to render
part = "single_piece_wheel"; // Options: "wheel", "tire", "complete_wheel", "single_piece_wheel", "geared_wheel", "motor_pinion"

// Wheel dimensions
wheel_diameter = 65;      // Overall wheel diameter (mm)
wheel_width = 13.5;       // Total wheel width (mm)
rim_width = 10;           // Width of the plastic rim (mm)
tire_thickness = 3;       // Thickness of tire tread (mm)

// Hub dimensions
hub_diameter = 20;        // Central hub diameter (mm)
hub_height = 13.5;        // Hub height/depth (mm) - extends to wheel edge

// Motor shaft (N20 micro gear motor uses 2mm shaft)
shaft_diameter = 2;       // Motor shaft diameter (mm) - N20 standard
shaft_flat = true;        // Does shaft have a flat side? (D-shaft)
shaft_flat_depth = 0.3;   // Depth of flat on D-shaft (mm)
shaft_tolerance = -0.05;  // Negative tolerance for tight press fit
set_screw_diameter = 2;   // M2 set screw to hold wheel on shaft (smaller for 2mm shaft)
set_screw_depth = 8;      // Depth of set screw hole

// Spoke design
num_spokes = 6;           // Number of spokes (4, 5, or 6 recommended)
spoke_thickness = 3;      // Thickness of each spoke (mm)

// Tire tread
tread_style = "smooth";   // Options: "smooth", "chevron", "diamond", "circular"
tread_depth = 1;          // Depth of tread pattern (mm)
num_treads = 16;          // Number of tread elements around circumference

// Print tolerance
tolerance = 0.2;

// ===== GEAR PARAMETERS =====
// For 5:1 gear reduction system
gear_module = 1.0;           // Tooth size (mm) - standard metric module
pinion_teeth = 10;           // Motor pinion gear teeth
wheel_gear_teeth = 50;       // Wheel gear teeth
pressure_angle = 20;         // Standard pressure angle (degrees)
gear_width = 8;              // Width/thickness of gears (mm)

// Bearing parameters (for geared wheel)
bearing_od = 22;             // Bearing outer diameter (mm)
bearing_id = 8;              // Bearing inner diameter (mm)
bearing_width = 7;           // Bearing width (mm)

// Motor shaft (for pinion gear)
motor_shaft_diameter = 2;    // N20 motor shaft (mm)

// ===== RENDERING LOGIC =====

if (part == "wheel") {
    wheel_rim();
} else if (part == "tire") {
    tire();
} else if (part == "complete_wheel") {
    complete_wheel();
} else if (part == "single_piece_wheel") {
    single_piece_wheel();
} else if (part == "geared_wheel") {
    geared_wheel();
} else if (part == "motor_pinion") {
    motor_pinion();
}

// ===== MODULES =====

module complete_wheel() {
    // Complete assembly for visualization
    color("lightgray")
        wheel_rim();

    color("black")
        tire();
}

module wheel_rim() {
    difference() {
        union() {
            // Central hub
            cylinder(d=hub_diameter, h=hub_height, center=true, $fn=50);

            // Spokes
            for (i = [0:num_spokes-1]) {
                rotate([0, 0, i * 360/num_spokes])
                    spoke();
            }
        }

        // Motor shaft hole
        cylinder(d=shaft_diameter + shaft_tolerance, h=hub_height + 2, center=true, $fn=30);

        // Flat on D-shaft
        if (shaft_flat) {
            translate([shaft_diameter/2 - shaft_flat_depth, 0, 0])
                cube([shaft_diameter, shaft_diameter, hub_height + 2], center=true);
        }
    }
}

module spoke() {
    // Single spoke from hub to tire ridge (for printability without supports)
    tire_inner_radius = (wheel_diameter - tire_thickness*2) / 2;
    spoke_length = tire_inner_radius - hub_diameter/2;

    hull() {
        // Start at hub
        translate([hub_diameter/2, 0, 0])
            cylinder(d=spoke_thickness, h=wheel_width, center=true, $fn=20);

        // End at tire ridge (extend into the tire)
        translate([tire_inner_radius + tire_thickness/2, 0, 0])
            cylinder(d=spoke_thickness, h=wheel_width, center=true, $fn=20);
    }
}

module tire() {
    // Flexible tire with tread pattern
    difference() {
        // Outer tire
        cylinder(d=wheel_diameter, h=wheel_width, center=true, $fn=100);

        // Inner cavity (fits over rim)
        cylinder(d=wheel_diameter - tire_thickness*2 + tolerance, h=wheel_width + 2, center=true, $fn=80);

        // Tread pattern
        if (tread_style == "chevron") {
            chevron_tread();
        } else if (tread_style == "diamond") {
            diamond_tread();
        } else if (tread_style == "circular") {
            circular_tread();
        }
        // "smooth" has no tread cutouts
    }
}

module chevron_tread() {
    // V-shaped tread pattern
    for (i = [0:num_treads-1]) {
        rotate([0, 0, i * 360/num_treads])
            translate([wheel_diameter/2 - tread_depth/2, 0, 0])
            rotate([0, 90, 0])
            rotate([0, 0, 45])
            cube([wheel_width/3, 2, tread_depth + 1], center=true);

        rotate([0, 0, i * 360/num_treads])
            translate([wheel_diameter/2 - tread_depth/2, 0, 0])
            rotate([0, 90, 0])
            rotate([0, 0, -45])
            cube([wheel_width/3, 2, tread_depth + 1], center=true);
    }
}

module diamond_tread() {
    // Diamond-shaped tread pattern
    for (i = [0:num_treads-1]) {
        for (j = [-1, 1]) {
            rotate([0, 0, i * 360/num_treads])
                translate([wheel_diameter/2 - tread_depth/2, 0, j * wheel_width/4])
                rotate([0, 90, 0])
                rotate([0, 0, 45])
                cube([3, 3, tread_depth + 1], center=true);
        }
    }
}

module circular_tread() {
    // Circular bumps
    for (i = [0:num_treads-1]) {
        rotate([0, 0, i * 360/num_treads])
            translate([wheel_diameter/2 - tread_depth/2, 0, 0])
            rotate([0, 90, 0])
            cylinder(d=4, h=tread_depth + 1, center=true, $fn=20);
    }
}

// Alternative: Single-piece wheel with integrated tire
module single_piece_wheel() {
    difference() {
        union() {
            // Use the rim
            wheel_rim();

            // Add tire ridge instead of separate tire
            tire_ridge();
        }

        // Add tread pattern directly
        if (tread_style == "chevron") {
            chevron_tread();
        } else if (tread_style == "diamond") {
            diamond_tread();
        } else if (tread_style == "circular") {
            circular_tread();
        }
    }
}

module tire_ridge() {
    // Simple ridge around rim for single-piece design
    difference() {
        cylinder(d=wheel_diameter, h=wheel_width, center=true, $fn=100);
        cylinder(d=wheel_diameter - tire_thickness*2, h=wheel_width + 2, center=true, $fn=80);
    }
}

// ===== GEARED WHEEL COMPONENTS =====

module geared_wheel() {
    // Complete wheel assembly: 70mm spoked wheel + 50-tooth 50mm gear + 22mm bearing hole
    actual_wheel_diameter = 70;  // Actual wheel size
    gear_diameter = 50;          // 50-tooth gear pitch diameter
    wheel_thickness = 6;         // Thickness of wheel disc

    difference() {
        union() {
            // 50-tooth gear (50mm pitch diameter)
            // MCAD formula: actual_diameter = specified_module * teeth / PI
            // To get 50mm: 50 = module * 50 / PI, so module = PI
            wheel_gear_module = PI;  // Module = PI for 50mm diameter with 50 teeth
            translate([0, 0, wheel_thickness/2])
                gear(
                    number_of_teeth=wheel_gear_teeth,
                    circular_pitch=wheel_gear_module * 180 / PI,
                    gear_thickness=gear_width,
                    rim_thickness=gear_width,
                    hub_thickness=gear_width,
                    bore_diameter=bearing_od + 0.3,  // 22mm hole for bearing
                    pressure_angle=pressure_angle,
                    clearance=0.2,
                    backlash=0.2
                );

            // 70mm spoked wheel base
            difference() {
                // Outer rim
                cylinder(d=actual_wheel_diameter, h=wheel_thickness, center=true, $fn=80);

                // Hollow out center, leaving rim
                cylinder(d=actual_wheel_diameter - 8, h=wheel_thickness + 2, center=true, $fn=80);
            }

            // Hub for bearing
            cylinder(d=bearing_od + 6, h=wheel_thickness, center=true, $fn=60);

            // Spokes connecting hub to rim
            for (i = [0:5]) {
                rotate([0, 0, i * 60])
                    hull() {
                        translate([bearing_od/2 + 3, 0, 0])
                            cylinder(d=4, h=wheel_thickness, center=true, $fn=20);
                        translate([actual_wheel_diameter/2 - 4, 0, 0])
                            cylinder(d=4, h=wheel_thickness, center=true, $fn=20);
                    }
            }
        }

        // 22mm bearing hole through entire assembly
        cylinder(d=bearing_od + 0.3, h=wheel_thickness + gear_width + 4, center=true, $fn=60);

        // Set screw holes to secure to bearing
        translate([0, bearing_od/2 + 3, 0])
            rotate([90, 0, 0])
            cylinder(d=2.5, h=6, $fn=20);
    }
}

module motor_pinion() {
    // Small pinion gear with 10 teeth for motor shaft
    // 10 teeth with PI module gives ~10mm pitch diameter
    // Uses same module as wheel gear for proper meshing
    pinion_module = PI;  // Same module as wheel gear
    difference() {
        // Pinion gear with proper involute teeth (MCAD library)
        // 2mm bore for motor shaft
        gear(
            number_of_teeth=pinion_teeth,
            circular_pitch=pinion_module * 180 / PI,  // Same module as wheel
            gear_thickness=gear_width,
            rim_thickness=gear_width,
            hub_thickness=gear_width,
            bore_diameter=motor_shaft_diameter + 0.1,  // 2mm hole for motor shaft
            pressure_angle=pressure_angle,
            clearance=0.2,
            backlash=0.2
        );

        // Flat for D-shaft
        translate([motor_shaft_diameter/2 - 0.3, 0, 0])
            cube([motor_shaft_diameter, motor_shaft_diameter, gear_width + 2], center=true);

        // Set screw hole to secure to motor shaft
        translate([0, 0, gear_width/2 - 2])
            rotate([90, 0, 0])
            cylinder(d=2, h=8, center=true, $fn=20);
    }
}

// Note: Using MCAD library for proper involute gears
// Old simplified gear modules removed - now using gear() from MCAD/involute_gears.scad
