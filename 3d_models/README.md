# ArloBot 3D Printed Chassis and Wheels

This directory contains the OpenSCAD parametric design files for a 2-wheel differential drive robot chassis and custom 3D printed wheels.

## Files

- `robot_chassis.scad` - Main OpenSCAD design file (parametric and customizable)
- `robot_wheels.scad` - Parametric wheel design with multiple tread options

## Parts to Print

### Chassis Parts

1. **Bottom Plate** (1x) - Main chassis base with mounting holes
2. **Motor Mount** (2x) - L-brackets to hold the DC motors
3. **Caster Bracket** (1x) - Mount for the rear caster wheel
4. **Top Plate** (1x) - Optional cover plate

### Wheel Parts

5. **Wheels** (2x) - 65mm diameter wheels with your choice of tread:
   - `wheel_65mm.stl` - Chevron tread pattern (recommended for traction)
   - `wheel_65mm_diamond.stl` - Diamond tread pattern
   - `wheel_65mm_smooth.stl` - Smooth surface (easier to print)

## How to Generate STL Files

1. Install [OpenSCAD](https://openscad.org/downloads.html)
2. Open `robot_chassis.scad` in OpenSCAD
3. Edit the `part` variable at the top of the file:
   ```openscad
   part = "bottom_plate";  // Change this to export different parts
   ```
4. Press **F6** to render the part
5. Go to **File → Export → Export as STL**
6. Repeat for each part: `"bottom_plate"`, `"motor_mount"`, `"caster_bracket"`, `"top_plate"`

## Viewing the Complete Assembly

To see how all parts fit together:
```openscad
part = "assembly";
```
Press **F5** for preview or **F6** for full render.

## Customization

### Chassis Customization

All dimensions are parameterized at the top of `robot_chassis.scad`. You can adjust:

- **Chassis size**: `chassis_length`, `chassis_width`
- **Motor dimensions**: `motor_diameter`, `motor_length`
- **Wheel size**: `wheel_diameter`, `wheel_width`
- **Battery compartment**: `battery_length`, `battery_width`
- **Standoff height**: `standoff_height` (space between plates)

### Wheel Customization

Edit `robot_wheels.scad` to customize:

- **Wheel size**: `wheel_diameter` (default 65mm), `wheel_width` (default 27mm)
- **Motor shaft**: `shaft_diameter` (default 4mm for common hobby motors)
  - Set `shaft_flat = true` for D-shaft motors
- **Tread pattern**: `tread_style` - "chevron", "diamond", "circular", or "smooth"
- **Hub design**: `num_spokes` (4, 5, or 6), `spoke_thickness`
- **Set screw**: `set_screw_diameter` (default M3) to secure wheel to motor shaft

## Hardware Needed

### Printed Parts
- 1x Bottom plate
- 2x Motor mounts
- 1x Caster bracket
- 1x Top plate (optional)
- 2x Wheels (choose your preferred tread pattern)

### Non-Printed Parts
- 1x Arduino UNO R4 WiFi
- 1x L298P Motor Shield
- 2x DC motors with 4mm shaft (37mm diameter recommended)
- 1x Ball caster wheel (15mm diameter)
- 1x Battery pack (flexible compartment for various sizes)
- M3 screws and nuts:
  - 4x M3 x 8mm (Arduino mounting)
  - 4x M3 x 12mm (motor mounting)
  - 2x M3 x 8mm (caster mounting)
  - 4x M3 x 30mm (standoffs between plates)
  - 2x M3 x 6mm set screws (to secure wheels to motor shafts)
- Wires and connectors

**Note**: The wheels include integrated hubs with set screw holes to mount directly onto motor shafts. No additional hardware needed for wheel attachment!

## Print Settings

### Chassis Parts
- **Layer height**: 0.2mm
- **Infill**: 20-30%
- **Supports**: Not needed
- **Material**: PLA or PETG

### Wheels
- **Layer height**: 0.2mm
- **Infill**: 50-100% (for strength and weight)
- **Perimeters**: 3-4 walls
- **Material**: PLA (rigid), PETG (more flexible), or TPU for outer tire (advanced)
- **Orientation**: Print with hub facing down for best results
- **Supports**: Not needed

**Tip**: For better traction, you can add rubber bands around the wheel, or print the tire portion in TPU if you have a dual-material printer.

## Assembly Instructions

1. **Print all parts** using the STL files generated from OpenSCAD
2. **Attach motor mounts** to the bottom plate using M3 screws
3. **Mount motors** to the motor mounts
4. **Attach caster bracket** to the rear of the bottom plate
5. **Install caster wheel** to the bracket
6. **Mount Arduino** to the bottom plate using M3 standoffs or screws
7. **Connect motor shield** to Arduino
8. **Wire motors** to the motor shield
9. **Add battery** and secure it in the chassis
10. **Optional**: Add top plate using M3 standoffs

## Notes

- The design assumes standard hobby DC motors (~37mm diameter)
- Motor mount tabs extend from the chassis to position wheels outside the body
- Arduino mounting holes match the UNO R4 footprint
- Battery can be secured with velcro or zip ties
- Cable management holes are provided for wire routing

## Modifications

To modify the design:
1. Open `robot_chassis.scad` in OpenSCAD
2. Adjust parameters at the top of the file
3. Press **F5** to preview changes
4. Re-export STL files when satisfied

## Questions?

The OpenSCAD file is heavily commented. Check the comments in the file for details on each module and parameter.
