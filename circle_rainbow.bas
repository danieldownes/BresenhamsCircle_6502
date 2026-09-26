10 REM Filled circle from Bresenham circles, 6502, MODE 2
20 REM Draws radius 127 down to 1, each in the next colour
30 REM Circle is worked out on a 320x256 grid like MODE 1
40 REM MODE 2 pixels are 2 wide, so column = grid x DIV 2
50 xc=160:yc=127:r=127
60 xx=&70:yy=&71:d=&72:t=&74:pr=&76:pl=&78:cy=&7A:rr=&7B:col=&7C
70 MODE2
80 PROCtables
90 PROCassemble
100 ?cy=yc
110 TIME=0
120 FOR r%=r TO 1 STEP -1
130 GCOL0,1+r% MOD 7
140 ?col=?&359
150 ?rr=r%
160 CALL circle
170 NEXT
180 GCOL0,1
190 PLOT69,4*xc,4*(255-yc)
200 PRINT ;TIME
210 END
220 DEF PROCtables
230 LOCAL i%,a%,b%
240 DIM rowlo 255,rowhi 255,mask 1
250 DIM rlo 127,rhi 127,rmask 127,llo 127,lhi 127,lmask 127
260 FOR i%=0 TO 255
270 a%=&3000+(i% DIV 8)*640+(i% AND 7)
280 rowlo?i%=a%:rowhi?i%=a% DIV 256
290 NEXT
300 ?mask=&AA:mask?1=&55
310 FOR i%=0 TO 127
320 a%=(xc+i%) DIV 2:b%=(xc-i%) DIV 2
330 rlo?i%=(a% DIV 2)*8:rhi?i%=(a% DIV 2)*8 DIV 256:rmask?i%=mask?(a% AND 1)
340 llo?i%=(b% DIV 2)*8:lhi?i%=(b% DIV 2)*8 DIV 256:lmask?i%=mask?(b% AND 1)
350 NEXT
360 ENDPROC
370 DEF PROCassemble
380 LOCAL pass
390 DIM code 200
400 FOR pass=0 TO 2 STEP 2
410 P%=code
420 [OPT pass
430 .circle
440 SEC           \ D = 1 - r
450 LDA #1
460 SBC rr
470 STA d
480 LDA #0
490 SBC #0
500 STA d+1
510 LDA #0        \ x = 0, y = r
520 STA xx
530 LDA rr
540 STA yy
550 .loop
560 LDX xx        \ rows cy+-y, columns cx+-x
570 CLC
580 LDA cy
590 ADC yy
600 JSR row2
610 SEC
620 LDA cy
630 SBC yy
640 JSR row2
650 LDX yy        \ rows cy+-x, columns cx+-y
660 CLC
670 LDA cy
680 ADC xx
690 JSR row2
700 SEC
710 LDA cy
720 SBC xx
730 JSR row2
740 LDA xx        \ A = 2x, carry clear as x < 128
750 ASL A
760 BIT d+1
770 BMI dneg
780 ADC #5        \ D >= 0 so D = D + 2x + 5 - 2y
790 ADC d
800 STA d
810 BCC nocarry
820 INC d+1
830 .nocarry
840 LDA yy
850 ASL A
860 STA t
870 SEC
880 LDA d
890 SBC t
900 STA d
910 BCS noborrow
920 DEC d+1
930 .noborrow
940 DEC yy        \ y = y - 1
950 JMP next
960 .dneg
970 ADC #3        \ D < 0 so D = D + 2x + 3
980 ADC d
990 STA d
1000 BCC next
1010 INC d+1
1020 .next
1030 INC xx        \ x = x + 1
1040 LDA yy
1050 CMP xx
1060 BCS loop      \ repeat while y >= x
1070 RTS
1080 .row2
1090 TAY           \ Y = row, X = distance from centre
1100 CLC
1110 LDA rowlo,Y   \ pr = right hand pixel address
1120 ADC rlo,X
1130 STA pr
1140 LDA rowhi,Y
1150 ADC rhi,X
1160 STA pr+1
1170 LDA rowlo,Y   \ pl = left hand pixel address
1180 ADC llo,X     \ carry is clear as addresses are below &8000
1190 STA pl
1200 LDA rowhi,Y
1210 ADC lhi,X
1220 STA pl+1
1230 LDY #0        \ new = old EOR ((old EOR col) AND mask)
1240 LDA (pr),Y
1250 EOR col
1260 AND rmask,X
1270 EOR (pr),Y
1280 STA (pr),Y
1290 LDA (pl),Y
1300 EOR col
1310 AND lmask,X
1320 EOR (pl),Y
1330 STA (pl),Y
1340 RTS
1350 ]
1360 NEXT
1370 ENDPROC
