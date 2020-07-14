from scipy import ndimage
import cv2
import pdb

maskfile = '/home/rubio/Projects/IsleOfManCLI/game_assets/tilemaps/thin_shadow_mask.png'
mask = cv2.imread(maskfile)
mask = cv2.cvtColor(mask, cv2.COLOR_BGR2GRAY)

#cv2.imshow("im", mask)#(mask == 0)*255)

dist_image = ndimage.distance_transform_edt(mask == 0)
cv2.imshow("im", dist_image/16)
cv2.waitKey(0)
cv2.imwrite("soft_shadows.png", 255*(dist_image/16.0))
