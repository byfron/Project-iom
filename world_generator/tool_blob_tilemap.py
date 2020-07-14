import json
import pdb
import cv2
import numpy as np
import copy

def check_limits(point):
    return point[0] >= 0 and point[1] >= 0 and point[0] < 448 and point[1] < 448

def is_connected(src, dst, image):
    if check_limits(dst):
        points_on_line = np.linspace(src, dst, dtype=int)
        values = mask[points_on_line[:,0], points_on_line[:,1]]
        if np.all(values == 0):
            return True
        
    return False

def generateAllBinaryStrings(n, arr, i, all_strings):  
  
    if i == n:
        all_strings.append(copy.deepcopy(arr))
        return
      
    # First assign "0" at ith position  
    # and try for all other permutations  
    # for remaining positions  
    arr[i] = 0
    generateAllBinaryStrings(n, arr, i + 1, all_strings)  
  
    # And then assign "1" at ith position  
    # and try for all other permutations  
    # for remaining positions  
    arr[i] = 1
    generateAllBinaryStrings(n, arr, i + 1, all_strings)

    
def compute_all_codes(n, ne, e, se, s, sw, w, nw):

    arr = [None] * 8
    all_strings = []
    generateAllBinaryStrings(8, arr, 0, all_strings)
    all_codes = np.array(all_strings)
    mask = np.array([True]*256).astype('int64')

    #If sides are not connected we know that there has to be no tile
    #If diagonals are not connected we do not care if there's tile or not
    
    if n:
        mask *= (all_codes[:,0] == 1)
    else:
        mask *= (all_codes[:,0] == 0)
        
    if ne:
        if n and e:
            mask *= (all_codes[:,1] == 1)
    else:
        if n and e:
            mask *= (all_codes[:,1] == 0)
        # else:
        #     mask *= (all_codes[:,1] == 0)
            
    if e:
        mask *= (all_codes[:,2] == 1)
    else:
        mask *= (all_codes[:,2] == 0)
        
    if se:
        if s and e:
            mask *= (all_codes[:,3] == 1)
    else:
        if s and e:
            mask *= (all_codes[:,3] == 0)        
            # else:
        #     mask *= (all_codes[:,3] == 0)
        
    if s:
        mask *= (all_codes[:,4] == 1)
    else:
        mask *= (all_codes[:,4] == 0)        
        
    if sw:
        if s and w:
            mask *= (all_codes[:,5] == 1)
    else:
        if s and w:
            mask *= (all_codes[:,5] == 0)
            
        # else:
        #     mask *= (all_codes[:,5] == 0)
        
    if w:
        mask *= (all_codes[:,6] == 1)
    else:
        mask *= (all_codes[:,6] == 0)
        
    if nw:
        if n and w:
            mask *= (all_codes[:,7] == 1)
    else:
        if n and w:
            mask *= (all_codes[:,7] == 0)        
        # else:
        #     mask *= (all_codes[:,7] == 0)

    valid_codes = np.where(mask)[0]
    final_codes = []
    for vc in valid_codes:
        final_codes.append(np.sum(all_codes[vc] * np.array([1,2,4,8,16,32,64,128])))
        
    return final_codes

config_file = '../game_assets/tilemap_meta/fov_blob.json'

tilemap = cv2.imread('../game_assets/tilemaps/shadow_tilemap.png')
# cv2.imshow('te', tilemap)
# cv2.waitKey()

output = {"codes": []}
list_of_codes = []
mask = tilemap[:,:,0]
tile_id = 0
for row in range(0,7):
    for col in range(0,7):
        center_row = row*64 + 32
        center_col = col*64 + 32
        N = np.array([center_row - 64, center_col])
        NE = np.array([center_row - 64, center_col + 64])
        E = np.array([center_row, center_col + 64])
        SE = np.array([center_row + 64, center_col + 64])
        S = np.array([center_row + 64, center_col])
        SW = np.array([center_row + 64, center_col - 64])
        W = np.array([center_row, center_col - 64])
        NW = np.array([center_row - 64, center_col - 64])

        #ignore empty tiles
        if mask[center_row, center_col] != 255:

            center = np.array([center_row, center_col])
        
            #find connected
            n_connected = is_connected(center, N, mask)
            nw_connected = is_connected(center, NW, mask)
            w_connected = is_connected(center, W, mask)
            sw_connected = is_connected(center, SW, mask)
            s_connected = is_connected(center, S, mask)
            se_connected = is_connected(center, SE, mask)
            e_connected = is_connected(center, E, mask)
            ne_connected = is_connected(center, NE, mask)
            
            codes = compute_all_codes(n_connected, ne_connected, e_connected,
                                      se_connected, s_connected, sw_connected,
                                      w_connected, nw_connected)

            for i in range(len(codes)):
                output["codes"].append({"code": int(codes[i]), "id": int(tile_id)})
                list_of_codes.append(int(codes[i]))

        tile_id += 1

list_of_codes.sort()
for i in range(0,255):
    if i not in list_of_codes:
        output["codes"].append({"code": i, "id": 0})

output_file = 'fov_automated.json'        
with open(output_file, 'w') as fp:
    json.dump(output, fp)
