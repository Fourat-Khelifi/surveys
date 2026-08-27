"""Renders the full "Surveys." wordmark with a transparent background.

    python tool/make_wordmark.py

Writes assets/wordmark.png (1920x480 by default), matching the splash screen:
the warm-black "Surveys" in Fraunces with the tangerine full stop.

Generated from the same font/weight/axes the in-app AppWordmark uses, so the
exported image and the rendered text cannot drift apart.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT = ROOT / "fonts" / "Fraunces-VariableFont_wght.ttf"
OUT = ROOT / "assets"

WIDTH, HEIGHT = 1920, 480

# Matches the wordmark in the splash / auth screens.
INK = (11, 11, 11)          # AppColors.textPrimary (near-black)
ACCENT = (239, 123, 69)     # AppColors.accent

# Fraunces axes: Optical Size, Weight, Softness, Wonky.
# Same as the app icon — optical size at its display end, wonky off.
AXES = [144, 600, 0, 0]
WEIGHT = 600

TEXT = "Surveys."


def load_font(px: int) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(str(FONT), px)
    font.set_variation_by_axes(AXES)
    return font


def main() -> None:
    # Binary-search a pixel size so the wordmark fills ~70% of the canvas width.
    coverage = 0.70
    target = WIDTH * coverage
    px = HEIGHT
    for _ in range(40):
        font = load_font(int(px))
        left, top, right, bottom = font.getbbox(TEXT)
        width = right - left
        if abs(width - target) < 2:
            break
        px *= target / max(width, 1)

    font = load_font(int(px))
    left, top, right, bottom = font.getbbox(TEXT)

    img = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Centre on the ink bounding box so the glyphs don't sit high/low.
    x = (WIDTH - (right - left)) / 2 - left
    y = (HEIGHT - (bottom - top)) / 2 - top

    # Draw "Surveys" in ink and "." in accent, offset by the font's own advance
    # for "Surveys" so the spacing matches the live wordmark.
    body = "Surveys"
    draw.text((x, y), body, font=font, fill=INK)
    dot_x = x + font.getlength(body)
    draw.text((dot_x, y), ".", font=font, fill=ACCENT)

    path = OUT / "wordmark.png"
    img.save(path)
    print(f"  {path.name:<22} {img.size}  {path.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
