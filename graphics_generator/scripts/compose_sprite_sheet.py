import cv2
import pdb
import os
import glob
import numpy as np

cam_keys = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'] 

char_subfolders = [ f.path for f in os.scandir('.') if f.is_dir() ]

for char_name in char_subfolders:

    anim_subfolders = [ f.path for f in os.scandir(char_name) if f.is_dir() ]

    for anim_name in anim_subfolders:

        types = ['NORMAL', 'DIFFUSE']

        for rtype in types:
        
            image_array = {}
            for key in cam_keys:
                image_array[key] = {}

                all_files = glob.glob(anim_name + "/" + rtype + "_Camera" + key + "_*.png")
                all_files.sort()
                frame_index = 0
                for file in all_files:
                    fspl = file.split('_')
                    #frame_index = fspl[2].split('.')[0]
                    orientation_index = cam_keys.index(key)
                    frame = cv2.imread(file, cv2.IMREAD_UNCHANGED)
                    image_array[key][frame_index] = frame
                    frame_index += 1

            rows = len(image_array)
            cols = len(image_array['N'])

            output_sheet = np.zeros((rows*64, cols*64, 4))
            ridx = 0
        
            for row_key in cam_keys:
                cidx = 0    
                for col_key in image_array[row_key]:
                    frame = image_array[row_key][col_key]
                    output_sheet[ridx*64:(ridx+1)*64, cidx*64:(cidx+1)*64,:] = frame
                    cidx += 1
                ridx += 1

            # try:
            print(anim_name)
            anim_split = anim_name.split('/')
            char_name_s = anim_split[1]
            anim_name_s = anim_split[2]
            # except:
            #     pdb.set_trace()
                
            sheet_name = rtype + '_' + char_name_s + '_' + anim_name_s + '_sheet.png'
            cv2.imwrite(sheet_name, output_sheet)
            print('Generated ' + sheet_name) 
