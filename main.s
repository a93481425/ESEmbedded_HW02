.syntax unified

.word 0x20000100
.word _start

.global _start
.type _start, %function
_start:
	//
	// mov
	//

        mov r0,#15
        mov r1,#1
        mov r2,#2
        mov r3,#3

	//
	//push
	//
 
	push	{r0, r1, r2, r3}

	//
	// mov
	//

        mov r0,#0xff
        mov r1,#0x11
        mov r2,#0x22
        mov r3,#0x33
        push	{r3, r2, r1, r0}

	//
	// clean r0 r1 r2 r3
	//
        bic r0,r0,r0
        bic r1,r1,r1
        bic r2,r2,r2
        bic r3,r3,r3

	//
	//pop
	//
 
	pop	{r0, r1, r2, r3}
        pop	{r3, r2, r1, r0}




	//
	//branch w/o link
	//
	b	label01

label01:
	nop

	//
	//branch w/ link
	//
	bl	sleep

sleep:
	nop
	b       sleep
