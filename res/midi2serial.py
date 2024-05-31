import mido
import serial

# 配置串口
serial_port = '/dev/ttyUSB1'  # 替换为实际的串口设备
baud_rate = 460800  # 波特率
ser = serial.Serial(serial_port, baudrate=baud_rate, timeout=1)

def send_to_serial(data):
    ser.write(data)

def midi_to_bytes(msg):
    return msg.bytes()

# 获取可用的MIDI输入端口
input_ports = mido.get_input_names()
print("Available MIDI input ports:", input_ports)

# 使用第一个可用的MIDI输入端口
if input_ports:
    input_port_name = input_ports[1]
    print(f"Using MIDI input port: {input_port_name}")
    
    try:
        with mido.open_input(input_port_name) as inport:
            for msg in inport:
                print(f"{msg}")
                midi_bytes = midi_to_bytes(msg)
                send_to_serial(midi_bytes)

    except KeyboardInterrupt:
        print("Interrupted by user")

    finally:
        ser.close()
else:
    print("No MIDI input ports available")
