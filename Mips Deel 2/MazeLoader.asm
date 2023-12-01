.data
	filename: .asciiz "C:/Users/DH Services BVBA/Desktop/Mips Deel 2/input_1.txt"
	buffer: .space 2
	charCount: .word 0

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
	#bestand is 512 karakters groot
	lw $t2, charCount
	li $t3, 512
	beq $t2, $t3, close 	#als het alle karakters heeft overlopen exit
	
	
#inlezen van 1 karakter
	li $v0, 14	#syscall voor inlezen van file
	move $a0, $s0 	#filedescriptor naar $a0
	
	la $a1, buffer	#buffer waar het karakter zal in worden opgeslagen
	li $a2, 1	#aantal karakters dat zal worden ingelezen
	syscall
	
	lb $t1, buffer	#gelezen byte inladen in $t1
	beqz $t1, close	#als het einde van het bestand bereikt exit
	
	#er mogen geen endl charachters bij zitten dus die filteren we weg
	li $t0, 10 	#ascii voor een endl
	beq $t1, $t0, read_loop #lees het volgende karakter zonder de count te verhogen
	
	
	jal Color	
	
	
#verhogen van de charCount
    lw $t2, charCount	
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
	la $t4, playerColor
	lw $t4, 0($t4)		
	
	add $t5, $gp, $t3	#offset optellen bij de gp om het juiste adres te krijgen ven het karakter
	
	sw $t4, 0($t5)
	
	jr $ra 
	




setExitColor:
	la $t4, exitColor
	lw $t4, 0($t4)		
	
	add $t5, $gp, $t3	#offset optellen bij de gp om het juiste adres te krijgen ven het karakter
	
	sw $t4, 0($t5)
	
	jr $ra 
	




close: #bestand sluiten

	li $v0, 16 	#syscall voor sluiten
	move $a0, $s0	#file descriptor laden in %$a0
	syscall

exit:
	li $v0, 10	# syscall voor exit
	syscall
	
	
	
	
	