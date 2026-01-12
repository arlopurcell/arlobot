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

// ===== CONFIGURATION PARAMETERS =====

// Which part to render
part = "single_piece_wheel"; // Options: "wheel", "tire", "complete_wheel", "single_piece_wheel"

// Wheel dimensions
wheel_diameter = 65;      // Overall wheel diameter (mm)
wheel_width = 27;         // Total wheel width (mm)
rim_width = 20;           // Width of the plastic rim (mm)
tire_thickness = 3;       // Thickness of tire tread (mm)

// Hub dimensions
hub_diameter = 20;        // Central hub diameter (mm)
hub_height = 15;          // Hub height/depth (mm)

// Motor shaft (most hobby motors use 3mm, 4mm, or 6mm shafts)
shaft_diameter = 4;       // Motor shaft diameter (mm)
shaft_flat = true;        // Does shaft have a flat side? (D-shaft)
shaft_flat_depth = 0.5;   // Depth of flat on D-shaft (mm)
set_screw_diameter = 3;   // M3 set screw to hold wheel on shaft
set_screw_depth = 10;     // Depth of set screw hole

// Spoke design
num_spokes = 6;           // Number of spokes (4, 5, or 6 recommended)
spoke_thickness = 3;      // Thickness of each spoke (mm)

// Tire tread
tread_style = "chevron";  // Options: "smooth", "chevron", "diamond", "circular"
tread_depth = 1;          // Depth of tread pattern (mm)
num_treads = 16;          // Number of tread elements around circumference

// Print tolerance
tolerance = 0.2;

// ===== RENDERING LOGIC =====

if (part == "wheel") {
    wheel_rim();
} else if (part == "tire") {
    tire();
} else if (part == "complete_wheel") {
    complete_wheel();
} else if (part == "single_piece_wheel") {
    single_piece_wheel();
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

            // Outer rim
            difference() {
                cylinder(d=wheel_diameter - tire_thickness*2, h=rim_width, center=true, $fn=80);
                cylinder(d=wheel_diameter - tire_thickness*2 - 4, h=rim_width + 2, center=true, $fn=80);
            }
        }

        // Motor shaft hole
        cylinder(d=shaft_diameter + tolerance, h=hub_height + 2, center=true, $fn=30);

        // Flat on D-shaft
        if (shaft_flat) {
            translate([shaft_diameter/2 - shaft_flat_depth, 0, 0])
                cube([shaft_diameter, shaft_diameter, hub_height + 2], center=true);
        }

        // Set screw hole (perpendicular to shaft)
        rotate([90, 0, 0])
            translate([0, 0, -hub_diameter/2 + set_screw_depth/2])
            cylinder(d=set_screw_diameter, h=set_screw_depth, center=true, $fn=20);

        // Countersink for set screw head
        rotate([90, 0, 0])
            translate([0, 0, -hub_diameter/2 + 1.5])
            cylinder(d=set_screw_diameter * 1.8, h=3, center=true, $fn=20);
    }
}

module spoke() {
    // Single spoke from hub to rim
    rim_radius = (wheel_diameter - tire_thickness*2) / 2;
    spoke_length = rim_radius - hub_diameter/2;

    hull() {
        // Start at hub
        translate([hub_diameter/2, 0, 0])
            cylinder(d=spoke_thickness, h=rim_width, center=true, $fn=20);

        // End at rim
        translate([rim_radius - 2, 0, 0])
            cylinder(d=spoke_thickness, h=rim_width, center=true, $fn=20);
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
