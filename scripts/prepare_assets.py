#!/usr/bin/env python3
"""One-shot asset preparation for Axolotl-demo.

* music : /mnt/e/Users/klp/Downloads/Fairy Dance.mp3 → game/bgm/fairy_dance.mp3
          (source as requested) plus a Vorbis/OGG encode (.ogg) — the current
          engine audio pipeline decodes WAV/OGG, so the playable track is the
          OGG; the MP3 is kept as the canonical source file.
* images: BR project files → game/background (JPG→PNG, the engine image
          pipeline currently decodes PNG/TGA) and game/figure (PNG as-is).
* voice : placeholder beeps via scripts/gen_beeps.py.

Dependencies for full regeneration: python3, miniaudio (pip), GStreamer
(gst-launch-1.0 with vorbisenc/oggmux), Pillow, and a checkout of the BR
project. The committed game/ tree is already generated — rerun only when the
source assets change.
"""

import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
GAME = os.path.join(ROOT, "game")

FAIRY_SRC = "/mnt/e/Users/klp/Downloads/Fairy Dance.mp3"
BR = "/home/klp/BR/game"

BACKGROUNDS = [
    "title_bg", "bg_classroom", "bg_corridor", "bg_night_street",
    "bg_bedroom_night", "bg_home_livingroom", "bg_classroom_lunch",
    "bg_blood_draw",
]
FIGURES = [
    "figure_hero", "figure_heroine", "figure_teacher", "figure_mom",
    "figure_support", "figure_classmate_a",
]
AVATARS = [
    "avatar_hero", "avatar_heroine", "avatar_teacher", "avatar_mom",
    "avatar_classmate_a",
]


def music():
    dst_dir = os.path.join(GAME, "bgm")
    os.makedirs(dst_dir, exist_ok=True)
    mp3 = os.path.join(dst_dir, "fairy_dance.mp3")
    ogg = os.path.join(dst_dir, "fairy_dance.ogg")
    print(f"[music] copy {FAIRY_SRC} -> {mp3}")
    shutil.copyfile(FAIRY_SRC, mp3)
    if os.path.exists(ogg):
        print(f"[music] {ogg} already exists, skip re-encode")
        return
    # Decode MP3 -> raw S16 PCM (miniaudio), then encode Vorbis via GStreamer.
    import miniaudio
    print("[music] decode MP3 -> PCM")
    d = miniaudio.decode_file(
        FAIRY_SRC, output_format=miniaudio.SampleFormat.SIGNED16,
        nchannels=2, sample_rate=44100,
    )
    data = d.samples if isinstance(d.samples, bytes) else d.samples.tobytes()
    with tempfile.NamedTemporaryFile(suffix=".s16", delete=False) as f:
        f.write(data)
        pcm = f.name
    pipe = (
        "gst-launch-1.0 -q filesrc location=%s"
        ' ! "audio/x-raw,format=S16LE,rate=44100,channels=2,layout=interleaved"'
        " ! rawaudioparse"
        " ! audioresample ! audioconvert"
        " ! vorbisenc quality=0.45 ! oggmux"
        " ! filesink location=%s"
    )
    print("[music] PCM -> OGG (Vorbis)")
    subprocess.run(pipe % (pcm, ogg), shell=True, check=True)
    os.unlink(pcm)
    print(f"[music] done: {mp3} + {ogg}")


def images():
    from PIL import Image
    bg_dir = os.path.join(GAME, "background")
    fig_dir = os.path.join(GAME, "figure")
    os.makedirs(bg_dir, exist_ok=True)
    os.makedirs(fig_dir, exist_ok=True)
    for name in BACKGROUNDS:
        src = os.path.join(BR, "background", f"{name}.jpg")
        dst = os.path.join(bg_dir, f"{name}.png")
        if os.path.exists(dst):
            print(f"[bg] {dst} exists, skip")
            continue
        print(f"[bg] {name}.jpg -> {name}.png")
        Image.open(src).convert("RGB").save(dst, optimize=True)
    for name in FIGURES + AVATARS:
        for ext in ("png", "webp"):
            src = os.path.join(BR, "figure", f"{name}.{ext}")
            if os.path.exists(src):
                break
        else:
            print(f"[figure] {name}: not found in BR, skip")
            continue
        dst = os.path.join(fig_dir, f"{name}.png")
        if os.path.exists(dst):
            print(f"[figure] {dst} exists, skip")
            continue
        if ext == "png":
            shutil.copyfile(src, dst)
        else:
            print(f"[figure] {name}.{ext} -> png")
            Image.open(src).convert("RGBA").save(dst, optimize=True)


def voices():
    subprocess.run([sys.executable, os.path.join(ROOT, "scripts", "gen_beeps.py")], check=True)


def main():
    music()
    images()
    voices()
    print("assets ready under", GAME)


if __name__ == "__main__":
    main()