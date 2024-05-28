import subprocess
import serial
import time

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

try:
    for midi_data in read_midi():
        print(f"Read MIDI data: {midi_data}")
        send_to_serial(midi_data)

except KeyboardInterrupt:
    print("Interrupted by user")

finally:
    ser.close()
