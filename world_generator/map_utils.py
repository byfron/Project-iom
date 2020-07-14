import utm
from django.contrib.gis.geos import fromstr
from shapely.geometry import Polygon
from shapely import wkt
from django.contrib.gis.geos import GEOSGeometry
import numpy as np
import sys
sys.path.append('../')
#from game.models import LocationCompData, EntityComponent, Component
import math
import pdb

def overlap1D(bb1, bb2):
    return bb1[1] > bb2[0] and bb2[1] > bb1[0]

class MapBoundingBox:
    def __init__(self, x, y, width, height):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        assert(self.width > 0)
        assert(self.height > 0)

    def get_tl(self):
        return [self.x, self.y]

    def get_br(self):
        return [self.x + self.width - 1, self.y + self.height - 1]

    def get_polygon(self):
        return Polygon([tuple(self.get_tl()), (self.x + self.width-1, self.y), tuple(self.get_br()), (self.x, self.y + self.height -1), tuple(self.get_tl())])

    def get_gis_polygon(self):
        poly = self.get_polygon()
        return fromstr(poly.wkt)

    def __str__(self):
        return 'X: %d , Y: %d, SIZE: (%d,%d)' % (self.x, self.y, self.width, self.height)

    def is_inside(self, x, y):
        if x > self.x and x <= self.x + self.width and y >= self.y and y < self.y + self.height:
            return True
        return False

    @staticmethod
    def intersection(bb1, bb2):
        tl = [max(bb1.get_tl()[0], bb2.get_tl()[0]), max(bb1.get_tl()[1], bb2.get_tl()[1])]
        br = [min(bb1.get_br()[0], bb2.get_br()[0]), min(bb1.get_br()[1], bb2.get_br()[1])]
        try:
            MapBoundingBox(tl[0], tl[1], br[0] - tl[0] + 1, br[1] - tl[1] + 1)
        except:
            pdb.set_trace()
        return MapBoundingBox(tl[0], tl[1], br[0] - tl[0] + 1, br[1] - tl[1] + 1)

    @staticmethod
    def from_trbr(tr, br):
        return MapBoundingBox(tr[0], tr[1], br[0] - tr[0] + 1, br[1] - tr[1] + 1)


    @staticmethod
    def intersect(bb1, bb2):
        tl1 = bb1.get_tl()
        br1 = bb1.get_br()
        tl2 = bb2.get_tl()
        br2 = bb2.get_br()
        b1x = [tl1[0], br1[0]]
        b1y = [tl1[1], br1[1]]
        b2x = [tl2[0], br2[0]]
        b2y = [tl2[1], br2[1]]
        return overlap1D(b1x, b2x) and overlap1D(b1y, b2y)


class MapSettings:
    height = 25
    width = 35

# def get_entity_location(ent_id):
#     location = LocationCompData.objects.filter(location_comp_id = EntityComponent.objects.filter(entity_id = ent_id, component_id=Component.objects.filter(name='location').first().component_id).first().comp_data_id).first()

#     return location.coord, location.level

def get_geom_from_bb(chunk_bb):
    return GEOSGeometry(wkt.dumps(chunk_bb.get_polygon()))


def get_bb_from_chunk_coords(x, y):
    chunk_sx = MapSettings.width
    chunk_sy = MapSettings.height
    return MapBoundingBox(x*chunk_sx, y*chunk_sy, chunk_sx, chunk_sy)

    # bb = [int(x*chunk_sx), int(y*chunk_sy), int((x+1)*chunk_sx), int((y+1)*chunk_sy)]
    # return bb

def get_chunk_coords_from_offset_coords(x, y):
    assert(x >= 0)
    assert(y >= 0)
    chunk_x = int(x/MapSettings.width)
    chunk_y = int(y/MapSettings.height)    
    return chunk_x, chunk_y
