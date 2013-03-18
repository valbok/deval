My_stack	Segment	stack
		dw	256 dup(?)
my_stack	ends
data		segment
Fini		db	'DEval.ini',0
inides		db	1 dup(0)
fnameDes	db	1 dup(0)
fname		db	12 dup(0),0
FnameLen	db	1 dup(0)
DECodefile	db	12 dup(0),0
DEcodeFDes	db	1 dup(0)
buf		db	1 dup(0)
ErrorOPen	db	'Ошибка открытия файла: '
ErrorCreate	db	'Ошибка создания файла: '
Password	db	25 dup(0)
PasswordCopy	db	25 dup(0)
PassLen		db	1 dup(0)
s1		db	1 dup(0)
s2		db	1 dup(0)
s3		db	1 dup(0)
DTA		db	64 dup(0)
ErrAx		db	'Ошибка чтения: '
FilePRINT	db	13,10,'Исходный файл: ';17
PAssPRINT	db	13,10,'Пароль:        ';
PassYEs		db	'Yes';3
PassNo		db	'No'
CodeFilePrint	db	13,10,'Конечный файл: ';17

Status		db	13,10,'Состояние:     ';17
DOt		db	'.'
WellDone	db	'HaPpY NeW yEar!';17
Titl		db	'           -──=======******// __DEVAL__ \\******=======──--',13,10
Tabl		db	'\\\\\\\\\\\|||||||||||///////////-----------'
BackSpace	db	8
SiCopy		dw	1 dup(0)
IndexPass	dw	1 dup(0)
IndexGRoup	db	1 dup(0)
IndExTabl	db	1 dup(0)

PassTable	db	256 dup(0)

HighB		db	240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255
LowB		db	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

data		ends
;=========================
printtable	macro
		push	si
		push	ax
		mov	ax,0
		mov	al,Indextabl
		mov	si,ax

               	prn	tabl+si,1	
		prn	backspace,1
		inc	al
		cmp	al,15+6+12+10;3
		ja	albig
		mov	IndexTabl,al
		jmp	albig1
albig:		mov	Indextabl,0
albig1:		
		pop	ax
        	pop	si
			endm
;===========================
CloseFile	macro	des
	push	bx
	push	ax
	mov	bx,0
	mov	bl,des
	mov	ah,3eh
	int	21h
	pop	ax
	pop	bx
		endm
;----------------------------
prn	macro	str,len
	push	ax
	push	dx
	push	cx
	push	bx
	mov	bx,1
	mov	cx,len
	mov	ah,40h
	lea	dx,str
	int	21h
	pop	bx
	pop	cx
	pop	dx
	pop	ax
		endm
;----------------------------
code	segment
	assume	cs:code,ds:data,ss:my_stack
OpenFile	proc
	push	ax
	push	dx
;------
	mov	ah,3dh	
	mov	dx,si
	mov	al,0
	int	21h
	jc	er
	mov	[di],al
;------
qqq:	pop	dx
	pop	ax
	jmp	exx
er:	prn	ErrorOpen,23
	prn	[si],12
	jmp	exit
	jmp	qqq
exx:    	ret
OpenFile	endp
;=======================
Extract	proc
	push	bx
	push	si
	mov	si,0
	mov	bx,0	
	mov	bl,inides	
        lea	dx,buf
	mov	cx,1
nx1:	
	mov	ah,3fh
	int	21h
	cmp	[buf],13
	jne	nx
	mov	ah,3fh
	int	21h
	pop	bx
	pop	si
		ret
nx:
	call	ExtrName
	jmp	nx1
Extract	endp
ExtrName	proc
	push	dx
	push	bx
	mov	bx,bp
	mov	dh,buf
	mov	[bx+si],dh
	inc	si
	pop	bx
	pop 	dx
		ret
ExtrName	endp
;======================
SetPass		proc
                cmp	[password],'#'
		je	rvnPass
ExitSet:	ret
rvnPass:	mov	[password],0
		mov	[password+3],'$'
		jmp	ExitSet
SetPass		endp
;[=========================================]

;------------------------
SetS1	proc
   		push	si	
		push	dx
		push	cx	
	mov	si,0
	mov	cx,0
		mov	ah,4eh
		lea	dx,[fname]
		int	21h
		jc	errS1
	
	mov	dl,[dta+26]
	mov	s1,dl

		pop	cx
		pop	dx
        	pop	si
			ret
ErrS1:		lea	si,fname
		jmp	er
			ret
SetS1	endp
;----------------------------
SetS2		proc
		push	dx
	mov	dl,[dta+27]
	mov	s2,dl
		pop	dx
	                ret
SetS2		endp
;------------------------
SetS3		proc
		push	ax
		push	si
        	push	dx
		mov	cx,0

		mov	si,0
	mov	cl,PassLen
AgaS3:	mov	dl,[password+si]
	add	[s3],dl
	inc	si

	loop	agas3		
		pop	dx				
		pop	si
		pop	ax
	             ret
SetS3		endp
;==========================
LenPassword	proc
	push	si	
	mov	si,0
agaPlen:	cmp	[password+si],'$'
	je	EoP
	inc	si
	cmp	si,25
	jb	agaPlen
	mov	ax,si
	mov	[PassLen],al
ExtLen:
        pop	si
		ret
EOP:	push	ax
	mov	ax,si
	mov	[passLen],al
	pop	ax
	jmp	ExtLen
LenPassword	endp
;-------------------------\
createDECodeFile	proc
		mov	ah,3ch
		lea	dx,[DEcodefile]
		xor	cx,cx
		int	21h
		jc	ErrCrt
		mov	[DECodeFDes],al
			ret
ErrCrt:		prn	ErrorCreate,23
		prn	[DEcodefile],12
		jmp	exit
CreateDECodeFile	endp
;=============================
findByte	proc
		push	si
		push	di
		push	ax
		push	bx
	mov	di,0
	mov	si,0
	mov	bx,0
	mov	cx,256
	mov	al,buf
agfind:	cmp	[PassTable+bx],al
	je	rvnbyte	
	inc	bx
	inc	si
	cmp	si,15
	ja	sibol
sii:    loop	agfind
exitFind:	pop	bx
		pop	ax
		pop	di
		pop	si
			ret
rvnbyte:	push	dx
		shl	si,4
;		mov	dh,[highb+si]
;		mov	dl,[lowb+di]
;		add	dh,dl
		add	si,di
		mov	dx,si
		mov	buf,dl
		pop	dx
		jmp	ExitFind
sibol:		inc	di
		mov	si,0
		jmp	sii
FindByte	endp
;==============================
DEcoder	proc
	mov	si,0
	mov	di,0
	mov	bp,0
;___________________________
agacode:  
		mov	ax,0
		mov	bx,0

		mov	bl,fnamedes	
	mov	ah,3fh		;read from
	mov	cx,1
	lea	dx,buf
	int	21h
;-----
        cmp	ax,0
	je	bp1	

	call	DEcodeBuf
	call	findByte
	call	writeCodefile
	inc	si
		mov	bx,si
	cmp	bl,[PassLen]
	jb	agacode
	mov	si,0
	inc	di
	cmp	di,3
	jb	agacode
	call	modifiedPass
	mov	si,0
	mov	di,0
;	prn	dot,1
	printtable
	jmp	agacode
bp1:	
	prn	welldone,17
		ret
ax01:	prn	ErrAx,15
	prn	Fname,12
DEcoder	endp
;-------------- ===============
ModifiedPass	proc
		mov	si,0
		mov	ax,0
		mov	cx,0
		mov	al,PassLen
		mov	cx,ax
		mov	di,ax
		dec	di
agamod:		mov	al,password+di
	
		add	[password+si],al
		dec	di
		inc	si
		loop	agamod

			ret
		
ModifiedPass	endp
;============================
DECodeBuf	proc
		push	bx
		push	cx
		push	ax
		push	dx
	mov	bh,[buf]
	mov	cl,[s1+di]
	add	cl,[password+si]
	sub	cl,buf
	mov	ax,si
	mov	dx,di
	inc	ax
	inc	dx
	mul	dx
	add	cx,ax	
	mov	[buf],cl
GoBuf:		pop	dx
		pop	ax
		pop	cx
		pop	bx
			ret
DECodeBuf	endp
;-----------********************
WriteCodeFile	proc
		push	bx
		push	ax
		push	cx
		push	dx
	mov	bx,0
	mov	bl,[DEcodeFdes]
	mov	ah,40h
	mov	cx,1
	lea	dx,buf
	int	21h
		pop	dx
		pop	cx
		pop	ax
		pop	bx
			ret
WriteCodeFile	endp
;================================
CopyPassword	proc
		push	si
		push	dx
        	mov	cx,0
		mov	cl,passlen
		mov	si,0
copyp:		mov	dl,[password+si]
		mov	[passwordCopy+si],dl
		inc	si
		loop	copyp
		pop	dx
		pop	si
		ret
copyPassword	endp
;---------------------------------------
createTable	proc
		inc	IndexGroup

		mov	ax,0
		mov	cx,256

nxtcrt1:	mov	al,passLen
		mov	di,ax
		dec	di
		mov	si,0
nextcrt:	mov	bx,indexPass
		cmp	bx,256
		jae	QuitCrtTBL

		mov	ah,[passwordCopy+si]
		mov	al,[password+di]

		call	encrypt
		call	checkTable
		inc	IndexPass

		mov	bx,indexPass

		mov	PassTable[bx-1],al
		mov	[passwordCopy+si],al
		inc	si
		dec	di
		mov	dx,si
		cmp	dl,passLen
		jb	nextcrt
		inc	IndexGroup
		loop	nxtcrt1
QuitCrttbl:			ret
CreateTable 	endp
;======================================
encrypt		proc
		add	al,ah
		mov	ah,0
		inc	si
		sub	ax,si
		dec	si
		add	al,IndexGroup

		ret
encrypt		endp
;---------------------------------------
CheckTable	proc
		push	si	
		mov	[sicopy],si
		push	cx
		mov	cx,0	
newchk:		mov	cx,indexpass
		cmp	cx,0
		je	jkm
		mov	si,0		
chtbl:		cmp	al,PassTable+si
		je	ravnoPass
		inc	si		
                loop	chtbl
jkm:		pop	cx
	       	pop	si
			ret
ravnoPass:     	
		inc	al
		jmp	newchk
CheckTable	endp
;=================================

;Body=========*********==========***********
begin:	
	mov	ax,data
	mov	ds,ax
	mov	ah,1ah
	lea	dx,dta
	int	21h

	prn	Titl,68-7
	lea	si,fini
	lea	di,inides
	call	OpenFile

	lea	bp,fname
	call	Extract
	lea	bp,password
	call	Extract
	lea	bp,DECodefile
	call	Extract

	prn	fileprint,17
	prn	Fname,12
	prn	PAssPrint,17
	cmp	password,'#'
	jne	Estpass
	prn	PassNo,2
DaliPrint:
	prn	CodeFilePrint,17
	prn	DECodeFIle,12
	jmp	goopen
EstPass:	prn	passYEs,3
		jmp	DaliPrint
goopen:
	prn	status,17
	call	setpass

	lea	si,fname
	lea	di,fnamedes
	call	OpenFile
	call	CreateDeCodeFile	
	call	lenPassword	
	Call	setS1	
	call	SetS2	
	call	setS3	

	call	copypassword
	call	CreateTable


	call	modifiedpass
	call	DEcoder


Exit:

	mov	ax,4C00h
	int	21h
code	ends
	END	BEGIN