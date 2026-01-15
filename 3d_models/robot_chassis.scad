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

// ===== CONFIGURATION PARAMETERS =====
// Adjust these to customize your robot

// Which part to render (for STL export)
part = "bottom_plate"; // Options: "bottom_plate", "motor_mount", "assembly"

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
tolerance = 0.2;

// ===== RENDERING LOGIC =====

if (part == "bottom_plate") {
    bottom_plate();
} else if (part == "motor_mount") {
    motor_mount();
} else if (part == "assembly") {
    assembly();
}

// ===== MODULES =====

module bottom_plate() {
    difference() {
        union() {
            // Main chassis plate
            rounded_rectangle(chassis_length, chassis_width, chassis_thickness, 5);

            // Integrated motor mounts (left and right)
            // Left motor mount - rotated to point outward (negative Y direction)
            translate([-chassis_length/2 + 25, -chassis_width/2, chassis_thickness])
                rotate([0, 0, -90])
                motor_mount();

            // Right motor mount - rotated to point outward (positive Y direction)
            translate([-chassis_length/2 + 25, chassis_width/2, chassis_thickness])
                rotate([0, 0, 90])
                motor_mount();
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
    mount_flange_length = 45;
    mount_flange_width = 35;

    // Motor housing dimensions
    housing_length = motor_length + 2;  // Slightly longer than motor
    housing_outer_diameter = motor_diameter + 2 * bracket_thickness;

    // Wire slot dimensions
    wire_slot_width = 4;
    wire_slot_height = 2;

    difference() {
        union() {
            // Horizontal mounting flange (attaches to chassis)
            translate([-mount_flange_length/2, -mount_flange_width/2, 0])
                cube([mount_flange_length, mount_flange_width, bracket_thickness]);

            // Vertical support post connecting flange to motor housing
            translate([0, 0, bracket_thickness])
                cylinder(d=housing_outer_diameter, h=motor_height - motor_diameter/2, $fn=40);

            // Cylindrical motor housing (fully encases motor)
            translate([0, 0, motor_height])
                rotate([0, 90, 0])
                cylinder(d=housing_outer_diameter, h=housing_length, center=true, $fn=50);

            // Front cap (closed end) - reinforced
            translate([housing_length/2, 0, motor_height])
                rotate([0, 90, 0])
                cylinder(d=housing_outer_diameter + 2, h=bracket_thickness, $fn=50);
        }

        // Motor cavity (flattened cylinder for motor body - N20 has flat sides)
        translate([0, 0, motor_height])
            rotate([0, 90, 0])
            intersection() {
                // Circular outer shape
                cylinder(d=motor_diameter + tolerance, h=housing_length + 2, center=true, $fn=50);
                // Flattened sides - cube constrains width to motor_flat_width
                cube([housing_length + 4, motor_flat_width + tolerance, motor_diameter + tolerance], center=true);
            }

        // Motor shaft exit hole (rear opening) - flattened opening for motor insertion
        translate([-housing_length/2 - 1, 0, motor_height])
            rotate([0, 90, 0])
            intersection() {
                // Circular opening slightly larger than motor - goes deep enough to reach cavity
                cylinder(d=motor_diameter + tolerance + 2, h=housing_length, $fn=40);
                // Flattened sides to match motor shape
                cube([motor_diameter + tolerance + 2, motor_flat_width + tolerance + 2, motor_diameter + tolerance + 2], center=true);
            }

        // Motor shaft exit hole (front opening) - 4mm hole through front cap for shaft to exit outward
        translate([housing_length/2 - housing_length/2 - 2, 0, motor_height])
            rotate([0, 90, 0])
            cylinder(d=4, h=housing_length, $fn=40);

        // Wire access slots (two slots on top and bottom for motor wires)
        translate([0, 0, motor_height + housing_outer_diameter/2 - wire_slot_height/2])
            cube([housing_length - 10, wire_slot_width, wire_slot_height + 1], center=true);

        translate([0, 0, motor_height - housing_outer_diameter/2 + wire_slot_height/2])
            cube([housing_length - 10, wire_slot_width, wire_slot_height + 1], center=true);

        // Mounting screw holes in flange (match motor_mount_tab)
        translate([15, motor_mount_screw_distance/2, -1])
            cylinder(d=3.2, h=bracket_thickness + 2, $fn=20);
        translate([15, -motor_mount_screw_distance/2, -1])
            cylinder(d=3.2, h=bracket_thickness + 2, $fn=20);

        // Set screw holes to secure motor (two on sides - perpendicular to shaft)
        // These allow you to tighten small screws against the motor to lock it in place
        translate([housing_length/4, housing_outer_diameter/2 - bracket_thickness/2, motor_height])
            rotate([90, 0, 0])
            cylinder(d=2.5, h=bracket_thickness + 1, $fn=20);

        translate([-housing_length/4, housing_outer_diameter/2 - bracket_thickness/2, motor_height])
            rotate([90, 0, 0])
            cylinder(d=2.5, h=bracket_thickness + 1, $fn=20);
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

module assembly() {
    // Full assembly view for visualization
    // Bottom plate now includes integrated motor mounts
    color("lightblue")
        bottom_plate();

    // Visualization of motors (not printable) - now pointing outward to sides
    color("gray", alpha=0.3) {
        // Left motor
        translate([-chassis_length/2 + 25, -chassis_width/2 - motor_length/2, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            cylinder(d=motor_diameter, h=motor_length, center=true, $fn=40);

        // Right motor
        translate([-chassis_length/2 + 25, chassis_width/2 + motor_length/2, chassis_thickness + motor_height])
            rotate([-90, 0, 0])
            cylinder(d=motor_diameter, h=motor_length, center=true, $fn=40);
    }

    // Visualization of drive wheels (not printable) - on the sides
    color("black", alpha=0.3) {
        // Left wheel
        translate([-chassis_length/2 + 25, -chassis_width/2 - motor_length - motor_shaft_length, chassis_thickness + motor_height])
            rotate([90, 0, 0])
            cylinder(d=wheel_diameter, h=wheel_width, center=true, $fn=60);

        // Right wheel
        translate([-chassis_length/2 + 25, chassis_width/2 + motor_length + motor_shaft_length, chassis_thickness + motor_height])
            rotate([-90, 0, 0])
            cylinder(d=wheel_diameter, h=wheel_width, center=true, $fn=60);
    }
}
