# ***** DO NOT MODIFY THIS FILE **** #
.include "./cs47_common_macro.asm"
.include "./cs47_proj_macro.asm"

# data section
.data 
.align 2
matchMsg: .asciiz "matched"
unmatchMsg: .asciiz "not matched"
charCR: .asciiz "\n"
testD: .word 0xffffffff
var0: .word 0x00000000
var1: .word 0x00000000
var2: .word 0x00000000
var3: .word 0x00000000
testV1Arr: .word 4 16 -13 -2 -6 -18  5 -19 4 -26
testV2Arr: .word 2 -3   5 -8 -6  18 -8   3 3 -64
noTest:	   .word 10
passTest:  .word 0
totalTest: .word 0
opList:	   .byte '/' '*' '-' '+'
testFlag:  .word 0x0
as_msg: .asciiz "(%d %c %d) \t normal => %d \t logical => %d \t [%s]\n"
mul_msg: .asciiz "(%d %c %d) \t normal => HI:%d LO:%d \t\ logical => HI:%d LO:%d \t [%s]\n"
div_msg: .asciiz "(%d %c %d) \t normal => R:%d Q:%d \t\ logical => R:%d Q:%d \t [%s]\n"
finalMSG: .asciiz "*** OVERALL RESULT %s ***\n"
statPASS: .asciiz "PASS"
statFAIL: .asciiz "FAILED"
testStatus: .asciiz "\n\nTotal passed %d / %d\n"

.text
.globl main
#####################################################################
# Main Program
#####################################################################
main:
	li	$t0, 0x8000000000000000
	li	$t1, 0xD000000000000000
	sub	$t2, $t0, $t1
