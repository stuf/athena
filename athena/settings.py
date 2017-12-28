from os.path import realpath, dirname, relpath, join

THIS = realpath(__file__)
THIS_DIR = dirname(THIS)
ROOT_DIR = realpath(join(THIS_DIR, '..'))

DATA_DIR = realpath(join(ROOT_DIR, 'data'))
OCR_DIR = realpath(join(DATA_DIR, 'ocr'))
SCAN_DIR = realpath(join(DATA_DIR, 'scan'))

WORK_DIR = realpath(join(ROOT_DIR, 'work'))
