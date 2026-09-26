10 MODE1
20 TIME=0
30 PROCBres(160,128,127)
40 PRINT TIME
50 END
60 DEF PROCBres(xc,yc,r)
70 LOCAL x,y,d
80 x=0
90 y=r
100 d=3-2*r
110 REPEAT
120 PROCcirc(4*xc,4*yc,4*x,4*y)
130 IF d<0 THEN d=d+4*x+6 ELSE d=d+4*(x-y)+10:y=y-1
140 x=x+1
150 UNTIL x>y
160 ENDPROC
170 DEF PROCcirc(xc,yc,x,y)
180 PLOT69,xc+x,yc+y
190 PLOT69,xc-x,yc+y
200 PLOT69,xc+x,yc-y
210 PLOT69,xc-x,yc-y
220 PLOT69,xc+y,yc+x
230 PLOT69,xc-y,yc+x
240 PLOT69,xc+y,yc-x
250 PLOT69,xc-y,yc-x
260 ENDPROC
