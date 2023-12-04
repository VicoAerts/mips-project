 .globl main

.data
mazeFilename:    .asciiz "C:\\Users\\Gebruiker\\Documents\\UNIF\\Jaar 1\\CSA\\CS\\input_1.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "You have won the game!"

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

wallColor:      .word 0x004286F4    # Color used for walls (blue)
passageColor:   .word 0x00000000    # Color used for passages (black)
playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
exitColor:      .word 0x0000FF00    # Color used for exit (green)

.text

main:
   #bestand inlezen
	#read file
    	li $v0,13
    	li $a1,0
    	la $a0,mazeFilename
   	syscall 

    	move $a0,$v0

    	#load file
    	la $a1,buffer
    	la $a2,4096
    	li $v0,14
    	syscall
    	move $s4,$a1
    	#print
la $a0,buffer
li $v0,4
syscall 

   #file is ingelezen nu maze maken 
   	li $s0,0 #rij  
   	li $s1,0 #kolom
   	
   		j loop_kolom
loop_rijen:
	bgt $s0,15,exit		#if greater dan 16 exit			
	addi $s0,$s0,1		# rij+1
	li $s1,0
	j loop_kolom
	
	
	
loop_kolom:
	bgt $s1,31,loop_rijen
	lb $s5,0($s4) 		#load wat er op deze plek in file staat
	jal check_colour	#als kolom groter dan 31 terug naar loop_rijen
	jal fill_colour
	addi $s4,$s4,1 		#ga eentje verder in de file
	addi $s1,$s1,1		#ga 1 kolom verder
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

     

check_colour:
    	# stack frame
    	sw $fp, 0($sp) # push old frame pointer (dynamic link)
    	move $fp, $sp # frame pointer now points to the top of the stack
    	subu $sp, $sp, 16 # allocate 16 bytes on the stack
    	sw $ra, -4($fp) # store the value of the return address
    	sw $s0, -8($fp) # save locally used registers
    	sw $s1, -12($fp)
    	
	beq $s5,119,colour_wall		#wanneer de ingelezen byte w is jump naar colour wall
	beq $s5,112,colour_passage 	#wanneer de ingelezen byte p is jump naar colour passage
	beq $s5,115,colour_player	#wanneer de ingelezen byte s is jump naar colour player
	beq $s5,117,colour_exit		#wanneer de ingelezen byte u is jump naar colour exit
	beq $s5,10,newline		#bij newline jumpen zonder te kleuren
    	
    	
	

colour_wall:
	lw $s3, wallColor      #Loading wallcolor in register s2
	
    	# stack frame     
    	lw $s1, -12($fp) # reset saved register $s1
    	lw $s0, -8($fp) # reset saved register $s0
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
colour_passage:
	lw $s3, passageColor      #Loading RED in passageColor s2
	
    	# stack frame     
    	lw $s1, -12($fp) # reset saved register $s1
    	lw $s0, -8($fp) # reset saved register $s0
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
colour_player:
	lw $s3, playerColor      #Loading playerColor in register s2
	
    	# stack frame     
    	lw $s1, -12($fp) # reset saved register $s1
    	lw $s0, -8($fp) # reset saved register $s0
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
colour_exit:
	lw $s3, exitColor      #Loading exitColor in register s2
	
    	# stack frame     
    	lw $s1, -12($fp) # reset saved register $s1
    	lw $s0, -8($fp) # reset saved register $s0
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
newline:
	addi $s4,$s4,1 		#ga eentje verder in de file
	j loop_kolom		#j terug naaar kolom er hoeft niks te gebeuren als er newline gelezen word
exit:
    	# syscall to end the program
    	li $v0, 10    
    	syscall
