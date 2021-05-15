import sys

from PIL import Image 
from numpy import asarray
#import matplotlib
#import matplotlib.pyplot as plt

#Dimension in characters(16 x 8)
width = 20
height = 10

#Character size
N = 8
M = 16

charCode = 97

def to_bin(tile, code):
    #ret = "db " + str(code) + "\n"
    ret = ""

    for l in tile:
        d = map(lambda x: 1 if x else 0, l)
        ret += "db " + "".join(str(x) for x in d) + "b\n"

    return ret

def show(tiles):
    matplotlib.use("TKAgg")

    fig = plt.figure(figsize=(height, width))
    for i in range(0, width * height):
        fig.add_subplot(height, width, i + 1)
        plt.imshow(tiles[i])

    plt.show()

#Read in image, convert to 128x128 black and white
#img = Image.open(sys.argv[1]).convert("1")
img = Image.open(sys.argv[1]).resize((width * N, height * M), Image.ANTIALIAS).convert("1")

#Switch over to array data
data = asarray(img)

#Break into 8x16 tiles
tiles = [data[x:x+M,y:y+N] for x in range(0,data.shape[0],M) for y in range(0,data.shape[1],N)]

#show(tiles)

font_pack = []
tile_map = []

#Clean up duplicates
for tile in tiles:
    d = to_bin(tile, charCode)

    if d in font_pack:
        i = font_pack.index(d)
        tile_map.append(i)
    else:
        font_pack.append(d)
        tile_map.append(len(font_pack) - 1)
        charCode += 1

print("db " + str(len(font_pack)))
print("\n".join(font_pack))

print("db " + str(len(tile_map)) + ", " + str(width))
print("db " + ", ".join(str(x + 127) for x in tile_map))
print("db 0")
