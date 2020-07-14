class Coordinate:
    def __init__(self, x=None, y=None):
        """
        A point in 2D space.
        :param x: (float) The x-coordinate
        :param y: (float) The y-coordinate
        """
        self.x = x
        self.y = y

    def __repr__(self):
        return "(%d, %d)" % (round(self.x, 3) , round(self.y, 3))
