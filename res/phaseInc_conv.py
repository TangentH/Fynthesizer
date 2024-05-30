import math

# Constants for phase increment calculation
f_base = 440.0  # Frequency of A4
note_offset = 69  # MIDI note number for A4
counter_len = 18  # Length of phase accumulator counter
clk_period = 1e-8  # Clock period in seconds
next_sample_counter_length = 10  # Length of next_sample_counter
factor = (2 ** counter_len) * (clk_period) * (2 ** next_sample_counter_length)

# Function to calculate frequency of a given MIDI note
def midi_note_to_freq(note):
    return f_base * (2 ** ((note - note_offset) / 12.0))

# Calculate phaseInc values for MIDI notes 21 (A0) to 108 (C8)
phase_incs = []
for note in range(21, 109):
    freq = midi_note_to_freq(note)
    phase_inc = int(freq * factor)
    # Ensure phase_inc fits in 16 bits (unsigned(15 downto 0))
    phase_inc = phase_inc & 0xFFFF
    phase_incs.append(f"x\"{phase_inc:04X}\"")

# Generate VHDL code
vhdl_code = """library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package phaseInc_package is
    type phaseInc_table is array (0 to 87) of unsigned(15 downto 0);
    constant phaseIncs : phaseInc_table := (
"""

# Add phaseInc values to the VHDL code
for i, phase_inc in enumerate(phase_incs):
    vhdl_code += f"        {phase_inc}"
    if i < len(phase_incs) - 1:
        vhdl_code += ",\n"
    else:
        vhdl_code += "\n"

vhdl_code += """    );
end package phaseInc_package;
"""

# Write to phaseInc_table.vhd
with open("phaseInc_table.vhd", "w") as f:
    f.write(vhdl_code)

print("phaseInc_table.vhd generated successfully.")
