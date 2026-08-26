"""Renders the app icon from the same font the wordmark uses.

    python tool/make_icon.py

Writes 1024x1024 PNGs into assets/icon/:
  icon.png             full-bleed, for iOS/web and the legacy Android icon
  icon_foreground.png  transparent, for the Android adaptive foreground layer

Generated rather than drawn by hand so the icon and the in-app wordmark can
never drift apart — both come from fonts/Fraunces-VariableFont_wght.ttf at the
same weight, with the same accent colour on the full stop.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT = ROOT / "fonts" / "Fraunces-VariableFont_wght.ttf"
OUT = ROOT / "assets" / "icon"

SIZE = 1024

# Straight from lib/core/constants/colors.dart
BACKGROUND = (245, 243, 241)          # AppColors.authBackground
INK = (11, 11, 11)                    # near-black, matches the wordmark
ACCENT = (239, 123, 69)               # AppColors.atomictangerine

# Fraunces axes: Optical Size, Weight, Softness, Wonky.
# Optical size at its display end (144) gives the higher-contrast, tighter
# letterform the face is designed to show large — which is what an icon is.
# Wonky off: its slanted terminals read as a rendering fault at 48dp.
AXES = [144, 600, 0, 0]


def load_font(px: int) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(str(FONT), px)
    font.set_variation_by_axes(AXES)
    return font


def draw_mark(canvas_size: int, coverage: float, background) -> Image.Image:
    """Draws "S." centred, scaled so it covers `coverage` of the canvas width."""
    img = Image.new("RGBA", (canvas_size, canvas_size), background)
    draw = ImageDraw.Draw(img)

    # Find the pixel size that makes the mark the requested share of the canvas.
    # Measuring rather than guessing keeps this correct if the axes change.
    target = canvas_size * coverage
    px = canvas_size
    for _ in range(40):
        font = load_font(int(px))
        left, top, right, bottom = draw.textbbox((0, 0), "S.", font=font)
        width = right - left
        if abs(width - target) < 2:
            break
        px *= target / max(width, 1)

    font = load_font(int(px))
    left, top, right, bottom = draw.textbbox((0, 0), "S.", font=font)

    # Centre on the ink bounding box, not the font's line box — otherwise the
    # glyph sits high, because the line box reserves room for descenders that
    # "S." does not use.
    x = (canvas_size - (right - left)) / 2 - left
    y = (canvas_size - (bottom - top)) / 2 - top

    # Draw the two glyphs separately so the stop can take the accent colour,
    # offsetting by the font's own advance width for "S" rather than a guessed
    # gap — that advance is exactly the spacing the designer intended.
    draw.text((x, y), "S", font=font, fill=INK)
    draw.text((x + font.getlength("S"), y), ".", font=font, fill=ACCENT)
    return img


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    # Full-bleed: the mark can be generous because nothing crops it.
    full = draw_mark(SIZE, coverage=0.56, background=BACKGROUND + (255,))
    full.convert("RGB").save(OUT / "icon.png")

    # Adaptive foreground: Android crops to a circle/squircle and only the
    # middle ~66% is guaranteed visible, so the mark has to sit well inside.
    fg = draw_mark(SIZE, coverage=0.38, background=(0, 0, 0, 0))
    fg.save(OUT / "icon_foreground.png")

    for name in ("icon.png", "icon_foreground.png"):
        path = OUT / name
        print(f"  {name:<22} {Image.open(path).size}  {path.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
