#!/usr/bin/env python3
"""生成 Sion 的 Inochi2D 木偶 `game/puppet/sion.inp`（Phase 5 demo · Live2D 展示）。

纯标准库：手写 `.inp` v2 容器（TRNSRTS\0 + JSON 模型 + TEX_SECT PNG 纹理），
与引擎 `axolotl_inochi2d::inp::parse` 的容器/JSON schema 严格一致
（schema 详见引擎 `crates/axolotl-inochi2d/src/codec.rs`）。

木偶规格：
  · 骨骼：左臂双层骨骼（Composite「arm_L_root」+ upper_arm/forearm 两个孩子
    Part），`ArmLift` 旋转大臂（RZ），`ElbowBend` 旋转小臂（RZ）——挥手动画
    同时驱动两处，展示「骨骼」；
  · 表情：`EyeOpen`（睁眼/眨眼/瞪大）、`MouthOpen`/`MouthSmile`（口型）、
    `BodyBob`/`HairSway`（待机律动）——可被命名动画（motions/expressions）
    驱动，展示「表情」；
  · 口型：`Talk` 循环动画驱动 MouthOpen 振荡（配合对白语音演出），展示「口型」。

作者映射：
  · 世界坐标 y 向上（对准引擎 Bevy 舞台的 y-up 坐标系）；
  · 坐标为像素（舞台约 1920×1080），根节点带 1.6 缩放放在槽位原点附近。

用法：python3 scripts/gen_sion_puppet.py   （输出 game/puppet/sion.inp）
"""
import struct
import zlib
import json
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
OUT = os.path.join(ROOT, "game", "puppet", "sion.inp")

# ---------------------------------------------------------------------------
# 最小 PNG 编码器（RGBA8，滤波器 0）
# ---------------------------------------------------------------------------


def chunk(tag: bytes, payload: bytes) -> bytes:
    return struct.pack(">I", len(payload)) + tag + payload + struct.pack(
        ">I", zlib.crc32(tag + payload) & 0xFFFFFFFF
    )


def png_rgba(w: int, h: int, rows: list) -> bytes:
    """rows: list of rows, each a list of 4-byte pixels."""
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    raw = b"".join(b"\x00" + b"".join(bytes(px) for px in r) for r in rows)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def make_canvas(w: int, h: int, color=(0, 0, 0, 0)):
    return [[bytearray(color) for _ in range(w)] for _ in range(h)]


def blend_px(rows, x, y, color):
    if 0 <= x < len(rows[0]) and 0 <= y < len(rows):
        rows[y][x] = bytearray(color)


def fill_rect(rows, x0, y0, x1, y1, color):
    for y in range(max(0, y0), min(len(rows), y1)):
        for x in range(max(0, x0), min(len(rows[0]), x1)):
            blend_px(rows, x, y, color)


def fill_ellipse(rows, cx, cy, rx, ry, color, inset=1.0):
    for y in range(cy - ry, cy + ry):
        for x in range(cx - rx, cx + rx):
            dx = (x - cx) / rx
            dy = (y - cy) / ry
            if dx * dx + dy * dy * (1.0 / inset) <= 1.0:
                blend_px(rows, x, y, color)


def fill_vert_gradient(rows, x0, y0, x1, y1, c_top, c_bottom):
    for y in range(max(0, y0), min(len(rows), y1)):
        t = (y - y0) / max(1, (y1 - y0))
        c = tuple(int(a + (b - a) * t) for a, b in zip(c_top, c_bottom))
        for x in range(max(0, x0), min(len(rows[0]), x1)):
            blend_px(rows, x, y, c)


# ---------------------------------------------------------------------------
# 素材绘制（Sion 的像素风部件纹理）
# ---------------------------------------------------------------------------
SKIN = (255, 226, 205, 255)
SKIN_SHADE = (246, 208, 182, 255)
HAIR = (72, 168, 168, 255)      # 青蓝
HAIR_DARK = (52, 138, 142, 255)
DRESS = (255, 255, 255, 255)     # 白裙
DRESS_DARK = (198, 224, 255, 255)
EYE_WHITE = (255, 255, 255, 255)
IRIS = (150, 122, 255, 255)      # 紫瞳
PUPIL = (46, 36, 96, 255)
BROW = (52, 100, 104, 255)
MOUTH = (198, 96, 110, 255)
BLUSH = (255, 150, 160, 190)


def art_face() -> bytes:
    w, h = 250, 290
    rows = make_canvas(w, h)
    # 脸型：椭圆 + 纵向渐变（下巴朝下=y 减小方向保持像素上轻下重即可）
    for y in range(h):
        for x in range(w):
            dx = (x - w / 2) / (w * 0.47)
            dy = (y - h * 0.52) / (h * 0.46)
            if dx * dx + dy * dy <= 1.0:
                t = y / h
                c = tuple(
                    int(SKIN[i] + (SKIN_SHADE[i] - SKIN[i]) * t)
                    for i in range(3)
                )
                blend_px(rows, x, y, (*c, 255))
    # 下颌阴影
    fill_ellipse(rows, w // 2, h - 38, 56, 26, SKIN_SHADE, 1.4)
    # 脖子
    fill_rect(rows, w // 2 - 22, h - 22, w // 2 + 22, h, SKIN_SHADE)
    return png_rgba(w, h, rows)


def art_eye() -> bytes:
    w, h = 56, 68
    rows = make_canvas(w, h)
    fill_ellipse(rows, w // 2, h // 2, 26, 30, EYE_WHITE)
    # 上眼睑（睫毛）
    fill_ellipse(rows, w // 2, h // 2 - 6, 27, 26, BROW, 0.6)
    # 虹膜
    fill_ellipse(rows, w // 2, h // 2 + 6, 17, 19, IRIS)
    fill_ellipse(rows, w // 2, h // 2 + 6, 10, 13, PUPIL)
    # 高光
    fill_ellipse(rows, w // 2 - 7, h // 2 - 2, 5, 7, (255, 255, 255, 240), 0.7)
    fill_ellipse(rows, w // 2 + 6, h // 2 + 14, 3, 4, (255, 255, 255, 180), 0.7)
    return png_rgba(w, h, rows)


def art_brow() -> bytes:
    w, h = 64, 16
    rows = make_canvas(w, h)
    fill_ellipse(rows, w // 2, h // 2, 30, 6, BROW, 0.5)
    return png_rgba(w, h, rows)


def art_mouth() -> bytes:
    w, h = 72, 24
    rows = make_canvas(w, h)
    fill_ellipse(rows, w // 2, h // 2, 30, 8, MOUTH, 0.45)
    return png_rgba(w, h, rows)


def art_blush() -> bytes:
    w, h = 60, 24
    rows = make_canvas(w, h)
    fill_ellipse(rows, w // 2, h // 2, 26, 9, BLUSH, 0.5)
    return png_rgba(w, h, rows)


def art_hair_back() -> bytes:
    w, h = 240, 280
    rows = make_canvas(w, h)
    # 后发（头后一大片）
    fill_ellipse(rows, w // 2, h // 2 + 10, 112, 128, HAIR_DARK)
    return png_rgba(w, h, rows)


def art_hair_front() -> bytes:
    w, h = 280, 130
    rows = make_canvas(w, h)
    # 刘海（两侧垂发 + 顶部刘海，露出眼睛）
    fill_rect(rows, 0, 0, w, 40, HAIR)
    fill_ellipse(rows, 30, 20, 34, 52, HAIR)
    fill_ellipse(rows, 250, 20, 34, 52, HAIR)
    fill_ellipse(rows, w // 2, 10, 70, 52, HAIR, 0.72)
    return png_rgba(w, h, rows)


def art_dress() -> bytes:
    w, h = 340, 210
    rows = make_canvas(w, h)
    fill_vert_gradient(rows, 0, 10, w, h - 10, DRESS, DRESS_DARK)
    # 领口
    fill_rect(rows, w // 2 - 40, 0, w // 2 + 40, 26, (120, 170, 240, 255))
    return png_rgba(w, h, rows)


def art_arm(front: bool) -> bytes:
    w, h = 54, 110
    rows = make_canvas(w, h)
    fill_ellipse(rows, w // 2, h // 2, 24, 50, SKIN)
    if front:
        fill_rect(rows, w // 2 - 8, 0, w // 2 + 8, h, SKIN_SHADE)
    return png_rgba(w, h, rows)


def art_sleeve() -> bytes:
    w, h = 60, 70
    rows = make_canvas(w, h)
    fill_ellipse(rows, w // 2, h // 2, 28, 32, DRESS_DARK)
    return png_rgba(w, h, rows)


TEXTURES = {
    "face": art_face(),
    "eye": art_eye(),
    "brow": art_brow(),
    "mouth": art_mouth(),
    "blush": art_blush(),
    "hair_back": art_hair_back(),
    "hair_front": art_hair_front(),
    "dress": art_dress(),
    "arm": art_arm(False),
    "sleeve": art_sleeve(),
}

# ---------------------------------------------------------------------------
# 模型 JSON（schema 与引擎 codec 一致）
# ---------------------------------------------------------------------------


def quad(cx, cy, w, h):
    """中心 (cx,cy)、宽 w 高 h 的平面四边形（像素坐标，y 向上）。"""
    hw, hh = w / 2.0, h / 2.0
    px = [cx - hw, cy + hh, cx + hw, cy + hh, cx - hw, cy - hh, cx + hw, cy - hh]
    uu = [0.0, 1.0, 0.0, 1.0]
    vv = [1.0, 1.0, 0.0, 0.0]
    return {
        "mesh": {
            "verts": px,
            "indices": [0, 1, 2, 2, 1, 3],
            "uvs": uu + vv,
            "origin": [0.0, 0.0],
        }
    }


def part(uuid, name, cx, cy, w, h, tex_id, tint=(1, 1, 1), opacity=1.0):
    node = {
        "uuid": uuid,
        "name": name,
        "type": "Part",
        "enabled": True,
        "zsort": 0,
        "transform": {"trans": [cx, cy, 0.0], "rot": [0.0, 0.0, 0.0], "scale": [1.0, 1.0, 1.0]},
        "lockToRoot": False,
        **quad(cx, cy, w, h),
        "textures": [tex_id, 4294967295, 4294967295],
        "blend_mode": "Normal",
        "tint": list(tint),
        "screenTint": [1.0, 1.0, 1.0],
        "emissionStrength": 0.0,
        "mask_threshold": 0.5,
        "opacity": opacity,
    }
    return node


def composite(uuid, name, cx, cy, children, scale=1.0, opacity=1.0):
    return {
        "uuid": uuid,
        "name": name,
        "type": "Composite",
        "enabled": True,
        "zsort": 0,
        "transform": {
            "trans": [cx, cy, 0.0],
            "rot": [0.0, 0.0, 0.0],
            "scale": [scale, scale, 1.0],
        },
        "lockToRoot": False,
        "blend_mode": "Normal",
        "tint": [1.0, 1.0, 1.0],
        "screenTint": [1.0, 1.0, 1.0],
        "opacity": opacity,
        "children": children,
    }


def binding(node, param_name, values, is_set, interp="Linear", x_axis=None):
    b = {
        "node": node,
        "param_name": param_name,
        "interpolate_mode": interp,
        "isSet": is_set,
        "values": [[v] for v in values],
    }
    return b


def param(uuid, name, axis, values, node, param_name, merge="Additive",
          defaults=None, mn=None, mx=None):
    if defaults is None:
        defaults = axis[0]
    if mn is None:
        mn = min(axis)
    if mx is None:
        mx = max(axis)
    return {
        "uuid": uuid,
        "name": name,
        "is_vec2": False,
        "min": [mn, mn],
        "max": [mx, mx],
        "defaults": [defaults, 0.0],
        "axis_points": [list(axis), [0.0]],
        "merge_mode": merge,
        "bindings": [
            binding(node, param_name, values, [[True] for _ in values])
        ],
    }


def animation(name, lanes, length, additive=False, timestep=1.0 / 60.0):
    return {
        "timestep": timestep,
        "additive": additive,
        "length": length,
        "leadIn": 0,
        "leadOut": 0,
        "animationWeight": 1.0,
        "lanes": lanes,
    }


def lane(param_uuid, keyframes, merge="Override", target=0):
    return {
        "interpolation": "Linear",
        "uuid": param_uuid,
        "target": target,
        "merge_mode": merge,
        "keyframes": [{"frame": f, "value": v, "tension": 0.5} for f, v in keyframes],
    }


def build_model_json() -> dict:
    # 部件纹理 id：face=0 eye=1 brow=2 mouth=3 blush=4 hair_back=5
    # hair_front=6 dress=7 arm=8 sleeve=9
    body = part(2, "body", 0, -185, 340, 210, 7)
    arm_root = composite(10, "arm_L_root", -175, -20, [
        part(11, "upper_arm", 0, 8, 54, 110, 8),
        part(13, "sleeve", 0, 30, 60, 70, 9),
        part(12, "forearm", 0, -62, 54, 110, 8),
    ], scale=1.0)
    face = composite(20, "face", 0, 70, [
        part(21, "hair_back", 0, 18, 240, 280, 5),
        part(22, "face_skin", 0, 0, 250, 290, 0),
        part(23, "eye_L", -62, 55, 56, 68, 1),
        part(24, "eye_R", 62, 55, 56, 68, 1),
        part(25, "brow_L", -62, 112, 64, 16, 2),
        part(26, "brow_R", 62, 112, 64, 16, 2),
        part(27, "mouth", 0, -38, 72, 24, 3),
        part(28, "blush_L", -92, -14, 60, 24, 4, opacity=0.85),
        part(29, "blush_R", 92, -14, 60, 24, 4, opacity=0.85),
        part(30, "hair_front", 0, 178, 280, 130, 6),
    ], scale=1.0)
    root = composite(1, "Sion", 0, 0, [body, arm_root, face], scale=1.6)

    params = [
        # 眼神（gaze）与眼睑
        param(100, "EyeTX", (-1, 0, 1), (-70, 0, 70), 23, "transform.t.x"),
        param(101, "EyeTX", (-1, 0, 1), (-70, 0, 70), 24, "transform.t.x"),
        param(102, "EyeTY", (-1, 0, 1), (-20, 0, 20), 23, "transform.t.y"),
        param(103, "EyeTY", (-1, 0, 1), (-20, 0, 20), 24, "transform.t.y"),
        # 睁眼：1.0 正常 / 0 闭眼 / 1.4 瞪大
        param(104, "EyeOpen", (0, 1, 1.4), (-0.9, 0.0, 0.5), 23, "transform.s.y"),
        param(105, "EyeOpen", (0, 1, 1.4), (-0.9, 0.0, 0.5), 24, "transform.s.y"),
        # 眉毛：随眼睛缩放同步（表情张力）
        param(106, "BrowLift", (0, 1, 1.4), (-0.4, 0.0, 0.3), 25, "transform.s.y"),
        param(107, "BrowLift", (0, 1, 1.4), (-0.4, 0.0, 0.3), 26, "transform.s.y"),
        # 口型
        param(108, "MouthOpen", (0, 1), (-0.6, 1.6), 27, "transform.s.y"),
        param(109, "MouthSmile", (0, 1), (-0.3, 0.6), 27, "transform.s.x"),
        # 骨骼：挥动
        param(110, "ArmLift", (0, 1), (0.0, 2.2), 10, "transform.r.z"),
        param(111, "ElbowBend", (0, 1), (0.0, -2.4), 12, "transform.r.z"),
        # 律动
        param(112, "BodyBob", (0, 1), (-10, 10), 20, "transform.t.y"),
        param(113, "HairSway", (0, 1), (-0.06, 0.06), 30, "transform.r.z"),
    ]

    # 动画（motions/expressions；lanes 按参数 uuid 驱动）
    idle = animation("Idle", [
        lane(112, [(0, 0.0), (30, 0.55), (60, 0.0), (90, 0.35), (120, 0.0)]),
        lane(113, [(0, 0.0), (30, 0.5), (60, 0.0), (90, 0.4), (120, 0.0)]),
        lane(104, [(0, 1.0), (45, 1.0), (60, 0.05), (75, 1.0), (120, 1.0)]),
    ], length=120)
    blink = animation("Blink", [
        lane(104, [(0, 1.0), (6, 1.0), (12, 0.05), (18, 1.0)]),
        lane(105, [(0, 1.0), (6, 1.0), (12, 0.05), (18, 1.0)]),
    ], additive=False, length=18)
    talk = animation("Talk", [
        lane(108, [(0, 0.25), (6, 0.85), (12, 0.3), (18, 0.95), (24, 0.25)]),
        lane(109, [(0, 0.8)]),
    ], additive=False, length=24)
    wave = animation("Wave", [
        lane(110, [(0, 0.0), (24, 1.0), (72, 1.0), (96, 0.0)]),
        lane(111, [(0, 0.0), (24, 0.9), (48, 0.6), (72, 0.9), (96, 0.0)]),
    ], additive=False, length=96)
    surprise = animation("Surprise", [
        lane(104, [(0, 1.0), (15, 1.4)]),
        lane(105, [(0, 1.0), (15, 1.4)]),
        lane(106, [(0, 1.0), (15, 1.35)]),
        lane(107, [(0, 1.0), (15, 1.35)]),
        lane(108, [(0, 0.0), (10, 0.5), (30, 0.5)]),
    ], additive=False, length=30)
    sad = animation("Sad", [
        lane(106, [(0, 0.3)]),
        lane(107, [(0, 0.3)]),
        lane(108, [(0, 0.55)]),
        lane(112, [(0, 0.0), (45, 0.25), (90, 0.0)]),
    ], additive=False, length=90)

    return {
        "meta": {
            "name": "Sion",
            "version": "1.0",
            "rigger": "Axolotl demo generator",
            "artist": "Axolotl demo generator",
            "rights": "Public domain demo puppet (Axolotl-demo)",
            "copyright": "© 2026 CubeGardenCosmos (demo)",
            "licenseURL": "",
            "contact": "",
            "reference": "",
            "thumbnailId": 4294967295,
            "preservePixels": False,
        },
        "physics": {"pixelsPerMeter": 1000.0, "gravity": 9.8},
        "nodes": root,
        "param": params,
        "automation": None,
        "animations": {
            "Idle": idle,
            "Blink": blink,
            "Talk": talk,
            "Wave": wave,
            "Surprise": surprise,
            "Sad": sad,
        },
        "groups": [],
    }


def main():
    model = build_model_json()
    body = json.dumps(model, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    tex_ids = {
        "face": 0, "eye": 1, "brow": 2, "mouth": 3, "blush": 4,
        "hair_back": 5, "hair_front": 6, "dress": 7, "arm": 8, "sleeve": 9,
    }
    texture_blobs = [(0, TEXTURES[k]) for k, _id in sorted(
        tex_ids.items(), key=lambda kv: kv[1])]

    out = b"TRNSRTS\0"
    out += struct.pack(">I", len(body))
    out += body
    out += b"TEX_SECT"
    out += struct.pack(">I", len(texture_blobs))
    for fmt, blob in texture_blobs:
        out += struct.pack(">I", len(blob))
        out += struct.pack(">B", fmt)
        out += blob

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "wb") as f:
        f.write(out)
    print(f"wrote {OUT} ({len(out):,} bytes, {len(texture_blobs)} textures)")


if __name__ == "__main__":
    sys.exit(main())