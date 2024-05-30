import subprocess
import serial
import re

# 配置串口
serial_port = '/dev/ttyUSB1'  # 替换为实际的串口设备
baud_rate = 115200  # 波特率
ser = serial.Serial(serial_port, baudrate=baud_rate, timeout=1)

# 读取MIDI信号
def read_midi():
    process = subprocess.Popen(['amidi', '-p', 'hw:2,0,0', '-d'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    while True:
        line = process.stdout.readline()
        if not line:
            break
        yield line

# 发送数据到串口
def send_to_serial(data):
    ser.write(data)

def remove_whitespace_and_newlines(bitstream: str) -> str:
    # Use regex to replace spaces and newline characters with an empty string
    cleaned_bitstream = re.sub(r'[ \r\n]', '', bitstream)
    return cleaned_bitstream

def remove_whitespace_and_newlines_from_binary(binary_data: bytes) -> str:
    # Decode binary data to a string
    bitstream = binary_data.decode('latin1')
    # Remove whitespace and newlines
    cleaned_bitstream = remove_whitespace_and_newlines(bitstream)
    return cleaned_bitstream

def hex_string_to_bytes(hex_string: str) -> bytes:
    # Convert each pair of hex characters to their byte equivalent
    return bytes.fromhex(hex_string)

try:
    for midi_data in read_midi():
        print(f"Read MIDI data: {midi_data}")
        midi_data_strip = remove_whitespace_and_newlines_from_binary(midi_data)
        midi_bytes = hex_string_to_bytes(midi_data_strip)
        # print(f"Sending bytes: {midi_bytes}")
        send_to_serial(midi_bytes)

except KeyboardInterrupt:
    print("Interrupted by user")

finally:
    ser.close()
