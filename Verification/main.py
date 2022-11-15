import cv2
import numpy as np

file_path = './image.jpg'
img = cv2.imread(file_path)

def interpolation(a, b, c, d, e, f):
    
    d1 = abs(a-f)
    d2 = abs(b-e)
    d3 = abs(c-d)

    min_data = min(d1, d2, d3)
    
    if min_data == d2:
        return (b+e)//2
    elif min_data == d1:
        return (a+f)//2
    else:
        return (c+d)//2
    
# convert to gray scale
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
# Resize the image into 32x31
img_resize = cv2.resize(img_gray, (32, 31))

# Remove the even row of pixels
pixel_odd = np.zeros((16, 32), np.uint8)

for row in range(31):
    for col in range(32):
        if row%2 == 0:
            pixel_odd[row//2, col] = np.uint8(img_resize[row, col])

# # Get golden.dat
img_golden = np.zeros((31, 32), np.uint8)

for row in range(31):
    for col in range(32):
        if row % 2 == 0:
            img_golden[row, col] = img_resize[row, col]
        else:
            if col==0 or col == 31:
                b = int(img_resize[row-1, col])
                e = int(img_resize[row+1, col])
                result = (b + e) // 2
                img_golden[row, col] = np.uint8(result)
            else:
                a = int(img_resize[row-1, col-1])
                b = int(img_resize[row-1, col])
                c = int(img_resize[row-1, col+1])
                d = int(img_resize[row+1, col-1])
                e = int(img_resize[row+1, col])
                f = int(img_resize[row+1, col+1])
                result = interpolation(a, b, c, d, e, f)
                img_golden[row, col] = np.uint8(result)  

# save img.dat 
with open('./img.dat', 'w', encoding='utf-8') as f:
    for row in range(16):
        for col in range(32):
            f.write(str(hex(pixel_odd[row, col]).replace('0x', ''))+'\n')

# save golden.dat 
with open('./golden.dat', 'w', encoding='utf-8') as f:
    for row in range(31):
        for col in range(32):
            f.write(str(hex(img_golden[row, col]).replace('0x', ''))+'\n')

# Print shape
print("resize image size: ", img_resize.shape)
print("pixel odd image size: ", pixel_odd.shape)
print("golden image size", img_golden.shape)
# print image
print("resize image")
print(img_resize)
print('=============================' + "\n")
print("pixel odd image")
print(pixel_odd)
print('=============================' + "\n")
print("golden image")
print(img_golden)
# write image
cv2.imwrite('./img_resize.jpg', img_resize)
cv2.imwrite('./pixel_odd.jpg', pixel_odd)
cv2.imwrite('./golden.jpg', pixel_odd)
