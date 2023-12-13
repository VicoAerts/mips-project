 .globl main

.data
mazeFilename:    .asciiz "input_1.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "You have won the game!"
start_msg:	 .asciiz "geef input"
error_msg:	 .asciiz "fout\n"
newline: 	 .asciiz "\n"

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

   #file is ingelezen nu maze maken 
   	li $s0,0 #rij  
   	li $s1,0 #kolom
   	
   		j loop_kolom
loop_rijen:
	bgt $s0,15,main_game_loop	#if greater dan 16 exit			
	addi $s0,$s0,1			# rij+1
	li $s1,0			# zet de kolomnummer terug op 0
	j loop_kolom			#jump terug naar loop rijen om de volgende rij in te kleuren
	
	
	
loop_kolom:
	bgt $s1,31,loop_rijen	#als kolom groter dan 31 terug naar loop_rijen
	lb $s5,0($s4) 		#load wat er op deze plek in file staat
	jal check_colour	#bepaal welke kleur op dit coordinaat moet komen
	jal fill_colour		#vul deze kleur in
	addi $s4,$s4,1 		#ga eentje verder in de file
	addi $s1,$s1,1		#ga 1 kolom verder
	j loop_kolom		#jump terug naar loop kolom
################################################################################################
#bestand ingelezen en maze gemaakt	
	
	
	
change_player:
#a0 a1 is het huidige coordinaat van de speler 
#a2 a3 is het nieuwe coordinaat van de speler
	move $s0,$a2 		#zet het rij nummer in het juiste register zodat we het coordinaat kunnen berekenen
	move $s1,$a3		#zet het kolom nummer in het juiste register zodat we het coordinaat kunnen berekenen
	jal coord_to_adress   	#bereken nu het coordinaat van de nieuwe positie
	#s2 bevat nu het coordinaat van de nieuwe positie
	lw $t0,0($s2)		#de kleur die op het nieuwe coord staat sit nu in t0
	lw $t1, passageColor   	#verplaats de waarde van passage in t1
	lw $t2, exitColor      	#verplaats de waarde van exit in t2
	beq $t0,$t1,valid_move #als de nieuwe coordinaat een passage bevat is de move geldig 	
	beq $t0,$t2,win_message	#als de nnieuwe coordinaat de exit bevat is de speler gewonnen
	j wrong_coord
	
	
valid_move:
	lw $s3,playerColor		#laad terug de player color in s3
	sw $s3, 0($s2)			#zet de speler op het nieuewe coordinaat
	move $s0,$a0			#zet het rij nummer in het juiste register zodat we het coordinaat kunnen berekenen
	move $s1,$a1			#zet het kolom nummer in het juiste register zodat we het coordinaat kunnen berekenen
	jal coord_to_adress		#bereken nu het coordinaat van de nieuwe positie
	lw $s3,passageColor		#laad de passage color op in s3
	sw $s3, 0($s2)			#zet op het oude adress van de speler terug een passage
	move $a0,$a2
	move $a1,$a3			
	j main_game_loop	
win_message:
#niet per se nodig maar zo zal de player echt tot de uitgang gaan ipv stoppen op 1plaats ervoor
	lw $s3,playerColor		#laad terug de player color in s3
	sw $s3, 0($s2)			#zet de speler op het nieuewe coordinaat
	move $s0,$a0			#zet het rij nummer in het juiste register zodat we het coordinaat kunnen berekenen
	move $s1,$a1			#zet het kolom nummer in het juiste register zodat we het coordinaat kunnen berekenen
	jal coord_to_adress		#bereken nu het coordinaat van de nieuwe positie
	lw $s3,passageColor		#laad de passage color op in s3
	sw $s3, 0($s2)			#zet op het oude adress van de speler terug een passage
#print de win message
	la $a0,victoryMessage
	li $v0,4
	syscall
# syscall to end the program
    	li $v0, 10    
    	syscall			
wrong_coord:
	move $a2,$a0 			#huidige plaats blijft behouden
	move $a3,$a1				
	j main_game_loop											
								
###############################################################################################
main_game_loop:
# stack frame
    	sw $fp, 0($sp) # push old frame pointer (dynamic link)
    	move $fp, $sp # frame pointer now points to the top of the stack
    	subu $sp, $sp, 8 # allocate 16 bytes on the stack
    	sw $a0, -4($fp) # store the value of a0 
    	
    	
# Sleep for 60 milli seconds
	li	$a0, 60		#60 milli sceonden sleep
	li	$v0, 32		#v0 voor sleep
	syscall 	

#start msg
	la $a0,start_msg	#laad de start message in a0
	li $v0,4		#print str
	syscall

#read character
	li $v0,12		#v0 voor read char
	syscall

#move char to s0
	move $t3,$v0
#newline
	la $a0,newline	#laad de newline in a0
	li $v0,4		#print str
	syscall
	
	# stack frame     
    	lw $a0, -4($fp) # get a0 address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	
	
input_verwerken:
	beq $t3,122,omhoog 		#wanneer we z krijgen beweeg omhoog 	
	beq $t3,115,omlaag		#wanneer we s krijgen beweeeg omlaag
	beq $t3,113,links		#wanneer we q krijgen beweeeg naar links
	beq $t3,100,rechts		#wanneer we d krijgen beweeg naar rechts
	beq $t3,120,einde_game		#beindig spel bij x
	
	j main_game_loop		#jump terug als imput niet een van bovenstaande is 

omhoog:
	subi $a2,$a0,1			#doe het rij nummer -1 en steek in a2
	move $a3,$a1			#steek de oorspronkelijke rij in a3
	j change_player			
omlaag:
	addi $a2,$a0,1			#doe het rij  numer +1 en steek in a2
	move $a3,$a1			#steek de oorspronkelijke rij in a3
	j change_player
links:
	subi $a3,$a1,1			#doe de kolom numer -1 en steek in a2
	move $a2,$a0			#steek de oorspronkelijke rij in a3
	j change_player
rechts:
	addi $a3,$a1,1			#doe de kolom numer -1 en steek in a2
	move $a2,$a0			#steek de oorspronkelijke rij in a3
	j change_player
einde_game:	
	li $v0, 10		#als x dan exit
	syscall									
											
#######################################################################################	
fill_colour:
# we zullen coordinaat omzetten naar het adres
# stack frame
    	sw $fp, 0($sp) # push old frame pointer (dynamic link)
    	move $fp, $sp # frame pointer now points to the top of the stack
    	subu $sp, $sp, 16 # allocate 16 bytes on the stack
    	sw $ra, -4($fp) # store the value of the return address
    	sw $s0, -8($fp) # save locally used registers
    	sw $s1, -12($fp) 
    	#s3 niet op stack want we hebben de waarde nodig die uit deze functie komt
    	
    	
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
    	subu $sp, $sp, 20 # allocate 16 bytes on the stack
    	sw $ra, -4($fp) # store the value of the return address
    	sw $s0, -8($fp) # save locally used registers
    	sw $s1, -12($fp)
    	sw $t0,-16($fp)
    	#s2 niet op stack want we hebben de waarde nodig die uit deze functie komt
    	

#we berekenen de offsset met formule BA+(r*K+c)*EL
    	mul $t0,$s0,32  # we zulllen het rij nummer vermenigvuldigen met de breedte nl 32
    	add $t0,$t0,$s1  # we tellen het kolomnummer bij onze vermenigvuldeging 
    	mul $t0,$t0,4    #we vermenigvuldigen het nog met de lengte van elk adres wat 4 bytes is
    	add $s2,$gp,$t0  # we tellen het base adress bij de (rxK+c)*el
    
# stack frame 
	
	lw $t0,-16($fp)    
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
    	subu $sp, $sp, 12 # allocate 16 bytes on the stack
    	sw $ra, -4($fp) # store the value of the return address
    	sw $s5, -8($fp) # save locally used registers
    	
    	
    	
	beq $s5,119,colour_wall		#wanneer de ingelezen byte w is jump naar colour wall
	beq $s5,112,colour_passage 	#wanneer de ingelezen byte p is jump naar colour passage
	beq $s5,115,colour_player	#wanneer de ingelezen byte s is jump naar colour player
	beq $s5,117,colour_exit		#wanneer de ingelezen byte u is jump naar colour exit
	beq $s5,10,newline_input		#bij newline jumpen zonder te kleuren
    	
    	
	

colour_wall:
	lw $s3, wallColor      #Loading wallcolor in register s2
	
    	# stack frame     
    	lw $s5, -8($fp) # reset saved register $s5
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
colour_passage:
	lw $s3, passageColor      #Loading RED in passageColor s2
	
    	# stack frame     
    	lw $s5, -8($fp) # reset saved register $s5
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
colour_player:
	lw $s3, playerColor      #Loading playerColor in register s2
	move $a0,$s0		 #laad de speler rij plaats in a0
	move $a1,$s1		 #laad de speler kolom plaats in a1	
    	# stack frame     
    	lw $s5, -8($fp) # reset saved register $s5
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
colour_exit:
	lw $s3, exitColor      #Loading exitColor in register s2
	
    	# stack frame     
    	lw $s5, -8($fp) # reset saved register $s5
    	lw $ra, -4($fp) # get return address from frame
    	move $sp, $fp # get old frame pointer from current fra
    	lw $fp, ($sp) # restore old frame pointer
    	jr $ra
newline_input:
	addi $s4,$s4,1 		#ga eentje verder in de file
	j loop_kolom		#j terug naaar kolom er hoeft niks te gebeuren als er newline gelezen word
exit:
    	# syscall to end the program
    	li $v0, 10    
    	syscall
