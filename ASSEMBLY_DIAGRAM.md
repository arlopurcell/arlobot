# ArloBot Assembly Diagram

## Complete Robot Assembly

```
                    ┌─────────────────────────────────────┐
                    │      Android Phone (BLE Control)    │
                    │         via Bluetooth LE            │
                    └──────────────┬──────────────────────┘
                                   │ BLE Connection
                                   ▼
    ┌───────────────────────────────────────────────────────────────┐
    │                        TOP LEVEL                              │
    │  ┌─────────────────────────────────────────────────────┐     │
    │  │           TOP PLATE (Optional)                      │     │
    │  │        - Ventilation holes                          │     │
    │  │        - Battery compartment space (80x60x20mm)     │     │
    │  │        - Mounted on 30mm standoffs                  │     │
    │  └─────────────────────────────────────────────────────┘     │
    └───────────────────────────────────────────────────────────────┘
                          │││││ (4x standoffs)
    ┌───────────────────────────────────────────────────────────────┐
    │                       MIDDLE LEVEL                            │
    │  ┌──────────────────────────────────────┐                    │
    │  │   Arduino UNO R4 WiFi                │                    │
    │  │   - Built-in BLE radio               │                    │
    │  │   - USB port (rear)                  │                    │
    │  │   - Mounted via 4x M3 screws         │                    │
    │  │   Position: Center-front of chassis  │                    │
    │  │                                       │                    │
    │  │   ┌───────────────────────────────┐  │                    │
    │  │   │  L298P Motor Driver Shield    │  │                    │
    │  │   │  - Stacks on Arduino headers  │  │                    │
    │  │   │  - Controls 2x DC motors      │  │                    │
    │  │   │  - Power input terminal       │  │                    │
    │  │   └───────────────────────────────┘  │                    │
    │  └──────────────────────────────────────┘                    │
    └───────────────────────────────────────────────────────────────┘
                          │
    ┌───────────────────────────────────────────────────────────────┐
    │                      BOTTOM PLATE                             │
    │  Dimensions: 140mm (L) x 100mm (W) x 3mm (thick)             │
    │                                                               │
    │  [REAR]                                                       │
    │     ╔═══╗  Caster Bracket (15mm ball caster)                │
    │     ║ ○ ║  - Rear center position                           │
    │     ╚═══╝  - 2x M3 mounting screws                           │
    │                                                               │
    │  [CENTER]                                                     │
    │     ┌─────────────────┐                                      │
    │     │  Arduino Mount  │  - 4x M3 mounting holes              │
    │     │  (Center-front) │  - 68.6 x 53.4mm footprint          │
    │     └─────────────────┘                                      │
    │                                                               │
    │  [LEFT SIDE]                [RIGHT SIDE]                     │
    │   ┌──────┐                   ┌──────┐                       │
    │   │Motor │═══[Wheel]         │Motor │═══[Wheel]             │
    │   │Mount │                   │Mount │                       │
    │   └──────┘                   └──────┘                       │
    │                                                               │
    │  Cable management holes (8mm diameter)                       │
    │  4x Corner holes for standoffs (3.2mm M3)                   │
    │                                                               │
    │  [FRONT]                                                      │
    └───────────────────────────────────────────────────────────────┘
```

## Side View Cross-Section

```
                    Top Plate
           ╔═══════════════════════════╗
           ║                           ║ ← 3mm thick
           ╚═══════════════════════════╝
                 │││  30mm standoffs
           ┌───────────────────────────┐
           │  L298P Shield             │
           ├───────────────────────────┤ ← Shield headers
           │  Arduino UNO R4 WiFi      │
           └─────┬───────────────────┬─┘
                 │                   │ M3 screws
    ═══════════════════════════════════════════ Bottom Plate (3mm)
         ╔╗                           ╔╗
         ║║                           ║║ ← Motor Mounts (L-brackets)
    ───[@@]───                   ───[@@]───
       Wheel                         Wheel
      (65mm ø)                      (65mm ø)

       Rear Caster (15mm ø)
            ○
```

## 3D Printed Parts List

### 1. Bottom Plate
- **File:** `3d_models/bottom_plate.stl`
- **Function:** Main chassis base
- **Features:**
  - Motor mount tabs (extend outward on sides)
  - Arduino mounting holes (4x M3, 50.8mm x 15.24mm spacing)
  - Caster mounting holes (rear center, 20mm spacing)
  - Standoff holes (4x corners for top plate)
  - Cable management holes (2x 8mm diameter)

### 2. Motor Mount (Print 2x)
- **File:** `3d_models/motor_mount.stl`
- **Function:** L-bracket to hold DC motors
- **Features:**
  - Vertical bracket (45mm height)
  - Motor shaft hole (37mm diameter + tolerance)
  - Mounting holes to attach to bottom plate tabs
  - Motor mounting screw holes

### 3. Caster Bracket
- **File:** `3d_models/caster_bracket.stl`
- **Function:** Holds ball caster wheel
- **Features:**
  - 25mm x 25mm base
  - 20mm support post
  - Mounting holes (20mm spacing)
  - Center hole for caster axle

### 4. Top Plate (Optional)
- **File:** `3d_models/top_plate.stl`
- **Function:** Upper deck for battery/sensors
- **Features:**
  - 130mm x 90mm (slightly smaller than bottom)
  - Ventilation holes (multiple 5mm holes)
  - 4x standoff mounting holes

### 5. Wheels (Print 2x)
- **Files:**
  - `3d_models/wheel_65mm.stl` (standard)
  - `3d_models/wheel_65mm_smooth.stl`
  - `3d_models/wheel_65mm_diamond.stl`
- **Specs:**
  - 65mm diameter
  - 27mm width
  - Press-fit onto motor shafts

## Electronic Components

### Arduino UNO R4 WiFi
- **Location:** Center-front of bottom plate
- **Mounting:** 4x M3 screws through Arduino mounting holes
- **Features:**
  - Built-in BLE radio (advertises as "ArloBot")
  - USB port for programming/power
  - Pins used by L298P shield

### L298P Motor Driver Shield
- **Location:** Stacked on top of Arduino (via headers)
- **Function:** Controls both DC motors
- **Power:** Battery input terminal on shield
- **Pins Used:**
  - Motor A (Left): ENA→D10, IN1→D12, IN2→D13
  - Motor B (Right): ENB→D5, IN1→D8, IN2→D7

### DC Motors (2x)
- **Specs:** 37mm diameter, 70mm length
- **Location:** Left and right sides via motor mounts
- **Mounting:** Attached to motor mount brackets
- **Connection:** Wired to L298P shield terminals
  - Left motor → Motor A terminals
  - Right motor → Motor B terminals

### Ball Caster
- **Specs:** 15mm diameter
- **Location:** Rear center of chassis
- **Mounting:** Bolted to caster bracket with M3 screws

### Battery Pack
- **Suggested Size:** 80mm x 60mm x 20mm
- **Location:** Top plate or bottom plate (has space)
- **Connection:**
  - Powers L298P shield via power terminal
  - Voltage: Check L298P requirements (typically 6-12V)

### Android Phone
- **Connection:** Wireless BLE connection
- **Function:** Sends joystick control data
- **App:** Custom Android app (`android_ble_app/`)
- **Control Format:** Sends "X:value,Y:value" strings

## Assembly Connections

### Wiring Diagram

```
┌──────────────────────┐
│  Battery Pack        │ (6-12V, check L298P specs)
└──────┬───────────────┘
       │
       │ Power wires
       ▼
┌──────────────────────────────────┐
│   L298P Motor Driver Shield      │
│   ┌────────────────────────┐     │
│   │ Motor A    Motor B     │     │
│   │ OUT1 OUT2  OUT3 OUT4   │     │
│   └──┬───┬──────┬────┬─────┘     │
│      │   │      │    │           │
├──────┼───┼──────┼────┼───────────┤ Shield pins
│ Arduino UNO R4 WiFi              │
│  D5  D7  D8  D10  D12  D13       │
│  ENB IN1 IN1  ENA  IN1  IN2      │
│      (Motor B)  (Motor A)        │
│                                  │
│  Built-in BLE Radio              │
└──────────────────────────────────┘
       │     │         │      │
       │     │         │      │
       ▼     ▼         ▼      ▼
    [Left Motor]    [Right Motor]
      (Motor A)       (Motor B)
          │               │
          ▼               ▼
      [Left Wheel]   [Right Wheel]
       (65mm ø)        (65mm ø)

       [Rear Caster]
           (15mm ø)


       Bluetooth LE ↕

    ┌──────────────┐
    │Android Phone │
    │  (Joystick)  │
    └──────────────┘
```

## Pin Mapping Details

### L298P Shield to Arduino
| L298P Function | Arduino Pin | Motor | Purpose |
|----------------|-------------|-------|---------|
| ENA (PWM)      | D10         | A     | Left motor speed control |
| IN1            | D12         | A     | Left motor direction 1 |
| IN2            | D13         | A     | Left motor direction 2 |
| ENB (PWM)      | D5          | B     | Right motor speed control |
| IN1            | D8          | B     | Right motor direction 1 |
| IN2            | D7          | B     | Right motor direction 2 |

### Motor Control Logic
- **Forward:** IN1=HIGH, IN2=LOW, PWM=speed
- **Backward:** IN1=LOW, IN2=HIGH, PWM=speed
- **Stop:** IN1=LOW, IN2=LOW, PWM=0

### Differential Drive Algorithm
```
Joystick (X, Y) → Motor speeds:
  Left Speed  = Y + X
  Right Speed = Y - X

Where:
  X = -1.0 (left) to +1.0 (right)
  Y = -1.0 (back) to +1.0 (forward)
```

## Assembly Steps

### 1. Print All Parts
- Bottom plate (1x)
- Motor mount (2x)
- Caster bracket (1x)
- Wheel (2x, choose tread pattern)
- Top plate (1x, optional)

### 2. Assemble Bottom Chassis
1. Attach motor mounts to bottom plate tabs (M3 screws)
2. Mount DC motors to motor mounts (M3 screws)
3. Attach wheels to motor shafts (press-fit)
4. Mount caster bracket to rear center (M3 screws)
5. Install ball caster to bracket

### 3. Install Electronics
1. Mount Arduino to bottom plate (4x M3 screws with standoffs)
2. Stack L298P motor driver shield onto Arduino headers
3. Connect left motor wires to Motor A terminals (OUT1, OUT2)
4. Connect right motor wires to Motor B terminals (OUT3, OUT4)
5. Route wires through cable management holes

### 4. Add Power
1. Connect battery pack to L298P power terminal
2. Ensure correct polarity (+/-)
3. Secure battery to chassis (velcro, zip ties, or mount on top plate)

### 5. Final Assembly
1. Install 4x standoffs at corner holes (30mm length)
2. Attach top plate to standoffs (optional)
3. Secure all wiring with zip ties

### 6. Software Setup
1. Upload `arduino_ble_project.ino` to Arduino
2. Install Android app on phone
3. Power on robot
4. Connect via BLE (device name: "ArloBot")
5. Control with joystick interface

## Hardware Shopping List

### Fasteners
- M3 screws (various lengths: 6mm, 10mm, 16mm)
- M3 nuts
- M3 standoffs (30mm length for top plate)

### Electronics (Not Printed)
- Arduino UNO R4 WiFi (1x)
- L298P Motor Driver Shield (1x)
- DC motors, 37mm diameter (2x)
- Ball caster, 15mm diameter (1x)
- Battery pack (6-12V, check L298P specs)
- Wire for connections
- USB cable for programming

### Optional
- Zip ties for cable management
- Velcro strips for battery mounting
- Power switch
- Status LEDs

## Dimensions Summary

| Component | Dimensions |
|-----------|------------|
| Bottom Plate | 140mm (L) x 100mm (W) x 3mm (H) |
| Wheel Diameter | 65mm |
| Wheel Width | 27mm |
| Motor | 37mm (ø) x 70mm (L) |
| Top Plate | 130mm (L) x 90mm (W) x 3mm (H) |
| Standoff Height | 30mm |
| Overall Height | ~80mm (bottom plate to top of top plate) |
| Overall Width | ~155mm (including wheels) |

## Notes

- Ensure motor wiring is correct (test direction before final assembly)
- Battery voltage should match L298P requirements (typically 6-12V)
- Keep wiring neat to avoid interference with moving parts
- The caster provides rear support; wheels handle propulsion
- Differential drive allows turning by running motors at different speeds
- BLE range is typically 10-30 meters depending on environment
