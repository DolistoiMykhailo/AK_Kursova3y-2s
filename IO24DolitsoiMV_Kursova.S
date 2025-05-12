.global IO24DolitsoiMV_Kursova
.syntax unified
.thumb
.equ ZK, 2410 @ Номер залікової книжки
IO24DolitsoiMV_Kursova:
	push {lr}
	ldr r0, =18 // X1
	ldr r1, =-9 // X2
	ldr r2, =23 // X3
	
	// X2 / 2
	mov r3, r1
	mov r4, #2
	sdiv r1, r3, r4 // r1 = X2 / 2
	
	// X1 AND (X2 / 2)
	and r3, r0, r1 // r3 = X1 & (X2 / 2)
	
	// r3 / 8
	asr r4, r3, #3 // r4 = r3 / 8
		
	// -2 * (NOTX3 XOR 1)
	mvn r5, r2 //NOTX3
	eor r5, r5, #1 //NOTX3 XOR 1
	mov r6, #-2
	mul r5, r5, r6 // -2 * (NOTX3 XOR 1)

	// F = r4 + r5
	adds r5, r4, r5 // r5 = result(F)
	
	// Step 1: check for oveflow
	bvs overflow

no_overflow:	
	// Step 2: check or 0
	uxth r0, r5 
	cmp r0, #0
	bne step4	
	
	// Step 3: Ry := ZK
	movw r0, #ZK
	b step4_continue

step4:
	uxth r0, r5

step4_continue:
	// Step 4: Rx := Rx + ZK
	lsrs r1, r5, #16 
	add r1, r1, #ZK
	lsls r1, r1, #16 
	orr r5, r1, r0

	// Step 5: check for normalization
 	lsrs r1, r5, #30
	ands r1, r1, #0x3
	cmp r1, #0
	beq store_result
	cmp r1, #3
	beq store_result
	// Step 6: normalization correction
	lsr r5, r5, #1

store_result:
	// Step 7: re-checking the sign bits
	lsrs r1, r5, #30
	ands r1, r1, #0x3
	cmp r1, #1
	beq end
	cmp r1, #2
	beq end
end:
	pop {pc}
overflow:
	lsr r5, r5, #1
	orr r5, r5, #(1 << 31)
	b no_overflow
