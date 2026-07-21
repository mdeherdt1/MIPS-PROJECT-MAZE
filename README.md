# MIPS Maze Project

A maze game written in MIPS assembly, run with the MARS simulator (`Mars45.jar`, included).
The maze is loaded from a text file and drawn on the Bitmap Display; you move a player to the exit.

## Layout

```
mazeLoader.asm      Final version of the game
Mips Deel 1/        Preliminary exercises
  Oefening 1/       Coordinate translation (row/col -> memory address)
  Oefening 2/       Coloring the screen with borders
  Oefening 3/       Reading keyboard input and printing the direction
  Oefening 4/       Reading and printing a file
Mips Deel 2/        Maze game + maze input files (input_1..3.txt)
```

## Maze format

A 32x16 grid of characters, one row per line:

| Char | Meaning |
|------|---------|
| `w`  | wall (blue) |
| `p`  | passage (black) |
| `s`  | player start (yellow) |
| `u`  | exit (green) |

## Controls

`z` up, `s` down, `q` left, `d` right, `x` quit.
Walls block movement; reaching the exit prints a win message.

## Running

1. Open `Mars45.jar` and load `mazeLoader.asm` (or `Mips Deel 2/MazeLoader.asm`).
2. Put the input file (e.g. `input_1.txt`) in MARS' working directory, and make sure
   the `filename` label in `.data` matches it.
3. Open **Tools > Bitmap Display** and set:
   - Unit width/height: 16x16
   - Display width/height: 512x256
   - Base address: `$gp` (0x10008000)
   Then click *Connect to MIPS*.
4. Assemble and run; type the movement keys one at a time into the *Run I/O* console
   (input is read with syscall 12).
