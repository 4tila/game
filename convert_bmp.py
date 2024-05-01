from PIL import Image
import numpy as np
def string(x):
    a=str(hex(x))[2:]
    if len(a)==1: return '0'+a
    return a
fname="./char.bmp"
array_name = "CHAR"
im = Image.open(fname)
p = np.array(im).tolist()
N = len(p)
p = [['0x'+string(p[i][j][0])+string(p[i][j][1])+string(p[i][j][2]) for j in range(N)] for i in range(N)]
s=array_name+":            .word "
for i in range(N): s+=str(p[i])[1:-1].replace("'", '')+',\n'
print(s[0:-2])
