"""Snake Classic App Store screenshots (6.5" iPhone, 1284 x 2778).

Python port of the Claude Design generator `gen_store_shots.js` (kept in the
owner's design artifact, see docs/APP_STORE_GROWTH.md). Same layout: dark
grid background, brand row, pixel-cell headline (lime, one line gold),
subtitle, and the raw capture inside a rounded device frame.

    pip install pillow
    python tools/store_shots/gen_store_shots.py tools/store_shots/jobs_ppo_2026_11.json

Paths in the jobs file are relative to that file. Each job:
    {src, out, head: [line, ...], sub, accent?: line index in gold,
     crop_top?, crop_bottom?, ios_status_bar?: true}

Android captures: crop_top/crop_bottom remove the Android status/gesture bars
and ios_status_bar draws an iPhone-style one (App Store screenshots must not
show another platform's UI). iOS simulator captures already have a real
status bar: set ios_status_bar false and crop nothing.

Headline glyphs: A-Z (no J or Q), 0-9 and ! . ? - / and space only.
"""
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
FONTS = os.path.join(ROOT, 'assets', 'fonts')
ICON = os.path.join(ROOT, 'assets', 'icon', 'ios_icon.png')

G = {'A':['111','101','111','101','101'],'B':['110','101','110','101','110'],'C':['111','100','100','100','111'],'D':['110','101','101','101','110'],'E':['111','100','111','100','111'],'F':['111','100','111','100','100'],'G':['111','100','101','101','111'],'H':['101','101','111','101','101'],'I':['111','010','010','010','111'],'K':['101','101','110','101','101'],'L':['100','100','100','100','111'],'M':['10001','11011','10101','10001','10001'],'N':['1001','1101','1011','1001','1001'],'O':['111','101','101','101','111'],'P':['111','101','111','100','100'],'R':['111','101','110','101','101'],'S':['111','100','111','001','111'],'T':['111','010','010','010','010'],'U':['101','101','101','101','111'],'V':['101','101','101','101','010'],'W':['10001','10001','10101','11011','10001'],'X':['101','101','010','101','101'],'Y':['101','101','111','010','010'],'Z':['111','001','010','100','111'],'0':['111','101','101','101','111'],'1':['010','110','010','010','111'],'2':['111','001','111','100','111'],'3':['111','001','111','001','111'],'4':['101','101','111','001','001'],'5':['111','100','111','001','111'],'6':['111','100','111','101','111'],'7':['111','001','001','001','001'],'8':['111','101','111','101','111'],'9':['111','101','111','001','111'],'!':['1','1','1','0','1'],'.':['0','0','0','0','1'],'?':['111','001','011','000','010'],' ':['0','0','0','0','0'],'-':['000','000','111','000','000'],'/':['001','001','010','100','100']}

LIME = (174, 220, 16)
GOLD = (245, 197, 24)
W, H = 1284, 2778
# Google Play: the listing takes up to 2:1, but store listing EXPERIMENTS only
# take 16:9 / 9:16. STORE_SHOT_PLAY=1 lays the same design out on a 9:16
# canvas (1284 x 2283; the phone mock runs off the bottom edge) and saves it at
# 1080 x 1920, which both accept.
PLAY = os.environ.get('STORE_SHOT_PLAY') == '1'
if PLAY:
    H = round(W * 16 / 9)


def font(name, size):
    return ImageFont.truetype(os.path.join(FONTS, name), size)


def cols(s):
    return sum(len(G.get(ch, G[' '])[0]) + (1 if i else 0) for i, ch in enumerate(s))


def cell_text(base, s, cx, y, cell, color):
    """Pixel-cell headline with a soft glow, centred on cx."""
    layer = Image.new('RGBA', base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    x = cx - cols(s) * cell / 2 + cell * .06
    for i, ch in enumerate(s):
        g = G.get(ch, G[' '])
        if i:
            x += cell
        for r, row in enumerate(g):
            for c, v in enumerate(row):
                if v == '1':
                    x0, y0 = x + c * cell, y + r * cell
                    d.rounded_rectangle([x0, y0, x0 + cell * .88, y0 + cell * .88], radius=cell * .2, fill=color + (255,))
        x += len(g[0]) * cell
    glow = layer.filter(ImageFilter.GaussianBlur(cell * .45))
    gl = Image.new('RGBA', base.size, color + (0,))
    gl.putalpha(glow.getchannel('A').point(lambda a: int(a * .6)))
    base.alpha_composite(gl)
    base.alpha_composite(layer)


def ios_status_bar(scr, w):
    """iPhone-style status bar (9:41, Dynamic Island, signal, wifi, battery)."""
    bar_h = int(w * .125)
    d = ImageDraw.Draw(scr)
    bg = scr.getpixel((w // 2, bar_h + 4))
    d.rectangle([0, 0, w, bar_h], fill=bg)
    d.text((w * .14, bar_h * .52), "9:41", font=font('JetBrainsMono-Bold.ttf', int(w * .045)), fill=(255, 255, 255), anchor='lm')
    iw, ih = w * .3, w * .085
    d.rounded_rectangle([(w - iw) / 2, bar_h * .52 - ih / 2, (w + iw) / 2, bar_h * .52 + ih / 2], radius=ih / 2, fill=(0, 0, 0))
    bx, by, u = w * .71, bar_h * .52, w * .009
    for i in range(4):
        hh = u * (1.6 + i * .9)
        d.rounded_rectangle([bx + i * u * 1.7, by + u * 2.2 - hh, bx + i * u * 1.7 + u * 1.1, by + u * 2.2], radius=u * .3, fill=(255, 255, 255))
    wx, wy = w * .8, by + u * 2.2
    for i, rr in enumerate((u * 4.2, u * 2.8, u * 1.4)):
        d.pieslice([wx - rr, wy - rr, wx + rr, wy + rr], 225, 315, fill=(255, 255, 255) if i % 2 == 0 else bg)
    d.pieslice([wx - u * .7, wy - u * .7, wx + u * .7, wy + u * .7], 225, 315, fill=(255, 255, 255))
    x0, y0 = w * .845, by - u * 1.5
    d.rounded_rectangle([x0, y0, x0 + u * 5.4, y0 + u * 3], radius=u * .8, outline=(255, 255, 255), width=max(2, int(u * .3)))
    d.rounded_rectangle([x0 + u * .55, y0 + u * .55, x0 + u * 4.85, y0 + u * 2.45], radius=u * .4, fill=(255, 255, 255))
    d.rounded_rectangle([x0 + u * 5.6, y0 + u * 1, x0 + u * 6.1, y0 + u * 2], radius=u * .2, fill=(255, 255, 255))
    return scr


def render(j, base_dir):
    cv = Image.new('RGBA', (W, H), (8, 22, 11, 255))
    # Translucent strokes go on an overlay and are blended in; drawing them
    # straight onto the canvas replaces pixels instead of blending.
    grid = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(grid)
    for x in range(0, W + 1, 42):
        gd.line([(x, 0), (x, H)], fill=(174, 220, 16, 18), width=2)
    for y in range(0, H + 1, 42):
        gd.line([(0, y), (W, y)], fill=(174, 220, 16, 18), width=2)
    cv.alpha_composite(grid)

    raw = Image.open(os.path.join(base_dir, j['src'])).convert('RGBA')
    raw = raw.crop((0, j.get('crop_top', 0), raw.width, raw.height - j.get('crop_bottom', 0)))
    if j.get('ios_status_bar', True):
        pad = int(raw.width * .125)
        scr = Image.new('RGBA', (raw.width, raw.height + pad), raw.getpixel((raw.width // 2, 2)))
        scr.paste(raw, (0, pad))
        scr = ios_status_bar(scr, raw.width)
    else:
        scr = raw

    devW, scrW = 1040, 1040 - 34
    scrH = int(scrW * scr.height / scr.width)
    bez = (devW - scrW) // 2
    devX = (W - devW) // 2

    glow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([W * .5 - W * .7, 900, W * .5 + W * .7, 2300], fill=(174, 220, 16, 50))
    cv.alpha_composite(glow.filter(ImageFilter.GaussianBlur(260)))

    # brand row
    icon = Image.open(ICON).convert('RGBA').resize((72, 72), Image.LANCZOS)
    mask = Image.new('L', (72, 72), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, 72, 72], radius=16, fill=255)
    bf = font('JetBrainsMono-ExtraBold.ttf', 32)
    label, sp = 'SNAKE CLASSIC', 32 * .22
    lw = sum(bf.getlength(c) for c in label) + sp * (len(label) - 1)
    bx, by = (W - (72 + 18 + lw)) / 2, 80
    cv.paste(icon, (int(bx), by), mask)
    d = ImageDraw.Draw(cv)
    x = bx + 72 + 18
    for c in label:
        d.text((x, by + 36), c, font=bf, fill=LIME, anchor='lm')
        x += bf.getlength(c) + sp

    # headline + subtitle
    cell = min(26, (W - 140) / max(cols(l) for l in j['head']))
    hy = 210
    for i, line in enumerate(j['head']):
        cell_text(cv, line, W / 2, hy, cell, GOLD if i == j.get('accent', -1) else LIME)
        hy += cell * 6.2
    d = ImageDraw.Draw(cv)
    d.text((W / 2, hy + 18), j['sub'], font=font('JetBrainsMono-SemiBold.ttf', 40), fill=(220, 234, 190), anchor='ma')
    devY = int(hy + 120)

    # device: shadow, body, rim, screen
    sh = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([devX, devY + 24, devX + devW, devY + scrH + bez * 2 + 24], radius=84, fill=(0, 0, 0, 150))
    cv.alpha_composite(sh.filter(ImageFilter.GaussianBlur(30)))
    d = ImageDraw.Draw(cv)
    d.rounded_rectangle([devX, devY, devX + devW, devY + scrH + bez * 2], radius=84, fill=(18, 19, 17, 255), outline=(72, 96, 20), width=3)
    s = scr.resize((scrW, scrH), Image.LANCZOS)
    smask = Image.new('L', s.size, 0)
    ImageDraw.Draw(smask).rounded_rectangle([0, 0, scrW, scrH], radius=68, fill=255)
    cv.paste(s, (devX + bez, devY + bez), smask)

    out = os.path.join(base_dir, j['out'])
    os.makedirs(os.path.dirname(out), exist_ok=True)
    img = cv.convert('RGB')
    if PLAY:
        img = img.resize((1080, 1920), Image.LANCZOS)
    img.save(out, 'PNG', optimize=True)
    print('wrote', out)


if __name__ == '__main__':
    jobs_path = os.path.abspath(sys.argv[1])
    base = os.path.dirname(jobs_path)
    for job in json.load(open(jobs_path, encoding='utf-8')):
        render(job, base)
