# SLINC

**SLINC: Slide Lable Image Name Conversion**  is a Nextflow-based pipeline designed to rename histology slide .svs files based on the contained label. It processes whole-slide images by extracting labels, cropping specific regions, performing OCR (Optical Character Recognition), and renaming the original SVS files based on extracted text. It’s ideal for projects needing automated image annotation and text recognition workflows.

This script was initially developed for a specific use case by a novice Nextflow user; suggestions for improvements are always welcome!

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Pipeline Steps](#pipeline-steps)
- [Examples](#examples)

## Installation

To use **SLINC**, clone this repository and ensure you have [Nextflow](https://www.nextflow.io/) and [Docker](https://www.docker.com) installed.

```bash
git clone https://github.com/mdrnao/SLINC.git
cd SLINC
# Additional installation steps if needed, e.g., dependencies or environment setup
docker build --platform="linux/amd64" -t slinc_docker .
```

## Usage

The main workflow is managed by the `main.nf` Nextflow script. To run the SLINC pipeline, use the following command:

```bash
nextflow run main.nf -ansi-log false --image_dir <path_to_image_directory>
```

### Parameters
- `--image_dir`: Path to the directory containing the input images.

## Pipeline Steps

The **SLINC** pipeline consists of several processes:

1. **EXTRACT_LABEL**: 
   - Extracts labels from whole-slide images.
   - Input: An SVS image.
   - Output: A labeled PNG image saved with the prefix `labelled_`.

2. **CROP**:
   - Crops specific regions from the labeled images.
   - Uses `magick` to apply image processing options such as deskew, morphology, and level adjustments.
   - Output: Cropped PNG files, saved to the `results/label_images` directory.

3. **OCR**:
   - Applies OCR to the cropped images to extract text.
   - Utilizes Tesseract OCR with custom parameters to whitelist/blacklist certain characters.
   - Output: Text files with extracted labels, saved in the `results/renamed` directory.

4. **RENAME**:
   - Renames the original SVS files based on extracted OCR labels.
   - Processes the text to replace certain characters, forming a valid filename, and renames the SVS file accordingly.
   - Output: Renamed SVS files saved in the `results/renamed_svs` directory.

## Examples

Here’s an example command to run SLINC with a specified input directory:

```bash
nextflow run main.nf --image_dir data/whole_slide_images
```

