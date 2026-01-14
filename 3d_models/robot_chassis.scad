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
part = "bottom_plate"; // Options: "bottom_plate", "motor_mount", "caster_bracket", "top_plate", "assembly"

// Chassis dimensions
chassis_length = 140;    // Length of the base plate (mm)
chassis_width = 100;     // Width of the base plate (mm)
chassis_thickness = 3;   // Thickness of plates (mm)

// Motor parameters (N20 micro gear motor)
motor_diameter = 20;     // DC motor diameter (mm) - N20 standard
motor_length = 40;       // Motor body length (mm) - typical N20 with gearbox
motor_shaft_length = 10; // Length of motor shaft extending out (mm)
motor_mount_screw_distance = 15; // Distance between motor mounting holes
motor_height = 10;       // Height of motor center from ground (mm)

// Wheel parameters
wheel_diameter = 65;     // Wheel diameter (mm)
wheel_width = 27;        // Wheel width (mm)
wheel_offset = 10;       // How far wheels stick out from chassis edge (mm)

// Arduino UNO dimensions
arduino_length = 68.6;
arduino_width = 53.4;
arduino_hole_spacing_length = 50.8;
arduino_hole_spacing_width = 15.24;
arduino_hole_diameter = 3.2;

// Battery compartment
battery_length = 80;     // Adjustable for different battery types
battery_width = 60;
battery_height = 20;

// Caster wheel
caster_diameter = 15;    // Small ball caster or wheel
caster_mount_holes = 20; // Distance between mounting holes

// Standoff parameters
standoff_height = 30;    // Height between bottom and top plates
standoff_diameter = 6;
standoff_hole = 3.2;     // M3 screw hole

// Print tolerance
tolerance = 0.2;

// ===== RENDERING LOGIC =====

if (part == "bottom_plate") {
    bottom_plate();
} else if (part == "motor_mount") {
    motor_mount();
} else if (part == "caster_bracket") {
    caster_bracket();
} else if (part == "top_plate") {
    top_plate();
} else if (part == "assembly") {
    assembly();
}

// ===== MODULES =====

module bottom_plate() {
    difference() {
        union() {
            // Main chassis plate
            rounded_rectangle(chassis_length, chassis_width, chassis_thickness, 5);

            // Motor mount tabs (left and right)
            translate([-chassis_length/2, -chassis_width/2 - wheel_offset, 0])
                motor_mount_tab();

            translate([-chassis_length/2, chassis_width/2 + wheel_offset, 0])
                mirror([0, 1, 0])
                motor_mount_tab();
        }

        // Arduino mounting holes
        translate([10, 0, -1])
            arduino_mounting_holes();

        // Caster mounting holes (at rear center)
        translate([-chassis_length/2 + 15, 0, -1])
            caster_mounting_holes();

        // Standoff holes at corners
        translate([chassis_length/2 - 10, chassis_width/2 - 10, -1])
            cylinder(d=standoff_hole, h=chassis_thickness + 2, $fn=20);
        translate([chassis_length/2 - 10, -chassis_width/2 + 10, -1])
            cylinder(d=standoff_hole, h=chassis_thickness + 2, $fn=20);
        translate([-chassis_length/2 + 10, chassis_width/2 - 10, -1])
            cylinder(d=standoff_hole, h=chassis_thickness + 2, $fn=20);
        translate([-chassis_length/2 + 10, -chassis_width/2 + 10, -1])
            cylinder(d=standoff_hole, h=chassis_thickness + 2, $fn=20);

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
    // L-bracket to hold motor
    bracket_height = 45;
    bracket_thickness = 3;
    bracket_length = 45;

    difference() {
        union() {
            // Vertical part
            cube([bracket_length, bracket_thickness, bracket_height]);

            // Horizontal mounting flange
            cube([bracket_length, 35, bracket_thickness]);
        }

        // Motor shaft hole
        translate([bracket_length/2, -1, bracket_height - motor_height])
            rotate([-90, 0, 0])
            cylinder(d=motor_diameter + tolerance, h=bracket_thickness + 2, $fn=50);

        // Mounting screw holes (match motor_mount_tab)
        translate([bracket_length/2 + 15, 35/2 + motor_mount_screw_distance/2, -1])
            cylinder(d=3.2, h=bracket_thickness + 2, $fn=20);
        translate([bracket_length/2 + 15, 35/2 - motor_mount_screw_distance/2, -1])
            cylinder(d=3.2, h=bracket_thickness + 2, $fn=20);

        // Motor mounting screws (on vertical face)
        translate([bracket_length/2, bracket_thickness + 1, bracket_height - motor_height])
            rotate([90, 0, 0])
            cylinder(d=3, h=bracket_thickness + 2, $fn=20);
    }
}

module caster_bracket() {
    // Simple bracket for ball caster
    bracket_size = 25;
    bracket_thickness = 3;
    bracket_height = 20;

    difference() {
        union() {
            // Base
            cube([bracket_size, bracket_size, bracket_thickness]);

            // Support posts
            translate([bracket_size/2, bracket_size/2, 0])
                cylinder(d=12, h=bracket_height, $fn=30);
        }

        // Mounting holes for chassis
        translate([bracket_size/2, bracket_size/2 + caster_mount_holes/2, -1])
            cylinder(d=3.2, h=bracket_thickness + 2, $fn=20);
        translate([bracket_size/2, bracket_size/2 - caster_mount_holes/2, -1])
            cylinder(d=3.2, h=bracket_thickness + 2, $fn=20);

        // Caster mounting hole (through post)
        translate([bracket_size/2, bracket_size/2, bracket_height/2])
            cylinder(d=3.2, h=bracket_height + 2, center=true, $fn=20);
    }
}

module top_plate() {
    // Optional top cover plate
    difference() {
        rounded_rectangle(chassis_length - 10, chassis_width - 10, chassis_thickness, 5);

        // Standoff holes at corners
        translate([chassis_length/2 - 15, chassis_width/2 - 15, -1])
            cylinder(d=standoff_hole, h=chassis_thickness + 2, $fn=20);
        translate([chassis_length/2 - 15, -chassis_width/2 + 15, -1])
            cylinder(d=standoff_hole, h=chassis_thickness + 2, $fn=20);
        translate([-chassis_length/2 + 15, chassis_width/2 - 15, -1])
            cylinder(d=standoff_hole, h=chassis_thickness + 2, $fn=20);
        translate([-chassis_length/2 + 15, -chassis_width/2 + 15, -1])
            cylinder(d=standoff_hole, h=chassis_thickness + 2, $fn=20);

        // Ventilation holes
        for (x = [-30:15:30]) {
            for (y = [-20:15:20]) {
                translate([x, y, -1])
                    cylinder(d=5, h=chassis_thickness + 2, $fn=20);
            }
        }
    }
}

module arduino_mounting_holes() {
    // Arduino UNO R4 mounting holes
    hole_x_offset = arduino_hole_spacing_length / 2;
    hole_y_offset = arduino_hole_spacing_width / 2;

    translate([hole_x_offset, hole_y_offset, 0])
        cylinder(d=arduino_hole_diameter, h=chassis_thickness + 2, $fn=20);
    translate([hole_x_offset, -hole_y_offset, 0])
        cylinder(d=arduino_hole_diameter, h=chassis_thickness + 2, $fn=20);
    translate([-hole_x_offset, hole_y_offset, 0])
        cylinder(d=arduino_hole_diameter, h=chassis_thickness + 2, $fn=20);
    translate([-hole_x_offset, -hole_y_offset, 0])
        cylinder(d=arduino_hole_diameter, h=chassis_thickness + 2, $fn=20);
}

module caster_mounting_holes() {
    translate([0, caster_mount_holes/2, 0])
        cylinder(d=3.2, h=chassis_thickness + 2, $fn=20);
    translate([0, -caster_mount_holes/2, 0])
        cylinder(d=3.2, h=chassis_thickness + 2, $fn=20);
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
    color("lightblue")
        bottom_plate();

    // Motor mounts (left and right)
    color("orange")
    translate([-chassis_length/2 + 5, -chassis_width/2 - wheel_offset, chassis_thickness]) {
        rotate([90, 0, 90])
            motor_mount();
    }

    color("orange")
    translate([-chassis_length/2 + 5, chassis_width/2 + wheel_offset, chassis_thickness]) {
        rotate([90, 0, 90])
            mirror([0, 1, 0])
            motor_mount();
    }

    // Caster bracket
    color("green")
    translate([-chassis_length/2 + 15 - 12.5, -12.5, chassis_thickness])
        caster_bracket();

    // Top plate (elevated on standoffs)
    color("lightblue", alpha=0.5)
    translate([0, 0, chassis_thickness + standoff_height])
        top_plate();

    // Visualization of motors (not printable)
    color("gray", alpha=0.3) {
        translate([-chassis_length/2 + 5 + motor_length/2, -chassis_width/2 - wheel_offset, chassis_thickness + motor_height])
            rotate([0, 90, 0])
            cylinder(d=motor_diameter, h=motor_length, center=true, $fn=40);

        translate([-chassis_length/2 + 5 + motor_length/2, chassis_width/2 + wheel_offset, chassis_thickness + motor_height])
            rotate([0, 90, 0])
            cylinder(d=motor_diameter, h=motor_length, center=true, $fn=40);
    }

    // Visualization of wheels (not printable)
    color("black", alpha=0.3) {
        translate([-chassis_length/2 + 5 + motor_length + motor_shaft_length, -chassis_width/2 - wheel_offset, chassis_thickness + motor_height])
            rotate([0, 90, 0])
            cylinder(d=wheel_diameter, h=wheel_width, center=true, $fn=60);

        translate([-chassis_length/2 + 5 + motor_length + motor_shaft_length, chassis_width/2 + wheel_offset, chassis_thickness + motor_height])
            rotate([0, 90, 0])
            cylinder(d=wheel_diameter, h=wheel_width, center=true, $fn=60);
    }
}
