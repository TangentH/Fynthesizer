import sys
import mido
import serial
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QHBoxLayout, QSlider, QLabel, QDial, QGroupBox, QComboBox, QLCDNumber
from PyQt5.QtCore import Qt, QThread, pyqtSignal

# Configuration
serial_port = '/dev/ttyUSB1'  # Serial port device
baud_rate = 460800  # BAUD_RATE
ser = serial.Serial(serial_port, baudrate=baud_rate, timeout=1)
MIDI_PORT = 1

def send_to_serial(data):
    ser.write(data)

def midi_to_bytes(msg):
    return msg.bytes()

1

class MidiThread(QThread):
    midi_signal = pyqtSignal(str, int)

    def run(self):
        # print available ports
        input_ports = mido.get_input_names()
        print("Available MIDI input ports:", input_ports)

        if input_ports:
            input_port_name = input_ports[MIDI_PORT]
            print(f"Using MIDI input port: {input_port_name}")

            try:
                with mido.open_input(input_port_name) as inport:
                    for msg in inport:
                        print(f"{msg}")
                        midi_bytes = midi_to_bytes(msg)
                        if msg.type == 'note_on' or msg.type == 'note_off':
                            send_to_serial(midi_bytes)
                        if msg.type == 'control_change':
                            self.midi_signal.emit(f"B{msg.control:03X}", msg.value)
                            send_to_serial(midi_bytes)

            except KeyboardInterrupt:
                print("Interrupted by user")

            finally:
                ser.close()
        else:
            print("No MIDI input ports available")

class SlowDial(QDial):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def wheelEvent(self, event):
        num_degrees = event.angleDelta().y() / 8
        num_steps = num_degrees / 15
        self.setValue(self.value() + int(num_steps))

class SynthWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Qt Synthesizer Panel")
        self.setGeometry(100, 100, 500, 400)
        # self.setWindowFlag(Qt.WindowStaysOnTopHint)
        self.initUI()

        # Start MIDI thread
        self.midi_thread = MidiThread()
        self.midi_thread.midi_signal.connect(self.update_midi_values)

        self.midi_thread.start()

    def initUI(self):
        main_layout = QVBoxLayout()

        # Add 3 Oscillators
        for i in range(1, 4):
            osc_group = QGroupBox(f'Oscillator {i}')
            osc_layout = QVBoxLayout()
            
            # Waveform selection
            waveform_label = QLabel("Waveform:")
            waveform_combo = QComboBox()
            waveform_combo.addItems(["Piano", "Kalimba", "Violin", "Guitar"])
            waveform_combo.currentIndexChanged.connect(lambda index, osc=i: self.send_waveform_change(osc, index))
            osc_layout.addWidget(waveform_label)
            osc_layout.addWidget(waveform_combo)

            if i > 1:  # Add Pitch and Volume control for OSC2 and OSC3
                # Pitch tuning
                tuning_layout = QHBoxLayout()
                
                pitch_layout = QVBoxLayout()
                pitch_label = QLabel("Pitch")
                pitch_dial = SlowDial()
                
                pitch_dial.setRange(-32, 31)
                pitch_dial.setValue(0)  # Set default to middle value
                pitch_dial.setNotchesVisible(True)
                pitch_value = QLCDNumber()
                pitch_value.setDigitCount(3)
                pitch_value.display(pitch_dial.value())
                pitch_dial.valueChanged.connect(pitch_value.display)
                pitch_layout.addWidget(pitch_label)
                pitch_layout.addWidget(pitch_dial)
                pitch_layout.addWidget(pitch_value)

                tuning_layout.addLayout(pitch_layout)

                volume_layout = QVBoxLayout()
                volume_label = QLabel("Volume")
                volume_dial = QDial()
                volume_dial.setRange(0, 127)
                volume_dial.setValue(0)  # Default to minimum value
                volume_dial.setNotchesVisible(True)
                volume_value = QLCDNumber()
                volume_value.setDigitCount(3)
                volume_value.display(volume_dial.value())
                volume_dial.valueChanged.connect(volume_value.display)
                volume_dial.valueChanged.connect(lambda value, control=f"B00{5 + i}": self.send_midi_control_change(control, value))
                volume_layout.addWidget(volume_label)
                volume_layout.addWidget(volume_dial)
                volume_layout.addWidget(volume_value)

                if i == 2:
                    self.pitch_dial2 = pitch_dial
                    self.pitch_dial2.valueChanged.connect(lambda value: self.send_midi_control_change("B012", value*2+64))
                    self.volume_dial2 = volume_dial
                    self.volume_dial2.valueChanged.connect(lambda value: self.send_midi_control_change("B013", value))
                elif i == 3:
                    self.pitch_dial3 = pitch_dial
                    self.pitch_dial3.valueChanged.connect(lambda value: self.send_midi_control_change("B014", value*2+64))
                    self.volume_dial3 = volume_dial
                    self.volume_dial3.valueChanged.connect(lambda value: self.send_midi_control_change("B015", value))
                
                tuning_layout.addLayout(volume_layout)
                
                osc_layout.addLayout(tuning_layout)
            
            osc_group.setLayout(osc_layout)
            main_layout.addWidget(osc_group)

        # Add ADSR sliders
        adsr_group = QGroupBox("ADSR")
        adsr_layout = QVBoxLayout()
        
        self.adsr_sliders = {}
        adsr_labels = ["Attack", "Decay", "Sustain", "Release"]
        for label in adsr_labels:
            slider_layout = QHBoxLayout()
            slider_label = QLabel(label)
            slider = QSlider(Qt.Horizontal)
            slider.setRange(0, 127)
            slider.setValue(0)  # Default to minimum value
            slider_value = QLCDNumber()
            slider_value.setDigitCount(3)
            slider_value.display(slider.value())
            slider.valueChanged.connect(slider_value.display)
            slider.valueChanged.connect(lambda value, control=f"B0{0x0E + adsr_labels.index(label):02X}": self.send_midi_control_change(control, value))
            slider_layout.addWidget(slider_label)
            slider_layout.addWidget(slider)
            slider_layout.addWidget(slider_value)
            adsr_layout.addLayout(slider_layout)
            self.adsr_sliders[label] = slider

        adsr_group.setLayout(adsr_layout)
        main_layout.addWidget(adsr_group)

        # Add Master Volume slider
        master_volume_layout = QHBoxLayout()
        master_volume_label = QLabel("Master Volume")
        self.master_volume_slider = QSlider(Qt.Horizontal)
        self.master_volume_slider.setRange(0, 127)
        self.master_volume_slider.setValue(80)  # Default to 80
        master_volume_value = QLCDNumber()
        master_volume_value.setDigitCount(3)
        master_volume_value.display(self.master_volume_slider.value())
        self.master_volume_slider.valueChanged.connect(master_volume_value.display)
        self.master_volume_slider.valueChanged.connect(lambda value: self.send_midi_control_change("B001", value))
        master_volume_layout.addWidget(master_volume_label)
        master_volume_layout.addWidget(self.master_volume_slider)
        master_volume_layout.addWidget(master_volume_value)
        main_layout.addLayout(master_volume_layout)

        self.setLayout(main_layout)

    def update_midi_values(self, control, value):
        if control == "B00E":
            self.adsr_sliders["Attack"].setValue(value)
        elif control == "B00F":
            self.adsr_sliders["Decay"].setValue(value)
        elif control == "B010":
            self.adsr_sliders["Sustain"].setValue(value)
        elif control == "B011":
            self.adsr_sliders["Release"].setValue(value)
        elif control == "B001":
            self.master_volume_slider.setValue(value)
        elif control == "B012":
            self.pitch_dial2.setValue(int((value-64)/2))
        elif control == "B013":
            self.volume_dial2.setValue(value)
        elif control == "B014":
            self.pitch_dial3.setValue(int((value-64)/2))
        elif control == "B015":
            self.volume_dial3.setValue(value)

    def send_midi_control_change(self, control, value):
        control_number = int(control[1:], 16)
        msg = mido.Message('control_change', control=control_number, value=value)
        midi_bytes = midi_to_bytes(msg)
        send_to_serial(midi_bytes)
        # print(f"Sent to serial: {msg}")

    def send_waveform_change(self, osc, index):
        control_map = {1: 0x16, 2: 0x17, 3: 0x18}
        waveform_map = {0: 0x00, 1: 0x03, 2: 0x02, 3: 0x01}
        control_number = control_map[osc]
        waveform_value = waveform_map[index]
        msg = mido.Message('control_change', control=control_number, value=waveform_value)
        midi_bytes = midi_to_bytes(msg)
        send_to_serial(midi_bytes)
        print(f"Sent waveform change for Oscillator {osc}: {msg}")
    
if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = SynthWindow()
    window.show()
    sys.exit(app.exec_())
