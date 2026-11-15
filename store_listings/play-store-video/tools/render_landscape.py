"""Snake Classic Play Store promo video, LANDSCAPE 1920x1080.

Big captions on the left, the phone recording on the right. Same scenes.json
as render.py. Usage: python render_landscape.py <ffmpeg.exe> <scenes.json> <out.mp4>
"""

import json
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

D = Path(__file__).parent
ASSETS = Path(r"G:\Personal\MyProjects\snake-classic\snake_classic\assets")
FF, SCENES, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
W, H = 1920, 1080
BG = (8, 22, 11)
LIME = (174, 220, 16)
HEAD = (212, 242, 90)
INK = (233, 245, 200)
GOLD = (245, 197, 24)
MUTED = (159, 184, 160)
ON_LIME = (8, 22, 11)

INTRO, OUTRO, FADE = 3.0, 4.5, 0.3

# Phone on the right
PH = 980
PW = round(PH * 1080 / 2340 / 2) * 2
PX, PY = 1250, (H - PH) // 2
RADIUS = 38
CAP_X, CAP_W = 150, 960  # caption column on the left

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


def chip(draw, x, y, label, color, size=34):
    f = font("ExtraBold", size)
    tw = spaced_width(draw, label, f, 6)
    h = size + 30
    draw.rounded_rectangle((x, y, x + tw + 52, y + h), radius=12, fill=color)
    spaced(draw, (x + 26, y + h / 2), label, f, ON_LIME, 6)
    return y + h


def caption_png(i, label, color, title, sub):
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    ft, fs = font("ExtraBold", 84), font("Regular", 44)
    tlines = wrap(d, title, ft, CAP_W)
    slines = wrap(d, sub, fs, CAP_W - 40)[:3]
    block = 64 + 40 + len(tlines) * 100 + 30 + len(slines) * 60
    y = (H - block) // 2
    y = chip(d, CAP_X, y, label, CHIP_COLORS.get(color, LIME)) + 40
    for line in tlines:
        d.text((CAP_X - 4, y), line, font=ft, fill=INK)
        y += 100
    y += 30
    for line in slines:
        d.text((CAP_X, y), line, font=fs, fill=MUTED)
        y += 60
    p = D / f"lcap{i}.png"
    img.save(p)
    return p


def grid_bg(img, alpha=18):
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
    gd.ellipse((-400, -400, 700, 600), fill=(174, 220, 16, 30))
    gd.ellipse((1100, 300, 2300, 1500), fill=(174, 220, 16, 26))
    glow = glow.filter(ImageFilter.GaussianBlur(140))
    img.paste(glow, (0, 0), glow)
    return img


def phone_assets():
    bg = background()
    halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(halo).rounded_rectangle(
        (PX - 16, PY - 16, PX + PW + 16, PY + PH + 16), radius=RADIUS + 16, fill=(174, 220, 16, 70))
    halo = halo.filter(ImageFilter.GaussianBlur(26))
    bg.paste(halo, (0, 0), halo)
    ImageDraw.Draw(bg).rounded_rectangle(
        (PX - 7, PY - 7, PX + PW + 6, PY + PH + 6), radius=RADIUS + 7, fill=(30, 52, 22))
    bg.save(D / "lstage.png")
    mask = Image.new("L", (PW, PH), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, PW - 1, PH - 1), radius=RADIUS, fill=255)
    mask.save(D / "lmask.png")


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


def centered_spaced(d, cx, y, text, f, fill, spacing):
    w = spaced_width(d, text, f, spacing)
    spaced(d, (cx - w / 2, y), text, f, fill, spacing)


def intro(img, d):
    lg = logo(300)
    img.paste(lg, ((W - 300) // 2, 230), lg)
    fb = font("ExtraBold", 120)
    wa = spaced_width(d, "SNAKE ", fb, 16)
    wb = spaced_width(d, "CLASSIC", fb, 16)
    x0 = (W - wa - wb) / 2
    spaced(d, (x0, 660), "SNAKE ", fb, INK, 16)
    spaced(d, (x0 + wa, 660), "CLASSIC", fb, LIME, 16)
    centered_spaced(d, W / 2, 800, "THE ARCADE CLASSIC, REBUILT", font("Bold", 38), MUTED, 7)


def outro(img, d):
    lg = logo(220)
    img.paste(lg, (180, 170), lg)
    spaced(d, (430, 230), "SNAKE", font("ExtraBold", 92), INK, 12)
    spaced(d, (430, 340), "CLASSIC", font("ExtraBold", 92), LIME, 12)
    items = ["8 game modes", "Power-ups & combos", "1v1 online Versus",
             "Daily challenges & seasons"]
    fi = font("Bold", 50)
    y = 520
    for t in items:
        d.rounded_rectangle((190, y, 228, y + 38), radius=7, fill=LIME)
        d.text((265, y + 19), t, font=fi, fill=INK, anchor="lm")
        y += 95
    bw, bh = 640, 150
    bx, by = 1130, 400
    d.rounded_rectangle((bx, by, bx + bw, by + bh), radius=24, fill=LIME)
    centered_spaced(d, bx + bw / 2, by + bh / 2, "PLAY FREE NOW", font("ExtraBold", 58), ON_LIME, 6)
    centered_spaced(d, bx + bw / 2, by + bh + 70, "ON GOOGLE PLAY", font("Bold", 38), MUTED, 9)


def main():
    scenes = json.loads(Path(SCENES).read_text(encoding="utf-8"))["segments"]
    phone_assets()
    caps = [caption_png(i, s["chip"], s.get("color", "lime"), s["title"], s["sub"])
            for i, s in enumerate(scenes)]
    intro_p, outro_p = card("lintro", intro), card("loutro", outro)

    durs = [s["b"] - s["a"] for s in scenes]
    demo_len = sum(durs)
    total = INTRO + demo_len + OUTRO

    srcs = sorted({s["src"] for s in scenes})
    inputs, idx = [], {}
    for sp in srcs:
        idx[sp] = len(inputs) // 2
        inputs += ["-i", str(D / sp)]
    n_src = len(srcs)
    inputs += ["-loop", "1", "-i", str(D / "lstage.png")]
    inputs += ["-i", str(D / "lmask.png")]
    inputs += ["-loop", "1", "-t", str(INTRO), "-i", str(intro_p)]
    inputs += ["-loop", "1", "-t", str(OUTRO), "-i", str(outro_p)]
    cap0 = n_src + 4
    for p, du in zip(caps, durs):
        inputs += ["-loop", "1", "-t", f"{du:.3f}", "-i", str(p)]
    music_i = cap0 + len(scenes)
    inputs += ["-stream_loop", "-1", "-i", str(ASSETS / "audio" / "lb" / "music" / "run_loop_140bpm.wav")]

    fc = []
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
    fc.append(f"[{n_src + 2}:v]fps=30,format=yuv420p,fade=in:st=0:d=0.35,fade=out:st={INTRO - 0.35}:d=0.35,setsar=1[in]")
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
