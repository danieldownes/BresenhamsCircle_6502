# BresenhamsCircle 6502
## Bresenham's Circle, implemented in BASIC and 6502 Assembly

### BASIC Version

![](./BASIC-on-ElectrEm.gif)

Tested on ElectrEm and ElkJS emulators.
The included snapshot.uef file can also be loaded with these emulators.

```basic
10 GOTO 240  
20 DEF PROCcirc(xc,yc,x,y)  
30 PLOT69,xc+x,yc+y  
40 PLOT69,xc-x,yc+y  
50 PLOT69,xc+x,yc-y  
60 PLOT69,xc-x,yc-y  
70 PLOT69,xc+y,yc+x  
80 PLOT69,xc-y,yc+x  
90 PLOT69,xc+y,yc-x  
100 PLOT69,xc-y,yc-x  
110 ENDPROC  
120 DEF PROCBres(xc,yc,r,s)  
130 LOCAL x,y,d  
140 x=0  
150 y=r  
160 d=3-2*r  
170 PROCcirc(xc,yc,x,y)  
180 REPEAT  
190 x=x+s  
200 IF d>=0 THEN y=y-s:d=d+4*(x-y)+10 ELSE d=d+4*x+6  
210 PROCcirc(xc,yc,x,y)  
220 UNTIL y <= x  
230 ENDPROC  
240 MODE1  
250 TIME=0  
260 PROCBres(640,512,510,4)  
270 PRINT TIME  
```

### 6502 Assembly Version

Looking at the BASIC code, the main and most complex part is the IF statement and proceeding maths operations

Having almost no prior experience with 6502, other than some light accademic exposure, I first looked for a multiplication solution. I understood that there was no multiplication operation on the 6502 so proceeded to search for one.

The first to be found was:
https://www.lysator.liu.se/~nisse/misc/6502-mul.html#
and
https://codebase64.org/doku.php?id=base:8bit_multiplication_8bit_product

These were both 8bit*8bit=8bit solutions and no check had been done to check if a 16bit operation was needed at this time.

I proceeded to check this code, and thought it may be interesting to fine a more pure 6502 emulator than using the Acorn Electon version, mostly due to the issue of no supported copy and paste, and also the idea that it would be easier to display a memory dump.

I quickly found this JS based one:
https://skilldrick.github.io/easy6502/


In the case of the White Flame multiplication solution, it wasn't clear how to load num1 and num2 with values.

Looking through examples I saw you can define a value using:
`define varible_name #$05 

The variable would then be directly replaced with the direct value of '05'

However, this isn't sufficient and failed to produce the result.

Of course you need to use num1 and num2 as memory locations, which are more like the idea of a, "int member instance" in C# terminology.

The first example on easy6502 show how to load values into memory, so I simply defined mem1 and mem2 to memory locations, and then loaded the desired values to be multiplied into these locations.

```asm
define num1 $01
define num2 $02

LDA #$04
STA num1
LDA #$03
STA num2
```

It was observed that A=$0c as expected.
