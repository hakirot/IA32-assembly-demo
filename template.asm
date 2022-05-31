TITLE Demonstrating Low-Level I/O procedures    (Program6a_hakirot_.asm)

; Author: hakirot 
; Last Modified: 12/6/2019
; OSU email address: hackirot@proton.me
; Course number/section: CS220
; Assignment Number: 6a                Due Date: 12/8/2019
; Description: 

INCLUDE Irvine32.inc

ARRAYSIZE = 10

displayString	MACRO	address

	push	EDX
	mov		EDX, address
	call	WriteString
	pop		EDX

ENDM

getString		MACRO	address

	push	EDX
	push	ECX
	mov		EDX, address
	mov		ECX, 32
	call	ReadString
	pop		ECX
	pop		EDX

ENDM

.data

intro			BYTE		"Demonstrating Low-Level I/O Procedures", 0
programmer		BYTE		"Programmed by hakirot " , 0	
promptUser		BYTE		"Please enter ten unsigned integers within range of a 32-bit register", 0
prompt_2		BYTE		"After entry, I will display a list of the integers with the sum and average value.", 0
prompt_3		BYTE		"Enter an integer: ", 0
invalidStr		BYTE		"Please Enter an integer between 0 and 4,294,967,295", 0
youEnteredStr	BYTE		"You entered the following integers: ", 0
commaStr		BYTE		", ", 0
sumStr			BYTE		"The sum of these numbers is: ", 0
aveStr			BYTE		"The average is: ", 0
byeStr			BYTE		"Bye!", 0
inputStr		BYTE		33 DUP(0)
outputStr		BYTE		11 DUP(0)
array			DWORD		10 DUP(0)
total			DWORD		0
average			DWORD		0
sum				DWORD		0


.code

main PROC

	push			OFFSET intro
	push			OFFSET programmer
	call			introduction					; Prints introduction to program and programmer

	push			OFFSET promptUser
	push			OFFSET prompt_2
	call			prompt							; Promt the user for ten integers
	call			CrLf
		
	mov				ECX, ARRAYSIZE					; set loop counter
	mov				EDI, OFFSET array				; place address of the array

L1:

	push			OFFSET inputStr
	push			OFFSET prompt_3
	push			total
	call			readVal							; start collecting data
	mov				[EDI], EAX
	add				EDI, 4
	loop			L1								; collect until 10 integers are recorded in array

		
	call			CrLf

	displayString	OFFSET youEnteredStr			; "You entered: "

	mov				ECX, 10							; Set counter to cycle through all ten integers in array
	mov				ESI, OFFSET array				; ESI @ base of integer array
	mov				EDI, OFFSET	outputStr			; EDI = @outputStr

L2:

	call			writeVal
	add				ESI, 4
	mov				EDI, OFFSET	outputStr			; EDI = @outputStr

	cmp				ECX, 1
	je				L3

	displayString	OFFSET commaStr

	loop			L2

L3:

	call			CrLf
	call			CrLf
	displayString	OFFSET sumStr					; Display the sum of entered integers
	mov				total, 0

	push			ARRAYSIZE
	push			OFFSET array
	push			total
	push			OFFSET aveStr
	call			displayTotals
	
	
	call			CrLf
	call			CrLf
	displayString	OFFSET byeStr
	call			CrLf

	exit	; exit to operating system

main ENDP

;--------------------------------------
;			introduction
;
;	Introduces the user to the program
; and programmer. Accepts two 
; parameters: the offset of the string
; containing the program title pushed
; first, followed by the offset of 
; the programmer's name.
;--------------------------------------


introduction PROC

	push			EBP
	mov				EBP, ESP

	call			CrLf
	displayString	[EBP + 12]
	call			CrLf
	displayString	[EBP + 8]
	call			CrLf
	call			CrLf

	pop				EBP
	ret 8

introduction ENDP

;-------------------------------------
;			prompt
;
;	Prompts the user for ten unsigned
; integers. Accepts two offsets of 
; strings pushed to the stack, and 
; prints the messages to the screen.
;-------------------------------------

prompt		PROC

	push			EBP
	mov				EBP, ESP

	displayString	[EBP + 12]
	call			CrLf
	call			CrLf
	displayString	[EBP + 8]

	pop				EBP
	ret 8

prompt		ENDP

;------------------------------------------
;			readVal
;
;	Reads a string entered by the
; user and converts the characters
; to integers. The equalized integer
; value of the converted string is
; returned in the EAX register.
;
; Parameters:
;	- Offset of string buffer pushed 1st
;	- Offset of prompting string pushed 2nd
;	- Unsigned int variable zero pushed 3rd
;	- Function is then called
; Returns:
;	- unsigned integer value in EAX
;------------------------------------------

readVal		PROC

	push			ECX
	push			EBP
	mov				EBP, ESP

Begin:

	call			CrLf
	displayString	[EBP + 16]			; "Enter an int: "

	mov				EDX, [EBP + 20]		; @inputStr	
	getString		EDX					; Recieve integers as string

	mov				ESI, EDX			; ESI = @ input character array

	mov				EAX, 0				; Reset for string accumulator
	mov				EBX, 1				; Ten factor increases with string position
	mov				ECX, 0				; Accumulate String Size
	mov				[EBP + 12], ECX		; reset total

ByteLoad:

	LODSB								; Put BYTE @ ESI into AL
	cmp				AL, 0
	je				CheckLength
	inc				ECX
	jmp				ByteLoad

Invalid:

	displayString	OFFSET invalidStr
	jmp				Begin

CheckLength:

	cmp				ECX, 10
	jg				Invalid				; invalid if more than 10 bytes are entered

	mov				ESI, [EBP + 20]		; ESI = @ input character array
	add				ESI, ECX			; Point to end of string @ /0
	dec				ESI					; Point to last character
	std									; Set direction flag

Reading:

	LODSB								; Load BYTE @ESI into AL
	cmp				AL, 48				; Validate
	jb				Invalid
	cmp				AL, 57
	ja				Invalid
	sub				AL, 48				; Equalize character to equalized integer

	mul				EBX					; by ten factor
	;call			WriteInt			; Print to screen

	mov				EDX, [EBP + 12]
	add				EDX, EAX
	mov				[EBP + 12], EDX

	mov				EAX, EBX
	mov				EBX, 10
	mul				EBX
	jc				Invalid	
	mov				EBX, EAX
	mov				EAX, 0

	std

	loop			Reading

Ending:

	mov	EAX, [EBP + 12]
	pop EBP
	pop ECX
	ret 12								; pushed inputStr, @ prompt, total

readVal		ENDP

;------------------------------------
;			writeVal
;
; Converts the value of an integer
; to a string and siplays it to
; the screen. The value must fit
; within a 32-bit register
;
; Parameters:
;	- Offset of integer array in ESI
;	- Offset of 11-byte string in EDI
;------------------------------------

writeVal PROC

	push	ECX
	mov		EBX, 10
	mov		ECX, 10			; For when the loop is made

	mov		EAX, [ESI]		; Get first integer in [ESI] into register
	add		EDI, 9			; Move the the end of the string to write characters in reverse

Writing:

	mov		EDX, 0			; Divide EAX by 10 and get the remainder
	div		EBX

	push	EAX
	mov		EAX, 0
	mov		AL, DL			; Move remainder to AL for saving to the string
	add		AL, 48
	
	std
	STOSB					; Store characterInt in byte string pointed to by [EDI]
							; EDI decremented by one BYTE
	pop		EAX
	loop	Writing			; Repeat until all numbers are written

	displayString OFFSET outputStr

	mov		ECX, 10
	mov		EDI, OFFSET outputStr
	add		EDI, 9

Clearing:					; Reset the string for the next integer

	mov		al, 0
	std
	STOSB
	loop	Clearing		; Clear for every position

	pop		ECX
	ret

writeVal ENDP

;--------------------------------
;		displayTotals
;
; Displays the sum and average of
; and integer array.
;
; Parameters:
;	- Array size pushed 1st
;	- Array offset pushed 2nd
;	- Total variable pushed 3rd
;	- String for average pushed 4th
;	- Function called
;--------------------------------

displayTotals PROC

	push	EBP
	push	EBX
	mov		EBP, ESP
	mov		EDX, [EBP + 12]
	mov		EAX, [EBP + 16]			; total in EAX
	mov		ESI, [EBP + 20]			; @array in ESI
	mov		ECX, [EBP + 24]			; arraySize in ECX

Summing:

	mov		EBX, [ESI]
	add		EAX, EBX				; Move through array and sum all data
	add		ESI, 4
	loop	Summing

	call	WriteDec				; Write Sum to screen

	call	CrLF
	call	CrLf
	displayString	EDX				; "average: "

	mov		EBX, [EBP + 24]			; Array size in EBX
	mov		EDX, 0
	div		EBX						; divide for average

	call	WriteDec				; Write average to screen

	pop		EBX						; Restore saved registers
	pop		EBP
	ret 16							; Skip 4 DWORDS pushed to stack

displayTotals ENDP

END main
