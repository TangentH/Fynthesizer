import numpy as np

# Parameters
depth = 2048
amplitude = 32767

# Generate sine wave values
sine_wave = [int(amplitude * np.sin(2 * np.pi * i / depth)) for i in range(depth)]

# Format the values for VHDL
sine_wave_formatted = [f"x\"{(value & 0xFFFF):04X}\"" for value in sine_wave]

with open("sine_wave_lut.txt", "w") as file:
    for i in range(0, len(sine_wave_formatted), 1):
        file.write(", ".join(sine_wave_formatted[i:i+8]) + '\n')
