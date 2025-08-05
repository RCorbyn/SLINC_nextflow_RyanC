# -*- coding: utf-8 -*-
"""
Created on Fri Jul 25 15:26:17 2025

@author: RCORBYN
"""
import pytesseract as pytess
import numpy as np 
import skimage 
import scipy 
import aicsimageio
import os 
import tifffile as tf
from PIL import Image
import tkinter as tk 
import pandas as pd
import matplotlib.pyplot as plt
from tkinter import filedialog
import sys

image_param = sys.argv[1]

rgba_image = Image.open(image_param)
im_data = rgba_image.convert('RGB')
# Convert to a numpy array
im_data = np.array(im_data)

#######
# Perform edge detection
edges = skimage.filters.sobel( np.sum(im_data, axis = 2) )

#####
# Threshold the image to remove most of the 
# unimportant information from the image.

# Find the threshold values
threshold_val = skimage.filters.threshold_otsu(edges)
edges[edges < threshold_val] = 0

# Fill the binary masks of the letters
fill_string = scipy.ndimage.binary_fill_holes(edges)

# Invert the image and multiply by the letter
# mask to get only the letters in the image. 
invert = fill_string * skimage.util.invert( im_data[:, :, 0] )
#####
# Create a binary image from the inverted letters
binary = np.array(invert)
binary[binary>0] = 1

# create labels from the binary image. 
labels = skimage.measure.label(binary)

# Get properties of the letters and remaining masks. 
region_props = pd.DataFrame( skimage.measure.regionprops_table(
                labels, properties = {'label', 'area', 
                'axis_minor_length', 'axis_major_length'}) )

# Create a mask of zeros
filtered_image = np.zeros(im_data.shape)

# Loop around all labels. 
for i in range(region_props.shape[0]): 
    # Find the positon of mask i in the label image. 
    mask_pos = np.where(labels == region_props['label'].iloc[i])
    # Find the maximum and minimum height and width of the masks. 
    delta_x = np.abs( np.min(mask_pos[0]) - np.max(mask_pos[0]) ) 
    delta_y = np.abs( np.min(mask_pos[1]) - np.max(mask_pos[1]) ) 
    # If the mask is too long or high, remove 
    # Also remove if the area is too small. 
    if delta_x  <= 75 and delta_y <= 75 and region_props['area'].iloc[i] > 100: 
        # keep the mask. 
        filtered_image[mask_pos[0], mask_pos[1]] = skimage.util.invert(
                                    im_data[mask_pos[0], mask_pos[1], :] )

filtered_image = np.array(filtered_image, dtype = 'uint8')

filtered_image[filtered_image>150] = 255
filtered_image[filtered_image<150] = 0

im = Image.fromarray(filtered_image)
im.save("out_pre.png")

# =============================================================================
# text = pytess.image_to_string(filtered_image)
# 
# text = text.replace( chr(10), '_' )
# text = text.replace( ' ' , '_' )
# text = text.replace( '/', '_' )
# text = text.replace('colorslide', '')
# 
# print(text)
# =============================================================================
