  .data 
    msg1: .asciiz "Enter file name:"
    msg3: .asciiz "Enter the initial weights:"
    msg4: .asciiz "Enter momentum:"
    msg5: .asciiz "Enter learning rate:"
    msg6: .asciiz "Enter Threshold:"
    msg7: .asciiz "Enter epochs:"  
    file: .space 40
    Wi: .word 0
    Ti: .float 0.0
    LR: .float 0.0
    B: .float 0.0
    EP: .word 0
    i: .word 0
    _j: .word 0
    k: .word 0
    X: .word 0
    Yd: .word 0
    W: .word 0
    T: .word 0
    activation: .word 0
    ONE: .float 1.0
    BUFSIZ: .word 8192
    PREDICTION: .asciiz "The prediction of the model\n"
    DESIRED: .asciiz "The desired output\n" 
    ERROR: .asciiz "The error in the prediction\n"
    WEIGHTS: .asciiz "The weights at the end of the iteration\n"
    WEIGHTS_LR: .asciiz "The learning rate of weights at the end of the iteration\n"
    THRESHOLDS: .asciiz "The thresholds at the end of the iteration\n"
    THRESHOLDS_LR: .asciiz "The learning rate of thresholds at the end of the iteration\n"
  .text
  .globl main
main:

#prompt for file name
li $v0, 4 	#call to print string
la $a0, msg1	#enter file name prompt
syscall

li $v0, 8	#call to read string
la $a0, file	#save file name
li $a1, 40	#name size
syscall

la $a0, file
li $a1, 10
jal tokenize

la $a0, file
jal read_csv
sw $v0, X
sw $v1, Yd
lw $t0, -4($fp)
sw $t0, i
lw $t0, -8($fp)
sw $t0, _j
lw $t0, -12($fp)
sw $t0, k

#_____________________________________ENTER OTHER VALUES______________________________________

#prompt for momentum
li $v0, 4 	#call to print string
la $a0, msg4	#enter file name prompt
syscall
#read momentum
la $a1, B	
li $v0, 6
syscall
s.s $f0, 0($a1)


#prompt for Learning rate
li $v0, 4 	#call to print string
la $a0, msg5	#enter file name prompt
syscall
#read Learning rate
la $a1, LR	
li $v0, 6
syscall
s.s $f0, 0($a1)

li $v0, 4 	#call to print string
la $a0, msg3	
syscall

#read weights
lw $a0, _j
jal allocate_vector
sw $v0, Wi

lw $s0, _j
move $s1, $zero
loop4:
li $v0, 6
syscall
lw $a0, Wi
move $a1, $s1
mfc1 $a2, $f0
jal set_in_vector
addi $s1, $s1, 1     
addi $s0, $s0, -1 	#decrement counter of weights
bnez $s0, loop4


#prompt for Threshold
li $v0, 4 	#call to print string
la $a0, msg6	#enter file name prompt
syscall
#read initial Threshold
la $a1, Ti	
li $v0, 6
syscall
s.s $f0, 0($a1)


#prompt for epochs
li $v0, 4 	#call to print string
la $a0, msg7	#enter file name prompt
syscall
#read number of epochs
li $v0, 5
syscall
la $t0, EP
sw $v0, 0($t0)


lw $a0, k
lw $a1, _j
jal allocate_matrix
la $t0, W
sw $v0, 0($t0)

lw $a0, W
lw $a1, Wi
lw $a2, k
lw $a3, _j
jal initialize_weights

lw $a0, k
jal allocate_vector
la $t0, T
sw $v0, 0($t0)

lw $a0, T
lw $a1, k
lw $a2, Ti
jal fill_vector

# pass the activation function
la $t0, hard_limiter
la $t1, activation
sw $t0, 0($t1)

jal fit

li $v0, 10
syscall

