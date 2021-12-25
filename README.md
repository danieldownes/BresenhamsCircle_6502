# BresenhamsCircle_6502
## Bresenhams Circle, implemented in BASIC and 6502 Assembly


10 GOTO 300
20 DEF PROCcirc(xc,yc,x,y)
30 VDU69,xc+x；yc+y；
40 VDU69,xc-x；yc+y；
50 VDU69,xc+x；yc-y；
60 VDU69,xc-x；yc-y；
70 VDU69,xc+y；yc+x；
80 VDU69,xc-y；yc+x；
90 VDU69,xc+y；yc-x；
100 VDU69,xc-y；yc-x;
110 ENDPROC
120 DEF PROCBres(xc,yc,r,s)
130 LOCAL x,y,d
140 x=0
150 y=r
160 d=3-2*r
170 PROCcirc(xc,yc,x,y)
180 REPEAT
190 x = x + s
200 IF d > 0 THEN y = y - s : d = d + 4 * (x - y) + 10; ELSE d = d + 4 * x + 6
210 PROCcircle(xc,yc,x,y)
220 UNTIL y < x
230 ENDPROC
300 MODE1
201 TIME=0
202 PROCBres(640, 512, 510, 4)
203 PRINT TIME
