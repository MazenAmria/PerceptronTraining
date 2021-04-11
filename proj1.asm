
  .data 
    msg1: .asciiz "Enter file name:"
    msg2: .asciiz "Enter the "
    msg3: .asciiz " initial weights:"
    msg4: .asciiz "Enter momentum:"
    msg5: .asciiz "Enter learning rate:"
    msg6: .asciiz "Enter Threshold:"
    msg7: .asciiz "Enter epochs:"  
    file: .space 40    		# filename for input
    buffer: .space 1024		#read file
    i: .word 0			#num of training sets
    _j: .word 0			#num of features
    k: .word 0			#num of classes
    X: .space 1024		#features
    Y: .space 1024		#desired classes
    Wi: .space 100		#initial weights
    B: .float 0.0		#momentum
    LR: .float 0.0		#learning rate
    Ti: .float 0.0		#initial threshold
    EP: .word 3			#num of epochs
    
    
    
   
    Yd: .word 0
    W: .word 0
    T: .word 0
    activation: .word 0
    ONE: .float 1.0
    PRE_ACTV: .asciiz "Before Applying the activation function\n"
    INPUT: .asciiz "The input vector\n"
    POST_ACTV: .asciiz "After Applying the activation function\n"
    DESIRED: .asciiz "The desired output\n"
    ERROR: .asciiz"The error in the prediction\n"
    WABS_CHANGE: .asciiz "The absolute change in the weights\n"
    WCHANGE: .asciiz "The change in the weights\n"
    WEIGHTS_BEFORE: .asciiz "The weights at the beginning of the iteration\n"
    WEIGHTS_AFTER: .asciiz "The weights at the end of the iteration\n"
    TH_CHANGE: .asciiz "Change in thresholds\n"
    THRESHOLDS_BEFORE: .asciiz "The thresholds at the beginning of the iteration\n"
    THRESHOLDS_AFTER: .asciiz "The thresholds at the end of the iteration\n"
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

la $t0, file	
li $t2, 10	#10 = \n
loop:		#loop to find the last char of the name
addi $t0, $t0, 1
lb $t1, 0($t0)
bne $t1, $t2, loop	#if name isn't over continue looping

li $t2, 0
sb $t2, 0($t0)	#terminate string with null char


#open file
la $a0, file	#"load file address"
li $a1, 0	#"flags"
li $a2, 0
li $v0, 13	#"call number for opening a file"
syscall

#read file
move $a0, $v0	#file handle
la $a1, buffer	
li $a2, 1024	#max buffer size
li $v0, 14	#call number to read file
syscall

#parse file
la $t9, buffer
lb $t0, 0($t9)	#read number of features
addi $t0,$t0, -48 # convert to int
la $t8, _j
sw $t0, 0($t8)	# store in memory

lb $t1, 3($t9) #read number of classes. Skip \r and \n
addi $t1, $t1, -48  # convert to int
la $t8, k 
sw $t1, 0($t8)	# store in memory

#___________________________read features & classes_____________________________________

li $s4, 0 	#counter for number of training sets
la $s3, Y	# s3: pointer to Y array (desired outputs)
la $t1, _j
lw $s2, 0($t1)	# s2: number of features to read
la $s1, X	# s1: pointer to X array (features)
li $s0, 0	# s0: stores the integer while it is being built
li $t1, 0	# t1: counter for the features read
		# t0: temp to hold components of the integer
		# t9: pointer to buffer 
addi $t9, $t9, 6

loop2:			#read a feature__________
lb $t0, 0($t9)
beq $t0, 44, comp	#compare to comma ','
addi $t9, $t9, 1 	#increment pointer
addi $t0,$t0, -48 	# convert to int
beqz $s2, row		#branch if last element in this row 
addu $s0, $s0, $t0	#build integer
mul $s0, $s0, 10	#build integer
j loop2

comp:
div $s0, $s0, 10	#reverse last multiplication
sw $s0, 0($s1)		#store feature in the X array
addu $s1, $s1, 4	#point to next index
addi $s2,$s2, -1	#decrement number of features left in this row
addi $t9, $t9, 1 	#skip ','
li $s0, 0		#reset s0 to hold the next integer
j loop2			#end read feature_________

row:
sw $t0, 0($s3)		#add desired output to Y array
addu $s3, $s3, 4	#point to next index
la $t1, _j		#reset number of features for the next line
lw $s2, 0($t1)		

addi $s4, $s4, 1	#increment the training set counter
addi $t9, $t9, 2	#skip \r \n
lb $t0, 0($t9)		#compare next to null
bne $t0, 0, loop2	#if eof continue

la $t0, i
sw $s4, 0($t0)		#store the number of training sets

#_____________________________________ENTER OTHER VALUES______________________________________

#display prompt
li $v0, 4 	#call to print string
la $a0, msg2	
syscall

la $t1, _j	#get number of features
lw $a0, 0($t1)
move $s0, $a0		# a0: number of weights
li $v0, 1
syscall			#print number of weights

li $v0, 4 	#call to print string
la $a0, msg3	
syscall

#read weights
la $a1, Wi	
loop4:
jal read_float
addi $a1, $a1, 4	#point to next index
addi $s0, $s0, -1 	#decrement counter of weights
bnez $s0, loop4

#prompt for momentum
li $v0, 4 	#call to print string
la $a0, msg4	#enter file name prompt
syscall
#read momentum
la $a1, B	
jal read_float


#prompt for Learning rate
li $v0, 4 	#call to print string
la $a0, msg5	#enter file name prompt
syscall
#read Learning rate
la $a1, LR	
jal read_float


#prompt for Threshold
li $v0, 4 	#call to print string
la $a0, msg6	#enter file name prompt
syscall
#read initial Threshold
la $a1, Ti	
jal read_float


#prompt for epochs
li $v0, 4 	#call to print string
la $a0, msg7	#enter file name prompt
syscall
#read number of epochs
li $v0, 5
syscall
la $t0, EP
sw $v0, 0($t0)

#print Float
#la $t0, B
#lwc1 $f12, 0($t0)
#li $v0, 2
#syscall


li $v0, 10
syscall

read_float:
li $v0, 6		#call to read float	
syscall			#read float weight
swc1 $f0, 0($a1)

jr $ra


 
