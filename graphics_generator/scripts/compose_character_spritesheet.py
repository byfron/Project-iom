import cv2
import pdb
import os
import glob
import numpy as np

cam_keys = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'] 

char_subfolders = [ f.path for f in os.scandir('./characters') if f.is_dir() ]

sprite_size = [32, 64]
sprite_size = [96, 96]

sprites_path = 'characters/'
characters = ['Eric', 'Carla', 'Elizabeth']

game_asset_path = '/home/rubio/Projects/Project-iom/game_assets/textures/characters/'


for char_name in characters:#char_subfolders:

    anim_subfolders = [ f.path for f in os.scandir(sprites_path + char_name) if f.is_dir() ]

    for anim_name in anim_subfolders:

        types = ['NORMAL', 'DIFFUSE']

        for rtype in types:

            print(char_name)
            print(anim_name)
        
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

            output_sheet = np.zeros((rows*sprite_size[1], cols*sprite_size[0], 4))
            ridx = 0
        
            for row_key in cam_keys:
                cidx = 0    
                for col_key in image_array[row_key]:
                    frame = image_array[row_key][col_key]
                    output_sheet[ridx*sprite_size[1]:(ridx+1)*sprite_size[1], cidx*sprite_size[0]:(cidx+1)*sprite_size[0],:] = frame
                    cidx += 1
                ridx += 1

            # try:
            print(anim_name)
            anim_split = anim_name.split('/')
            char_name_s = anim_split[-2]
            anim_name_s = anim_split[-1]
            # except:
            #     pdb.set_trace()


            if not os.path.exists(game_asset_path + char_name_s):
                os.mkdir(game_asset_path + char_name_s)


            sheet_name = game_asset_path + char_name_s + '/' + rtype + '_' + char_name_s + '_' + anim_name_s + '_sheet.png'
            cv2.imwrite(sheet_name, output_sheet)
            print('Generated ' + sheet_name) 
