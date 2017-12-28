# -*- coding: utf-8 -*-

import os.path as p

import athena.settings as s

def collect_data(task_name, image_format='pnm'):
    """
    Collect data based on `task_name` from data directories.
    """
    image_filename = '.'.join([task_name, image_format])
    image_path = p.realpath(p.join(s.SCAN_DIR, image_filename))
    ocr_path = p.join(s.OCR_DIR, image_filename, '{}.txt'.format(task_name))

    ocr_text = None

    with open(ocr_path, 'r') as file:
        ocr_text = file.read()

    return {
        'document_image': image_path,
        'document_text': ocr_text
    }
