.data
up: .asciiz "\n up\n"
down: .asciiz "\n down\n"
left: .asciiz "\n left\n"
right: .asciiz "\n right\n"
unknown: .asciiz "\n Unknown input! Valid inputs: z s q d x\n"

.text
.globl main
main:
read_char:
    li $v0, 12            # Syscall karakter inlezen
    syscall
    move $t0, $v0         # plaats karakter in $t0


    # controle karakter
    li $v0, 4             # Syscall voor het printen van een string
    beq $t0, 'z', print_up
    beq $t0, 's', print_down
    beq $t0, 'q', print_left
    beq $t0, 'd', print_right
    beq $t0, 'x', exit
    la $a0, unknown   # Print onbekende invoerboodschap
    syscall
    j delay_and_loop

    ###################
print_up:
    la $a0, up	#laad "up" in $a0
    syscall
    j delay_and_loop

    ###################
print_down:
    la $a0, down	#laad "down" in $a0
    syscall
    j delay_and_loop

    ###################
print_left:
    la $a0, left	#laad "left" in $a0
    syscall
    j delay_and_loop

    ###################
print_right:
    la $a0, right	#laad "right" in $a0
    syscall
    j delay_and_loop

    ###################
delay_and_loop:
    li $t1, 500000       # zorgt voor vertraging in het programma 
    
    ###################
delay_loop:
    addi $t1, $t1, -1
    bnez $t1, delay_loop

    j read_char          # Ga terug naar het lezen van een karakter

exit:
    li $v0, 10           # Syscall om programma af te sluiten
    syscall
