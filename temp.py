file_name = 'zhi.dict.orgin'
f = open(file_name, 'r')
offsets = [127413]
for offset in offsets:
    f.seek(offset)
    print (f.readline().strip())
