/*
 * ArloBot - 2-Wheel Differential Drive Robot Chassis
 *
 * Parametric OpenSCAD design for a simple robot chassis
 * Compatible with Arduino UNO R4 WiFi + L298P Motor Shield
 *
 * To generate STL files:
 * 1. Open in OpenSCAD
 * 2. Set 'part' variable to the part you want to export
 * 3. Press F6 to render, then Export as STL
 */

// Import gear components from robot_wheels.scad
use <robot_wheels.scad>

// ===== CONFIGURATION PARAMETERS =====
// Adjust these to customize your robot

// Which part to render (for STL export)
part = "bottom_plate"; // Options: "bottom_plate", "motor_mount", "assembly", "geared_assembly", "labeled_assembly"

// Chassis dimensions
chassis_length = 140;    // Length of the base plate (mm)
chassis_width = 100;     // Width of the base plate (mm)
chassis_thickness = 3;   // Thickness of plates (mm)

// Motor parameters (N20 micro gear motor)
motor_diameter = 20;     // DC motor diameter (mm) - N20 standard
motor_flat_width = 15;   // Motor width at flattened sides (mm) - N20 has flat sides
motor_length = 30;       // Motor body length (mm) - N20 motor body
motor_shaft_length = 10; // Length of motor shaft extending out (mm)
motor_mount_screw_distance = 15; // Distance between motor mounting holes
motor_height = 10;       // Height of motor center from ground (mm)

// Wheel parameters
wheel_diameter = 65;     // Wheel diameter (mm)
wheel_width = 27;        // Wheel width (mm)
wheel_offset = 10;       // How far wheels stick out from chassis edge (mm)

// Arduino UNO R4 dimensions
arduino_length = 68.6;
arduino_width = 53.4;
arduino_hole_diameter = 3.2;

// Battery compartment
battery_length = 80;     // Adjustable for different battery types
battery_width = 60;
battery_height = 20;

// Print tolerance
tolerance = 1.0;

// ===== RENDERING LOGIC =====

if (part == "bottom_plate") {
    bottom_plate();
} else if (part == "motor_mount") {
    motor_mount();
} else if (part == "assembly") {
    assembly();
} else if (part == "geared_assembly") {
    geared_assembly();
} else if (part == "labeled_assembly") {
    labeled_assembly();
}

// ===== MODULES =====

module bottom_plate() {
    motor_x = -chassis_length/2 + 10;
    wheel_distance = 30;  // Distance from motor shaft to wheel shaft center
    peg_length = 20;      // Length of horizontal 8mm mounting peg

    difference() {
        union() {
            // Main chassis plate
            rounded_rectangle(chassis_length, chassis_width, chassis_thickness, 5);

            // Integrated motor mounts (left and right)
            // Moved inward by 13mm for gear meshing (7mm farther from center)
            // Left motor mount - rotated to point outward (negative Y direction)
            translate([-chassis_length/2 + 10, -chassis_width/2 + 13, chassis_thickness])
                rotate([0, 0, -90])
                motor_mount();

            // Right motor mount - rotated to point outward (positive Y direction)
            translate([-chassis_length/2 + 10, chassis_width/2 - 13, chassis_thickness])
                rotate([0, 0, 90])
                motor_mount();

            // 8mm horizontal mounting pegs for wheel bearings (stick out from chassis edge)
            // Positioned 30mm forward (+X) from motor for gear meshing

            // Left side support and peg
            // Vertical support covering the full length of peg, 3mm taller than motor height
            translate([motor_x + wheel_distance - 6, -chassis_width/2, chassis_thickness])
                cube([12, peg_length, motor_height + 3], center=false);

            // Left peg - horizontal, pointing in -Y direction, with chamfered end
            translate([motor_x + wheel_distance, -chassis_width/2, chassis_thickness + motor_height])
                rotate([90, 0, 0])
                chamfered_cylinder(d=8, h=peg_length, chamfer_height=1.5);

            // Right side support and peg
            // Vertical support covering the full length of peg, 3mm taller than motor height
            translate([motor_x + wheel_distance - 6, chassis_width/2 - peg_length, chassis_thickness])
                cube([12, peg_length, motor_height + 3], center=false);

            // Right peg - horizontal, pointing in +Y direction, with chamfered end
            translate([motor_x + wheel_distance, chassis_width/2, chassis_thickness + motor_height])
                rotate([-90, 0, 0])
                chamfered_cylinder(d=8, h=peg_length, chamfer_height=1.5);
        }

        // Arduino mounting holes
        translate([10, 0, -1])
            arduino_mounting_holes();

        // Cable management holes
        translate([20, chassis_width/2 - 15, -1])
            cylinder(d=8, h=chassis_thickness + 2, $fn=30);
        translate([20, -chassis_width/2 + 15, -1])
            cylinder(d=8, h=chassis_thickness + 2, $fn=30);
    }
}

module motor_mount_tab() {
    // Extends outward for motor mounting
    tab_length = 40;
    tab_width = 35;

    translate([tab_length/2, 0, chassis_thickness/2])
    difference() {
        cube([tab_length, tab_width, chassis_thickness], center=true);

        // Motor mounting holes
        translate([15, motor_mount_screw_distance/2, 0])
            cylinder(d=3.2, h=chassis_thickness + 2, center=true, $fn=20);
        translate([15, -motor_mount_screw_distance/2, 0])
            cylinder(d=3.2, h=chassis_thickness + 2, center=true, $fn=20);
    }
}

module motor_mount() {
    // Fully enclosed motor mount that encases the motor completely
    bracket_thickness = 3;
    front_cap_thickness = 1.5;  // Thinner front wall for shaft exit
    mount_flange_length = 45;
    mount_flange_width = 35;
    epsilon = 0.01;  // Small value to ensure clean boolean operations

    // Motor housing dimensions
    housing_length = motor_length - 10;  // Shorter housing for more shaft protrusion
    housing_outer_diameter = motor_diameter + 2 * bracket_thickness;

    // Wire slot dimensions
    wire_slot_width = 4;
    wire_slot_height = 2;

    difference() {
        union() {
            // Vertical support post connecting to motor housing
            translate([0, 0, -epsilon])
                cylinder(d=housing_outer_diameter, h=motor_height - motor_diameter/2 + epsilon, $fn=40);

            // Cylindrical motor housing (fully encases motor)
            translate([0, 0, motor_height])
                rotate([0, 90, 0])
                cylinder(d=housing_outer_diameter, h=housing_length, center=true, $fn=50);

            // Front cap (closed end)
            translate([housing_length/2 - epsilon, 0, motor_height])
                rotate([0, 90, 0])
                cylinder(d=housing_outer_diameter, h=front_cap_thickness + epsilon, $fn=50);
        }

        // Motor cavity (flattened cylinder for motor body - N20 has flat sides)
        translate([0, 0, motor_height])
            rotate([0, 90, 0])
            intersection() {
                // Circular outer shape
                cylinder(d=motor_diameter + tolerance, h=housing_length + 4, center=true, $fn=50);
                // Flattened sides - cube constrains width to motor_flat_width
                cube([housing_length + 6, motor_flat_width + tolerance, motor_diameter + tolerance], center=true);
            }

        // Motor shaft exit hole (rear opening) - flattened opening for motor insertion
        translate([-housing_length/2 - bracket_thickness, 0, motor_height])
            rotate([0, 90, 0])
            intersection() {
                // Circular opening slightly larger than motor - goes deep enough to reach cavity
                cylinder(d=motor_diameter + tolerance + 2, h=housing_length + bracket_thickness + 1, $fn=40);
                // Flattened sides to match motor shape
                cube([housing_length + bracket_thickness + 1, motor_flat_width + tolerance + 2, motor_diameter + tolerance + 2], center=true);
            }

        // Motor shaft exit hole (front opening) - 18mm hole through front cap for pinion gear clearance
        translate([-2, 0, motor_height])
            rotate([0, 90, 0])
            cylinder(d=18, h=housing_length + bracket_thickness + 2, $fn=40);

        // Wire access slots (two slots on top and bottom for motor wires)
        translate([0, 0, motor_height + housing_outer_diameter/2 - wire_slot_height/2 + epsilon])
            cube([housing_length - 10, wire_slot_width, wire_slot_height + 1], center=true);

        translate([0, 0, motor_height - housing_outer_diameter/2 + wire_slot_height/2 - epsilon])
            cube([housing_length - 10, wire_slot_width, wire_slot_height + 1], center=true);

        // Set screw holes to secure motor (two on sides - perpendicular to shaft)
        // These allow you to tighten small screws against the motor to lock it in place
        translate([housing_length/4, housing_outer_diameter/2 + epsilon, motor_height])
            rotate([90, 0, 0])
            cylinder(d=2, h=bracket_thickness + 2*epsilon, $fn=20);

        translate([-housing_length/4, housing_outer_diameter/2 + epsilon, motor_height])
            rotate([90, 0, 0])
            cylinder(d=2, h=bracket_thickness + 2*epsilon, $fn=20);
    }
}

module arduino_mounting_holes() {
    // Arduino UNO R4 mounting holes (actual positions from board corner)
    // These are the real hole positions, not a symmetric pattern
    // Reference point is center of the board

    // Convert from board corner coordinates to center-based coordinates
    // Board dimensions: 68.6mm x 53.4mm

    // Hole 1: Near barrel jack (14.0, 2.54) from corner
    translate([14.0 - arduino_length/2, 2.54 - arduino_width/2, 0])
        cylinder(d=arduino_hole_diameter, h=chassis_thickness + 2, $fn=20);

    // Hole 2: Near USB connector (15.24, 50.8) from corner
    translate([15.24 - arduino_length/2, 50.8 - arduino_width/2, 0])
        cylinder(d=arduino_hole_diameter, h=chassis_thickness + 2, $fn=20);

    // Hole 3: Near digital pin 13 (66.04, 35.56) from corner
    translate([66.04 - arduino_length/2, 35.56 - arduino_width/2, 0])
        cylinder(d=arduino_hole_diameter, h=chassis_thickness + 2, $fn=20);

    // Hole 4: Near AREF pin (66.04, 7.62) from corner
    translate([66.04 - arduino_length/2, 7.62 - arduino_width/2, 0])
        cylinder(d=arduino_hole_diameter, h=chassis_thickness + 2, $fn=20);
}

module rounded_rectangle(length, width, height, radius) {
    // Creates a rectangle with rounded corners
    hull() {
        translate([length/2 - radius, width/2 - radius, 0])
            cylinder(r=radius, h=height, $fn=30);
        translate([length/2 - radius, -width/2 + radius, 0])
            cylinder(r=radius, h=height, $fn=30);
        translate([-length/2 + radius, width/2 - radius, 0])
            cylinder(r=radius, h=height, $fn=30);
        translate([-length/2 + radius, -width/2 + radius, 0])
            cylinder(r=radius, h=height, $fn=30);
    }
}

module chamfered_cylinder(d, h, chamfer_height) {
    // Creates a cylinder with a chamfered end (45 degree bevel at the tip)
    union() {
        // Main cylinder body
        cylinder(d=d, h=h - chamfer_height, $fn=40);

        // Chamfered tip (cone at the end)
        translate([0, 0, h - chamfer_height])
            cylinder(d1=d, d2=d - chamfer_height*2, h=chamfer_height, $fn=40);
    }
}

module assembly() {
    // Full assembly view for visualization
    // Bottom plate now includes integrated motor mounts
    color("lightblue")
        bottom_plate();

    // Visualization of motors (not printable) - now pointing outward to sides
    color("gray", alpha=0.3) {
        // Left motor
        translate([-chassis_length/2 + 10, -chassis_width/2 + 13 - motor_length/2, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            cylinder(d=motor_diameter, h=motor_length, center=true, $fn=40);

        // Right motor
        translate([-chassis_length/2 + 10, chassis_width/2 - 13 + motor_length/2, chassis_thickness + motor_height])
            rotate([-90, 0, 0])
            cylinder(d=motor_diameter, h=motor_length, center=true, $fn=40);
    }

    // Visualization of drive wheels (not printable) - on the sides
    color("black", alpha=0.3) {
        // Left wheel
        translate([-chassis_length/2 + 10, -chassis_width/2 - motor_length - motor_shaft_length, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            cylinder(d=wheel_diameter, h=wheel_width, center=true, $fn=60);

        // Right wheel
        translate([-chassis_length/2 + 10, chassis_width/2 + motor_length + motor_shaft_length, chassis_thickness + motor_height])
            rotate([-90, 0, 0])
            cylinder(d=wheel_diameter, h=wheel_width, center=true, $fn=60);
    }
}

module geared_assembly() {
    // Assembly view showing the complete geared drive system
    motor_x = -chassis_length/2 + 10;
    wheel_distance = 30;  // Distance from motor shaft to wheel shaft center
    peg_length = 20;      // Length of horizontal peg

    // Bottom plate with integrated motor mounts and horizontal 8mm pegs
    color([0.7, 0.8, 1.0])  // Light blue
        bottom_plate();

    // Motors (horizontal, pointing outward)
    // Moved inward by 13mm for gear meshing (7mm farther from center)
    color([0.3, 0.3, 0.3]) {  // Dark gray
        // Left motor - points toward -Y, moved inward by 13mm
        translate([motor_x, -chassis_width/2 + 13 - motor_length/2, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            cylinder(d=motor_diameter, h=motor_length, center=true, $fn=40);

        // Right motor - points toward +Y, moved inward by 13mm
        translate([motor_x, chassis_width/2 - 13 + motor_length/2, chassis_thickness + motor_height])
            rotate([-90, 0, 0])
            cylinder(d=motor_diameter, h=motor_length, center=true, $fn=40);
    }

    // Motor pinion gears (on motor shafts, vertical orientation)
    color([1.0, 0.5, 0.0]) {  // Orange
        // Left pinion - on left motor shaft, positioned 4mm from motor end
        translate([motor_x, -chassis_width/2 + 13 - motor_length - 4, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            motor_pinion();

        // Right pinion - on right motor shaft
        translate([motor_x, chassis_width/2 - 13 + motor_length + 4, chassis_thickness + motor_height])
            rotate([-90, 0, 0])
            motor_pinion();
    }

    // Ball bearings (22mm OD, 8mm ID) on the horizontal 8mm pegs
    // Positioned 30mm forward (+X) from motor for proper gear meshing
    color([0.9, 0.9, 0.95]) {  // Silver/white
        // Left bearing - on horizontal peg, 12mm out from chassis edge
        translate([motor_x + wheel_distance, -chassis_width/2 - 12, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            difference() {
                cylinder(d=22, h=7, center=true, $fn=60);
                cylinder(d=8, h=8, center=true, $fn=40);
            }

        // Right bearing - on horizontal peg
        translate([motor_x + wheel_distance, chassis_width/2 + 12, chassis_thickness + motor_height])
            rotate([-90, 0, 0])
            difference() {
                cylinder(d=22, h=7, center=true, $fn=60);
                cylinder(d=8, h=8, center=true, $fn=40);
            }
    }

    // Geared wheels (mount on bearing OD, positioned to mesh with pinions)
    // Wheels are 30mm forward (+X) from motor pinions for side-by-side gear meshing
    // Rotated so gears face inward
    color([1.0, 0.2, 0.2]) {  // Bright red
        // Left wheel - on bearing, gear faces inward (toward chassis)
        translate([motor_x + wheel_distance, -chassis_width/2 - 12, chassis_thickness + motor_height])
            rotate([-90, 0, 0])
            geared_wheel();

        // Right wheel - on bearing, gear faces inward
        translate([motor_x + wheel_distance, chassis_width/2 + 12, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            geared_wheel();
    }
}

module labeled_assembly() {
    // Same as geared_assembly but with text labels
    motor_x = -chassis_length/2 + 10;
    wheel_distance = 30;

    geared_assembly();

    // Add 3D text labels
    color("black") {
        // Label: Bottom Plate
        translate([0, -80, 0])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("Bottom Plate", size=8, halign="center", font="Liberation Sans:style=Bold");

        // Label: Motor
        translate([motor_x - 20, -chassis_width/2 - 40, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("Motor", size=6, halign="center", font="Liberation Sans:style=Bold");

        // Label: 10T Pinion Gear
        translate([motor_x - 5, -chassis_width/2 - motor_length - 20, chassis_thickness + motor_height + 10])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("10T Pinion", size=5, halign="center", font="Liberation Sans:style=Bold");

        // Label: 50T Wheel Gear
        translate([motor_x + wheel_distance + 20, -chassis_width/2 - 30, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("50T Wheel Gear", size=6, halign="center", font="Liberation Sans:style=Bold");

        // Label: 22mm Bearing
        translate([motor_x + wheel_distance, -chassis_width/2 - 25, chassis_thickness + motor_height - 10])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("Bearing", size=5, halign="center", font="Liberation Sans:style=Bold");

        // Label: 8mm Peg
        translate([motor_x + wheel_distance, -chassis_width/2 + 5, chassis_thickness + motor_height - 8])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("8mm Peg", size=4, halign="center", font="Liberation Sans:style=Bold");

        // Label: 5:1 Ratio
        translate([motor_x + 15, -chassis_width/2 - motor_length - 5, chassis_thickness + motor_height + 15])
            rotate([90, 0, 0])
            linear_extrude(1)
            text("5:1 Gear Ratio", size=7, halign="center", font="Liberation Sans:style=Bold");
    }
}
