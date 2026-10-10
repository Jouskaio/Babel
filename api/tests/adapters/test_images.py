import io

from PIL import Image

from babel_api.adapters.images import MAX_WIDTH, shrink


def test_a_big_picture_becomes_a_light_jpeg() -> None:
    big = io.BytesIO()
    Image.new("RGBA", (1600, 2400), (200, 30, 30, 255)).save(big, "PNG")
    content, media_type = shrink(big.getvalue(), "image/png")
    assert media_type == "image/jpeg"
    assert len(content) < len(big.getvalue())
    assert Image.open(io.BytesIO(content)).size == (MAX_WIDTH, 720)
    assert shrink(b"not an image", "image/png") == (b"not an image", "image/png")
