"""Snake Classic Play Store promo video.

1080x1920 portrait. Intro card -> captioned gameplay segments (phone recording
with rounded corners on the board-green background) -> outro card. Music is
the game's own run loop. Usage: python render.py <ffmpeg.exe> <scenes.json> <out.mp4>

scenes.json: {"segments": [{"src": "rec1.mp4", "a": 12.0, "b": 18.5,
               "chip": "CLASSIC", "title": "...", "sub": "..."}, ...]}
"""

import json
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

D = Path(__file__).parent
ASSETS = Path(r"G:\Personal\MyProjects\snake-classic\snake_classic\assets")
FF, SCENES, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
W, H = 1080, 1920
BG = (8, 22, 11)          # LB.board
DEEP = (12, 31, 15)       # LB.deep
LIME = (174, 220, 16)     # LB.lime
HEAD = (212, 242, 90)     # LB.head
INK = (233, 245, 200)     # LB.ink
GOLD = (245, 197, 24)
MUTED = (159, 184, 160)   # LB.common
ON_LIME = (8, 22, 11)

INTRO, OUTRO, FADE = 3.5, 4.5, 0.3

# Phone frame
PH = 1500
PW = round(PH * 1080 / 2340 / 2) * 2
PX, PY = (W - PW) // 2, 360
RADIUS = 46

CHIP_COLORS = {"gold": GOLD, "lime": LIME, "head": HEAD, "red": (255, 90, 78),
               "blue": (79, 184, 240), "purple": (180, 124, 255)}


def font(weight, size):
    return ImageFont.truetype(str(ASSETS / "fonts" / f"JetBrainsMono-{weight}.ttf"), size)


def wrap(draw, text, f, width):
    lines, cur = [], ""
    for word in text.split():
        trial = f"{cur} {word}".strip()
        if draw.textlength(trial, font=f) <= width:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    return lines + [cur]


def spaced(draw, xy, text, f, fill, spacing, anchor="lm"):
    x, y = xy
    for ch in text:
        draw.text((x, y), ch, font=f, fill=fill, anchor=anchor)
        x += draw.textlength(ch, font=f) + spacing
    return x


def spaced_width(draw, text, f, spacing):
    return sum(draw.textlength(c, font=f) + spacing for c in text) - spacing


def chip(draw, x, y, label, color, size=28):
    f = font("ExtraBold", size)
    tw = spaced_width(draw, label, f, 5)
    h = size + 26
    draw.rounded_rectangle((x, y, x + tw + 44, y + h), radius=10, fill=color)
    spaced(draw, (x + 22, y + h / 2), label, f, ON_LIME, 5)
    return y + h


def caption_png(i, label, color, title, sub):
    img = Image.new("RGBA", (W, PY - 10), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    y = chip(d, 60, 56, label, CHIP_COLORS.get(color, LIME))
    d.text((58, y + 22), title, font=font("ExtraBold", 64), fill=INK)
    fs = font("Regular", 34)
    for n, line in enumerate(wrap(d, sub, fs, W - 120)[:2]):
        d.text((60, y + 120 + n * 46), line, font=fs, fill=MUTED)
    p = D / f"cap{i}.png"
    img.save(p)
    return p


def grid_bg(img, alpha=18):
    """The game's faint board grid behind everything."""
    d = ImageDraw.Draw(img, "RGBA")
    step = 54
    for x in range(0, W, step):
        d.line([(x, 0), (x, H)], fill=(174, 220, 16, alpha), width=1)
    for y in range(0, H, step):
        d.line([(0, y), (W, y)], fill=(174, 220, 16, alpha), width=1)


def background():
    img = Image.new("RGB", (W, H), BG)
    grid_bg(img)
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((-350, -300, 650, 700), fill=(174, 220, 16, 30))
    gd.ellipse((450, 1300, 1450, 2300), fill=(174, 220, 16, 22))
    glow = glow.filter(ImageFilter.GaussianBlur(120))
    img.paste(glow, (0, 0), glow)
    return img


def phone_assets():
    bg = background()
    # Lime glow + bezel behind the phone.
    halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(halo).rounded_rectangle(
        (PX - 18, PY - 18, PX + PW + 18, PY + PH + 18), radius=RADIUS + 18, fill=(174, 220, 16, 70))
    halo = halo.filter(ImageFilter.GaussianBlur(28))
    bg.paste(halo, (0, 0), halo)
    ImageDraw.Draw(bg).rounded_rectangle(
        (PX - 8, PY - 8, PX + PW + 7, PY + PH + 7), radius=RADIUS + 8, fill=(30, 52, 22))
    bg.save(D / "stage.png")
    mask = Image.new("L", (PW, PH), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, PW - 1, PH - 1), radius=RADIUS, fill=255)
    mask.save(D / "mask.png")


def logo(size):
    return Image.open(ASSETS / "images" / "snake_classic_logo.png").convert("RGBA").resize(
        (size, size), Image.LANCZOS)


def card(name, build):
    img = background()
    d = ImageDraw.Draw(img)
    build(img, d)
    p = D / f"{name}.png"
    img.save(p)
    return p


def centered_spaced(d, y, text, f, fill, spacing):
    w = spaced_width(d, text, f, spacing)
    spaced(d, ((W - w) / 2, y), text, f, fill, spacing)


def intro(img, d):
    lg = logo(360)
    img.paste(lg, ((W - 360) // 2, 520), lg)
    centered_spaced(d, 1010, "SNAKE", font("ExtraBold", 120), INK, 18)
    centered_spaced(d, 1140, "CLASSIC", font("ExtraBold", 120), LIME, 18)
    centered_spaced(d, 1290, "THE ARCADE CLASSIC, REBUILT", font("Bold", 34), MUTED, 6)


def outro(img, d):
    lg = logo(240)
    img.paste(lg, ((W - 240) // 2, 380), lg)
    centered_spaced(d, 720, "SNAKE CLASSIC", font("ExtraBold", 84), INK, 10)
    items = ["8 game modes", "Power-ups & combos", "1v1 online Versus",
             "Daily challenges & seasons"]
    fi = font("Bold", 44)
    y = 880
    for t in items:
        d.rounded_rectangle((150, y, 186, y + 36), radius=6, fill=LIME)
        d.text((220, y + 18), t, font=fi, fill=INK, anchor="lm")
        y += 92
    # Download button
    bw, bh = 640, 130
    bx, by = (W - bw) // 2, 1340
    d.rounded_rectangle((bx, by, bx + bw, by + bh), radius=22, fill=LIME)
    centered_spaced(d, by + bh / 2, "PLAY FREE NOW", font("ExtraBold", 54), ON_LIME, 6)
    centered_spaced(d, 1560, "ON GOOGLE PLAY", font("Bold", 34), MUTED, 8)


def main():
    scenes = json.loads(Path(SCENES).read_text(encoding="utf-8"))["segments"]
    phone_assets()
    caps = [caption_png(i, s["chip"], s.get("color", "lime"), s["title"], s["sub"])
            for i, s in enumerate(scenes)]
    intro_p, outro_p = card("intro", intro), card("outro", outro)

    durs = [s["b"] - s["a"] for s in scenes]
    demo_len = sum(durs)
    total = INTRO + demo_len + OUTRO

    srcs = sorted({s["src"] for s in scenes})
    inputs, idx = [], {}
    for sp in srcs:
        idx[sp] = len(inputs) // 2
        inputs += ["-i", str(D / sp)]
    n_src = len(srcs)
    inputs += ["-loop", "1", "-i", str(D / "stage.png")]           # n_src
    inputs += ["-i", str(D / "mask.png")]                         # n_src+1
    inputs += ["-loop", "1", "-t", str(INTRO), "-i", str(intro_p)]  # +2
    inputs += ["-loop", "1", "-t", str(OUTRO), "-i", str(outro_p)]  # +3
    cap0 = n_src + 4
    for s, p, du in zip(scenes, caps, durs):
        inputs += ["-loop", "1", "-t", f"{du:.3f}", "-i", str(p)]
    music_i = cap0 + len(scenes)
    inputs += ["-stream_loop", "-1", "-i", str(ASSETS / "audio" / "lb" / "music" / "run_loop_140bpm.wav")]

    fc = []
    # Split each source as many times as it is used, trim each segment.
    uses = {sp: [i for i, s in enumerate(scenes) if s["src"] == sp] for sp in srcs}
    for sp, ids in uses.items():
        k = idx[sp]
        outs = "".join(f"[r{i}]" for i in ids)
        fc.append(f"[{k}:v]fps=30,split={len(ids)}{outs}" if len(ids) > 1 else f"[{k}:v]fps=30{outs}")
    for i, s in enumerate(scenes):
        fc.append(f"[r{i}]trim={s['a']}:{s['b']},setpts=PTS-STARTPTS[t{i}]")
    fc.append("".join(f"[t{i}]" for i in range(len(scenes))) + f"concat=n={len(scenes)}:v=1:a=0[rec]")
    fc.append(f"[rec]scale={PW}:{PH}:flags=lanczos,format=rgba[ph]")
    fc.append(f"[{n_src + 1}:v]format=gray[mk]")
    fc.append("[ph][mk]alphamerge[phr]")
    fc.append(f"[{n_src}:v]fps=30,trim=0:{demo_len:.3f},setpts=PTS-STARTPTS[stg]")
    fc.append(f"[stg][phr]overlay={PX}:{PY}:shortest=1[a0]")
    last, t = "a0", 0.0
    for i, du in enumerate(durs):
        fades = f"fade=in:st=0:d={FADE}:alpha=1,fade=out:st={du - FADE:.3f}:d={FADE}:alpha=1"
        fc.append(f"[{cap0 + i}:v]format=rgba,{fades},setpts=PTS-STARTPTS+{t:.3f}/TB[c{i}]")
        fc.append(f"[{last}][c{i}]overlay=0:0:eof_action=pass[b{i}]")
        last, t = f"b{i}", t + du
    fc.append(f"color=c=0xAEDC10:s={W}x8:r=30:d={demo_len:.3f}[bar]")
    fc.append(f"[{last}][bar]overlay=x='-{W}+{W}*t/{demo_len:.3f}':y={H - 8}:shortest=1,"
              f"format=yuv420p,setsar=1[demo]")
    fc.append(f"[{n_src + 2}:v]fps=30,format=yuv420p,fade=in:st=0:d=0.4,fade=out:st={INTRO - 0.35}:d=0.35,setsar=1[in]")
    fc.append(f"[{n_src + 3}:v]fps=30,format=yuv420p,fade=in:st=0:d=0.35,fade=out:st={OUTRO - 0.6}:d=0.6,setsar=1[out]")
    fc.append("[in][demo][out]concat=n=3:v=1:a=0[v]")
    fc.append(f"[{music_i}:a]atrim=0:{total:.3f},asetpts=PTS-STARTPTS,volume=0.8,"
              f"afade=in:st=0:d=0.6,afade=out:st={total - 1.8:.3f}:d=1.8[aud]")

    cmd = [FF, "-hide_banner", "-loglevel", "error", "-y", *inputs, "-filter_complex", ";".join(fc),
           "-map", "[v]", "-map", "[aud]", "-t", f"{total:.2f}", "-c:v", "libx264", "-crf", "19",
           "-preset", "slow", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k",
           "-movflags", "+faststart", OUT]
    subprocess.run(cmd, check=True)
    print("done", round(total, 2))


main()
