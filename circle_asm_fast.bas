10 REM Bresenham's circle in 6502 assembler, faster version
20 REM Writes pixels straight into MODE 1 screen memory
30 REM Centre (xc,yc) in pixels from top left, radius r up to 127
40 xc=160:yc=127:r=127
50 xx=&70:yy=&71:d=&72:t=&74:pr=&76:pl=&78:cy=&7A:rr=&7B
60 MODE1
70 PROCtables
80 PROCassemble
90 ?cy=yc:?rr=r
100 TIME=0
110 CALL circle
120 PRINT TIME
130 END
140 DEF PROCtables
150 LOCAL i%,a%,b%
160 DIM rowlo 255,rowhi 255,mask 3
170 DIM rlo 127,rhi 127,rmask 127,llo 127,lhi 127,lmask 127
180 FOR i%=0 TO 255
190 a%=&3000+(i% DIV 8)*640+(i% AND 7)
200 rowlo?i%=a%:rowhi?i%=a% DIV 256
210 NEXT
220 ?mask=&88:mask?1=&44:mask?2=&22:mask?3=&11
230 FOR i%=0 TO 127
240 a%=xc+i%:b%=xc-i%
250 rlo?i%=(a% DIV 4)*8:rhi?i%=(a% DIV 4)*8 DIV 256:rmask?i%=mask?(a% AND 3)
260 llo?i%=(b% DIV 4)*8:lhi?i%=(b% DIV 4)*8 DIV 256:lmask?i%=mask?(b% AND 3)
270 NEXT
280 ENDPROC
290 DEF PROCassemble
300 LOCAL pass
310 DIM code 200
320 FOR pass=0 TO 2 STEP 2
330 P%=code
340 [OPT pass
350 .circle
360 SEC           \ D = 1 - r
370 LDA #1
380 SBC rr
390 STA d
400 LDA #0
410 SBC #0
420 STA d+1
430 LDA #0        \ x = 0, y = r
440 STA xx
450 LDA rr
460 STA yy
470 .loop
480 LDX xx        \ rows cy+-y, columns cx+-x
490 CLC
500 LDA cy
510 ADC yy
520 JSR row2
530 SEC
540 LDA cy
550 SBC yy
560 JSR row2
570 LDX yy        \ rows cy+-x, columns cx+-y
580 CLC
590 LDA cy
600 ADC xx
610 JSR row2
620 SEC
630 LDA cy
640 SBC xx
650 JSR row2
660 LDA xx        \ A = 2x, carry clear as x < 128
670 ASL A
680 BIT d+1
690 BMI dneg
700 ADC #5        \ D >= 0 so D = D + 2x + 5 - 2y
710 ADC d
720 STA d
730 BCC nocarry
740 INC d+1
750 .nocarry
760 LDA yy
770 ASL A
780 STA t
790 SEC
800 LDA d
810 SBC t
820 STA d
830 BCS noborrow
840 DEC d+1
850 .noborrow
860 DEC yy        \ y = y - 1
870 JMP next
880 .dneg
890 ADC #3        \ D < 0 so D = D + 2x + 3
900 ADC d
910 STA d
920 BCC next
930 INC d+1
940 .next
950 INC xx        \ x = x + 1
960 LDA yy
970 CMP xx
980 BCS loop      \ repeat while y >= x
990 RTS
1000 .row2
1010 TAY           \ Y = row, X = distance from centre
1020 CLC
1030 LDA rowlo,Y   \ pr = right hand pixel address
1040 ADC rlo,X
1050 STA pr
1060 LDA rowhi,Y
1070 ADC rhi,X
1080 STA pr+1
1090 LDA rowlo,Y   \ pl = left hand pixel address
1100 ADC llo,X     \ carry is clear as addresses are below &8000
1110 STA pl
1120 LDA rowhi,Y
1130 ADC lhi,X
1140 STA pl+1
1150 LDY #0
1160 LDA rmask,X   \ set both pixels to colour 3
1170 ORA (pr),Y
1180 STA (pr),Y
1190 LDA lmask,X
1200 ORA (pl),Y
1210 STA (pl),Y
1220 RTS
1230 ]
1240 NEXT
1250 ENDPROC
