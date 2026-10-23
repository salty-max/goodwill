# Goodwill artwork

Generated with the built-in image_gen tool on 23 October 2026, matching the
family's painted inventory-item style. The exact prompt and consulted style
references are in [logo-prompts.json](logo-prompts.json).

- `logo-master.png`: original generated master, 1254px square.
- `logo-1024.png`: 1024px square for store and project artwork.
- `logo.png`: 512px square for general use.
- `medallion.png`, `../addon/Goodwill/Media/Medallion.tga`: the logo's
  medallion cut round from the master on its gold rim (centre 502, 436 and
  radius 404 of 1024, a soft round edge, the ribbons and the navy left out),
  128px, the TGA uncompressed 32-bit with a top-left origin as Logo.tga:
  `ns.ICON`, every round picture (the window's portrait, the pages' and
  cards' pictures, the banners, the minimap button, the welcome's portrait).
- `../addon/Goodwill/Media/Logo.tga`: uncompressed 256px RGBA game texture,
  with rounded corners (radius 34), used by the addon listing and `ns.LOGO` (the welcome page's logo).

The PNGs keep the opaque navy square. Resize from the master for future
exports. ImageMagick produces the smaller files and the game texture.
The TGA mask is a white `roundrectangle 0,0 255,255 34,34` on black.
Disable the mask's alpha before compositing with CopyOpacity, so its
grayscale values supply the opacity. Verify transparent corners and an
opaque centre after exporting.

The mark is an emerald medallion with a gold handshake, laurel and ribbon.
