import mido
import serial

# 配置串口
serial_port = '/dev/ttyUSB1'  # 替换为实际的串口设备
baud_rate = 460800  # 波特率
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
    
    status_byte += 0  # 设置通道为 0

    # 仅返回包含3个字节的消息
    if len(data) == 2:
        return bytes([status_byte] + data)
    else:
        return None

# 读取 MIDI 文件
midi_file = mido.MidiFile('main.mid')

# 获取所有通道
channels = set()
for track in midi_file.tracks:
    for msg in track:
        if not msg.is_meta and hasattr(msg, 'channel'):
            channels.add(msg.channel)

channels = sorted(list(channels))

# 打印信息
print(f"Loaded MIDI file: outer.mid")
print(f"Number of channels: {len(channels)}")
print(f"Channels: {', '.join(map(str, channels))}")

# 用户选择通道
selected_channel = int(input("Enter the channel number you want to play: "))

# 发送 MIDI 文件中的每一条消息到串口
try:
    for msg in midi_file.play():
        if not msg.is_meta and hasattr(msg, 'channel') and msg.channel == selected_channel:
            # 构建 MIDI 消息字节数组
            midi_bytes = build_midi_message(msg)
            
            if midi_bytes:
                print(f"Original message: {msg} (channel {msg.channel})")
                print(f"Modified message bytes: {list(midi_bytes)}")
                send_to_serial(midi_bytes)

except KeyboardInterrupt:
    print("Interrupted by user")

finally:
    ser.close()
