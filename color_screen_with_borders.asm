.data
	li $s0,0 # teller zoveelste
	li $s1,0 
	#rijnummer a0
	#kolomnummer a1


.text
main:
	
	li $s3, 0x00ff0000      #Loading RED in register t1
	j loop_kolom
loop_rijen:
	bgt $s0,15,exit		#if greater dan 16 exit			
	addi $s0,$s0,1		# rij+1
	li $s1,0
	j loop_kolom
	
	
	
loop_kolom:
	bgt $s1,31,loop_rijen	#als kolom groter dan 31 terug naar loop_rijen
	jal fill_colour
	addi $s1,$s1,1
	j loop_kolom
	
fill_colour:
# we zullen coordinaat omzetten naar het adres
# stack frame
    	sw $fp, 0($sp) # push old frame pointer (dynamic link)
    	move $fp, $sp # frame pointer now points to the top of the stack
    	subu $sp, $sp, 16 # allocate 16 bytes on the stack
    	sw $ra, -4($fp) # store the value of the return address
    	sw $s0, -8($fp) # save locally used registers
    	sw $s1, -12($fp)
    	
    	jal coord_to_adress
	sw $s3, 0($s2)
	
	# stack frame     
    	lw $s1, -12($fp) # reset saved register $s1
    	lw $s0, -8($fp) # reset saved register $s0
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
	    	
    	
coord_to_adress: 
# we zullen coordinaat omzetten naar het adres
# stack frame
    	sw $fp, 0($sp) # push old frame pointer (dynamic link)
    	move $fp, $sp # frame pointer now points to the top of the stack
    	subu $sp, $sp, 16 # allocate 16 bytes on the stack
    	sw $ra, -4($fp) # store the value of the return address
    	sw $s0, -8($fp) # save locally used registers
    	sw $s1, -12($fp)

#we berekenen de offsset met formule BA+(r*K+c)*EL
    	mul $t0,$s0,32  # we zulllen het rij nummer vermenigvuldigen met de breedte nl 32
    	add $t0,$t0,$s1  # we tellen het kolomnummer bij onze vermenigvuldeging 
    	mul $t0,$t0,4    #we vermenigvuldigen het nog met de lengte van elk adres wat 4 bytes is
    	add $s2,$gp,$t0  # we tellen het base adress bij de (rxK+c)*el
    
# stack frame     
    	lw $s1, -12($fp) # reset saved register $s1
    	lw $s0, -8($fp) # reset saved register $s0
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
    
     





exit: 
#einde programme
    li $v0,10 #exit code
    syscall
