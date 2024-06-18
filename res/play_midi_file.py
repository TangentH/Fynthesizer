import mido
import serial
import os

# Configure serial port
serial_port = '/dev/ttyUSB1'  # Replace with actual serial port
baud_rate = 460800  # Baud rate
ser = serial.Serial(serial_port, baudrate=baud_rate, timeout=1)

def send_to_serial(data):
    print(f"Sending to serial: {data}")
    ser.write(data)

def build_midi_message(msg):
    status_byte = 0
    data = []

    if msg.type == 'note_on':
        status_byte = 0x90
        data = [msg.note, msg.velocity]
    elif msg.type == 'note_off':
        status_byte = 0x80
        data = [msg.note, msg.velocity]
    elif msg.type == 'control_change':
        status_byte = 0xB0
        data = [msg.control, msg.value]
    elif msg.type == 'program_change':
        status_byte = 0xC0
        data = [msg.program]
    elif msg.type == 'pitchwheel':
        status_byte = 0xE0
        # Pitch wheel value is a 14-bit value split into two 7-bit bytes.
        # mido stores it as a signed integer in range -8192 to 8191
        value = msg.pitch + 8192
        data = [value & 0x7F, (value >> 7) & 0x7F]
    elif msg.type == 'aftertouch':
        status_byte = 0xD0
        data = [msg.value]
    elif msg.type == 'polytouch':
        status_byte = 0xA0
        data = [msg.note, msg.value]
    
    status_byte += 0  # Set channel to 0

    # Return message containing 3 bytes
    if len(data) == 2:
        return bytes([status_byte] + data)
    else:
        return None

# List all MIDI files in the 'midi' folder
midi_folder = 'midi'
midi_files = [f for f in os.listdir(midi_folder) if f.endswith('.mid')]

# Display list of MIDI files
print("Available MIDI files:")
for i, file_name in enumerate(midi_files):
    print(f"{i + 1}: {file_name}")

# User selects a MIDI file
selected_index = int(input("Enter the number of the MIDI file you want to play: ")) - 1
selected_file = midi_files[selected_index]
midi_file_path = os.path.join(midi_folder, selected_file)

# Read the selected MIDI file
midi_file = mido.MidiFile(midi_file_path)

# Get all channels
channels = set()
for track in midi_file.tracks:
    for msg in track:
        if not msg.is_meta and hasattr(msg, 'channel'):
            channels.add(msg.channel)

channels = sorted(list(channels))

# Display information
print(f"Loaded MIDI file: {selected_file}")
print(f"Number of channels: {len(channels)}")
print(f"Channels: {', '.join(map(str, channels))}")

# User selects a channel
selected_channel = int(input("Enter the channel number you want to play: "))

# Send each message in the MIDI file to the serial port
try:
    for msg in midi_file.play():
        if not msg.is_meta and hasattr(msg, 'channel') and msg.channel == selected_channel:
            # Build MIDI message byte array
            midi_bytes = build_midi_message(msg)
            
            if midi_bytes:
                print(f"Original message: {msg} (channel {msg.channel})")
                print(f"Modified message bytes: {list(midi_bytes)}")
                send_to_serial(midi_bytes)

except KeyboardInterrupt:
    print("Interrupted by user")

finally:
    ser.close()
