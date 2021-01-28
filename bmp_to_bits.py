import sys
import os

from PIL import Image
from numpy import asarray

image = Image.open(sys.argv[1]).convert('1').resize((128, 128), Image.ANTIALIAS)
data = asarray(image)

for l in data:
    #print "db " + (", ".join(map(lambda p: '1' if p else '0', l)))
    for i in range(0, 64, 8):
        print "db " + ("".join(map(lambda p: '1' if p else '0', l[i:i + 8]))) + "b"
