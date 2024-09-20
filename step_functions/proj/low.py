import ctypes as C
import ctypes.wintypes
import sounddevice as sd
import numpy as np
import wave
import threading
import time

_dsound_dll = C.windll.LoadLibrary("dsound.dll")
_DirectSoundEnumerateW = _dsound_dll.DirectSoundCaptureEnumerateW

_LPDSENUMCALLBACK = C.WINFUNCTYPE(C.wintypes.BOOL,
                                  C.wintypes.LPVOID,
                                  C.wintypes.LPCWSTR,
                                  C.wintypes.LPCWSTR,
                                  C.wintypes.LPCVOID)

_ole32_dll = C.oledll.ole32
_StringFromGUID2 = _ole32_dll.StringFromGUID2

def get_devices():
    devices = []
    
    def cb_enum(lpGUID, lpszDesc, lpszDrvName, _unused):
        dev = ""
        if lpGUID is not None:
            buf = C.create_unicode_buffer(500)
            if _StringFromGUID2(C.c_int64(lpGUID), C.byref(buf), 500):
                dev = buf.value
        
        devices.append((dev, lpszDesc, lpszDrvName))
        return True
    
    _DirectSoundEnumerateW(_LPDSENUMCALLBACK(cb_enum), None)
    
    return devices

class AudioRecorder:
    def __init__(self, device_id, sample_rate=44100, channels=2):
        self.device_id = device_id
        self.sample_rate = sample_rate
        self.channels = channels
        self.recording = False
        self.audio_data = []

    def callback(self, indata, frames, time, status):
        if status:
            print(status)
        self.audio_data.append(indata.copy())

    def start_recording(self):
        self.recording = True
        self.audio_data = []
        self.stream = sd.InputStream(device=self.device_id,
                                     samplerate=self.sample_rate,
                                     channels=self.channels,
                                     callback=self.callback)
        self.stream.start()

    def stop_recording(self):
        self.recording = False
        self.stream.stop()
        self.stream.close()

    def save_recording(self, filename):
        if not self.audio_data:
            print("No audio data to save")
            return

        audio_data = np.concatenate(self.audio_data, axis=0)
        with wave.open(filename, 'wb') as wf:
            wf.setnchannels(self.channels)
            wf.setsampwidth(2)  # 16-bit audio
            wf.setframerate(self.sample_rate)
            wf.writeframes((audio_data * 32767).astype(np.int16).tobytes())
        print(f"Recording saved to {filename}")

def monitor_and_record(device_id, duration):
    recorder = AudioRecorder(device_id)
    recorder.start_recording()
    print(f"Recording from device {device_id} for {duration} seconds...")
    time.sleep(duration)
    recorder.stop_recording()
    recorder.save_recording(f"recording_{device_id.replace('{', '').replace('}', '')}.wav")

if __name__ == '__main__':
    devices = get_devices()
    for i, (devid, desc, name) in enumerate(devices):
        print(f"{i}: {desc} | {name}")

    selected_devices = input("Enter the numbers of the devices you want to monitor (comma-separated): ").split(',')
    duration = int(input("Enter the duration to record (in seconds): "))

    threads = []
    for device_index in selected_devices:
        device_id = devices[int(device_index)][0]
        thread = threading.Thread(target=monitor_and_record, args=(device_id, duration))
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()

    print("Recording completed for all selected devices.")