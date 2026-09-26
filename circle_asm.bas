10 REM Bresenham's circle in 6502 assembler
20 REM Writes pixels straight into MODE 1 screen memory
30 xx=&70:yy=&71:d=&72:t=&74:px=&76:py=&78
40 scr=&7A:cx=&7C:cy=&7E:rr=&7F:ua=&80:va=&81
50 MODE1
60 PROCassemble
70 ?cx=160 MOD 256:cx?1=160 DIV 256
80 ?cy=127:?rr=127
90 TIME=0
100 CALL circle
110 PRINT TIME
120 END
130 DEF PROCassemble
140 LOCAL i,a,pass
150 DIM rowlo 31,rowhi 31,mask 3,code 300
160 FOR i=0 TO 31
170 a=&3000+i*640
180 rowlo?i=a MOD 256:rowhi?i=a DIV 256
190 NEXT
200 mask?0=&88:mask?1=&44:mask?2=&22:mask?3=&11
210 FOR pass=0 TO 2 STEP 2
220 P%=code
230 [OPT pass
240 .circle
250 LDA rr        \ d = 3 - 2*r
260 ASL A
270 STA t
280 LDA #0
290 ROL A
300 STA t+1
310 SEC
320 LDA #3
330 SBC t
340 STA d
350 LDA #0
360 SBC t+1
370 STA d+1
380 LDA #0        \ x = 0, y = r
390 STA xx
400 LDA rr
410 STA yy
420 .loop
430 LDA xx        \ plot (cx+-x, cy+-y)
440 STA ua
450 LDA yy
460 STA va
470 JSR plot4
480 LDA yy        \ plot (cx+-y, cy+-x)
490 STA ua
500 LDA xx
510 STA va
520 JSR plot4
530 LDA d+1
540 BMI dneg
550 SEC           \ d >= 0 so t = x - y and y = y - 1
560 LDA xx
570 SBC yy
580 STA t
590 LDA #0
600 SBC #0
610 STA t+1
620 DEC yy
630 LDX #10
640 JMP upd
650 .dneg
660 LDA xx        \ d < 0 so t = x
670 STA t
680 LDA #0
690 STA t+1
700 LDX #6
710 .upd
720 ASL t         \ d = d + 4*t + X
730 ROL t+1
740 ASL t
750 ROL t+1
760 TXA
770 CLC
780 ADC t
790 STA t
800 LDA t+1
810 ADC #0
820 STA t+1
830 CLC
840 LDA d
850 ADC t
860 STA d
870 LDA d+1
880 ADC t+1
890 STA d+1
900 INC xx        \ x = x + 1
910 LDA yy
920 CMP xx
930 BCS loop      \ repeat while y >= x
940 RTS
950 .plot4
960 CLC           \ px = cx + u
970 LDA cx
980 ADC ua
990 STA px
1000 LDA cx+1
1010 ADC #0
1020 STA px+1
1030 JSR plotv
1040 SEC           \ px = cx - u, then fall into plotv
1050 LDA cx
1060 SBC ua
1070 STA px
1080 LDA cx+1
1090 SBC #0
1100 STA px+1
1110 .plotv
1120 CLC           \ plot (px, cy+v)
1130 LDA cy
1140 ADC va
1150 STA py
1160 JSR plot
1170 SEC           \ plot (px, cy-v), falls into plot
1180 LDA cy
1190 SBC va
1200 STA py
1210 .plot
1220 LDA py        \ X = character row
1230 LSR A
1240 LSR A
1250 LSR A
1260 TAX
1270 LDA px        \ scr = (px DIV 4)*8
1280 AND #&FC
1290 ASL A
1300 STA scr
1310 LDA px+1
1320 ROL A
1330 STA scr+1
1340 CLC           \ scr = scr + &3000 + row*640
1350 LDA scr
1360 ADC rowlo,X
1370 STA scr
1380 LDA scr+1
1390 ADC rowhi,X
1400 STA scr+1
1410 LDA px        \ X = pixel within byte
1420 AND #3
1430 TAX
1440 LDA py        \ Y = pixel row within cell
1450 AND #7
1460 TAY
1470 LDA mask,X    \ set both bits for colour 3
1480 ORA (scr),Y
1490 STA (scr),Y
1500 RTS
1510 ]
1520 NEXT
1530 ENDPROC
