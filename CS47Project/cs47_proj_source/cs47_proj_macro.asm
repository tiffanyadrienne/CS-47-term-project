# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

	# Macro : extract_nth_bit
        # Usage: extract_nth_bit($regD, $regS, $regT)
        .macro extract_nth_bit($regD, $regS, $regT)
        srlv	$t0, $regS, $regT	# right shift regS by regT and store it in $t0
        li	$t1, 1			# mask = $t1 = 1
        and	$regD, $t0, $t1
        .end_macro 
        
        # Macro : insert_to_nth_bit
        # Usage : insert_to_nth_bit($regD, $regS, $regT, $maskReg){
        .macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
        li	$maskReg, 1			# mask = 1
        sllv	$maskReg, $maskReg, $regS	# shifts mask by regS
        not 	$maskReg, $maskReg		# invert mask
        and	$regD, $maskReg, $regD		# mask regD w/ maskReg
        sllv	$t0, $regT, $regS		# shift regT by regS
       	or	$regD, $regD, $t0		# mask regD w/ $t0
        .end_macro 
	
