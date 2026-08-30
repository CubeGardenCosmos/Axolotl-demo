#!/usr/bin/env python3
"""Generate placeholder 'beep' voice lines (嘟嘟声) for Axolotl-demo.

The engine's current audio pipeline decodes WAV / OGG, so voice placeholders
are tiny WAV tones. Three voice layers are produced to exercise the Phase 6
vocal-pack routing:

  game/vocal/beep_*.wav        shared voices (played by default)
  game/vocal/zh_CN/beep_*.wav  zh_CN localised layer (double-tone 嘟-嘟)
  game/vocal/en_US/beep_*.wav  en_US localised layer (descending 嘟-嘟)

Selecting zh_CN / en_US in the Settings overlay switches the placeholder
pitch pattern live through VocalRouter — no engine code change.

Pure stdlib (wave + math); no third-party dependencies.
"""

import math
import os
import struct
import wave

RATE = 22050
AMPL = 0.55
ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "game", "vocal"))


def tone_samples(freqs, amp=AMPL, decay=True):
    """Sum of sine bursts: freqs = [(freq, ms), ...], soft attack/decay."""
    n = int(RATE * sum(dur for _, dur in freqs) / 1000)
    samples = []
    t0 = 0.0
    for freq, dur in freqs:
        length = int(RATE * dur / 1000)
        for i in range(length):
            t = i / RATE
            env = 1.0
            if decay:
                env = min(1.0, i / (RATE * 0.012))          # 12 ms attack
                env *= max(0.0, 1.0 - i / (RATE * (dur / 1000)))  # linear decay
            samples.append(amp * env * math.sin(2.0 * math.pi * freq * t))
        t0 += dur / 1000
    # pad 40 ms tail
    n += int(RATE * 0.040)
    while len(samples) < n:
        samples.append(0.0)
    return samples


def write_wav(path, samples):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples
        )
        w.writeframes(frames)


# (voice name, per-character base pitch)
VOICES = {
    "beep_system":    880,   # 引擎/系统提示音 cue
    "beep_hero":      392,   # 主角
    "beep_heroine":   523,   # 女主角
    "beep_teacher":   659,   # 老师
    "beep_mom":       330,   # 母亲
    "beep_fan":       494,   # 文学部女生
    "beep_alarm":     740,   # 电话铃/警报 cue
    "beep_tada":      784,   # 演出成功的提示 cue
}

# Localised pitch patterns (音高差异方便听出语音层切换):
#   shared / default : single tone  125 ms
#   zh_CN            : 两连嘟 嘟-嘟 (same pitch, ~50ms间隔)
#   en_US            : 下行两连 嘟→嘟 (second tone one octave down)
LAYERS = {
    None:   lambda f0: [(f0, 130)],
    "zh_CN": lambda f0: [(f0, 90), (f0, 110)],
    "en_US": lambda f0: [(f0, 90), (f0 / 2, 110)],
}


def main():
    built = 0
    for name, f0 in VOICES.items():
        for locale, maker in LAYERS.items():
            if locale is None:
                out = os.path.join(ROOT, f"{name}.wav")
            else:
                out = os.path.join(ROOT, locale, f"{name}.wav")
            write_wav(out, tone_samples(maker(f0)))
            built += 1
    print(f"generated {built} beep voice files under {ROOT}")


if __name__ == "__main__":
    main()