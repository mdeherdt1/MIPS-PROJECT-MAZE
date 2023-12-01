.data
# Plaats je data elementen hier
rij:        .asciiz "Geef het aantal rijen in: "
kolom:      .asciiz "Geef het aantal kolommen in:"
emptyspace: .space 100
.text
################################################################## 

main1:

    # Input
    la $a0, rij
    li $v0, 4       # PRINT "Geef het aantal rijen in"
    syscall

    # Rijen inlezen
    la $a0, emptyspace    # Reserveer geheugen
    li $v0, 5       # Syscall voor lezen
    syscall

    move $a2, $v0   # Zet het aantal rijen in $a2

    la $a0, kolom
    li $v0, 4       # PRINT "Geef het aantal kolommen in"
    syscall
    
    
    
    # Kolommen inlezen
    la $a0, emptyspace
    li $v0, 5       # Syscall inlezen int
    syscall

    move $a1, $v0   # Zet het aantal kolommen in $a1
    
    jal calc        # Springt naar functie calc

    move $s0, $v0 	#opslagen op de stack voor verschillende functies

    
    jal main_file2

##############################################################
# in de vorm van [ RIJ , KOLOM ]
calc:
    # Maak stackframe
    addi $sp, $sp, -12  # Reserveer ruimte op de stack
    sw $ra, 0($sp)      # Sla return-adres op
    sw $a1, 4($sp)      # Sla kolomnummer op
    sw $a2, 8($sp)      # Sla rijnummer op

    # Gebruik lokale kopieën van de argumenten
    move $t0, $a2       # Zet het aantal rijen in $t0
    mul $t0, $t0, 128   # 1 rij is 512 bits breed

    move $t1, $a1       # Zet het aantal kolommen in $t1
    mul $t1, $t1, 4     # 1 kolom is 16 bits breed

    # Bereken het adres
    add $v0, $t0, $gp   # Voeg offset van rijen toe aan $gp
    add $v0, $t1, $v0   # Voeg offset van kolommen toe

    # Herstel stackframe en keer terug
    lw $ra, 0($sp)      # Herstel return-adres
    lw $a1, 4($sp)      # Herstel kolomnummer
    lw $a2, 8($sp)      # Herstel rijnummer
    addi $sp, $sp, 12   # Geef ruimte op de stack vrij
    jr $ra              # Keer terug naar main
