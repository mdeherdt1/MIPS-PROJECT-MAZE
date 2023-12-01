.data
filename: .asciiz "C:/Users/DH Services BVBA/Desktop/MIPS project 1/test_file_1.txt"
buffer: .space 1024              # Buffer voor bestandsinhoud

.text
.globl main
main:
    # Open het bestand voor lezen
    li $v0, 13                  # syscall voor open() functie
    la $a0, filename           # Bestandsnaam
    li $a1, 0                   # Vlaggen (0 voor lezen)
    li $a2, 0                   # Modus (niet relevant voor lezen)
    syscall
    move $s0, $v0               # Bewaar bestandsdescriptor

    # Lees het bestand
    li $v0, 14                  # syscall voor read() functie
    move $a0, $s0               # Bestandsdescriptor
    la $a1, buffer              # Buffer om gegevens te lezen
    li $a2, 1024                # Aantal bytes om te lezen
    syscall

    # Print de inhoud van het bestand
    li $v0, 4                   # syscall voor print_string
    la $a0, buffer              # Buffer met bestandsinhoud
    syscall

    # Sluit het bestand
    li $v0, 16                  # syscall voor close() functie
    move $a0, $s0               # Bestandsdescriptor
    syscall
    j exit
    
    
exit:
    # Beëindig het programma
    li $v0, 10                  # syscall voor exit
    syscall


