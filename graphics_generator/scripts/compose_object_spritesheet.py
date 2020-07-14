import cv2
import pdb
import os
import glob
import numpy as np
import json

subfolder = 'objects'
object_subfolders = [ f.path for f in os.scandir(subfolder) if f.is_dir() ]
TSIZE_X = 32
TSIZE_Y = 64

rows = 8
cols = 8

#We can create a json file that relates ID with row/col of the spritesheet
sheet_meta = {'size': [TSIZE_X, TSIZE_Y], 'objects': {}}
sidx = 0
for object_name in object_subfolders:
    oname = object_name.split('/')[1]
    object_id = oname.split('_')[1]
    row = int(sidx/rows)
    col = int(sidx%cols)
    sidx += 1
    sheet_meta['objects'][object_id] = [row, col]


meta_filename = os.path.join(subfolder, 'object_sheet_meta_32x64.json')
with open(meta_filename, 'w') as fp:
    json.dump(sheet_meta, fp)
    
types = ['NORMAL', 'DIFFUSE']
for rtype in types:
    sidx = 0
    output_sheet = np.zeros((rows*TSIZE_Y, cols*TSIZE_X, 4), dtype='uint16')
    for object_name in object_subfolders:
        oname = object_name.split('/')[1]
        object_id = oname.split('/')[0]
        filename = glob.glob(object_name + '/' + rtype + '*.png')[0]
        frame = cv2.imread(filename, cv2.IMREAD_UNCHANGED)
        row = int(sidx/rows)
        col = int(sidx%cols)
        output_sheet[row*TSIZE_Y:(row+1)*TSIZE_Y, col*TSIZE_X:(col+1)*TSIZE_X,:] = frame
        sidx += 1

    sheet_name = rtype + '_objects_sheet_32x64.png'
    cv2.imwrite(os.path.join(subfolder,sheet_name), output_sheet)
    print('Generated ' + sheet_name)
