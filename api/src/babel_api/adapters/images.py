"""Making a downloaded cover lighter: a poster of a million bytes is slow to show."""

import io

from PIL import Image, UnidentifiedImageError

MAX_WIDTH = 480


def shrink(content: bytes, media_type: str) -> tuple[bytes, str]:
    """The image no wider than [MAX_WIDTH], as a JPEG; as it came when it is not a picture
    Pillow can read."""
    try:
        with Image.open(io.BytesIO(content)) as image:
            image.load()
            if image.width > MAX_WIDTH:
                height = round(image.height * MAX_WIDTH / image.width)
                image = image.resize(  # pyright: ignore[reportUnknownMemberType]
                    (MAX_WIDTH, height), Image.Resampling.LANCZOS
                )
            out = io.BytesIO()
            image.convert("RGB").save(out, "JPEG", quality=84, optimize=True)
            return out.getvalue(), "image/jpeg"
    except (UnidentifiedImageError, OSError, ValueError):
        return content, media_type
