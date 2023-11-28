.data
	li $s0,0 # huidig rij nummer
	li $s1,0 # huidig kolom nummer 
	rijnummer: .asciiz "rijnummer: "  #messsage rij nummer
    	kolomnummer: .asciiz "kolomnummer: " # message kolom nummer


.text
main:
	
	li $s2, 0x00ff0000      #Loading RED in register t1
	#print de vraag naar rijnummer
    	la $a0, rijnummer #laad het adres van de message rijnummer in a0
    	li $v0, 4 # print string is v0 4
    	syscall
    	#read het gegeven rij nummer
    	li $v0,5 #read int v0 is 5
    	syscall
    	move $s0,$v0 #verplaats de gelezen integer naar s0
    
    
    	#print de vraag naar kolomnummer
    	la $a0, kolomnummer #laad het adres van de message kolomnummer in a0
    	li $v0, 4 # print string is v0 4
    	syscall
    	#read het gegeven kolom nummer
    	li $v0,5  #read int v0 is 5
    	syscall
    	move $a1,$v0  #verplaats de gelezen integer naar a1
    
    	move $a0,$s0  #nu we a0 niet meer nodig hebben kunnen we rij nummer in a0 steken
    	#Na deze blok code zal a0 het nummer van de rij bevatten en a1 die van kolom.
    	jal colour_all
    	j exit
    	
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
    	mul $t0,$a0,32  # we zulllen het rij nummer vermenigvuldigen met de breedte nl 32
    	add $t0,$t0,$a1  # we tellen het kolomnummer bij onze vermenigvuldeging 
    	mul $t0,$t0,4    #we vermenigvuldigen het nog met de lengte van elk adres wat 4 bytes is
    	add $a2,$gp,$t0  # we tellen het base adress bij de (rxK+c)*el
    
# stack frame     
    	lw $s1, -12($fp) # reset saved register $s1
    	lw $s0, -8($fp) # reset saved register $s0
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
    
     


colour_1:
	jal coord_to_adress
#adress van pixel inkleuren
# stack frame
    	sw $fp, 0($sp) # push old frame pointer (dynamic link)
    	move $fp, $sp # frame pointer now points to the top of the stack
    	subu $sp, $sp, 16 # allocate 16 bytes on the stack
    	sw $ra, -4($fp) # store the value of the return address
    	sw $s0, -8($fp) # save locally used registers
    	sw $s1, -12($fp)
    	
    	
    	sw $s2 , 0($a2)
    	
    	
    	
    	# stack frame     
    	lw $s1, -12($fp) # reset saved register $s1
    	lw $s0, -8($fp) # reset saved register $s0
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra	






colour_all:

jal colour_1

exit: 
#einde programme
    li $v0,10 #exit code
    syscall
