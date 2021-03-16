# BresenhamsCircle_6502
Bresenhams Circle, implemented in BASIC and 6502 Assembly


10GOTO 300
20DEF PROCcirc(xc,yc,x,y)
30VDU69,xc+x；yc+y；
40VDU69,xc-x；yc+y；
50VDU69,xc+x；yc-y；
60VDU69,xc-x；yc-y；
70VDU69,xc+y；yc+x；
80VDU69,xc-y；yc+x；
90VDU69,xc+y；yc-x；
100VDU69,xc-y；yc-x;
110ENDPROC
120DEF PROCBres(xc,yc,r,s)
130LOCAL x,y,d
140x=0
150y=r
160d=3-2*r
170PROCcirc(xc,yc,x,y)
180REPEAT
190x = x + s
200IF d > 0 THEN y = y - s : d = d + 4 * (x - y) + 10; ELSE d = d + 4 * x + 6
210PROCcircle(xc,yc,x,y)
220UNTIL y < x
230ENDPROC
300MODE1
201TIME=0
202PROCBres(640, 512, 510, 4)
203PRINT TIME
