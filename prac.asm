.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
clearArea_C PROTO C, value:SDWORD, value1: SDWORD
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C
rand PROTO C, value:SDWORD

.data
lost1 db \
"                    db       .d88b.  .d8888. d888888b ",13,10,
"                    88      .8P  Y8. 88'  YP `~~88~~' ",13,10,
"                    88      88    88 `8bo.      88    ",13,10,
"                    88      88    88   `Y8b.    88    ",13,10,
"                    88booo. `8b  d8' db   8D    88    ",13,10,
"                    Y88888P  `Y88P'  `8888Y'    YP    ",'$'


Win1 db \
"                    db   d8b   db d888888b d8b   db",13,10, 
"                    88   I8I   88   `88'   888o  88",13,10, 
"                    88   I8I   88    88    88V8o 88",13,10, 
"                    Y8   I8I   88    88    88 V8o88",13,10, 
"                    `8b d8'8b d8'   .88.   88  V888",13,10,
"                     `8b8' `8d8'  Y888888P VP   V8P",'$' 



.code   
   
;;Macros que guarden y recuperen de la pila els registres de proposit general de la arquitectura de 32 bits de Intel  
Push_all macro
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro
   pop edi
      pop esi
      pop edx
      pop ecx
      pop ebx
      pop eax
endm
   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1, setupBoard
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, gameCards: BYTE, tauler: BYTE, indexMat: SDWORD
extern C rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE
extern C gameCards: BYTE, firstVal: SDWORD, firstCol: BYTE, firstRow: SDWORD, cardTurn: SDWORD, totalPairs: SDWORD, totalTries: SDWORD
extern C cards: BYTE

;****************************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funci� de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funci� gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funci� gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els par�metres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un car�cter, guardat a la variable carac
; en la pantalla en la posici� on est� el cursor,  
; cridant a la funci� printChar_C.
; 
; Variables utilitzades: 
; carac : variable on est� emmagatzemat el caracter a treure per pantalla
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqu�
   ;les funcions de C no mantenen l'estat dels registres.
   
   Push_all

   ; Quan cridem la funci�  printch_C(char c) des d'assemblador, 
   ; el par�metre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat   
; cridant a la funci� getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch proc
   push ebp
   mov  ebp, esp
    
   Push_all

   call getch_C
   
   mov [carac2],al
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funci� de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 3 
; i convertir el char de la columna (A..D) a un n�mero entre 0 i 3.
; Per calcular la posici� del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes f�rmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:   
; row       : fila per a accedir a la matriu gameCards/tauler
; col       : columna per a accedir a la matriu gameCards/tauler
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreenP1 proc
   push ebp
   mov  ebp, esp
   mov eax, [row] ;int row, 32 bits
   sub eax, 1
   ; rowScreen=rowScreenIni+(row*2)
   shl eax, 1
   add eax,[rowScreenIni]
   mov [rowScreen], eax
   mov al, [col] ;char col, 8 bits
   sub al, 'A' ; 65 = A ascii
   ; colScreen=colScreenIni+(col*4)
   shl al, 2
   add eax,[colScreenIni]
   mov [colScreen], eax
   call gotoxy
   mov esp, ebp
   pop ebp
   ret
posCurScreenP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', 
; o les tecles espai ' ', o 's' i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : variable on s'emmagatzema el car�cter llegit
; 
; Par�metres d'entrada : 
; Cap
;    
; Par�metres de sortida: 
; El car�cter llegit s'emmagatzema a la variable carac2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMoveP1 proc
   push ebp
   mov  ebp, esp
   call getch
   mov al, [carac2]
   ; carac2>=i && carac2 <=l || carac2 == s || carac2>=I && carac2 <=L || carac2 == S || carac2 == ' ' 
;lower:
   cmp al, 'i'
   jl s_lower
   cmp al, 'j'
   jg s_lower
   jmp final
s_lower:
   cmp al, 's'
   jne upper
   jmp final
upper:
   cmp al, 'I'
   jl S_upper
   cmp al, 'J'
   jg S_upper
   jmp final
S_upper:
   cmp al, 'S'
   jne space
   jmp final
space:
   cmp al, 32
   jne error
   jmp final
error: ; que fer??
   mov [carac2], 's'; si es error, retornar 's'
	
final:
   mov [carac2], al

   mov esp, ebp
   pop ebp
   ret
getMoveP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (row) i (col) en funci� de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, (row) i (col) nom�s poden 
; prendre els valors [1..4] i [A..D]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : car�cter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; row : fila del cursor a la matriu gameCards.
; col : columna del cursor a la matriu gameCards.
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorP1 proc
   push ebp
   mov  ebp, esp 
   mov al,[carac2]
	
;#region Switch
   cmp al,'i'
   je I
   cmp al,'I'
   je I
   cmp al,'j'
   je J
   cmp al,'J'
   je J
   cmp al,'k'
   je K
   cmp al,'K'
   je K
   cmp al,'l'
   je L
   cmp al,'L'
   je L
   jmp break
;#endregion


;#region Body
I:
	mov eax,[row]
	dec eax
	cmp eax,1
	jl break
	mov [row],eax
   jmp break
J:
   mov al,[col]
	dec al
	cmp al,'A'
	jl break
	mov [col],al
   jmp break
K:
	mov eax,[row]
	inc eax
	cmp eax,4
	jg break
	mov [row],eax
   jmp break
L:
   mov al,[col]
	inc al
	cmp al,'D'
	jg break
	mov [col],al
   jmp break
break:
;#endregion
   mov esp, ebp
   pop ebp
   ret
moveCursorP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades:
;      carac2   : variable on s�emmagatzema el car�cter llegit
;      row      : fila per a accedir a la matriu gameCards
;      col      : columna per a accedir a la matriu gameCards
; 
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movContinuoP1 proc
   push ebp
   mov  ebp, esp
bucle:
	call getMoveP1
	call moveCursorP1
	call posCurScreenP1
	cmp [carac2],'S'
	je fi
	cmp [carac2],'s'
	je fi
	cmp [carac2], ' '
	je fi
	jmp bucle
fi:
   mov esp, ebp
   pop ebp
   ret
movContinuoP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'�ndex per a accedir a les matrius en assemblador.
; gameCards[row][col] en C, �s [gameCards+indexMat] en assemblador.
; on indexMat = row*4 + col (col convertir a n�mero).
;
; Variables utilitzades:   
; row       : fila per a accedir a la matriu gameCards
; col       : columna per a accedir a la matriu gameCards
; indexMat  : �ndex per a accedir a la matriu gameCards
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndexP1 proc
   push ebp
   mov  ebp, esp
   mov eax, [row]
	dec eax
	sal eax, 2
	push eax ; push row * 4
	mov al, [col] ;char col, 8 bits
   sub al, 'A' ; make decimal
	add eax, [esp] ; row * 8 + col
	add esp, 4 ;equal pop
	mov [indexMat], eax 
   mov esp, ebp
   pop ebp
   ret
calcIndexP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; En primer lloc calcular la posici� de la matriu corresponent a la
; posici� que ocupa el cursor a la pantalla, cridant a la subrutina 
; calcIndexP1. Mostrar el contingut de la casella a la posici� de 
; pantalla corresponent.
;
; Canvis per a OpenContinuous:
; En cas de que la carta no estigui girada mostrar el valor
; En cas de que sigui la primera carta girada:
;   - Guardar el valor i la posici� de la carta en el registres 
;     firstVal i firstPos
;   - Actualitzar la matriu tauler y printar el valor per pantalla 
;     a la seva posici�
; En cas de que sigui la segona carta girada:
;   - Comprovar si el valor es el mateix que la primera carta
;      - Si el valor es el mateix actualitzar la matriu tauler, la 
;        variable totalPairs, i el valor de parelles restants 
;        mostrat per pantalla (updateScore)
;      - Si el valor no es el mateix, esperar a que el usuari premi 
;        qualsevol tecla (getMoveP1), esborrar els valors de pantalla 
;        i la matriu tauler, i actualitzar els intents restants.
; Mostrarem el contingut de la carta criant a la subrutina printch. L'�ndex per
; a accedir a la matriu gameCards, el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta o marcada.
;
; Canvis per al nivell avan�at:
; Cada vegada que fem una parella o fallem, actualitzar el total de parelles 
; i intents restants.
;
; Variables utilitzades:   
; row       : fila per a accedir a la matriu gameCards
; col       : columna per a accedir a la matriu gameCards
; indexMat  : �ndex per a accedir a la matriu gameCards
; gameCards : matriu 8x8 on tenim les posicions de les mines. 
; carac       : car�cter per a escriure a pantalla.
; tauler   : matriu en la que guardem els valors de les tirades 
; firstVal  : valor de la primera carta destapada
; firstPos  : posici� de la primera carta destapada
; cardTurn  : flag per controlar si el jugador esta obrint la 
;             primera o la segona carta
; totalPairs: nombre de parelles restants
; totalTries: nombre de intents restants
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; endGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openP1 proc
   push ebp
   mov  ebp, esp
start:
	cmp [carac2], ' '
	jne fi
	call calcIndexP1
	mov esi, [indexMat]
	mov al, gameCards[esi]
	cmp tauler[esi], al
	jne notOpen
	call movContinuoP1
	jmp start
notOpen:
	mov [carac],al
	cmp [firstVal], 0
	je first
	jmp second
first:
	mov tauler[esi], al
	mov [firstVal], eax
	mov al, [col]
	mov [firstCol],al
	mov eax, [row]
	mov [firstRow], eax
	call printch
	call movContinuoP1
	jmp start
second:
	mov tauler[esi], al
	call printch
	cmp [firstVal], eax
	jne incorrect
	;correct
	dec [totalPairs]
	jmp fi
incorrect:
	dec [totalTries]
	call getMoveP1
	;save cursor position
	mov eax, [row]
	push eax
	mov al, [col]
	push eax
	; hide second card
	mov [carac], ' '
	call posCurScreenP1
	call printch
	mov tauler[esi], 32
	;hide first card
	mov eax, [firstRow]
	mov [row], eax
	mov al, [firstCol]
	mov [col], al
	call calcIndexP1
	mov esi, [indexMat]
	mov tauler[esi], 32
	call posCurScreenP1
	call printch
	; mov cursor to the last position
	pop eax
	mov [col], al
	pop eax
	mov [row], eax
	call posCurScreenP1
fi:
	call updateScore
	mov [firstVal], 0
   mov esp, ebp
   pop ebp
   ret
openP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l�obertura continua de cartes. S�ha 
; d�utilitzar la tecla espai per girar/obrir una carta i la 's' per 
; sortir. 
;
; Canvis per al nivell avan�at: 
; Per a cada moviment introdu�t comprovar si hem guanyat o perdut el 
; joc compovant les variables totalPairs i totalTries.
;
; Variables utilitzades: 
; carac2     : car�cter introdu�t per l�usuari
; row        : fila per a accedir a la matriu gameCards
; col        : columna per a accedir a la matriu gameCards
; totalPairs : nombre de variables restants que ens queden en joc
; totalTries : nombre de intents restants que ens queden en joc
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openContinuousP1 proc
   push ebp
   mov  ebp, esp
	call setupBoard
bucle:
	call movContinuoP1
	call openP1
	cmp [totalTries], 0
	jne noLost
	call printWinLost
	call getMoveP1
	jmp fi
noLost:
	cmp [totalPairs], 0
	jne noWin
	call printWinLost
	call getMoveP1
	jmp fi
noWin:
	cmp [carac2],'S'
	je fi
	cmp [carac2],'s'
	je fi
	jmp bucle
fi:
   mov esp, ebp
   pop ebp
   ret
openContinuousP1 endp


printWinLost proc
	push ebp
   mov  ebp, esp
	;set cursor position
	mov eax, 0 ; col
   push eax
   mov eax, 19 ; row
   push eax
   call gotoxy_C
	pop eax
	pop eax
   xor eax,eax
	;print string
	cmp [totalPairs], 0
	je win
	cmp [totalTries], 0
	je lost
	jmp fi
win:
	lea eax, win1
	push eax
	call printString
	pop eax
	jmp fi
lost:
	lea eax, lost1
	push eax
	call printString
	pop eax
fi:
	mov esp, ebp
   pop ebp
   ret
printWinLost endp
; load string using the address of the string passed in the stack ([ebp + 8])
printString proc
	push ebp
   mov  ebp, esp
	mov esi, [ebp + 8]
	mov edi, 0
bucle:
	mov  al, [esi + edi]
	cmp al, '$'
	je fi
   push eax 
   call printChar_C
   pop eax
	inc edi
	jmp bucle
fi:
	mov esp, ebp
   pop ebp
   ret
printString endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que mostra el n�mero de parelles restants. Moure el 
; cursor a la posici� (row=-1, col=5) i (row=-1, col=3), per printar 
; el n�mero de parelles i intents restants, al finalitzar, retornar
; el cursor a la posici� original.
;
; Variables utilitzades: 
; totalPairs : nombre de parelles restants
; totalTries : nombre d'intentns restants
; row        : fila per a accedir a la matriu gameCards
; col        : columna per a accedir a la matriu gameCards
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateScore proc
   push ebp
   mov  ebp, esp
	;save last row,col
	mov eax, [row]
	push eax
	mov al, [col]
	push eax
	;print total tries
	mov [row], -1
	mov [col], 5
	call posCurScreenP1
	mov eax, [totalTries]
	add eax, 48 ;convert to char
	mov [carac], al
	call printch
	;print total pairs
	mov [row], -1
	mov [col], 2
	call posCurScreenP1
	mov eax, [totalPairs]
	add eax, 48 ;convert to char
	mov [carac], al
	call printch
	;restore position
	pop eax
	mov [col],al
	pop eax
	mov [row],eax
	call posCurScreenP1
   mov esp, ebp
   pop ebp
   ret
updateScore endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que inicialitza el tauler aleat�riament.
;
; Pistes:
; - La crida a la funci� rand guarda el valor aleatori al
;   registre eax
; - La crida a la funci� div guarda el modul de la divisi� al
;   registre edx
;
; Variables utilitzades: 
; row      : fila per a accedir a la matriu gameCards
; col      : columna per a accedir a la matriu gameCards
; cards      : llistat ordenat de cartes en joc
; gameCards: matriu de cartes ordenades aleat�riament.
;
;
; Par�metres d'entrada : 
; Cap
;
; Par�metres de sortida: 
; Cap 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setupBoard proc
   push ebp
   mov  ebp, esp
	sub esp, 12 ;allocate space for local variables
	xor eax,eax
;	inc eax
	mov [ebp - 8], eax ; letter counter starts at 1
	; ascii alphabet range [65, 90], we need 9
	push 65
	push 90 - 8
	call randomMinMax
	add esp, 8
	dec eax
	mov [ebp - 4], eax ; base letter
	mov edx, eax
	mov ecx, 4 * 4 
bucle1:
	mov gameCards[ecx - 1], 0
	loop bucle1

	mov ecx, 4 * 4 ; counter
	mov [ebp - 12],ecx
bucle2:
	;random row
	mov ecx, [ebp - 12]
	cmp ecx, 0
	je fi
	push 0
	push 3
	call randomMinMax
	; offset = index row * 4 + col
	mov esi, eax ; row
	sal esi, 2
	call randomMinMax
	add esp, 8
	add esi, eax
	cmp gameCards[esi], 0
	je setCard
	jmp bucle2
setCard:
	mov eax, [ebp - 8]
	mov edx, [ebp - 4]
	add edx, eax
	mov gameCards[esi], dl
	;decrease bucle2 counter
	mov ecx, [ebp - 12]
	dec ecx
	mov [ebp - 12], ecx
	cmp eax, 7 ; if letter count hits 7 (8 letters, 0 ... 7) reset
	je resetCounter
	inc eax
	mov [ebp - 8], eax
	jmp bucle2
resetCounter:
	xor eax, eax
	mov [ebp - 8], eax
	jmp bucle2
fi:
   mov esp, ebp
   pop ebp
   ret
setupBoard endp

; arguments from stack, max ([ebp + 8]), min ([epb + 12]), return value in eax
randomMinMax proc
   push ebp
   mov  ebp, esp
	call rand
	; min + (rand() % (max - min + 1))
	mov ecx, [ebp + 8] ; max
	sub ecx, [ebp + 12] ; min
	inc ecx 
	xor edx,edx
	div ecx ; remainder in edx
	add edx, [ebp + 12]
	mov eax, edx
   mov esp, ebp
   pop ebp
   ret
randomMinMax endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que mostra nombres de 2 xifres per pantalla
;
; rowscreen   : fila del cursor a la pantalla
; colscreen   : columna del cursor a la pantalla
; carac      : car�cter a visulatizar per la pantalla
;
; Par�metres d'entrada : 
; AL: nombre a mostrar
;
; Par�metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showNumbers proc
   push ebp
   mov  ebp, esp



   mov esp, ebp
   pop ebp
   ret
showNumbers endp

;****************************************************************************************


END
