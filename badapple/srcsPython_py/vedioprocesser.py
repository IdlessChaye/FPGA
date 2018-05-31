# -*- coding: utf-8 -*-
import cv2
import numpy as np
#封装函数，实现一张128*64的图片转化为二进制数据，
#符合oled写入128*64图片数据顺序，具体参考oled图片取模像素点顺序
def img12864tohex1024(img):
    buffer = [0x00]*1024
    #bytes(buffer)
    y=0
    x=0
    i=0
    while True:
        buffer[i]=img[x+7][y]*2**7+img[x+6][y]*2**6+img[x+5][y]*2**5+img[x+4][y]*2**4+img[x+3][y]*2**3+img[x+2][y]*2**2+img[x+1][y]*2**1+img[x][y]
        i=i+1
        if(i==1024):
            break
        if(y+1<128):
            y=y+1
        else:
            x=x+8
            y=0
    for i in range(len(buffer)):
        buffer[i] = int(buffer[i]);
    return bytearray(buffer)
i=1
f = open("testtext.txt", 'wb') #二进制数据存储的文件
#f.write("")
f.close
f = open("testtext.txt", 'ab')
cap = cv2.VideoCapture("东方Project-BadApple.mkv") #视频数据文件
print(cap.isOpened()) #视频是否打开
while(cap.isOpened()):#循环，逐帧处理视频
    ret, frame = cap.read()
    if(frame.all()):
        break
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    ret,thresh = cv2.threshold(gray,127,255,cv2.THRESH_BINARY)
    #图片二值化处理，OLED屏幕只有0，1
    rect= cv2.copyMakeBorder(thresh,0,0,78,78,cv2.BORDER_CONSTANT,value=0)
    img = cv2.resize(rect,(128,64))
    #OLED屏幕为128*64，增加边框，使得图片大小也为128*64
    if(i%3==0):   #每三帧图片取一帧，减小数据量
        print(i) #显示当前的帧数
        cv2.imshow('thresh',img)
        img=img/255
        buffer=img12864tohex1024(img)
        #图片矩阵转化为二进制数据
        f.write(buffer)
        #二进制数据存储到文件中
    i=i+1
    if cv2.waitKey(1) & 0xFF == ord('w'):
        print (img)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
#循环结束，处理结束
f.close()
cap.release()
cv2.destroyAllWindows()