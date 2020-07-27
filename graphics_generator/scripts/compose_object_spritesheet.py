import cv2
import pdb
import os
import glob
import numpy as np
import json
import sys

sprite_size = '32x64'

argv = ''
if '--' in sys.argv:
    argv = sys.argv
    argv = argv[argv.index("--") + 1:]

if argv:
    sprite_size = argv[0]
else:
    print('Specify sprite size')
    assert(False)

subfolder = 'objects_' + sprite_size
object_subfolders = [ f.path for f in os.scandir(subfolder) if f.is_dir() ]

TSIZE_X = int(sprite_size.split('x')[0])
TSIZE_Y = int(sprite_size.split('x')[1])

rows = 8
cols = 8

#We can create a json file that relates ID with row/col of the spritesheet
sheet_meta = {'size': [TSIZE_X, TSIZE_Y], 'objects': []}
sidx = 0
for object_name in object_subfolders:
    oname = object_name.split('/')[1]
    object_id = oname.split('_')[1]
    row = int(sidx/rows)
    col = int(sidx%cols)
    sidx += 1

    obj_dict = {"object_id": object_id,
                "row": row,
                "col": col,
                "orientation": orientation}
    
    sheet_meta['objects'].append(obj_dict)


meta_filename = os.path.join(subfolder, 'object_sheet_meta_' + str(TSIZE_X) + 'x' + str(TSIZE_Y) + '.json')
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

    sheet_name = rtype + '_objects_sheet_' + str(TSIZE_X) + 'x' + str(TSIZE_Y) + '.png'
    cv2.imwrite(os.path.join(subfolder,sheet_name), output_sheet)
    print('Generated ' + sheet_name)
