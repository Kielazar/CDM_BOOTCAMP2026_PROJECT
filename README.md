# TV Static / No Signal — VGA Playground Verilog Design

A small Verilog project for the Tiny Tapeout VGA Playground that generates a classic "no signal" TV static effect — full-screen random noise with subtle CRT-style scanline shading, rendered live on the VGA output.

## What it does
Fills the entire visible screen with pseudo-random grayscale noise every clock cycle, mimicking analog TV static.

Darkens every other scanline slightly, giving it a subtle rolling/CRT look.

Since red, green, and blue are all driven by the same noise value, the output is grayscale snow — just like a real "no signal" screen — rather than colored noise.

Runs entirely on digital logic: a 24-bit LFSR (linear feedback shift register) generates the randomness, with no external RNG, ROM, or memory needed.

## How it works
A 24-bit LFSR is advanced by one bit every clock cycle. Its feedback taps (bits 23, 22, 21, and 16) are XORed together and fed back into the register, which is the standard way to build a simple hardware pseudo-random sequence.

The lowest 2 bits of the LFSR (lfsr[1:0]) are used directly as a 2-bit grayscale "noise" value for each pixel, giving 4 shades of gray.
On odd scanlines (pix_y[0] == 1), the noise value is right-shifted by one bit, halving its brightness — this creates the faint horizontal banding you'd see on an old analog CRT.

The hvsync_generator module (already provided by the VGA Playground template) handles all horizontal/vertical sync timing and tells the design which pixel is currently being drawn (pix_x, pix_y) and whether it's within the visible display area (video_active).

## Files
project.v — the full design (paste this into the playground's project.v tab)
## How to run it on VGA Playground
Go to the Tiny Tapeout VGA Playground.
Open the project.v tab in the editor.
Delete any existing example code and paste in the full contents of this project's project.v.
The simulator should compile automatically and start rendering. You should immediately see a full-screen field of black/gray/white static, with faint horizontal banding.
No input switches or buttons are required — the effect runs and updates continuously as soon as the design starts.
