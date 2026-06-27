#!/usr/bin/env python3
import os
import hashlib
import wave
import struct
import numpy as np

def generate_procedural_audio(universe_id: str, asset_id: str, output_path: str):
    seed_str = f"{universe_id}{asset_id}"
    seed = int(hashlib.md5(seed_str.encode()).hexdigest(), 16) % (2**31 - 1)
    np.random.seed(seed)
    
    sample_rate = 44100
    audio_data = None
    
    if "click" in asset_id:
        duration = 0.2
        t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
        freq = np.random.uniform(800, 1200)
        sine = np.sin(2 * np.pi * freq * t)
        envelope = np.exp(-15.0 * t) 
        audio_data = sine * envelope
        
    elif "error" in asset_id:
        duration = 0.4
        half = int(sample_rate * (duration / 2.0))
        t1 = np.linspace(0, duration/2.0, half, endpoint=False)
        t2 = np.linspace(0, duration/2.0, half, endpoint=False)
        
        freq1 = np.random.uniform(400, 500)
        freq2 = freq1 * 0.75 
        
        tone1 = np.sin(2 * np.pi * freq1 * t1) * np.exp(-5.0 * t1)
        tone2 = np.sin(2 * np.pi * freq2 * t2) * np.exp(-5.0 * t2)
        audio_data = np.concatenate((tone1, tone2))
        
    else:
        duration = 2.0 
        t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
        base_freq = np.random.uniform(55, 110) 
        lfo = 0.5 * (1.0 + np.sin(2 * np.pi * 0.5 * t)) 
        sine = np.sin(2 * np.pi * base_freq * t)
        noise = np.random.normal(0, 0.05, len(t))
        audio_data = (sine * 0.8 + noise) * lfo * 0.5

    audio_data = np.clip(audio_data, -1.0, 1.0)
    pcm16 = (audio_data * 32767).astype(np.int16)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with wave.open(output_path, 'wb') as wav_file:
        wav_file.setnchannels(1) 
        wav_file.setsampwidth(2) 
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(pcm16.tobytes())
        
    print(f"[AUDIO GENERATOR] Synthesized 16-bit WAV audio: {output_path} (Seed: {seed_str})")

if __name__ == '__main__':
    generate_procedural_audio("science_lab", "ui_click", "temp_click.wav")
    generate_procedural_audio("science_lab", "ui_error", "temp_error.wav")
    generate_procedural_audio("science_lab", "ambience_science_lab", "temp_ambience.wav")
