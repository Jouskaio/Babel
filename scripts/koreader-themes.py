# ruff: noqa: S311, E501  (seeded drawings, not secrets; long lines are SVG and descriptions)
"""Draws the Bookshelf themes the Babel plugin for KOReader installs.

Bookshelf (github.com/AndyHazz/bookshelf.koplugin) reads "theme packs" from
koreader/settings/bookshelf/ornaments/<pack>/: a theme/ folder (theme.json, colours.json,
wallpaper.png, plank.left/middle/right.png) and ornaments (SVG) beside it. This script draws
every pack of the plugin into babel.koplugin/themes/<pack>/ and writes babel_themes.lua, the list
the plugin installs from (with a version per pack, so an e-reader gets a redrawn pack again).

Usage: uv run --with pillow --with numpy scripts/koreader-themes.py
The drawings are seeded: running it again gives the same files.
"""

import hashlib
import json
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from PIL.PngImagePlugin import PngInfo

PLUGIN = Path(__file__).resolve().parents[1] / "api/src/babel_api/plugins/koreader/babel.koplugin"
OUT = PLUGIN / "themes"

# The wallpaper: a 6" to 8" e-reader's screen, portrait. Bookshelf fits it to the screen.
W, H = 1236, 1648
SS = 2  # drawn twice as big, then scaled down: smooth edges

# A plank design: three bands of 120 px. The middle band is the plank: its top 80% the top surface,
# the rest the front face (Bookshelf fits each to its own). Below it, the shadow.
PW, PH, BAND = 960, 360, 120
SURF0, FACE0 = BAND, BAND + round(BAND * 0.8)
FACE1 = 2 * BAND
CAP_W, CAP_END = 220, 70


def rgb(hex_):
    hex_ = hex_.lstrip("#")
    return tuple(int(hex_[i : i + 2], 16) for i in (0, 2, 4))


def mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b, strict=True))


def noise(w, h, rx, ry, seed, wrap=True):
    """Smooth noise in -1..1, repeating across x (so a plank tiles without a seam)."""
    rng = np.random.default_rng(seed)
    base = Image.fromarray((rng.random((h, w)) * 255).astype(np.uint8))
    if wrap:
        big = Image.new("L", (w * 3, h))
        for i in range(3):
            big.paste(base, (i * w, 0))
        big = big.filter(ImageFilter.GaussianBlur((rx, ry))).crop((w, 0, 2 * w, h))
    else:
        big = base.filter(ImageFilter.GaussianBlur((rx, ry)))
    a = np.asarray(big, dtype=np.float32)
    a -= a.mean()
    return a / (np.abs(a).max() or 1)


def paper(color, amount, seed, w=W, h=H):
    """A sheet of paper: a colour with a fine, soft grain."""
    grain = (
        noise(w, h, 1.2, 1.2, seed, wrap=False) * 0.6
        + noise(w, h, 18, 18, seed + 1, wrap=False) * 0.4
    )
    a = np.empty((h, w, 3), dtype=np.float32)
    a[:] = color
    a += grain[..., None] * amount
    return np.clip(a, 0, 255)


def save_wallpaper(img, path, colors=48, dither=False):
    """A palette PNG: small, and e-ink shows few shades anyway. Gradients want dithering."""
    img = img.convert("RGB")
    palette = img.quantize(colors=colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    if dither:
        palette = img.quantize(palette=palette, dither=Image.Dither.FLOYDSTEINBERG)
    img = palette
    img.save(path, optimize=True)


def poly_ellipse(cx, cy, rx, ry, angle, n=28):
    ca, sa = math.cos(angle), math.sin(angle)
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        x, y = rx * math.cos(t), ry * math.sin(t)
        pts.append((cx + x * ca - y * sa, cy + x * sa + y * ca))
    return pts


# ── Wallpapers ────────────────────────────────────────────────────────────


def wall_babel():
    """Parchment, and small stepped towers in pale gold, set like a tiled floor."""
    img = Image.fromarray(paper(rgb("#EFE4D0"), 7, 11).astype(np.uint8)).resize((W * SS, H * SS))
    d = ImageDraw.Draw(img)
    gold, faint = rgb("#D9C59B"), rgb("#E4D5B4")
    cell = 206 * SS
    for row in range(-1, H * SS // cell + 2):
        for col in range(-1, W * SS // cell + 2):
            cx = col * cell + (cell // 2 if row % 2 else 0) + cell // 2
            cy = row * cell + cell // 2
            # The tower: four steps, a door in the lowest.
            base = cy + 30 * SS
            for i, wd in enumerate((64, 48, 32, 18)):
                x0, x1 = cx - wd * SS // 2, cx + wd * SS // 2
                y1 = base - i * 13 * SS
                d.rectangle((x0, y1 - 13 * SS, x1, y1), outline=gold, width=2 * SS)
            d.rectangle((cx - 4 * SS, base - 11 * SS, cx + 4 * SS, base), fill=gold)
            # Between the towers, a four-pointed star.
            sx, sy = cx + cell // 2, cy + cell // 2
            r, q = 9 * SS, 2 * SS
            d.polygon(
                [
                    (sx, sy - r),
                    (sx + q, sy - q),
                    (sx + r, sy),
                    (sx + q, sy + q),
                    (sx, sy + r),
                    (sx - q, sy + q),
                    (sx - r, sy),
                    (sx - q, sy - q),
                ],
                fill=faint,
            )
    return img.resize((W, H), Image.Resampling.LANCZOS)


def wall_midnight():
    """A night sky: deep blue, a field of stars, a crescent moon."""
    top, bottom = np.array(rgb("#0B1020"), np.float32), np.array(rgb("#1C2A4A"), np.float32)
    t = np.linspace(0, 1, H * SS, dtype=np.float32)[:, None, None]
    sky = top + (bottom - top) * t
    sky = np.broadcast_to(sky, (H * SS, W * SS, 3)).copy()
    img = Image.fromarray(sky.astype(np.uint8))
    rng = random.Random(7)
    glow = Image.new("L", img.size, 0)
    dg = ImageDraw.Draw(glow)
    # The moon: a disc less a disc, with a soft halo.
    mx, my, mr = 960 * SS, 250 * SS, 112 * SS
    dg.ellipse((mx - mr * 1.9, my - mr * 1.9, mx + mr * 1.9, my + mr * 1.9), fill=40)
    glow = glow.filter(ImageFilter.GaussianBlur(60 * SS))
    img = Image.composite(Image.new("RGB", img.size, rgb("#3A4A70")), img, glow)
    moon = Image.new("L", img.size, 0)
    dm = ImageDraw.Draw(moon)
    dm.ellipse((mx - mr, my - mr, mx + mr, my + mr), fill=255)
    dm.ellipse((mx - mr * 0.55, my - mr * 1.05, mx + mr * 1.35, my + mr * 0.85), fill=0)
    img = Image.composite(Image.new("RGB", img.size, rgb("#EDE3C6")), img, moon)
    d = ImageDraw.Draw(img)
    stars = []
    for _ in range(420):
        x, y = rng.uniform(0, W * SS), rng.uniform(0, H * SS)
        if math.hypot(x - mx, y - my) < mr * 1.6:
            continue
        r = rng.choice((1, 1, 1, 1.5, 1.5, 2, 2.5)) * SS
        c = mix(rgb("#1C2A4A"), rgb("#F4EEDC"), rng.uniform(0.45, 1))
        d.ellipse((x - r, y - r, x + r, y + r), fill=c)
        stars.append((x, y))
    # A few constellations, faintly joined.
    for _ in range(4):
        cx, cy = rng.uniform(100, W - 100) * SS, rng.uniform(450, H - 100) * SS
        pts = [(cx + rng.uniform(-110, 110) * SS, cy + rng.uniform(-80, 80) * SS) for _ in range(5)]
        pts.sort()
        d.line(pts, fill=rgb("#3B4B72"), width=2 * SS)
        for x, y in pts:
            r = 3.5 * SS
            d.ellipse((x - r, y - r, x + r, y + r), fill=rgb("#F4EEDC"))
    # Sparkles: four-pointed stars.
    for _ in range(26):
        x, y = rng.uniform(0, W * SS), rng.uniform(0, H * SS)
        if math.hypot(x - mx, y - my) < mr * 1.6:
            continue
        r, q = rng.uniform(7, 13) * SS, 1.6 * SS
        d.polygon(
            [
                (x, y - r),
                (x + q, y - q),
                (x + r, y),
                (x + q, y + q),
                (x, y + r),
                (x - q, y + q),
                (x - r, y),
                (x - q, y - q),
            ],
            fill=rgb("#F4EEDC"),
        )
    return img.resize((W, H), Image.Resampling.LANCZOS)


def sprig(d, x, y, length, angle, leaf, stem, rng):
    """A stem bending as it grows, with leaves in pairs and one at the tip."""
    steps = 9
    bend = rng.uniform(-0.5, 0.5)
    pts = []
    a = angle
    px, py = x, y
    for _ in range(steps + 1):
        pts.append((px, py))
        a += bend / steps
        px += math.cos(a) * length / steps
        py += math.sin(a) * length / steps
    d.line(pts, fill=stem, width=3 * SS, joint="curve")
    size = length / 6.5
    for i in range(2, steps, 2):
        (x0, y0), (x1, y1) = pts[i - 1], pts[i]
        a = math.atan2(y1 - y0, x1 - x0)
        for side in (-1, 1):
            la = a + side * 0.9
            cx = x1 + math.cos(la) * size * 0.9
            cy = y1 + math.sin(la) * size * 0.9
            d.polygon(poly_ellipse(cx, cy, size, size * 0.42, la), fill=leaf)
    (x0, y0), (x1, y1) = pts[-2], pts[-1]
    a = math.atan2(y1 - y0, x1 - x0)
    d.polygon(
        poly_ellipse(
            x1 + math.cos(a) * size * 0.8, y1 + math.sin(a) * size * 0.8, size, size * 0.4, a
        ),
        fill=leaf,
    )


def wall_herbarium():
    """Pressed sprigs scattered on cream paper, as in a botanist's album."""
    tile = 412  # W and H are whole tiles: the pattern repeats without a seam
    rng = random.Random(3)
    img = Image.fromarray(paper(rgb("#F4F1E7"), 5, 21).astype(np.uint8)).resize((W * SS, H * SS))
    layer = Image.new("RGBA", (tile * SS, tile * SS), (0, 0, 0, 0))
    big = Image.new("RGBA", (tile * 3 * SS, tile * 3 * SS), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    leaves = [rgb("#A9BBA2"), rgb("#B9C6A8"), rgb("#9FB4A6")]
    for _ in range(7):
        x, y = rng.uniform(0, tile) * SS, rng.uniform(0, tile) * SS
        length, angle = rng.uniform(110, 170) * SS, rng.uniform(0, 2 * math.pi)
        leaf = rng.choice(leaves)
        stem = mix(leaf, (90, 110, 90), 0.25)
        for ox in (0, tile, 2 * tile):
            for oy in (0, tile, 2 * tile):
                sprig(
                    d,
                    x + ox * SS,
                    y + oy * SS,
                    length,
                    angle,
                    leaf,
                    stem,
                    random.Random(int(x + y)),
                )
    for _ in range(14):
        x, y = rng.uniform(0, tile) * SS, rng.uniform(0, tile) * SS
        r = rng.uniform(3, 5) * SS
        for ox in (0, tile, 2 * tile):
            for oy in (0, tile, 2 * tile):
                cx, cy = x + ox * SS, y + oy * SS
                d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=rgb("#D4B9A0"))
    layer = big.crop((tile * SS, tile * SS, 2 * tile * SS, 2 * tile * SS))
    for tx in range(0, W * SS, tile * SS):
        for ty in range(0, H * SS, tile * SS):
            img.paste(layer, (tx, ty), layer)
    return img.resize((W, H), Image.Resampling.LANCZOS)


def ridge(w, base, height, seed):
    rng = np.random.default_rng(seed)
    x = np.arange(w, dtype=np.float32)
    y = np.full(w, base, dtype=np.float32)
    for k, amp in ((1.3, 1.0), (3.1, 0.45), (7.7, 0.2), (17.0, 0.08)):
        y -= height * amp * (0.5 + 0.5 * np.sin(2 * np.pi * k * x / w + rng.uniform(0, 6.28)))
    return y


def wall_ink():
    """Ink wash: misty mountain ranges, a red sun, rice paper."""
    paper_a = paper(rgb("#F6F3EC"), 6, 31)
    h, w = H, W
    yy = np.arange(h, dtype=np.float32)[:, None]
    img = paper_a.copy()
    # The sun, behind the ranges.
    sx, sy, sr = 900, 470, 120
    xx = np.arange(w, dtype=np.float32)[None, :]
    sun = np.clip(sr + 1 - np.hypot(xx - sx, yy - sy), 0, 1)[..., None]
    img = img * (1 - sun * 0.85) + np.array(rgb("#C0533E"), np.float32) * sun * 0.85
    layers = [
        (760, 170, "#D8D4CC"),
        (950, 190, "#B9B5AD"),
        (1150, 170, "#8F8B85"),
        (1380, 150, "#5E5B57"),
    ]
    for i, (base, height, tone) in enumerate(layers):
        top = ridge(w, base, height, 40 + i)[None, :]
        below = yy - top
        # Solid at the ridge, washed out further down: the mist between the ranges.
        a = np.where(below >= 0, np.clip(1 - below / 260, 0.18, 1), 0)
        edge = np.clip(below + 1, 0, 1)
        a = (a * edge)[..., None]
        img = img * (1 - a) + np.array(rgb(tone), np.float32) * a
    out = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(out)
    # Three birds crossing the sky.
    for bx, by, s in ((300, 360, 16), (350, 330, 12), (395, 372, 10)):
        d.line(
            [(bx - s, by - s * 0.4), (bx, by), (bx + s, by - s * 0.4)],
            fill=rgb("#4B4844"),
            width=3,
            joint="curve",
        )
    return out


def wall_seaside():
    """Pale sand and rows of little waves, like a printed beach towel faded by the sun."""
    img = Image.fromarray(paper(rgb("#EFE7D6"), 6, 41).astype(np.uint8)).resize((W * SS, H * SS))
    d = ImageDraw.Draw(img)
    wave, foam = rgb("#BFD0D6"), rgb("#D6E1E2")
    r = 26 * SS
    step = 2 * r
    row_h = 46 * SS
    for row in range(-1, H * SS // row_h + 2):
        y = row * row_h
        shift = r if row % 2 else 0
        color = wave if row % 3 else foam
        for col in range(-1, W * SS // step + 2):
            x = col * step + shift
            d.arc((x - r, y - r, x + r, y + r), 200, 340, fill=color, width=3 * SS)
    rng = random.Random(5)
    for _ in range(18):
        x, y = rng.uniform(0, W * SS), rng.uniform(0, H * SS)
        s = rng.uniform(8, 13) * SS
        pts = [
            (
                x + math.cos(a) * s * (1 if i % 2 == 0 else 0.42),
                y + math.sin(a) * s * (1 if i % 2 == 0 else 0.42),
            )
            for i, a in enumerate(np.linspace(-math.pi / 2, 1.5 * math.pi, 11)[:-1])
        ]
        d.polygon(pts, fill=rgb("#E3C2A8"))
    return img.resize((W, H), Image.Resampling.LANCZOS)


# ── Planks ────────────────────────────────────────────────────────────────


def material(kind, light, dark, seed):
    """The plank's texture, PW wide and PH tall, repeating across x."""
    light, dark = np.array(rgb(light), np.float32), np.array(rgb(dark), np.float32)
    y = np.arange(PH, dtype=np.float32)[:, None]
    if kind == "wood":
        warp = noise(PW, PH, 90, 18, seed) * 7 + noise(PW, PH, 25, 6, seed + 1) * 1.5
        rings = 0.5 + 0.5 * np.sin(2 * np.pi * (y / 9.5 + warp))
        fibres = noise(PW, PH, 30, 0.6, seed + 2)
        t = np.clip(rings**1.8 * 0.75 + fibres * 0.25 + 0.1, 0, 1)
    elif kind == "lacquer":
        t = np.clip(
            0.55 + noise(PW, PH, 120, 10, seed) * 0.25 + noise(PW, PH, 40, 0.8, seed + 1) * 0.06,
            0,
            1,
        )
    else:  # stone
        t = np.clip(
            0.5 + noise(PW, PH, 2, 2, seed) * 0.3 + noise(PW, PH, 60, 14, seed + 1) * 0.35, 0, 1
        )
    return dark + (light - dark) * t[..., None]


def plank_image(tex, trim=None):
    """RGBA plank from a texture: surface shaded back to front, darker face, soft shadow under."""
    img = np.zeros((PH, PW, 4), np.float32)
    rows = np.arange(PH)
    for y in rows:
        if SURF0 <= y < FACE0:
            shade = 0.8 + 0.2 * (y - SURF0) / (FACE0 - SURF0)
            img[y, :, :3] = tex[y] * shade
            img[y, :, 3] = 255
        elif FACE0 <= y < FACE1:
            shade = 0.66 if y < FACE1 - 2 else 0.5
            img[y, :, :3] = tex[y] * shade
            img[y, :, 3] = 255
        elif FACE1 <= y < FACE1 + 55:
            t = (y - FACE1) / 55
            img[y, :, 3] = 150 * (1 - t) ** 2
    # The front edge catches the light.
    img[FACE0 - 2 : FACE0, :, :3] = np.minimum(255, img[FACE0 - 2 : FACE0, :, :3] * 1.22 + 10)
    if trim:
        trim = np.array(rgb(trim), np.float32)
        img[FACE0 + 4 : FACE0 + 6, :, :3] = trim
        img[FACE1 - 6 : FACE1 - 5, :, :3] = trim
    return np.clip(img, 0, 255)


def plank_cap(middle):
    """The left end: the plank from CAP_END on, rounded at the corners, fading into the middle."""
    cap = np.zeros((PH, CAP_W, 4), np.float32)
    xs = (np.arange(CAP_W) - CAP_END) % PW
    cap[:] = middle[:, xs]
    x = np.arange(CAP_W, dtype=np.float32)[None, :]
    y = np.arange(PH, dtype=np.float32)[:, None]
    alpha = (x >= CAP_END).astype(np.float32)
    rad = 14
    for cy in (SURF0 + rad, FACE1 - rad):
        cx = CAP_END + rad
        corner = (
            (x < cx)
            & (np.abs(y - cy) <= PH)
            & (((y < cy) & (cy == SURF0 + rad)) | ((y > cy) & (cy == FACE1 - rad)))
        )
        dist = np.hypot(x - cx, y - cy)
        alpha = np.where(corner, alpha * np.clip(rad + 0.5 - dist, 0, 1), alpha)
    # The shadow starts a little in, as under a real board.
    alpha = np.where(y >= FACE1, alpha * np.clip((x - CAP_END - 4) / 10, 0, 1), alpha)
    fade = np.clip((CAP_W - x) / (CAP_W - 110), 0, 1)
    cap[..., 3] *= alpha * fade
    return cap


def save_rgba(a, path, text=None):
    info = PngInfo()
    if text:
        info.add_text("bookshelf", text)
    Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "RGBA").save(
        path, optimize=True, pnginfo=info
    )


def save_plank(folder, kind, light, dark, seed, trim=None):
    tex = material(kind, light, dark, seed)
    middle = plank_image(tex, trim)
    save_rgba(middle, folder / "plank.middle.png")
    left = plank_cap(middle)
    save_rgba(left, folder / "plank.left.png", f"plank_end={CAP_END}")
    save_rgba(left[:, ::-1], folder / "plank.right.png", f"plank_end={CAP_END}")


# ── Ornaments ─────────────────────────────────────────────────────────────
# The bottom of the viewBox is the plank's front edge; the last 6 units stay empty so the piece
# stands back on the plank, beside the books. Bold shapes, no text, filters or masks.


def svg(view_w, view_h, body, note):
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f"<!-- {note} Drawn for Babel's Bookshelf themes. -->\n"
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {view_w} {view_h}">\n{body}\n</svg>\n'
    )


ORNAMENTS = {
    "babel": {
        "ziggurat.svg": svg(
            84,
            106,
            """
  <ellipse cx="42" cy="99" rx="40" ry="3" fill="#000" opacity="0.25"/>
  <rect x="4" y="80" width="76" height="20" fill="#C8A465"/>
  <rect x="4" y="80" width="76" height="4" fill="#E3C98E"/>
  <rect x="14" y="62" width="56" height="18" fill="#B8924F"/>
  <rect x="14" y="62" width="56" height="4" fill="#D9BC7E"/>
  <rect x="24" y="45" width="36" height="17" fill="#C8A465"/>
  <rect x="24" y="45" width="36" height="4" fill="#E3C98E"/>
  <rect x="33" y="30" width="18" height="15" fill="#B8924F"/>
  <rect x="33" y="30" width="18" height="4" fill="#D9BC7E"/>
  <path d="M38 30 L42 20 L46 30 Z" fill="#0E1424"/>
  <path d="M36 100 L36 89 Q42 83 48 89 L48 100 Z" fill="#0E1424"/>
  <rect x="38" y="68" width="8" height="10" rx="4" fill="#0E1424"/>
  <rect x="39" y="50" width="6" height="9" rx="3" fill="#0E1424"/>
  <rect x="8" y="88" width="6" height="6" fill="#0E1424"/>
  <rect x="70" y="88" width="6" height="6" fill="#0E1424"/>""",
            "A stepped tower of gold bricks.",
        ),
        "oil-lamp.svg": svg(
            70,
            106,
            """
  <ellipse cx="35" cy="99" rx="28" ry="3" fill="#000" opacity="0.25"/>
  <path d="M12 100 L58 100 L52 92 L18 92 Z" fill="#8C6A35"/>
  <path d="M30 92 L40 92 L38 78 L32 78 Z" fill="#B8924F"/>
  <path d="M6 70 Q8 56 35 56 Q62 56 64 70 Q60 80 35 80 Q10 80 6 70 Z" fill="#C8A465"/>
  <path d="M6 70 Q8 62 35 62 Q62 62 64 70" fill="none" stroke="#E3C98E" stroke-width="3"/>
  <path d="M62 66 Q70 62 68 54 Q66 50 62 54" fill="none" stroke="#B8924F" stroke-width="4"/>
  <ellipse cx="35" cy="56" rx="10" ry="2.5" fill="#0E1424"/>
  <path d="M35 54 Q25 40 35 22 Q45 40 35 54 Z" fill="#F2B94B"/>
  <path d="M35 52 Q30 43 35 33 Q40 43 35 52 Z" fill="#FBE7B0"/>""",
            "A brass oil lamp, lit.",
        ),
    },
    "midnight": {
        "moon-lamp.svg": svg(
            70,
            106,
            """
  <ellipse cx="35" cy="99" rx="24" ry="3" fill="#000" opacity="0.35"/>
  <path d="M15 100 L55 100 L50 93 L20 93 Z" fill="#2B3654"/>
  <rect x="33" y="70" width="4" height="23" fill="#4A5675"/>
  <path d="M46 18 A28 28 0 1 0 46 72 A22 22 0 1 1 46 18 Z" fill="#EDE3C6"/>
  <circle cx="28" cy="42" r="3" fill="#D5C9A6"/>
  <circle cx="24" cy="56" r="2" fill="#D5C9A6"/>
  <path d="M56 30 L58 36 L64 38 L58 40 L56 46 L54 40 L48 38 L54 36 Z" fill="#F4EEDC"/>""",
            "A crescent moon on a stand.",
        ),
        "lantern.svg": svg(
            56,
            106,
            """
  <ellipse cx="28" cy="99" rx="20" ry="3" fill="#000" opacity="0.35"/>
  <path d="M28 6 A7 7 0 1 1 27.9 6" fill="none" stroke="#4A5675" stroke-width="3"/>
  <path d="M14 26 L42 26 L36 18 L20 18 Z" fill="#2B3654"/>
  <rect x="10" y="26" width="36" height="6" fill="#2B3654"/>
  <rect x="12" y="32" width="32" height="56" fill="#F2C46B"/>
  <rect x="17" y="37" width="22" height="46" fill="#FBE3A6"/>
  <path d="M28 76 Q20 64 28 50 Q36 64 28 76 Z" fill="#E59A3A"/>
  <rect x="12" y="32" width="4" height="56" fill="#2B3654"/>
  <rect x="40" y="32" width="4" height="56" fill="#2B3654"/>
  <rect x="26" y="32" width="4" height="56" fill="#2B3654" opacity="0.6"/>
  <rect x="8" y="88" width="40" height="12" fill="#2B3654"/>""",
            "A lantern glowing in the dark.",
        ),
    },
    "herbarium": {
        "fern-pot.svg": svg(
            76,
            106,
            """
  <ellipse cx="38" cy="99" rx="22" ry="3" fill="#000" opacity="0.25"/>
  <path d="M38 64 Q30 40 8 30" fill="none" stroke="#4E6B4A" stroke-width="3"/>
  <path d="M38 64 Q46 36 68 24" fill="none" stroke="#4E6B4A" stroke-width="3"/>
  <path d="M38 64 Q38 34 36 8" fill="none" stroke="#4E6B4A" stroke-width="3"/>
  <g fill="#6E8F63">
    <ellipse cx="14" cy="28" rx="7" ry="3" transform="rotate(-30 14 28)"/>
    <ellipse cx="20" cy="40" rx="8" ry="3" transform="rotate(30 20 40)"/>
    <ellipse cx="24" cy="30" rx="8" ry="3" transform="rotate(-50 24 30)"/>
    <ellipse cx="30" cy="48" rx="8" ry="3" transform="rotate(40 30 48)"/>
    <ellipse cx="62" cy="22" rx="7" ry="3" transform="rotate(30 62 22)"/>
    <ellipse cx="56" cy="36" rx="8" ry="3" transform="rotate(-30 56 36)"/>
    <ellipse cx="52" cy="26" rx="8" ry="3" transform="rotate(60 52 26)"/>
    <ellipse cx="46" cy="46" rx="8" ry="3" transform="rotate(-40 46 46)"/>
    <ellipse cx="30" cy="14" rx="7" ry="3" transform="rotate(-20 30 14)"/>
    <ellipse cx="42" cy="18" rx="7" ry="3" transform="rotate(20 42 18)"/>
    <ellipse cx="30" cy="28" rx="7" ry="3" transform="rotate(-10 30 28)"/>
    <ellipse cx="44" cy="32" rx="7" ry="3" transform="rotate(10 44 32)"/>
  </g>
  <path d="M20 66 L56 66 L50 100 L26 100 Z" fill="#B76E4B"/>
  <rect x="17" y="60" width="42" height="9" rx="2" fill="#C98460"/>
  <ellipse cx="38" cy="61" rx="19" ry="3.5" fill="#5B3B2A"/>""",
            "A fern in a terracotta pot.",
        ),
        "specimen-jar.svg": svg(
            54,
            106,
            """
  <ellipse cx="27" cy="99" rx="20" ry="3" fill="#000" opacity="0.25"/>
  <rect x="9" y="38" width="36" height="62" rx="7" fill="#D7E3DA"/>
  <rect x="13" y="42" width="5" height="50" rx="2.5" fill="#F2F6F2"/>
  <path d="M27 96 Q25 76 30 52" fill="none" stroke="#4E6B4A" stroke-width="2.5"/>
  <ellipse cx="22" cy="80" rx="6" ry="2.6" fill="#6E8F63" transform="rotate(-35 22 80)"/>
  <ellipse cx="33" cy="72" rx="6" ry="2.6" fill="#6E8F63" transform="rotate(30 33 72)"/>
  <ellipse cx="24" cy="64" rx="5.5" ry="2.4" fill="#6E8F63" transform="rotate(-40 24 64)"/>
  <circle cx="31" cy="52" r="4" fill="#C9786A"/>
  <rect x="12" y="28" width="30" height="10" rx="2" fill="#8A6A4A"/>
  <ellipse cx="27" cy="28" rx="15" ry="3" fill="#A88460"/>
  <rect x="15" y="80" width="24" height="10" fill="#F3EAD2"/>""",
            "A specimen jar with a sprig.",
        ),
    },
    "ink": {
        "stones.svg": svg(
            64,
            106,
            """
  <ellipse cx="32" cy="99" rx="28" ry="3" fill="#000" opacity="0.2"/>
  <ellipse cx="32" cy="88" rx="28" ry="12" fill="#3A3836"/>
  <ellipse cx="29" cy="85" rx="18" ry="4" fill="#55524E"/>
  <ellipse cx="34" cy="66" rx="21" ry="10" fill="#5E5B57"/>
  <ellipse cx="31" cy="63" rx="12" ry="3" fill="#7A7772"/>
  <ellipse cx="31" cy="47" rx="15" ry="8" fill="#8F8B85"/>
  <ellipse cx="29" cy="45" rx="8" ry="2.5" fill="#A9A59F"/>
  <ellipse cx="33" cy="33" rx="9" ry="6" fill="#2A2928"/>""",
            "A cairn of river stones.",
        ),
        "inkpot.svg": svg(
            76,
            106,
            """
  <ellipse cx="38" cy="99" rx="30" ry="3" fill="#000" opacity="0.2"/>
  <path d="M10 100 L10 74 Q10 66 18 66 L46 66 Q54 66 54 74 L54 100 Z" fill="#1E1D1C"/>
  <ellipse cx="32" cy="66" rx="22" ry="4.5" fill="#3A3836"/>
  <ellipse cx="32" cy="66" rx="12" ry="2.5" fill="#000"/>
  <rect x="14" y="78" width="8" height="14" fill="#C0533E"/>
  <path d="M38 66 L66 8" stroke="#8A6A3E" stroke-width="5" stroke-linecap="round"/>
  <path d="M34 74 L40 62 L44 64 L38 76 Z" fill="#2A2928"/>
  <circle cx="66" cy="8" r="2.5" fill="#C0533E"/>""",
            "An ink pot with a brush.",
        ),
    },
    "seaside": {
        "lighthouse.svg": svg(
            56,
            106,
            """
  <ellipse cx="28" cy="99" rx="22" ry="3" fill="#000" opacity="0.25"/>
  <path d="M8 100 Q8 90 28 90 Q48 90 48 100 Z" fill="#8C8578"/>
  <path d="M16 90 L40 90 L36 30 L20 30 Z" fill="#F4F1EA"/>
  <path d="M16.9 76 L39.1 76 L38.2 62 L17.8 62 Z" fill="#C55B4A"/>
  <path d="M18.8 48 L37.2 48 L36.4 36 L19.6 36 Z" fill="#C55B4A"/>
  <rect x="25" y="80" width="6" height="10" rx="3" fill="#3E4A5A"/>
  <rect x="16" y="26" width="24" height="4" fill="#3E4A5A"/>
  <rect x="19" y="14" width="18" height="12" fill="#F6D776"/>
  <rect x="19" y="14" width="3" height="12" fill="#3E4A5A"/>
  <rect x="34" y="14" width="3" height="12" fill="#3E4A5A"/>
  <path d="M16 14 L40 14 L28 4 Z" fill="#C55B4A"/>""",
            "A striped lighthouse.",
        ),
        "shell.svg": svg(
            70,
            106,
            """
  <ellipse cx="35" cy="99" rx="28" ry="3" fill="#000" opacity="0.25"/>
  <path d="M35 100 L8 72 Q4 40 35 34 Q66 40 62 72 Z" fill="#E9B79B"/>
  <g stroke="#C98B6E" stroke-width="3" fill="none" stroke-linecap="round">
    <path d="M35 98 L14 66"/>
    <path d="M35 98 L22 50"/>
    <path d="M35 98 L35 40"/>
    <path d="M35 98 L48 50"/>
    <path d="M35 98 L56 66"/>
  </g>
  <path d="M26 100 L44 100 L40 92 L30 92 Z" fill="#D59C80"/>
  <path d="M60 100 L62 92 L66 98 Z" fill="#E3C2A8"/>""",
            "A scallop shell.",
        ),
    },
}


# ── The packs ─────────────────────────────────────────────────────────────

PACKS = [
    {
        "id": "babel",
        "folder": "Babel",
        "name": "Babel",
        "description": "Parchment with little gold towers, a navy shelf inlaid with gold, an oil lamp.",
        "shelf": "light",
        "wallpaper": wall_babel,
        "plank": ("lacquer", "#2A3558", "#141B33", 101, "#C8A465"),
        "hero": "ziggurat",
        "colours": {
            "day": {
                "text": "#1A2036",
                "progress bar": "#0E1424",
                "progress track": "#D9CBAE",
                "selected shelf": "#0E1424",
                "selected shelf text": "#EFE4D0",
                "page": "#EFE4D0",
                "bookmark": "#A8833F",
                "plank": "#1B2440",
            },
            "night": {"text": "#EFE4D0", "progress bar": "#C8A465", "plank": "#1B2440"},
        },
    },
    {
        "id": "midnight",
        "folder": "Babel Midnight",
        "name": "Midnight",
        "description": "A starry night sky and its crescent moon, a slate shelf, a lantern to read by.",
        "shelf": "dark",
        "wallpaper": wall_midnight,
        "plank": ("stone", "#5C667C", "#30384A", 202, None),
        "hero": "moon-lamp",
        "panel_shading": "moderate",
        "colours": {
            "day": {
                "text": "#EDE6D3",
                "progress bar": "#EDE3C6",
                "progress track": "#3A4A70",
                "selected shelf": "#EDE3C6",
                "selected shelf text": "#0E1424",
                "page": "#0E1424",
                "panel": "#141C33",
                "panel text": "#EDE6D3",
                "plank": "#3E4759",
            },
            "night": {
                "text": "#EDE6D3",
                "progress bar": "#EDE3C6",
                "page": "#0E1424",
                "plank": "#3E4759",
            },
        },
    },
    {
        "id": "herbarium",
        "folder": "Babel Herbarium",
        "name": "Herbarium",
        "description": "Pressed sprigs on cream paper, a pale birch shelf, a fern and a specimen jar.",
        "shelf": "light",
        "wallpaper": wall_herbarium,
        "plank": ("wood", "#E2D1AE", "#B79E74", 303, None),
        "hero": "fern-pot",
        "colours": {
            "day": {
                "text": "#2F3A2C",
                "progress bar": "#4E6B4A",
                "progress track": "#D5DCCB",
                "selected shelf": "#4E6B4A",
                "selected shelf text": "#F4F1E7",
                "page": "#F4F1E7",
                "bookmark": "#B76E4B",
                "plank": "#CDB88E",
            },
            "night": {"text": "#E6EBDD", "progress bar": "#9FB4A6", "plank": "#CDB88E"},
        },
    },
    {
        "id": "ink",
        "folder": "Babel Ink",
        "name": "Ink",
        "description": "Ink-wash mountains under a red sun, a black lacquer shelf, a cairn and an ink pot.",
        "shelf": "light",
        "wallpaper": wall_ink,
        "dither": True,
        "plank": ("lacquer", "#3A3836", "#121212", 404, None),
        "hero": "stones",
        "colours": {
            "day": {
                "text": "#1E1D1C",
                "progress bar": "#1E1D1C",
                "progress track": "#D8D4CC",
                "selected shelf": "#1E1D1C",
                "selected shelf text": "#F6F3EC",
                "page": "#F6F3EC",
                "bookmark": "#C0533E",
                "plank": "#232221",
            },
            "night": {"text": "#F6F3EC", "progress bar": "#D8D4CC", "plank": "#232221"},
        },
    },
    {
        "id": "seaside",
        "folder": "Babel Seaside",
        "name": "Seaside",
        "description": "Sand and little waves, a driftwood shelf, a lighthouse and a shell.",
        "shelf": "light",
        "wallpaper": wall_seaside,
        "plank": ("wood", "#C9C1B2", "#8E8576", 505, None),
        "hero": "lighthouse",
        "colours": {
            "day": {
                "text": "#2E3C48",
                "progress bar": "#3E5A6C",
                "progress track": "#D6E1E2",
                "selected shelf": "#3E5A6C",
                "selected shelf text": "#F4F1EA",
                "page": "#EFE7D6",
                "bookmark": "#C55B4A",
                "plank": "#ABA392",
            },
            "night": {"text": "#EAF0F2", "progress bar": "#BFD0D6", "plank": "#ABA392"},
        },
    },
]


def lua_string(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    catalog = []
    for pack in PACKS:
        root = OUT / pack["id"]
        theme = root / "theme"
        theme.mkdir(parents=True, exist_ok=True)
        for old in root.rglob("*"):
            if old.is_file():
                old.unlink()
        save_wallpaper(
            pack["wallpaper"](), theme / "wallpaper.png", dither=pack.get("dither", False)
        )
        kind, light, dark, seed, trim = pack["plank"]
        save_plank(theme, kind, light, dark, seed, trim)
        manifest = {
            "name": pack["name"],
            "description": pack["description"],
            "shelf": pack["shelf"],
            "hero": pack["hero"],
        }
        if "panel_shading" in pack:
            manifest["panel_shading"] = pack["panel_shading"]
        (theme / "theme.json").write_text(json.dumps(manifest, indent=2) + "\n")
        (theme / "colours.json").write_text(json.dumps(pack["colours"], indent=2) + "\n")
        for name, text in ORNAMENTS[pack["id"]].items():
            (root / name).write_text(text)
        files = sorted(p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file())
        digest = hashlib.sha256()
        for f in files:
            digest.update(f.encode())
            digest.update((root / f).read_bytes())
        size = sum((root / f).stat().st_size for f in files)
        catalog.append((pack, files, digest.hexdigest()[:12], size))
        print(f"{pack['id']}: {len(files)} files, {size // 1024} KB")

    lines = [
        "-- The Bookshelf themes this plugin installs: written by scripts/koreader-themes.py, do not edit.",
        "-- Each is a folder of themes/ copied into Bookshelf's ornaments folder; version changes",
        "-- whenever a file of it does, so an e-reader gets the new drawing.",
        "return {",
    ]
    for pack, files, version, size in catalog:
        lines.append("    {")
        lines.append(f"        id = {lua_string(pack['id'])},")
        lines.append(f"        folder = {lua_string(pack['folder'])},")
        lines.append(f"        name = {lua_string(pack['name'])},")
        lines.append(f"        description = {lua_string(pack['description'])},")
        lines.append(f"        version = {lua_string(version)},")
        lines.append(f"        size = {size},")
        lines.append("        files = {")
        lines.extend(f"            {lua_string(f)}," for f in files)
        lines.append("        },")
        lines.append("    },")
    lines.append("}")
    (PLUGIN / "babel_themes.lua").write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
