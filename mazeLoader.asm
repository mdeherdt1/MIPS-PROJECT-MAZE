.data 
	filename: .asciiz "input_1.txt" #zorg ervoor dat de input file in de home folder staat (/home in CMI)
	buffer: .space 2
	charCount: .word 0
	wonMsg: .asciiz "\nYou won"

#kleuren
	wallColor:      .word 0x004286F4    # Color used for walls (blue)
	passageColor:   .word 0x00000000    # Color used for passages (black)
	playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
	exitColor:      .word 0x0000FF00    # Color used for exit (green)
.text


main:
#openen van de file
	li $v0, 13		#syscall voor openen van file
	la $a0, filename	#pointer naar de filename
	li $a1, 0		#flag voor bestand alleen te lezen
	li $a2, 0		#mode is ignored
	syscall
	
	move $s0, $v0		#opslaan van filedescriptor in $s0
	
	
	

read_loop:
    # Lees 1 karakter
    li $v0, 14          # Syscall voor het lezen van een bestand
    move $a0, $s0       # Filedescriptor naar $a0
    la $a1, buffer      # Buffer voor gelezen karakter
    li $a2, 1           # Lees 1 karakter
    syscall

    # Controleer op end of file
    beqz $v0, close     # Als er geen karakters gelezen zijn, close file

    # Laad het gelezen karakter
    lb $t1, buffer	#Lees elk karakter 1 voor 1 in (onefficient maar werkt beter met het opslaan van de spelerposities)

    # Controleer op toegestane karakters: w, p, u, s
    li $t0, 'w'
    beq $t1, $t0, process_character
    li $t0, 'p'
    beq $t1, $t0, process_character
    li $t0, 'u'
    beq $t1, $t0, process_character
    li $t0, 's'
    beq $t1, $t0, process_character

    # Als het karakter niet een van de toegestane karakters is, ga verder
    j read_loop

process_character:


    jal Color    # Verwerk het toegestane karakter


    lw $t2, charCount   	   # Verhoog de charCount
    addi $t2, $t2, 1
    sw $t2, charCount

    j read_loop

    
    
Color: 
#offset berekenen
	lw $t3, charCount
	sll $t3, $t3, 2		#vermenigvuldig met 4 voor de juiste offset
	
#nakijken van de kleur
	li $t0, 'w'			#laad de ascii w waarde in t0
	beq $t1, $t0, setWallColor		#als de twee ascii waardes overeen komen gan aan label
	
	li $t0, 'p'			#laad de ascii p waarde in t0
	beq $t1, $t0, setPassageColor	#als de twee ascii waardes overeen komen gan aan label
	
	li $t0, 's'			#laad de ascii s waarde in t0
	beq $t1, $t0, setPlayerColor	#als de twee ascii waardes overeen komen gan aan label
	
	li $t0, 'u'			#laad de ascii u waarde in t0
	beq $t1, $t0, setExitColor	#als de twee ascii waardes overeen komen gan aan label
	
	
	jr $ra
	
	
	
setWallColor:
	la $t4, wallColor	
	lw $t4, 0($t4)		
	
	add $t5, $gp, $t3	#offset optellen bij de gp om het juiste adres te krijgen ven het karakter
	
	sw $t4, 0($t5)
	
	jr $ra 
	
	
	
setPassageColor:
	la $t4, passageColor
	lw $t4, 0($t4)		
	
	add $t5, $gp, $t3	#offset optellen bij de gp om het juiste adres te krijgen ven het karakter
	
	sw $t4, 0($t5)
	
	jr $ra 
	



setPlayerColor:

	#we slagen de positie op van de speler
	
	
	la $t4, playerColor
	lw $t4, 0($t4)		
	
	add $t5, $gp, $t3	#offset optellen bij de gp om het juiste adres te krijgen ven het karakter
	
	move $t9, $t5	#opslaan van positie speler
	sw $t4, 0($t5)
	
	jr $ra 
	




setExitColor:
	la $t4, exitColor
	lw $t4, 0($t4)		
	
	add $t5, $gp, $t3	#offset optellen bij de gp om het juiste adres te krijgen ven het karakter
	
	move $s1, $t5	#opslaan van exit adres
	sw $t4, 0($t5)
	
	jr $ra 
	
	
#end of loading background

################################################################################################


#reading and updating player position

main2: 
#main for reading the input
	jal readInput	#jump and link naar de readInput Loop
	j exit		#controle exit (indien error)




readInput: 
#updates the player position for each input
#player position is in $t9
	
#creating stackframe
	addi $sp, $sp, -12
	
	sw $ra, 8($sp)
	sw $t6, 4($sp)		#is normaal leeg 
	sw $t0, 0($sp)		#opslaan van vorige t0
	

#we vragen eerst de input	
	li $v0, 12		#syscall voor read charachter
	syscall
	
	move $t6, $v0	#opslagen het charachter op in $t6
	
	li $t0, 'z'	#laden van charachter z in $t0
	beq $t6, $t0, calcz #als de karakters overeen komen, bereken het nieuwe adres
	
	li $t0, 's'	#laden van charachter s in $t0
	beq $t6, $t0, calcs
	
	li $t0, 'q'	#laden van charachter q in $t0
	beq $t6, $t0, calcq
	
	li $t0, 'd'	#laden van charachter d in $t0
	beq $t6, $t0, calcd
	
	li $t0, 'x'	#laden van charachter x in $t0
	beq $t6, $t0, exit
	
	
	jal slapen 	#indien er geen/andere input is
	
	j exitstack
	



slapen:
	li $v0, 32 #syscall voor sleep
	li $a0, 60	#60 ms sleep
	syscall
	
	jr $ra
	
	
	
exitstack:

#fixen van stackframe want dit is nog niet gebeurt 
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	
	
	
	j readInput

	

calcz:
#calculating the right position to move to 
	
	sub $t3, $t3, $t3 #reset t0
	
	addi $t3, $t3 -128 #we zetten -4 in t3 voor nieuwe adres te berekenen
	
	add $t8, $t9, $t3	# t8 is het nieuwe ares waar de speler moet geplaatst worden
	
	jal movePlayer
	
	
	
	jal slapen 	#indien er wel input is


#fixen van stackframe	
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	
	
	
	j readInput
	
	
calcs:

	sub $t3, $t3, $t3 #reset t0
	
	addi $t3, $t3 128 #we zetten -4 in t3 voor nieuwe adres te berekenen
	
	add $t8, $t9, $t3	# t8 is het nieuwe ares waar de speler moet geplaatst worden
	
	jal movePlayer
	
	
	
	jal slapen 	#indien er wel input is



#fixen van stackframe	
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	
	
	jal slapen 	#indien er wel input is

	j readInput
	
	
calcq: #move left
	#adres zit nog in $t9
	#offset is $t3
	
	sub $t3, $t3, $t3 #reset t0
	
	addi $t3, $t3 -4 #we zetten -4 in t3 voor nieuwe adres te berekenen
	
	add $t8, $t9, $t3	# t8 is het nieuwe ares waar de speler moet geplaatst worden
	
	jal movePlayer
	
	
	jal slapen 	#indien er wel input is
	



#fixen van stackframe	
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	

	
	j readInput
	
	
calcd: #move right
	sub $t3, $t3, $t3 #reset t0
	
	addi $t3, $t3 4 #we zetten -4 in t3 voor nieuwe adres te berekenen
	
	add $t8, $t9, $t3	# t8 is het nieuwe ares waar de speler moet geplaatst worden
	
	jal movePlayer
	

	
	jal slapen 	#indien er wel input is




#fixen van stackframe	
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	
	j readInput
	
	
	
calcx:




#fixen van stackframe	
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	
	
	jal slapen 	#indien er wel input is
	
	
	j exit
	
	
away:
	jr $ra
	
movePlayer: #krijgt een adres zet dat adres naar geel en zet het vorige adres naar zwart
	
#moet nog nagaan of het nieuwe adres geen blauw vakje is
	la $t7, wallColor
	lw $t7, 0($t7)		#laden van de blauwe kleur $t7
	
	la $t6, 0($t8)		#laden van nieuw berekende adres
	lw $t6, 0($t6)		
	
	beq $t6, $t7, away 	#als het nieuwe adres een blauwe blok is, doe niks
	

	#t9 is het oude adres
	#t8 is het nieuwe adres
	
	
	la $t4, playerColor
	lw $t4, 0($t4)	
	sw $t4, 0($t8)
	
	la $t4, passageColor
	lw $t4, 0($t4)
	sw $t4, 0($t9)
	
	
			

	
	
	
	move $t9, $t8 #update current player position
	
	beq $s1, $t9, exitWin	#als de speler op het groene vakje komt, print wonMsg en stop
	
	jr $ra			#ga terug naar de readInput
	
	

	

	j exit
	
exitWin:
#print bericht als je wint
	li $v0,4	#syscall voor print string
	la $a0, wonMsg	#laden van de string in $a0
	syscall	
	
	j exit		#print de string en stop dan

	

	
	

close: #bestand sluiten

	li $v0, 16 	#syscall voor sluiten
	move $a0, $s0	#file descriptor laden in $a0
	syscall
	
	jal main2
	

exit:
	li $v0, 10	# syscall voor exit
	syscall
	
	
	
	
	
