# basic_CPU

A basic CPU implemented in VHDL.

This repository contains only the files required to rebuild the project: HDL, Block Design, memory initialization, simulation, constraints, and scripts. Automatically generated Vivado artifacts are not versioned.

## Repository Structure

```text
basic_CPU/
├── hdl/              # Custom VHDL source files
├── bd/               # Block Design TCL script
├── memory/           # Memory initialization files and scripts
├── simulation/       # Testbench and waveform configuration
├── constraints/      # XDC constraint files (if any)
├── ips/              # Custom IPs (if any)
├── scripts/          # Preparation and rebuild scripts
├── .gitignore
└── README.md
```

## Clone the Project

```bash
git clone <REPOSITORY_URL>
cd basic_CPU
```

## Rebuild the Project in Vivado

From the root directory of the repository:

```bash
vivado -source scripts/build.tcl
```

This command recreates the Vivado project from the versioned source files.

## Update the Repository from the Original Vivado Project

If changes have been made inside the original Vivado project, run:

```bash
python scripts/prepare_repo.py
```

This script copies the relevant files from the Vivado-generated structure into the clean repository folders.

Then:

```bash
git status
git add .
git commit -m "Update CPU project"
git push
```

## Implemented Instructions

The CPU uses 8-bit instructions.

The two most significant bits define the operation, and the remaining six bits define either a memory address or an unused field.

| Instruction | Code     | Operation             |
|------------|----------|-----------------------|
| ADD        | 00AAAAAA | AC ← AC + M[AAAAAA]   |
| AND        | 01AAAAAA | AC ← AC ∧ M[AAAAAA]   |
| JMP        | 10AAAAAA | GOTO AAAAAA           |
| INC        | 11XXXXXX | AC ← AC + 1           |

Where:

- `AC` is the accumulator.
- `M[AAAAAA]` is the memory content at address `AAAAAA`.
- `AAAAAA` is a 6-bit memory address.
- `XXXXXX` is unused in the `INC` instruction.

## Example Program Loaded into Memory

The memory initialization generates the following contents:

```python
memory_data = {
    0: 0x0A,    # ADD 0 + addr 0xA       --> AC = 0x32
    1: 0x4B,    # AND 0x32 and addr 0xB  --> AC = 0x32 and 0x0E = 0x02
    2: 0xFF,    # INC 0x02 + 1           --> AC = 0x03
    3: 0x8C,    # JMP 0x0C
    4: 0xFF,    # INC 0x04 + 1           --> AC = 0x05
    10: 0x32,
    11: 0x0E,
    12: 0xF1,   # INC 0x03 + 1           --> AC = 0x04
    13: 0x84    # JMP 0x04
}
```

## Program Explanation

The program starts at address `0`.

### Address 0

```text
0x0A = 00001010
```

The two most significant bits are `00`, so this is an `ADD` instruction.

The lower six bits are:

```text
001010 = 0x0A
```

The CPU executes:

```text
AC ← AC + M[0x0A]
```

Since initially `AC = 0` and `M[0x0A] = 0x32`, the result is:

```text
AC = 0x32
```

### Address 1

```text
0x4B = 01001011
```

The two most significant bits are `01`, so this is an `AND` instruction.

The lower six bits are:

```text
001011 = 0x0B
```

The CPU executes:

```text
AC ← AC AND M[0x0B]
```

Since `AC = 0x32` and `M[0x0B] = 0x0E`:

```text
0x32 AND 0x0E = 0x02
```

Therefore:

```text
AC = 0x02
```

### Address 2

```text
0xFF = 11111111
```

The two most significant bits are `11`, so this is an `INC` instruction.

The CPU executes:

```text
AC ← AC + 1
```

Since `AC = 0x02`:

```text
AC = 0x03
```

### Address 3

```text
0x8C = 10001100
```

The two most significant bits are `10`, so this is a `JMP` instruction.

The lower six bits are:

```text
001100 = 0x0C
```

The CPU executes:

```text
PC ← 0x0C
```

Therefore, execution jumps to address `12`.

### Address 12

```text
0xF1 = 11110001
```

The two most significant bits are `11`, so this is another `INC` instruction.

The CPU executes:

```text
AC ← AC + 1
```

Since `AC = 0x03`:

```text
AC = 0x04
```

### Address 13

```text
0x84 = 10000100
```

The two most significant bits are `10`, so this is a `JMP` instruction.

The lower six bits are:

```text
000100 = 0x04
```

The CPU executes:

```text
PC ← 0x04
```

Therefore, execution jumps to address `4`.

### Address 4

```text
0xFF = 11111111
```

This is another `INC` instruction.

The CPU executes:

```text
AC ← AC + 1
```

Since `AC = 0x04`:

```text
AC = 0x05
```

## Expected Full Execution Sequence

```text
PC = 0   ADD M[0x0A]   AC = 0x32
PC = 1   AND M[0x0B]   AC = 0x02
PC = 2   INC           AC = 0x03
PC = 3   JMP 0x0C
PC = 12  INC           AC = 0x04
PC = 13  JMP 0x04
PC = 4   INC           AC = 0x05
```

If the CPU executes correctly, the accumulator should evolve as follows:

```text
0x00 → 0x32 → 0x02 → 0x03 → 0x04 → 0x05
```

## Important Files

- `hdl/`: contains the VHDL description of the CPU.
- `memory/`: contains the memory generation script and the `.coe` file used by the Block RAM.
- `bd/`: contains the TCL script used to recreate the Block Design.
- `simulation/`: contains the testbench and waveform configuration.
- `scripts/build.tcl`: rebuilds the complete Vivado project.
- `scripts/prepare_repo.py`: updates the clean repository structure from the original Vivado project.

## Vivado Note

The generated Vivado project itself is not versioned. It is rebuilt using:

```bash
vivado -source scripts/build.tcl
```

This avoids committing large automatically generated folders such as `.runs`, `.gen`, `.sim`, `.cache`, `.srcs`, etc.
