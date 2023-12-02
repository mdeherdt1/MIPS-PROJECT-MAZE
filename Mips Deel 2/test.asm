.data
	filename: .asciiz "C:/Users/DH Services BVBA/Desktop/MIPS PROJECT MAZE/Mips Deel 2/input_1.txt"
	buffer: .space 2
	charCount: .word 0
	wonMsg: .asciiz "\nJe hebt gewonnen"

#kleuren
	wallColor:      .word 0x004286F4    # Kleur voor muren (blauw)
	passageColor:   .word 0x00000000    # Kleur voor doorgangen (zwart)
	playerColor:    .word 0x00FFFF00    # Kleur voor speler (geel)
	exitColor:      .word 0x0000FF00    # Kleur voor uitgang (groen)
.text

main:
#openen van het bestand
	li $v0, 13		#syscall voor openen van bestand
	la $a0, filename	#pointer naar de bestandsnaam
	li $a1, 0		#flag voor bestand alleen-lezen
	li $a2, 0		#mode wordt genegeerd
	syscall
	
	move $s0, $v0		#opslaan van filedescriptor in $s0

read_loop:
	#bestandsgrootte is 512 karakters
	lw $t2, charCount
	li $t3, 512
	beq $t2, $t3, close 	#einde als alle karakters zijn gelezen

#lezen van 1 karakter
	li $v0, 14	#syscall voor het lezen van bestand
	move $a0, $s0 	#filedescriptor naar $a0
	
	la $a1, buffer	#buffer voor opslag van karakter
	li $a2, 1	#aantal te lezen karakters
	syscall
	
	lb $t1, buffer	#laad gelezen byte in $t1
	beqz $t1, close	#als einde van bestand bereikt, exit
	
	#filter newline karakters weg
	li $t0, 10 	#ascii voor newline
	beq $t1, $t0, read_loop #volgende karakter lezen zonder count te verhogen

	jal Color

#verhogen van charCount
    lw $t2, charCount	
    addi $t2, $t2, 1
    sw $t2, charCount

    j read_loop  

Color: 
#bereken offset
	lw $t3, charCount
	sll $t3, $t3, 2		#vermenigvuldig met 4 voor juiste offset

#controleer kleur
	li $t0, 'w'
	beq $t1, $t0, setWallColor
	
	li $t0, 'p'
	beq $t1, $t0, setPassageColor
	
	li $t0, 's'
	beq $t1, $t0, setPlayerColor
	
	li $t0, 'u'
	beq $t1, $t0, setExitColor
	
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
	
##################################################################

main2: #hoofdprogramma voor het lezen van de invoer
	jal readInput
	
	j exit

readInput: #update de positie van de speler bij elke invoer
#spelerpositie in $t9

#stackframe aanmaken
	addi $sp, $sp, -12
	
	sw $ra, 8($sp)
	sw $t6, 4($sp)	
	sw $t0, 0($sp)		#opslaan van vorige t0

#vraag eerst om invoer	
	li $v0, 12		#syscall voor lezen van karakter
	syscall
	
	move $t6, $v0	#opslaan karakter in $t6
	
	li $t0, 'z'
	beq $t6, $t0, calcz
	
	li $t0, 's'
	beq $t6, $t0, calcs
	
	li $t0, 'q'
	beq $t6, $t0, calcq
	
	li $t0, 'd'
	beq $t6, $t0, calcd
	
	li $t0, 'x'
	beq $t6, $t0, exit
	
	jal slapen 	#als geen of andere invoer

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
	
	
	beq $s1, $t9, exitWin
	jal slapen 	#indien er wel input is

	j readInput
	
	
calcq: #move left
	#adres zit nog in $t9
	#offset is $t3
	
	sub $t3, $t3, $t3 #reset t0
	
	addi $t3, $t3 -4 #we zetten -4 in t3 voor nieuwe adres te berekenen
	
	add $t8, $t9, $t3	# t8 is het nieuwe ares waar de speler moet geplaatst worden
	beq $s1, $t9, exitWin
	
	jal movePlayer
	
	
	jal slapen 	#indien er wel input is
	



#fixen van stackframe	
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	
	beq $s1, $t9, exitWin

	
	j readInput
	
	
calcd: #move right
	sub $t3, $t3, $t3 #reset t0
	
	addi $t3, $t3 4 #we zetten -4 in t3 voor nieuwe adres te berekenen
	
	add $t8, $t9, $t3	# t8 is het nieuwe ares waar de speler moet geplaatst worden
	
	jal movePlayer
	
	beq $s1, $t9, exitWin
	
	jal slapen 	#indien er wel input is




#fixen van stackframe	
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	
	beq $s1, $t9, exitWin
	j readInput
	
	
	
calcx:
#fixen van stackframe	
	lw $t0, 0($sp)
	lw $t6, 4($sp)
	lw $ra, 8($sp)
	
	addi $sp, $sp, 12
	
	j exit
	
away:
	jr $ra
	
	
movePlayer: #krijgt een adres zet dat adres naar geel en zet het vorige adres naar zwart
	
	#moet nog nagaan of het nieuwe adres geen blauw vakje is (voor later)
	la $t7, wallColor
	lw $t7, 0($t7)
	
	la $t6, 0($t8)
	lw $t6, 0($t6)
	
	beq $t6, $t7, away 	#als het een blauwe blok is, doe niks
	
	#t9 is het oude adres
	#t8 is het nieuwe adres
	
	la $t4, playerColor
	lw $t4, 0($t4)	
	sw $t4, 0($t8)
	
	la $t4, passageColor
	lw $t4, 0($t4)
	sw $t4, 0($t9)
	
	
	move $t9, $t8 #update current player position
	jr $ra
	

	j exit
exitTekst:

exitWin:
	li $v0,4
	la $a0, wonMsg
	syscall
	
	j exit

close: #bestand sluiten

	li $v0, 16 	#syscall voor sluiten
	move $a0, $s0	#file descriptor laden in %$a0
	syscall
	
	jal main2
	



exit:
	li $v0, 10	# syscall voor afsluiten
	syscall
