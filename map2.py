from random import randint
def rdLs(ls): return ls[randint(0, len(ls)-1)]
for i in range(512): print(','.join(["0xffffff" for j in range(256)])+',')
