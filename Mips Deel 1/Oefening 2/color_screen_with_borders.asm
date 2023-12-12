
.include "translate_coordinates.asm"

.data
myColor:    .word 0x0bade3   # Voorbeeldwaarde voor blauw
redColor: .word 0xff0000	#rood
yellowColor: .word 0xffff00	#geel
errortxt: .asciiz "Is alles correct voltooid?"
.text

.globl main_file2



#de calc heeft het berekende adres nu al in $s0 gezet dit heb je later nodig


main_file2:
    #counter voor de randen
    li $s1, 0       # Rijteller
    li $s2, 0       # Kolomteller
	
    jal setBackground # ga naar setbackground
    
   



    ##################################################################


calc1:
    # Maak stackframe
    addi $sp, $sp, -12  # Reserveer ruimte op de stack
    sw $ra, 0($sp)      # Sla return-adres op
    sw $a1, 4($sp)      # Sla kolomnummer op
    sw $a2, 8($sp)      # Sla rijnummer op

    # Gebruik lokale kopieën van de argumenten
    move $t0, $a2       # Zet het aantal rijen in $t0
    mul $t0, $t0, 128   # 1 rij is 512 bits breed

    move $t1, $a1       # Zet het aantal kolommen in $t1
    mul $t1, $t1, 4     # Elke kolom is 16 bits breed

    # Bereken het adres
    add $v0, $t0, $gp   # Voeg offset van rijen toe aan $gp
    add $v0, $t1, $v0   # Voeg offset van kolommen toe

    # Herstel stackframe en keer terug
    lw $ra, 0($sp)      # Herstel return-adres
    lw $a1, 4($sp)      # Herstel kolomnummer
    lw $a2, 8($sp)      # Herstel rijnummer
    addi $sp, $sp, 12   # Geef ruimte op de stack vrij
    jr $ra              # Keer terug naar main
    
    
    ##################################################################
    
    
# Functie om een pixel in te kleuren
setColor: #specifieke kleur
    # Maak een stackframe
    addi $sp, $sp, -8
    sw $ra, 0($sp)           # Sla return-adres op
    sw $a1, 4($sp)           # Sla pixeladres op

    # Kleur de pixel in
    sw $a0, 0($a1)           # Schrijf kleur naar pixeladres

    # Herstel het stackframe en keer terug
    lw $ra, 0($sp)
    lw $a1, 4($sp)
    addi $sp, $sp, 8
 
    jr $ra

    ##################################################################

# Functie om een string af te drukken
	
setBackground: #zet de achtergrond goed
	bge $s1, 32, specific 		# MAAKT DE ACHTERGROND EN STOP DAN
	
	#randen op geel, rood voor de rest
	lw $s5, redColor	#zet de kleur op rood
	
	#gaat na wanneer de kleur op geel moet worden gezet
	beqz $s1, setYellow
	bge $s1, 15, setYellow
	beqz $s2, setYellow
	bge $s2, 31, setYellow
	
	j color


    ##################################################################

setYellow:	# rood -> geel
	lw $s5, yellowColor
	j color
	
	
	
    ##################################################################
	
color:
	move $a0, $s1 #rijnummer in a0
	move $a1, $s2 #kolomnummer in a1
	move $a2, $s5 #zet de bepaalde kleur in a2
	jal setPixelColor
	
	
	
	addi $s2, $s2, 1
	blt $s2, 32, setBackground

	li $s2, 0
	addi $s1, $s1, 1
	j setBackground

	
	
	
    ##################################################################	
	
setPixelColor:	#berekend steeds het bijbehorende adres (Niet super efficient maar het werkt)
	addi $sp, $sp, -16
	sw $ra, 0($sp)	#opslagen van het linked adress op de stack
	sw $a2, 4($sp)  #opslagen van de bepaalde kleur op de stack
	sw $a0, 8($sp)  #zet de rijnummer opd e stack 
	sw $a1, 12($sp) #zet kolomnummer op de stack
	
	#aanmaak lokale kopieen
	move $t0, $a0 #zet het aantal rijen in $t0
	mul $t0, $t0, 128
	
	move $t1, $a1 #zet het aantal kolommen in $t1
	mul $t1, $t1, 4
	
	
	sub $v0, $v0, $v0 #reset register naar 0
	#berekening
	add $v0, $t0, $gp
	add $v0, $t1, $v0 #v0 is nu het berekende vakje
	
	
	#kleurwaarde laden
	move $t2, $v0 #zet het berekende vakje in $t2
	sw $s5, 0($t2)
	
	
	#terug gaan
	lw $ra, 0($sp)	#opslagen van het linked adress op de stack
	lw $a2, 4($sp)  #opslagen van de bepaalde kleur op de stack
	lw $a0, 8($sp)  #zet de rijnummer opd e stack 
	lw $a1, 12($sp) #zet kolomnummer op de stack
	addi $sp, $sp, 16
	
	jr $ra
	
	
    ##################################################################
    

specific:


    # Voorbereiden van argumenten voor de setColor functie
    lw $a0, myColor         # zetten de adres van blauw in a0
    move $a1, $s0            # Adres van de pixel in $a1
    # Aanroepen van de setColor functie
    jal setColor

    j exit
    			
exit:     # Afsluitcode
    la $a0, errortxt
    li $v0, 4      
    syscall
   
    li $v0, 10	#clean exit
    syscall
    
    
    
