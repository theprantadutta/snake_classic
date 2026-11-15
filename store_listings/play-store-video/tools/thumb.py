from PIL import Image, ImageDraw, ImageFilter

SRC = r"G:\Personal\MyProjects\snake-classic\snake_classic\marketing\feature_graphic.png"
OUT = r"G:\Personal\MyProjects\snake-classic\snake_classic\store_listings\play-store-video\youtube-thumbnail-1280x720.png"
W, H = 1280, 720
FEATHER = 70

src = Image.open(SRC).convert("RGB")
scaled = src.resize((W, round(src.height * W / src.width)), Image.LANCZOS)  # 1280x625
top = (H - scaled.height) // 2

# Base: the art's own colours, blurred and stretched, so the glows continue.
base = scaled.filter(ImageFilter.GaussianBlur(80)).resize((W, H), Image.LANCZOS)
base = Image.blend(base, Image.new("RGB", (W, H), (8, 22, 11)), 0.35)

# The board grid: 20 px in the source = 25 px here, aligned with the art.
grid = Image.new("RGBA", (W, H), (0, 0, 0, 0))
g = ImageDraw.Draw(grid)
step = 25
for x in range(0, W, step):
    g.line([(x, 0), (x, H)], fill=(174, 220, 16, 22), width=1)
for y in range(top % step, H, step):
    g.line([(0, y), (W, y)], fill=(174, 220, 16, 22), width=1)
base = Image.alpha_composite(base.convert("RGBA"), grid)

# Art on top, faded into the background at its top and bottom edges.
mask = Image.new("L", scaled.size, 255)
md = ImageDraw.Draw(mask)
for i in range(FEATHER):
    a = round(255 * (i / FEATHER) ** 1.4)
    md.line([(0, i), (W, i)], fill=a)
    md.line([(0, scaled.height - 1 - i), (W, scaled.height - 1 - i)], fill=a)
base.paste(scaled, (0, top), mask)
base.convert("RGB").save(OUT, optimize=True)
print(base.size)
