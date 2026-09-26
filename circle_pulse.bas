10 REM Concentric Bresenham circles, 6502, MODE 2
20 REM Draws every 2nd radius from 127 down to 1, each in the next colour
30 REM A MODE 2 pixel is 2 grid units wide, so each circle is
40 REM 1 pixel wider than the next and none are drawn over
50 REM Then shows one colour at a time, a step every frame
60 REM Press ESCAPE to stop
70 REM Circle is worked out on a 320x256 grid like MODE 1
80 REM MODE 2 pixels are 2 wide, so column = grid x DIV 2
90 xc=160:yc=127:r=127
100 xx=&70:yy=&71:d=&72:t=&74:pr=&76:pl=&78:cy=&7A:rr=&7B:col=&7C
110 blk=&7D:cur=&82:osword=&FFF1:osbyte=&FFF4
120 MODE2
130 PROCtables
140 PROCassemble
150 ?cy=yc
160 TIME=0
170 FOR r%=r TO 1 STEP -2
180 GCOL0,1+(r% DIV 2) MOD 7
190 ?col=?&359
200 ?rr=r%
210 CALL circle
220 NEXT
230 GCOL0,1
240 PLOT69,4*xc,4*(255-yc)
250 PRINT ;TIME
260 FOR c%=2 TO 7:VDU19,c%,0;0;:NEXT
270 !blk=0:blk?4=0:?cur=1
280 CALL pulse
290 VDU20
300 END
310 DEF PROCtables
320 LOCAL i%,a%,b%
330 DIM rowlo 255,rowhi 255,mask 1
340 DIM rlo 127,rhi 127,rmask 127,llo 127,lhi 127,lmask 127
350 FOR i%=0 TO 255
360 a%=&3000+(i% DIV 8)*640+(i% AND 7)
370 rowlo?i%=a%:rowhi?i%=a% DIV 256
380 NEXT
390 ?mask=&AA:mask?1=&55
400 FOR i%=0 TO 127
410 a%=(xc+i%) DIV 2:b%=(xc-i%) DIV 2
420 rlo?i%=(a% DIV 2)*8:rhi?i%=(a% DIV 2)*8 DIV 256:rmask?i%=mask?(a% AND 1)
430 llo?i%=(b% DIV 2)*8:lhi?i%=(b% DIV 2)*8 DIV 256:lmask?i%=mask?(b% AND 1)
440 NEXT
450 ENDPROC
460 DEF PROCassemble
470 LOCAL pass
480 DIM code 300
490 FOR pass=0 TO 2 STEP 2
500 P%=code
510 [OPT pass
520 .circle
530 SEC           \ D = 1 - r
540 LDA #1
550 SBC rr
560 STA d
570 LDA #0
580 SBC #0
590 STA d+1
600 LDA #0        \ x = 0, y = r
610 STA xx
620 LDA rr
630 STA yy
640 .loop
650 LDX xx        \ rows cy+-y, columns cx+-x
660 CLC
670 LDA cy
680 ADC yy
690 JSR row2
700 SEC
710 LDA cy
720 SBC yy
730 JSR row2
740 LDX yy        \ rows cy+-x, columns cx+-y
750 CLC
760 LDA cy
770 ADC xx
780 JSR row2
790 SEC
800 LDA cy
810 SBC xx
820 JSR row2
830 LDA xx        \ A = 2x, carry clear as x < 128
840 ASL A
850 BIT d+1
860 BMI dneg
870 ADC #5        \ D >= 0 so D = D + 2x + 5 - 2y
880 ADC d
890 STA d
900 BCC nocarry
910 INC d+1
920 .nocarry
930 LDA yy
940 ASL A
950 STA t
960 SEC
970 LDA d
980 SBC t
990 STA d
1000 BCS noborrow
1010 DEC d+1
1020 .noborrow
1030 DEC yy        \ y = y - 1
1040 JMP next
1050 .dneg
1060 ADC #3        \ D < 0 so D = D + 2x + 3
1070 ADC d
1080 STA d
1090 BCC next
1100 INC d+1
1110 .next
1120 INC xx        \ x = x + 1
1130 LDA yy
1140 CMP xx
1150 BCS loop      \ repeat while y >= x
1160 RTS
1170 .row2
1180 TAY           \ Y = row, X = distance from centre
1190 CLC
1200 LDA rowlo,Y   \ pr = right hand pixel address
1210 ADC rlo,X
1220 STA pr
1230 LDA rowhi,Y
1240 ADC rhi,X
1250 STA pr+1
1260 LDA rowlo,Y   \ pl = left hand pixel address
1270 ADC llo,X     \ carry is clear as addresses are below &8000
1280 STA pl
1290 LDA rowhi,Y
1300 ADC lhi,X
1310 STA pl+1
1320 LDY #0        \ new = old EOR ((old EOR col) AND mask)
1330 LDA (pr),Y
1340 EOR col
1350 AND rmask,X
1360 EOR (pr),Y
1370 STA (pr),Y
1380 LDA (pl),Y
1390 EOR col
1400 AND lmask,X
1410 EOR (pl),Y
1420 STA (pl),Y
1430 RTS
1440 .pulse
1450 LDA #&13      \ wait for the start of the next frame
1460 JSR osbyte
1470 LDA cur       \ hide the current colour
1480 STA blk
1490 LDA #0
1500 STA blk+1
1510 JSR palette
1520 LDX cur       \ move on to the next colour, 7 wraps to 1
1530 INX
1540 CPX #8
1550 BNE show
1560 LDX #1
1570 .show
1580 STX cur       \ show it as its own physical colour
1590 STX blk
1600 STX blk+1
1610 JSR palette
1620 BIT &FF       \ repeat until ESCAPE is pressed
1630 BPL pulse
1640 LDA #&7E      \ acknowledge ESCAPE
1650 JMP osbyte
1660 .palette
1670 LDA #&C       \ OSWORD &C writes the palette entry in blk
1680 LDX #blk
1690 LDY #0
1700 JMP osword
1710 ]
1720 NEXT
1730 ENDPROC
