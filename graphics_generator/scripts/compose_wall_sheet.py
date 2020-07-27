import pdb
import sys
import os
import glob
import numpy as np
import cv2

#cameras = ['B_0', 'BL_1', 'LR_1', 'TB_1', 'TBG_1', 'TL_1', 'LR_1', 'TR_1', 'TBR_1', 'CROSS', 'LRT_1', 'LRB_1', 'BR_1']
object_name = 'Walls'
types = ['NORMAL', 'DIFFUSE']
TSIZE = 32

rows = 7
cols = 7
locations = {}
locations['B_0'] = [[5, 0], [5, 1], [5, 2], [1, 1]]
locations['BL_1'] = [[4, 0]]
locations['TBG_1'] = [[2, 0]]
locations['TB_1'] = [[1, 0], [3,0]]
locations['TL_1'] = [[0, 0]]
locations['LR_1'] = [[4, 1], [0,1]]

locations = [['' for x in range(rows)] for y in range(cols)] 
locations[0][0] = ''
locations[0][1] = 'LR_1'
locations[0][2] = 'LRB_1'
locations[0][3] = 'LR_1'
locations[0][4] = 'LRB_1'
locations[0][5] = 'TR_1'
locations[0][6] = ''
locations[1][0] = 'TB_1'
locations[1][1] = 'TL_1'
locations[1][2] = 'CROSS'
locations[1][3] = 'TR_1'
locations[1][4] = 'TB_1'
locations[1][4] = 'TB_1'
locations[1][5] = 'TBR_1'
locations[1][6] = 'LR_1'
locations[2][0] = 'TBR_1'
locations[2][1] = 'CROSS'
locations[2][2] = 'CROSS'
locations[2][3] = 'LRT_1'
locations[2][4] = 'CROSS'
locations[2][5] = 'LRT_1'
locations[2][6] = 'TR_1'
locations[3][0] = 'TB_1'
locations[3][1] = 'CROSS'
locations[3][2] = 'TBL_1'
locations[3][3] = 'TL_1'
locations[3][4] = 'CROSS'
locations[3][5] = 'CROSS'
locations[3][6] = 'TB_1'
locations[4][0] = 'TBR_1'
locations[4][1] = 'LRT_1'
locations[4][2] = 'CROSS'
locations[4][3] = 'CROSS'
locations[4][4] = 'CROSS'
locations[4][5] = 'CROSS'
locations[4][6] = 'TBR_1'
locations[5][0] = 'BL_1'
locations[5][1] = 'LRB_1'
locations[5][2] = 'CROSS'
locations[5][3] = 'CROSS'
locations[5][4] = 'CROSS'
locations[5][5] = 'TBL_1'
locations[5][6] = 'TB_1'
locations[6][0] = 'B_0'
locations[6][1] = 'TB_1'
locations[6][2] = 'BR_1'
locations[6][3] = 'LRT_1'
locations[6][4] = 'LRT_1'
locations[6][5] = 'LR_1'
locations[6][6] = 'BR_1'
    
for rtype in types:
    output_sheet = np.zeros((rows*TSIZE, cols*TSIZE, 4))

    idx = 1
    for row in range(rows):
        for col in range(cols):

            cam_name = 'Camera.%02d' % idx
#            cam_name = locations[row][col]               
 #           if not cam_name in cameras:                
  #              continue
            
            all_files = glob.glob("Walls/" + rtype + "_Camera_" + cam_name + "*.png")
            print("Walls/" + rtype + "_Camera_" + cam_name + "*.png")

            filename = all_files[0]
            frame = cv2.imread(filename, cv2.IMREAD_UNCHANGED)
            output_sheet[row*TSIZE:(row+1)*TSIZE, col*TSIZE:(col+1)*TSIZE,:] = frame


            cv2.imshow('test', output_sheet/255.0)
            cv2.waitKey(50)
        
            idx += 1

    sheet_name = 'Walls_' + rtype + '_sheet.png'
    cv2.imwrite(sheet_name, output_sheet)



#make another wallsheet that ONLY has the bottom tile
output_sheet = np.zeros((rows*TSIZE, cols*TSIZE, 4))
for row in range(rows):
    for col in range(cols):
        all_files = glob.glob("Walls/DIFFUSE_Camera_Camera.43*.png")
        filename = all_files[0]
        frame = cv2.imread(filename, cv2.IMREAD_UNCHANGED)
        output_sheet[row*TSIZE:(row+1)*TSIZE, col*TSIZE:(col+1)*TSIZE,:] = frame

        
#        pdb.set_trace()
        

sheet_name = 'Walls_Bottom_sheet_DIFFUSE.png'
cv2.imwrite(sheet_name, output_sheet)

#make another wallsheet that ONLY has the bottom tile
output_sheet = np.zeros((rows*TSIZE, cols*TSIZE, 4))
for row in range(rows):
    for col in range(cols):
        all_files = glob.glob("Walls/NORMAL_Camera_Camera.43*.png")
        filename = all_files[0]
        frame = cv2.imread(filename, cv2.IMREAD_UNCHANGED)
        output_sheet[row*TSIZE:(row+1)*TSIZE, col*TSIZE:(col+1)*TSIZE,:] = frame

sheet_name = 'Walls_Bottom_sheet_NORMAL.png'
cv2.imwrite(sheet_name, output_sheet)

