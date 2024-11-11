#!/usr/bin/env python3

from openslide import open_slide
import os
import sys

image_param = sys.argv[1]
# Extract the base name (filename without extension)
base_name = os.path.splitext(os.path.basename(image_param))[0]

slide_in = open_slide(image_param)
slide_label = slide_in.associated_images["label"]


# Save with the base name as part of the filename
slide_label.save(f"labelled_{base_name}.png", "PNG")
