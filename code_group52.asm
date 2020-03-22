TITLE MASM Template    					(main.asm)

INCLUDE Irvine32.inc
main EQU start@0
.data

screenColumns		DWORD	40
screenLeftBoundry	BYTE	1
screenRightBoundry	BYTE	39
screenDownBoundry	BYTE	25
QuitFlag			BYTE	0


winCaption	BYTE	"Game Message", 0
winQuestion	BYTE	"YOU WIN!", 0dh, 0ah
			BYTE	"You are so powerful! Try again?", 0

lossCaption		BYTE	"Game Message", 0
lossQuestion	BYTE	"You Lose!", 0dh, 0ah
				BYTE	"Would you like to try again?", 0

Invader			BYTE	06h, 0	
InvaderMoveStep	BYTE	3
InvaderFrontColor	BYTE	white
InvaderBackColor	BYTE	green*16
InvaderX			BYTE	20
InvaderY			BYTE	25
OldInvaderX		BYTE	20
OldInvaderY		BYTE	25

BulletSymbol		BYTE	0fh, 0
BulletFrontColor	BYTE	lightblue
BulletBackColor		BYTE	blue*16
BulletFlag			BYTE	0
BulletX				BYTE	0
BulletY				BYTE	25
OldBulletX			BYTE	0
OldBulletY			BYTE	0

scoreColor	DWORD	white+(black*16)
scoreMsg	BYTE	"Score:", 0
score		DWORD	0
winScore	DWORD	10
scoreY		BYTE	27
scoreX		BYTE	25

lifeColor				DWORD	white+(black*16)
lifeWarningColor		DWORD	lightred+(lightblue*16)
lifeWarningToggleColor	DWORD	black+(black*16)
lifeWarningToggle		BYTE	0
lifeResetSymbol			BYTE	6 DUP(" ")
lifeMsg					BYTE	"Life:", 0
lifeY					BYTE	27
lifeX					BYTE	15
life					DWORD	5
initLife				DWORD	5

particleSymbol		BYTE	0fh, 0
particleResetSymbol	BYTE	" "
particleX			BYTE	?
particleY			BYTE	?
explosionFlag		BYTE	0
explosionFrontColor	BYTE	magenta
explosionBackColor	BYTE	gray*16

MonsterSymbol		BYTE	" O  O ", 0
MonsterSize			BYTE	6
MonsterResetSymbol	BYTE	6 DUP(" ")
MonsterInitX			BYTE	0
MonsterInitY			BYTE	0
MonsterX				BYTE	0
MonsterY				BYTE	1
MonsterFrontColor		BYTE	magenta
MonsterBackColor		BYTE	yellow*16
MonsterHitBoundryFlag	BYTE 	0
MonsterResetLine		BYTE	80 DUP(" ")


background BYTE	" "
backgroundColor DWORD (black*16)+black
frontColorMask BYTE 0Fh

secondroundCaption BYTE		"Game Message", 0
secondroundString  BYTE		"Go to second round!!!", 0 
thirdroundCaption BYTE		"Game Message",0
thirdroundString  BYTE		"Go to evil round!!!",0
secondScore DWORD   3
thirdScore  DWORD   5
secondroundFlag BYTE	0
thirdroundFlag  BYTE	0
restartFlag		BYTE	0

levelColor	DWORD	white+(black*16)
levelMsg	BYTE	"Level:", 0
level		DWORD   1
levelY		BYTE	27
levelX		BYTE	35

initmsg BYTE"	          -----------instruction------------", 0dh, 0ah, 0dh, 0ah
		BYTE"	The monster will randomly appear on the top of the screan",0dh, 0ah, 0dh, 0ah
		BYTE"	Players needs to control the craft to defeat the monsters",0dh, 0ah, 0dh, 0ah, 0dh, 0ah
		BYTE"	Here are the things players can do:", 0dh, 0ah, 0dh, 0ah
		BYTE"	1.Use A and D or LEFT and RIGHT to control the space craft", 0dh, 0ah, 0dh, 0ah
		BYTE"	2.Press SPACE to activate the missle",0dh, 0ah, 0dh, 0ah
		BYTE"	3.Press ESC to quit the game ",0dh, 0ah, 0dh, 0ah, 0dh, 0ah,0dh,0ah
		BYTE"                           :::WARNING:::                              ",0dh, 0ah
		BYTE"	There are three levels and you only have five lives.",0
		
level1msg	BYTE	"		--------------level1--------------", 0dh, 0ah, 0dh, 0ah,0
			
level2msg	BYTE	"		--------------level2--------------", 0dh, 0ah, 0dh, 0ah,0
		
level3msg	BYTE	"		--------------level3--------------", 0dh, 0ah, 0dh, 0ah,0
			
winmsg	BYTE		"		------You DEFEAT the Monster------", 0dh, 0ah, 0dh, 0ah				
		BYTE		"		--------------You WIN-------------" ,0

losemsg	BYTE		"		-------------You LOSE-------------" ,0

pickmsg BYTE		"		    keep going ? press Y or N " ,0

rulemsg BYTE 		"shooooooooooooooooooooting game", 0dh, 0ah, 0dh, 0ah ,0


;顯示畫面
mWrite MACRO msg
	LOCAL string
	.code
	pushad
	mov eax, black*16+(white)
	call SetTextColor
	call Clrscr
	
	mov dh, 20		; 位置
	mov dl, 17
	call Gotoxy
	mov edx, OFFSET rulemsg
	call writeString

	mov dh, 3
	mov dl, 0	
	call Gotoxy		; 重新定位游標，然後重新輸出一次字串
	mov edx, OFFSET msg
	call writeString 

	call readchar
	
	mov eax, black*16+(white)
	call SetTextColor
	call Clrscr
	
	popad
ENDM
.code
main PROC

start:
	mov restartFlag, 0
	call Clrscr		; clear screen
	mWrite initmsg
	mWrite level1msg
	cmp QuitFlag, 1
	call Intro
	

L0:
	call HandleKeyEvent	
	call ClearInvaderOldPos
	call ClearBulletOldPos
	call ClearMonster
	call ClearExplosion
	call CheckBulletHitMonster
	call UpdateMonster
	call ShowInvader
	call ShowBullet
	call ShowMonster
	call ShowExplosion
	call ShowLife
	call ShowScore	
	call ShowLevel
	call CheckLife
	cmp RestartFlag , 1
	je Start	
	
	
	add BulletFrontColor, 1
	add MonsterFrontColor, 2
	add explosionFrontColor, 3
	cmp QuitFlag, 1
	je Exit0
	jmp L0

Exit0:
	INVOKE ExitProcess, 0

main ENDP

Intro PROC
	pushad
	mov eax, backgroundColor
	call SetTextColor
	mov dh, 0
	mov dl, 0
	mov bx, dx
	mov eax, 40
	mov ecx, eax
	
L1:	
	mov eax, ecx
	mov ecx, 25
	
L0:
	mov dx, bx	
	call Gotoxy
	mov edx, offset background
	call WriteString
	inc bh
	loop L0
	mov bh, 0
	inc bl
	mov ecx, eax
	loop L1
	popad
	ret
Intro ENDP


;清除舊的游標位置
ClearInvaderOldPos PROC USES eax edx
	mov dh, OldInvaderY
	mov dl, OldInvaderX
	call ClearInvaderPosBlack
	mov al, InvaderY
	mov OldInvaderY, al
	mov al, InvaderX
	mov OldInvaderX, al
	ret
ClearInvaderOldPos ENDP

;把舊游標位置變成黑色
ClearInvaderPosBlack PROC USES eax edx
	mov ah, black
	mov al, black
	call SetTextColor
	call Gotoxy
	mov edx, offset background
	call WriteString
	ret
ClearInvaderPosBlack ENDP

;清除舊子彈位置
ClearBulletOldPos PROC USES eax edx
	mov dh, OldBulletY
	mov dl, OldBulletX
	call ClearBulletPos
	mov al, BulletY
	mov OldBulletY, al
	ret
ClearBulletOldPos ENDP

;把舊子彈位置變成黑色
ClearBulletPos PROC USES eax
	mov eax, backgroundColor
	call SetTextColor
	call Gotoxy
	push edx
	mov edx, offset background
	call WriteString
	pop edx
	ret
ClearBulletPos ENDP

;顯示子彈位置
ShowBullet PROC USES eax edx
	cmp BulletFlag, 0
	je dontshow
	cmp OldBulletY, 5
	jbe disappear
	cmp explosionFlag, 1
	je	disappear
	mov dh, BulletY
	mov dl, BulletX
	call Gotoxy
	xor eax, eax
	mov al, BulletBackColor
	mov dl, frontColorMask
	and BulletFrontColor, dl
	add al, BulletFrontColor
	call SetTextColor
	mov edx, offset BulletSymbol
	call WriteString
	dec BulletY
	jmp dontshow
	
disappear:
	mov BulletFlag, 0
dontshow:
	ret	
ShowBullet ENDP

;空白鍵發射子彈
ActivateBullet PROC USES eax
	cmp BulletFlag, 1
	je stay
	mov BulletFlag, 1
	mov al, InvaderY
	dec al
	mov BulletY, al
	mov OldBulletY, al
	mov al, InvaderX
	mov BulletX, al
	mov OldBulletX, al

stay:
	ret
ActivateBullet ENDP

;顯示游標位置
ShowInvader PROC USES eax edx
	xor eax, eax
	mov al, InvaderBackColor
	mov dl, frontColorMask
	and InvaderFrontColor, dl
	add al, InvaderFrontColor
	call SetTextColor

	mov dh, InvaderY
	mov dl, InvaderX
	call Gotoxy
	mov edx, offset Invader
	call WriteString
	ret
ShowInvader ENDP

;清除怪物
ClearMonster PROC USES eax edx
	mov eax, backgroundColor
	call SetTextColor
	mov dh, MonsterY
	mov dl, MonsterX
	call Gotoxy
	mov edx, offset MonsterResetSymbol
	call WriteString
	ret
ClearMonster ENDP

;更新怪物位置
UpdateMonster PROC USES eax
	cmp explosionFlag, 1
	je resetMonsterPostion
	mov al, 30				; al 用來決定下邊界
	sub al, MonsterSize
	cmp MonsterY, al
	je monsterHitBoundry
	inc MonsterY
	jmp continue
	
monsterHitBoundry:
	mov MonsterHitBoundryFlag, 1
	mov explosionFlag, 0
	add MonsterBackColor, 16
	
resetMonsterPostion:
	call ClearMonsterLine	
	mov al, MonsterInitY
	mov MonsterY, al
	
	; 要注意這個random是不是每一次都一樣(Randomize)
	call Randomize
	mov eax, 40
	call RandomRange
	mov MonsterX, al
	
continue:
	ret
UpdateMonster ENDP

ClearMonsterLine PROC USES eax edx
	mov eax, backgroundColor
	call SetTextColor
	mov dh, MonsterY
	mov dl, 0
	call Gotoxy
	mov edx, offset MonsterResetLine
	call WriteString
	ret
ClearMonsterLine ENDP

;顯示怪物
ShowMonster PROC USES eax edx
	xor eax, eax
	mov al, MonsterBackColor
	mov dl, frontColorMask
	and MonsterFrontColor, dl
	add al, MonsterFrontColor
	call SetTextColor
	
	mov dh, MonsterY
	mov dl, MonsterX
	
	call Gotoxy
	mov edx, offset MonsterSymbol
	call WriteString
	ret
ShowMonster ENDP

;顯示分數
ShowScore PROC USES eax edx
	mov eax, scoreColor
	call SetTextColor
	mov dh, scoreY
	mov dl, scoreX
	call Gotoxy
	mov edx, offset scoreMsg
	call WriteString
	add dl, 7
	call Gotoxy
	cmp explosionFlag, 0
	je remain
	inc score
	mov explosionFlag, 2
	
remain:
	mov eax, score
	call WriteDec
	ret
ShowScore ENDP

;顯示關卡
ShowLevel PROC USES eax edx
	mov eax, levelColor
	call SetTextColor
	mov dh, levelY
	mov dl, levelX
	call Gotoxy
	mov edx, offset levelMsg
	call WriteString
	add dl, 7
	call Gotoxy
	cmp secondroundFlag, 0 ;若secondroundFlag=0則維持
	je remain
	mov level, 2
	cmp thirdroundFlag, 0  ;若thirdroundFlag=0則維持
	je remain
	mov level, 3

	
remain:
	mov eax, level
	call WriteDec
	ret
ShowLevel ENDP

;清空生命值
ClearShowLife PROC USES eax edx
	mov eax, 00000000h
	call SetTextColor
	mov dh, lifeY
	mov dl, lifeX
	call Gotoxy
	mov edx, offset lifeResetSymbol
	call WriteString
	ret
ClearShowLife ENDP

;顯示生命
ShowLife PROC USES eax edx
	mov eax, lifeColor
	cmp life, 1
	ja nowarning
	call clearShowLife
	mov eax, lifeWarningColor
	cmp lifeWarningToggle, 1
	je toggle
	mov eax, lifeWarningToggleColor
	mov lifeWarningToggle, 1
	jmp nowarning

toggle:
	mov lifeWarningToggle, 0

nowarning:
	call SetTextColor
	mov dh, lifeY
	mov dl, lifeX
	call Gotoxy
	mov edx, offset lifeMsg
	call WriteString
	add dl, 6
	call Gotoxy
	cmp MonsterHitBoundryFlag, 0
	je remain
	dec life
	mov MonsterHitBoundryFlag, 0

	
remain:
	mov eax, life
	call WriteDec
	ret
ShowLife ENDP

;擊中判定
CheckBulletHitMonster PROC USES eax
	; if (((Y == BulletY) || (Y == BulletY)) and (MonsterY <= BulletX <= MonsterY+4)) 
	; then explosionFlag = 1
	; else nochange
	mov al, MonsterY
	sub al, BulletY		; MonsterY-BulletY=1或0 都可以改變
	cmp al, 0
	je hit
	cmp al, 1
	je hit
	jmp nochange
	

hit:	
	mov al, MonsterX
	cmp BulletX, al
	jb nochange
	add al, MonsterSize
	cmp BulletX, al
	ja nochange
	mov explosionFlag, 1
	add MonsterBackColor, 16
	
nochange:
	ret
CheckBulletHitMonster ENDP

;產生爆炸
ShowExplosion PROC USES eax edx
	cmp explosionFlag, 0
	je	noexplosion
	
	xor eax, eax
	mov al, explosionBackColor
	mov dl, frontColorMask
	and explosionFrontColor, dl
	add al, explosionFrontColor
	call SetTextColor
	
	; particleX/Y are used in clearExplosion
	mov ah, BulletY
	mov particleY, ah
	mov al, BulletX
	mov particleX, al
	
	;draw left-up  particle
	mov ah, BulletY
	sub ah, 1
	mov dh, ah
	mov al, BulletX
	sub al, 1
	mov dl, al
	call Gotoxy
	mov edx, offset particleSymbol
	call WriteString
	
	;draw left-bottom particle
	mov ah, BulletY
	add ah, 1
	mov dh, ah
	mov al, BulletX
	sub al, 1
	mov dl, al
	call Gotoxy
	mov edx, offset particleSymbol
	call WriteString
	
	;draw right-bottom particle
	mov ah, BulletY
	add ah, 1
	mov dh, ah
	mov al, BulletX
	add al, 1
	mov dl, al
	call Gotoxy
	mov edx, offset particleSymbol
	call WriteString
	
	;draw right-up particle
	mov ah, BulletY
	sub ah, 1
	mov dh, ah
	mov al, BulletX
	add al, 1
	mov dl, al
	call Gotoxy
	mov edx, offset particleSymbol
	call WriteString
	
	;reset Bullet position
	mov BulletY, 0
	mov BulletX, 0
	add MonsterBackColor, 16
	
noexplosion:
	ret
ShowExplosion ENDP 

;清除爆炸
ClearExplosion PROC USES eax edx
	cmp explosionFlag, 2
	jne nothingtoclear
	
	mov eax, backgroundColor
	call SetTextColor
	
	;reset left-up  particle
	mov ah, particleY
	sub ah, 1
	mov dh, ah
	mov al, particleX
	sub al, 1
	mov dl, al
	call Gotoxy
	mov edx, offset particleResetSymbol
	call WriteString
	
	;reset left-bottom particle
	mov ah, particleY
	add ah, 1
	mov dh, ah
	mov al, particleX
	sub al, 1
	mov dl, al
	call Gotoxy
	mov edx, offset particleResetSymbol
	call WriteString
	
	;reset right-bottom particle
	mov ah, particleY
	add ah, 1
	mov dh, ah
	mov al, particleX
	add al, 1
	mov dl, al
	call Gotoxy
	mov edx, offset particleResetSymbol
	call WriteString
	
	;reset right-up particle
	mov ah, particleY
	sub ah, 1
	mov dh, ah
	mov al, particleX
	add al, 1
	mov dl, al
	call Gotoxy
	mov edx, offset particleResetSymbol
	call WriteString
	
	mov explosionFlag, 0
	
nothingtoclear:	
	ret
ClearExplosion ENDP

;生命判定
CheckLife PROC USES eax ebx edx
	.IF secondroundFlag == 0 ;判斷是否為第二關
	 mov eax, secondScore
	 cmp score, eax
	 je L6
	.ENDIF
	.IF thirdroundFlag == 0  ;判斷是否為第三關
	 mov eax, thirdScore
	 cmp score, eax
	 je L7
	.ENDIF
	mov eax, winScore
	cmp score, eax
	jne L4
	mWrite winmsg
	
	mov ebx, OFFSET winCaption
	mov edx, OFFSET winQuestion
	call MsgBoxAsk
	
	mov restartFlag, 1
	
	cmp eax, 6	; user press 'y'
	je L5
	mov QuitFlag, 1
	mov restartFlag, 0
	ret

L7: 
	mWrite level3msg
	call intro
	mov thirdroundFlag, 1
	ret
	
L6: 
	mWrite level2msg
	call intro
	mov secondroundFlag, 1
	ret

L5: ;三關都贏了要繼續的話就初始化
	mov restartFlag, 1
	mov eax, initLife
	mov life, eax
	mov score, 0
	mov level, 1
	mov secondroundFlag, 0
	mov thirdroundFlag, 0
	mov restartFlag, 1
	ret
	
L4:	;判斷還有沒有命
	cmp life, 0
	je L0
	ret
	
L0: ;沒有命了
	mWrite losemsg
	mov ebx, OFFSET lossCaption
	mov edx, OFFSET lossQuestion
	call MsgBoxAsk
	mov restartFlag, 1
	cmp eax, 6
	je L1
	mov QuitFlag, 1
	mov restartFlag, 0
	
	
L1: ;初始化值
	mov eax, initLife
	mov life, eax
	mov score, 0
    mov BulletFlag, 0 
	mov level, 1
	mov secondroundFlag, 0
	mov thirdroundFlag, 0
	ret	
CheckLife ENDP

;判斷鍵盤輸入
HandleKeyEvent PROC
	pushad
	mov eax, 100
	call Delay		; 延遲
	call ReadKey	; 讀按鍵
	
	cmp al, 'a'
	je Left
	cmp al, 'A'
	je Left
	cmp ax, 4B00h	; Gray left Arrow
	je Left
	
	cmp al, 'd'
	je Right
	cmp al, 'D'
	je Right
	cmp ax, 4D00h	; Gray Right Arrow
	je Right
	
	cmp al, ' '
	je Fire
	cmp dx, 001Bh	; key ESC
	je Quit
	jmp	L1
	
Left:
	call HandleKeyEventLeftMove
	jmp L1
	
Right:
	call HandleKeyEventRightMove
	jmp L1
	
Fire:
	call ActivateBullet 
	jmp L1
	
Quit:
	mov QuitFlag, 1
	
L1:
	popad
	ret
HandleKeyEvent ENDP 

;左邊輸入
HandleKeyEventLeftMove PROC USES eax
	mov al, screenLeftBoundry
	inc al
	cmp InvaderX, al	; check left boundry
	jbe stay
	mov al, InvaderMoveStep
	sub InvaderX, al
	
stay:
	ret
HandleKeyEventLeftMove ENDP 

;右邊輸入
HandleKeyEventRightMove PROC USES eax
	mov al, screenRightBoundry
	dec al
	cmp InvaderX, al	; check right boundry
	jae stay
	mov al, InvaderMoveStep
	add InvaderX, al
	
stay:
	ret
HandleKeyEventRightMove ENDP 

END main 