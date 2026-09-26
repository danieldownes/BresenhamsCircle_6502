10 REM Bresenham's circle in 6502 assembler, MODE 5 version
20 REM Writes pixels straight into MODE 5 screen memory
30 REM Circle is worked out on a 320x256 grid like MODE 1
40 REM MODE 5 pixels are 2 wide, so column = grid x DIV 2
50 REM Centre (xc,yc) on that grid from top left, radius r up to 127
60 xc=160:yc=127:r=127
70 xx=&70:yy=&71:d=&72:t=&74:pr=&76:pl=&78:cy=&7A:rr=&7B
80 MODE5
90 PROCtables
100 PROCassemble
110 ?cy=yc:?rr=r
120 TIME=0
130 CALL circle
140 PRINT ;TIME
150 END
160 DEF PROCtables
170 LOCAL i%,a%,b%
180 DIM rowlo 255,rowhi 255,mask 3
190 DIM rlo 127,rhi 127,rmask 127,llo 127,lhi 127,lmask 127
200 FOR i%=0 TO 255
210 a%=&5800+(i% DIV 8)*320+(i% AND 7)
220 rowlo?i%=a%:rowhi?i%=a% DIV 256
230 NEXT
240 ?mask=&88:mask?1=&44:mask?2=&22:mask?3=&11
250 FOR i%=0 TO 127
260 a%=(xc+i%) DIV 2:b%=(xc-i%) DIV 2
270 rlo?i%=(a% DIV 4)*8:rhi?i%=(a% DIV 4)*8 DIV 256:rmask?i%=mask?(a% AND 3)
280 llo?i%=(b% DIV 4)*8:lhi?i%=(b% DIV 4)*8 DIV 256:lmask?i%=mask?(b% AND 3)
290 NEXT
300 ENDPROC
310 DEF PROCassemble
320 LOCAL pass
330 DIM code 200
340 FOR pass=0 TO 2 STEP 2
350 P%=code
360 [OPT pass
370 .circle
380 SEC           \ D = 1 - r
390 LDA #1
400 SBC rr
410 STA d
420 LDA #0
430 SBC #0
440 STA d+1
450 LDA #0        \ x = 0, y = r
460 STA xx
470 LDA rr
480 STA yy
490 .loop
500 LDX xx        \ rows cy+-y, columns cx+-x
510 CLC
520 LDA cy
530 ADC yy
540 JSR row2
550 SEC
560 LDA cy
570 SBC yy
580 JSR row2
590 LDX yy        \ rows cy+-x, columns cx+-y
600 CLC
610 LDA cy
620 ADC xx
630 JSR row2
640 SEC
650 LDA cy
660 SBC xx
670 JSR row2
680 LDA xx        \ A = 2x, carry clear as x < 128
690 ASL A
700 BIT d+1
710 BMI dneg
720 ADC #5        \ D >= 0 so D = D + 2x + 5 - 2y
730 ADC d
740 STA d
750 BCC nocarry
760 INC d+1
770 .nocarry
780 LDA yy
790 ASL A
800 STA t
810 SEC
820 LDA d
830 SBC t
840 STA d
850 BCS noborrow
860 DEC d+1
870 .noborrow
880 DEC yy        \ y = y - 1
890 JMP next
900 .dneg
910 ADC #3        \ D < 0 so D = D + 2x + 3
920 ADC d
930 STA d
940 BCC next
950 INC d+1
960 .next
970 INC xx        \ x = x + 1
980 LDA yy
990 CMP xx
1000 BCS loop      \ repeat while y >= x
1010 RTS
1020 .row2
1030 TAY           \ Y = row, X = distance from centre
1040 CLC
1050 LDA rowlo,Y   \ pr = right hand pixel address
1060 ADC rlo,X
1070 STA pr
1080 LDA rowhi,Y
1090 ADC rhi,X
1100 STA pr+1
1110 LDA rowlo,Y   \ pl = left hand pixel address
1120 ADC llo,X     \ carry is clear as addresses are below &8000
1130 STA pl
1140 LDA rowhi,Y
1150 ADC lhi,X
1160 STA pl+1
1170 LDY #0
1180 LDA rmask,X   \ set both pixels to colour 3
1190 ORA (pr),Y
1200 STA (pr),Y
1210 LDA lmask,X
1220 ORA (pl),Y
1230 STA (pl),Y
1240 RTS
1250 ]
1260 NEXT
1270 ENDPROC
