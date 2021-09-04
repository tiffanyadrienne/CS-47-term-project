.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	# Caller RTE store: save $fp, $ra, $a0, $a1, $a2
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	# Code implementation: 
	beq	$a2, '+', au_logical_add
	beq	$a2, '-', au_logical_sub
	beq	$a2, '*', au_logical_mul
	beq	$a2, '/', au_logical_div
au_logical_add:
	jal	add_logical
	j	au_logical_end
au_logical_sub:
	jal	sub_logical
	j	au_logical_end
au_logical_mul:
	jal	mul_signed
	j	au_logical_end
au_logical_div:
	jal	div_signed
au_logical_end:
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw 	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr 	$ra
	
add_logical:
	# frame: save $fp, $ra, $a0, $a1, $a2
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	li	$a2, 0x00000000
	jal	add_sub_logical
	
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw 	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr 	$ra
	
sub_logical:
	# frame: save $fp, $ra, $a0, $a1, $a2
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	li	$a2, 0xffffffff
	jal	add_sub_logical
	
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw 	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr 	$ra
	
add_sub_logical:
	# frame: save $fp, $ra, $a0, $a1, $a2, $s0, $s1, $s2, $s3, $s4
	addi	$sp, $sp, -44
	sw	$fp, 44($sp)
	sw	$ra, 40($sp)
	sw	$a0, 36($sp)
	sw	$a1, 32($sp)
	sw 	$a2, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	sw	$s4, 8($sp)
	addi	$fp, $sp, 44
	
	# code implementation 
	li	$s0, 0				# $s0 = i = 0
	li	$v0, 0				# $v0 = s = result of operation
	li	$t9, 0
	extract_nth_bit($s1, $a2, $t9)		# $s1 = c = first bit in $a2
	
	beq	$s1, 0, compute			# verify if mode is sub/add
	not	$a1, $a1
	
compute: 
	extract_nth_bit($s2, $a0, $s0)		# $s2 = $a0[i]
	extract_nth_bit($s3, $a1, $s0)		# $s3 = $a1[i]
	xor	$s4, $s2, $s3			
	xor	$s4, $s4, $s1			# $s4 = y = xor ($a0[i], $a1[i], c)
	
	# CO = CI.(A xor B) + A.B
	xor	$t0, $s2, $s3			# $t0 = A xor B
	and	$t0, $t0, $s1			# $t0 = CI.(A xor B)
	and 	$t1, $s2, $s3			# $t1 = A.B
	or	$s1, $t0, $t1			# $s1 = CI.(A xor B) + A.B = c = next carry bit 
	
	insert_to_nth_bit($v0, $s0, $s4, $t9)	# $v0 = s[i] = y
	
	addi	$s0, $s0, 1
	bne	$s0, 32, compute
	move	$v1, $s1
	
	# restore RTE
	lw	$fp, 44($sp)
	lw	$ra, 40($sp)
	lw	$a0, 36($sp)
	lw	$a1, 32($sp)
	lw 	$a2, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)
	lw	$s3, 12($sp)
	lw	$s4, 8($sp)
	addi	$sp, $sp, 44
	jr 	$ra

twos_complement:
	# frame: save $fp, $ra, $a0, $a1
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1, 8($sp)
	addi	$fp, $sp, 20
	
	not	$a0, $a0
	li	$a1, 1
	jal	add_logical	# arguments in $a0, $a1; results in $v0
				# $v0 = $a0 + $a1 = inv($a0) + 1
		
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1, 8($sp)
	addi	$sp, $sp, 20
	jr 	$ra
	
twos_complement_if_neg:
	# frame: save $fp, $ra, $a0
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	
	move	$v0, $a0
	bgtz	$a0, twos_complement_if_neg_end
	jal 	twos_complement		# arg in $a0; results in $v0

twos_complement_if_neg_end:	
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr 	$ra
	
twos_complement_64bit:
	# frame: save $fp, $ra, $a0, $a1, $s0, $s1
	addi	$sp, $sp, -28
	sw	$fp, 28($sp)
	sw	$ra, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	addi	$fp, $sp, 28
	
	not	$a0, $a0	# $a0 = inv($a0)
	not	$s0, $a1	# $s0 = inv($a1)
	
	li	$a1, 1
	jal 	add_logical	# args in $a0, $a1; results in $v0, $v1
	move	$s1, $v0	# $s1 = $v0 = $a0 + $a1 = inv($a0) + 1 (lo)
	
	move	$a0, $v1	# $a0 = carry out from previous step ($v1)
	move	$a1, $s0	# restore $a1 to inv($a1)
	jal 	add_logical	# args in $a0, $a1; results in $v0, $v1
				# $v0 = $a0 + $a1 = carry out + $a1 (hi)
	
	move	$v1, $v0	# $v1 = hi
	move	$v0, $s1	# $v0 = lo
	
	lw	$fp, 28($sp)
	lw	$ra, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$s0, 12($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 28
	jr 	$ra

bit_replicator:
	# frame: save $fp, $ra, $a0
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$a0, 8($sp)
	addi	$fp, $sp, 16
	
	beq	$a0, 0, equals_zero
	li	$v0, 0xffffffff
	j 	bit_replicator_end
equals_zero: 
	li	$v0, 0x00000000
bit_replicator_end: 
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$a0, 8($sp)
	addi	$sp, $sp, 16
	jr 	$ra

mul_unsigned:
	# frame: save $fp, $ra, $a0, $a1, $s0, $s1, $s2, $s3, $s4
	addi	$sp, $sp, -40
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	sw	$s4, 8($sp)
	addi	$fp, $sp, 40
	
	li	$s0, 0				# $s0 = i = 0
	li	$s1, 0				# $s1 = h = 0 (hi)
	move	$s2, $a1			# $s2 = l = multiplier = $a1 (lo)
	move	$s3, $a0			# $s3 = m = multiplicand = $a0

mul_unsigned_loop:
	li	$t9, 0
	extract_nth_bit($a0, $s2, $t9)		# $a0 = l[0]
	jal bit_replicator			# arg in $a0, result in $v0
						# $v0 = r = {32{L[0]}}

	and	$t0, $s3, $v0			# $t0 = x = m & r
	
	move	$a0, $s1		
	move	$a1, $t0
	jal 	add_logical			# arg in $a0, $a1; results in $v0, $v1
	move	$s1, $v0			# $s1 = $v0 = h = h + x
	
	srl	$s2, $s2, 1			# right shift l ($s2) by 1 bit
	
	li	$t9, 0
	extract_nth_bit($s4, $s1, $t9)		# $s4 = h[0] 
	li	$t9, 31
	insert_to_nth_bit($s2, $t9, $s4, $t8)	# l[31] = h[0] 

	srl	$s1, $s1, 1			# right shift h ($s1) by 1 bit
	
	addi	$s0, $s0, 1			# i++
	
	bne	$s0, 32, mul_unsigned_loop
	
	move	$v0, $s2			# $v0 = lo
	move	$v1, $s1			# $v1 = hi
	
	lw	$fp, 40($sp)
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)
	lw	$s3, 12($sp)
	lw	$s4, 8($sp)
	addi	$sp, $sp, 40
	jr 	$ra
	
mul_signed:
	# frame: save $fp, $ra, $a1, $a2, $s0, $s1, $s2, $s3, $s4
	addi	$sp, $sp, -40
	sw	$fp, 40($sp)
	sw	$ra, 36($sp)
	sw	$a0, 32($sp)
	sw	$a1, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	sw	$s4, 8($sp)
	addi	$fp, $sp, 40
	
	li	$t9, 31
	extract_nth_bit($s2, $a0, $t9)
	li	$t9, 31
	extract_nth_bit($s3, $a1, $t9)
	xor	$s4, $s2, $s3
	
	jal	twos_complement_if_neg	# argument in $a0; result in $v0
	move	$s0, $v0		# $s0 = N1
	
	move	$a0, $a1		
	jal	twos_complement_if_neg	# argument in $a0; result in $v0
	move	$s1, $v0		# $s1 = N2
	
	move	$a0, $s0
	move	$a1, $s1
	jal 	mul_unsigned		# arguments are in $a0, $a1; results are in $v0, $v1
	
	bne 	$s4, 1, mul_signed_end
	move	$a0, $v0
	move	$a1, $v1
	jal	twos_complement_64bit	# arguments in $a0, $a1; results in $v0, $v1
	
mul_signed_end:
	lw	$fp, 40($sp)
	lw	$ra, 36($sp)
	lw	$a0, 32($sp)
	lw	$a1, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)
	lw	$s3, 12($sp)
	lw	$s4, 8($sp)
	addi	$sp, $sp, 40
	jr 	$ra

div_unsigned: 
	# frame: save $fp, $ra, $a0, $a1, $s0, $s1, $s2, $s3
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$a0, 28($sp)
	sw	$a1, 24($sp)
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	addi	$fp, $sp, 36
		
	li	$s0, 0				# $s0 = i = 0
	move	$s1, $a0			# $s1 = q = dividend = $a0 
	move	$s2, $a1			# $s2 = d = divisor = $a1
	li	$s3, 0				# $s3 = r = 0

div_unsigned_loop:
	sll	$s3, $s3, 1			# left shift r
	li	$t9, 31
	extract_nth_bit($t8, $s1, $t9)		# $t8 = q[31]
	li	$t9, 0
	insert_to_nth_bit($s3, $t9, $t8, $t7)	# R[0] = Q[31]
	
	sll	$s1, $s1, 1			# left shift q
	
	move	$a0, $s3			# $a0 = r
	move	$a1, $s2			# $a1 = d
	jal 	sub_logical 			# args in $a0, $a1, results in $v0
						# $v0 = s = r - d 
	
	bltz  	$v0, s_is_less_than_zero
	move	$s3, $v0			# r = s
	li	$t9, 0
	li	$t8, 1
	insert_to_nth_bit($s1, $t9, $t8, $t7)	#Q[0] = 1

s_is_less_than_zero:
	addi	$s0, $s0, 1			# i++
	
	bne 	$s0, 32, div_unsigned_loop
	move	$v0, $s1			# $v0 = quotient 
	move	$v1, $s3			# $v1 = remainder

	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$a0, 28($sp)
	lw	$a1, 24($sp)
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	addi	$sp, $sp, 36
	jr 	$ra
	
div_signed:
	# frame: save $fp, $ra, $a0, $a1, $s0, $s1, $s2, $s3, $s4, $s5
	addi	$sp, $sp, -48
	sw	$fp, 48($sp)
	sw	$ra, 44($sp)
	sw	$a0, 40($sp)
	sw	$a1, 36($sp)
	sw 	$a2, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$s4, 12($sp)
	sw	$s5, 8($sp)
	addi	$fp, $sp, 48
	
	move	$s0, $a0			# $s0 = N1 = $a0
	move	$s1, $a1			# $s1 = N2 = $a1
	
	li	$t9, 31
	extract_nth_bit($s2, $a0, $t9) 		# $s2 = $a0[31]
	extract_nth_bit($t8, $a1, $t9)		# $t9 = $a1[31]
	xor	$s3, $s2, $t8			# $s3 = S
		
	jal	twos_complement_if_neg		# arg in $a0, results in $v0
	move	$s0, $v0
	
	move	$a0, $s1
	jal	twos_complement_if_neg
	move	$s1, $v0
	
	move	$a0, $s0
	move	$a1, $s1
	jal	div_unsigned			# args in $a0, $a1, results in $v0, $v1
	move	$s4, $v0			# $s4 = $v0 = Q, $v1 = R
	move	$s5, $v1

	bne 	$s3, 1, check_sign_of_R
	move	$a0, $s4	
	jal	twos_complement			# args in $a0, result in $v0 = twos complement of Q
	move	$s4, $v0
	
check_sign_of_R:
	bne	$s2, 1, div_signed_end
	move	$a0, $s5
	jal	twos_complement			# args in $a0, result in $v0 = twos complement of R
	move	$s5, $v0
	
div_signed_end:
	move	$v0, $s4
	move	$v1, $s5
	
	# restore RTE
	lw	$fp, 48($sp)
	lw	$ra, 44($sp)
	lw	$a0, 40($sp)
	lw	$a1, 36($sp)
	lw 	$a2, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$s4, 12($sp)
	lw	$s5, 8($sp)
	addi	$sp, $sp, 48
	jr $ra
