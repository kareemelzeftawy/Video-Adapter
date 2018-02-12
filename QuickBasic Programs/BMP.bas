'PRINTER PORT VIDEO ADAPTER - BMP VERSION
CLS: SCREEN 12 '12 = 640 X 480 16
FOR I& = 0 TO 15: PALETTE I&, (65536 * I& + 256 * I& + I&) * 4
NEXT I&
COLOR 10
LINE (1, 1)-(256, 247), , B: LINE (3, 3)-(254, 245), , B
LINE (300, 1)-(255, 247), , B: LINE (303, 3)-(553, 245), , B
LOCATE 16, 10: PRINT "LIVE VIDEO"
LOCATE 16, 48: PRINT "STORED PICTURE"
LOCATE 17, 1: PRINT "** PRINTER PORT VIDEO ADAPTER **"
LOCATE 17, 40: PRINT "OPTIONS; Q=QUIT, S=SAVE, V=VIEW"
LOCATE 18, 1: PRINT "AVAILABLE FILES;": LOCATE 19, 1: FILES "*.BMP"
START: OUT &H37A, 2 'WRITE PICTURE DATA TO RAM
FOR A = 1 TO 6000: NEXT A 'DELAY FOR V SYNC
OUT &H37A, 4 'READ DATA, RESET
DIM BARY%(0 TO 29600): V2 = -16 'STORE REVERSE & WRITE NORMAL
FOR V = 250 TO 0 STEP -1 'STORE IN ARRAY & ON SCREEN
    B = V * 128
    PSET (0, V2), 0: V2 = V2 + 1
    FOR H = 0 TO 127
        OUT &H37A, 0: OUT &H37A, 1: C = INP(&H379) AND &HF0: PSET STEP(1, 0), C / 16
        OUT &H37A, 0: OUT &H37A, 1: D = INP(&H379) \ 16: PSET STEP(1, 0), D
        IF V <= 230 THEN BARY%(B) = C + D: B = B + 1
    NEXT H
NEXT V
key$ = INKEY$ 'GET USERS RESPONSE
IF key$ = "Q" OR key$ = "q" THEN END
IF key$ = "S" OR key$ = "s" THEN 'SAVE PICTURE TO DISK
    LOCATE 18, 40: INPUT "SAVE FILE NAME? ", FILE$
    LOCATE 1, 40: PRINT "                                                "
    FILE$ = FILE$ + ".BMP": OPEN FILE$ FOR BINARY AS #1
    DATA 66,77,246,115,0,0,0,0,0,0,118,0,0,0,40,0
    DATA 0,0,255,0,0,0,230,0,0,0,1,0,4,0,0,0
    DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    DATA 0,0,0,0,16,16,16,0,32,32,32,0,48,48,48,0
    DATA 64,64,64,0,80,80,80,0,96,96,96,0,112,112,112,0
    DATA 128,128,128,0,144,144,144,0,160,160,160,0,176,176,176,0
    DATA 192,192,192,0,208,208,208,0,224,224,224,0,240,240,240,0
    FOR A = 1 TO 118: READ B: C$ = CHR$(B): PUT #1, A, C$: NEXT A
    FOR A = 119 TO 29559: PUT #1, (A), BARY%(A - 119): NEXT A
    RESTORE: CLOSE #1
END IF
IF key$ = "V" OR key$ = "v" THEN 'GET PICTURE FROM DISK
    LOCATE 18, 40: INPUT "VIEW FILE NAME? ", FILE$
    LOCATE 18, 40: PRINT "                                               "
    FILE$ = FILE$ + ".BMP": OPEN FILE$ FOR BINARY AS #1
    B = 1
    FOR V = 230 TO 1 STEP -1 'REVERSE ORDER FOR .BPB FILE
        PSET (300, V), 0
        FOR H = 1 TO 128
            GET #1, B + 118, BARY%(B)
            PSET STEP(1, 0), (BARY%(B) AND &HF0) / 16
            PSET STEP(1, 0), BARY%(B) AND &HF
            B = B + 1
        NEXT H
    NEXT V: CLOSE #1
END IF
LOCATE 18, 1: PRINT "AVAILABLE FILES; ": LOCATE 19, 1: FILES "*.BMP"
GOTO START 'RESTART FOR CONTINUOUS UPDATING


