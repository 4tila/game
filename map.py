from random import randint
def rdLs(ls): return ls[randint(0, len(ls)-1)]
cols = ["0xfff858", '0x11d987', '0x09ac88', '0x13d6f7', '0x3b3791']
for i in range(512): print(','.join([cols[(i+j)%len(cols)] for j in range(256)])+',')
