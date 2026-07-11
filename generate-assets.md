# Snake Classic — AI Asset Generation Guide

This file contains ready-to-paste prompts for generating the game's image assets with an
AI image generator (Midjourney, DALL-E, Stable Diffusion, Ideogram, etc.).

## Why these assets are needed

Today the entire game is drawn procedurally (CustomPainter shapes). That causes two problems:

1. **Visibility** — some pickups are nearly invisible on certain themes:
   - Classic theme: food color is *identical* to the snake color (`0xFF9BBD0F`).
   - Invincibility shield (plain blue) disappears on Space / Ocean / Cyberpunk backgrounds.
   - Slow-motion spiral (plain purple) disappears on Cyberpunk / Crystal / Space backgrounds.
   - Score-multiplier coin (plain green) disappears on Forest.
2. **Readability** — procedural shapes at small cell sizes read as "colored blobs". Real
   sprites with strong silhouettes and outlines are instantly recognizable.

All 10 game themes use **dark backgrounds** (`0xFF0F380F` → `0xFF3D1F0E` range), so every
sprite below is designed around one rule: **bright saturated fill + thick dark outline +
thin white/light rim glow**. That combination is visible on every theme without needing
per-theme variants.

---

## Global style guide (prepend to every prompt)

Use this prefix on every generation so the whole set looks like one family:

> Flat 2D mobile game sprite, clean vector style, bold shapes, thick dark navy outline
> (#1A1A2E, roughly 5% of image width), subtle top-left inner highlight, faint outer glow,
> vibrant saturated colors, centered composition, subject fills ~80% of canvas,
> transparent background, no text, no watermark, no drop shadow on the canvas.

**Technical requirements for every asset:**

| Property | Value |
|---|---|
| Format | PNG with alpha transparency |
| Canvas size | 512×512 px (game renders them anywhere from 32–96 px, so test readability by zooming out) |
| Background | Fully transparent — reject any generation with a baked-in background |
| Silhouette | Must be recognizable at 40×40 px — squint test! |
| Outline | Dark navy `#1A1A2E`, thick and uniform |
| Rim light | Thin white/very light edge highlight inside the outline (this is what guarantees visibility on dark themes) |
| Orientation | Upright, facing the viewer (the game rotates/pulses sprites at runtime) |

**Do NOT generate animation frames.** The game animates at runtime (pulse, rotate, bob,
glow). One clean static frame per asset is all we need.

**Destination folders** (add to `pubspec.yaml` under `assets:` after generating):

```
assets/images/food/
assets/images/powerups/
assets/images/effects/
```

---

## 1. Food sprites → `assets/images/food/`

### 1.1 `food_apple.png` — Normal food (10 pts)

> [style prefix] A glossy red apple game pickup, bright cherry red (#FF3B3B) body with a
> lighter red (#FF6B6B) top-left highlight, short brown (#8B4513) stem, single small
> leaf in bright green (#4CAF50), round friendly shape.

- **Key colors:** body `#FF3B3B`, highlight `#FF6B6B`, stem `#8B4513`, leaf `#4CAF50`
- **Why red:** no theme uses a red-family background, so it pops everywhere (replaces the
  current theme-tinted food that blends in on Classic).

### 1.2 `food_golden.png` — Bonus food (25 pts)

> [style prefix] A golden glowing fruit game pickup, rich gold (#FFD700) round berry with
> orange (#FF9800) undertone at the bottom, three tiny white four-pointed sparkles
> floating around it, warm yellow (#FFF3B0) rim glow, looks precious and valuable.

- **Key colors:** body `#FFD700`, undertone `#FF9800`, sparkles `#FFFFFF`, glow `#FFF3B0`
- **Reads as:** "worth more than the apple" at a glance.

### 1.3 `food_star.png` — Special food (50 pts)

> [style prefix] A radiant crystal star game pickup, five-pointed star with faceted
> gem-like surface, gradient from hot magenta (#FF2D95) at the top to bright cyan
> (#00E5FF) at the bottom, tiny white specular sparkles on two facets, thin white rim
> glow, looks rare and magical.

- **Key colors:** magenta `#FF2D95`, cyan `#00E5FF`, sparkle `#FFFFFF`
- **Why magenta→cyan:** this two-tone pair is distinguishable on every one of the 10
  backgrounds, including Crystal purple and Space navy.

---

## 2. Power-up sprites → `assets/images/powerups/`

Power-ups must read as "items", not food — every sprite below sits inside a **badge/token
shape** so players learn "round token = power-up" instantly.

### 2.1 `powerup_speed.png` — Speed boost

> [style prefix] A round game power-up token, dark navy (#16213E) circular badge with a
> bold lightning bolt in the center, bolt is bright golden yellow (#FFD600) with a white
> (#FFFFFF) hot core stripe, thin electric yellow rim around the badge, energetic and fast
> feeling.

- **Key colors:** badge `#16213E`, bolt `#FFD600`, core `#FFFFFF`

### 2.2 `powerup_shield.png` — Invincibility

> [style prefix] A round game power-up token, dark navy (#16213E) circular badge with a
> bold knight's shield in the center, shield is bright cyan (#00E5FF) with a white
> (#FFFFFF) chevron stripe across the middle and a thin gold (#FFD700) trim border,
> protective and solid feeling.

- **Key colors:** badge `#16213E`, shield `#00E5FF`, chevron `#FFFFFF`, trim `#FFD700`
- **Replaces:** plain blue shield (invisible on Space/Ocean/Cyberpunk). Cyan + gold trim
  survives every blue-family background.

### 2.3 `powerup_coin.png` — Score multiplier

> [style prefix] A round game power-up token, a shiny gold (#FFD700) coin with a bold
> "×2" embossed in dark navy (#1A1A2E) in the center, lighter gold (#FFF0A0) crescent
> highlight on the top-left edge, thin white rim light, valuable and rewarding feeling.

- **Key colors:** coin `#FFD700`, emboss `#1A1A2E`, highlight `#FFF0A0`
- **Note:** "×2" replaces the current "$" — clearer meaning, no currency confusion.

### 2.4 `powerup_slow.png` — Slow motion

> [style prefix] A round game power-up token, dark navy (#16213E) circular badge with a
> bold hourglass in the center, hourglass frame in soft lavender (#C77DFF), sand inside
> in bright magenta-pink (#FF6EC7), small white sparkle on the glass, calm dreamy feeling.

- **Key colors:** badge `#16213E`, frame `#C77DFF`, sand `#FF6EC7`
- **Replaces:** the purple spiral (invisible on Cyberpunk/Crystal). Hourglass is also a
  much clearer "time" metaphor than a spiral/snail.

---

## 3. Effect sprites → `assets/images/effects/`

These are small reusable particles/flourishes that make eating and crashing feel juicy.
They get tinted at runtime, so generate them **white/neutral**.

### 3.1 `sparkle.png` — Generic sparkle particle

> Flat 2D game particle sprite, a single four-pointed star sparkle, pure white (#FFFFFF)
> with a soft transparent glow falloff at the tips, centered, transparent background,
> 512×512, no outline, no text.

- **Usage:** eat bursts, special-food ambience, score popups. Tinted per theme at runtime,
  so it must be pure white.

### 3.2 `glow_dot.png` — Soft glow orb

> Flat 2D game particle sprite, a soft round white (#FFFFFF) orb with a smooth radial
> fade to fully transparent at the edges, like a bokeh light, centered, transparent
> background, 512×512, no outline, no text.

- **Usage:** trail particles, power-up auras, death poofs. Also tinted at runtime.

### 3.3 `impact_star.png` — Crash impact flash

> Flat 2D game effect sprite, a comic-style impact burst, jagged eight-pointed starburst,
> white (#FFFFFF) center flaring into bright orange (#FF9800) then red (#FF3B3B) at the
> jagged tips, thin dark navy (#1A1A2E) outline, high energy collision feeling, centered,
> transparent background, 512×512, no text.

- **Usage:** the frame shown at the crash cell on wall/self collision, scaled + faded out.

---

## 4. Nice-to-have (optional, generate if the first batch goes well)

### 4.1 `food_shadow.png` — Contact shadow blob

> Flat 2D game sprite, a soft black (#000000) ellipse with heavy blur fading to
> transparent at the edges, wider than tall, centered in the lower half of the canvas,
> transparent background, 512×512.

- **Usage:** placed under food/power-ups so they read as "sitting on the board" instead
  of floating — big depth win for almost no cost.

### 4.2 `crown.png` — New high score badge

> [style prefix] A small royal crown game icon, bright gold (#FFD700) with three points,
> ruby red (#FF3B3B) gem in the center, white sparkle on the left point, celebratory.

- **Usage:** high-score celebration UI and leaderboard rows.

---

## Generation & QA checklist

1. Generate at least 4 candidates per asset, pick the cleanest silhouette.
2. **Squint test:** shrink to 40×40 px — if you can't name the object instantly, regenerate.
3. **Theme test:** place each PNG over these hex swatches (the darkest/most conflicting
   backgrounds) and confirm it's clearly visible on all of them:
   `#0F380F` (classic) · `#0B0C2A` (space) · `#0D0221` (cyberpunk) · `#1A0033` (crystal) · `#3D1F0E` (desert)
4. Remove any baked-in background/halo with a background remover if the generator adds one.
5. Export as 512×512 PNG, name exactly as listed above, drop into the destination folder.
6. Add the three folders to `pubspec.yaml` under `flutter: assets:`.
