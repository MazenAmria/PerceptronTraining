
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
    X: .word 0			#features
    Y: .word 0			#desired classes
    W: .word 0
    Wi: .word 0		#initial weights
    B: .float 0.0		#momentum
    LR: .float 0.0		#learning rate
    Ti: .float 0.0		#initial threshold
    EP: .word 3			#num of epochs
    
    
    
   
    Yd: .word 0
  
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
la $a0, buffer
jal read_int	#read number of features (_j)
sw $v0, _j	# store in memory

addu $a0,$a0, 2	#Skip \r and \n
jal read_int  #read number of classes (k)  
sw $v0, k

addu $a0, $a0, 2	#Skip \r and \n
jal read_int  #read number of training sets (i) 
sw $v0, i

addu $a0, $a0, 2	#Skip \r and \n
move $s7, $a0		#save pointer to buffer

# allocate space for X
lw $a0, i
lw $a1, _j
jal allocate_matrix
sw $v0, X

#allocate space for Y
lw $a0, i
lw $a1, k
jal allocate_matrix
sw $v0, Y

#allocate space for W
lw $a0, k
lw $a1, _j
jal allocate_matrix
sw $v0, W

#allocate space for Wi
lw $a0, _j
jal allocate_vector
sw $v0, Wi

#allocate space for Wi
lw $a0, k
jal allocate_vector
sw $v0, T

#___________________________read features & classes_____________________________________



la $s1, X	# s1: pointer to X array (features)
lw $s2, _j	# s2: number of features per set
lw $s3, i	# s3: number of features per set
la $s4, Y	# s4: pointer to Y array (desired outputs)

		# s7: pointer to buffer 
li $a1, 0	#i
li $a2, 0	#j



loop2:			#read a feature__________
move $a0, $s7		#$a0 points to next feature in buffer
jal read_float_file
addiu $s7, $a0, 1	#skip comma

lw $a0, X		#pass argument for matrix address
move $a3, $v0		#pass argument for float value 
move $s5, $a1		#save a1
move $s6, $a2		#save a2
jal set_in_matrix
move $a1, $s5		#restore a1
move $a2, $s6		#restore a2

addiu $a2, $a2, 1	#j++
bne $a2, $s2, loop2 	#all features have been read? if no read another

#read desired class
move $a0, $s7		#$a0 points to the desired class
jal read_int		
addiu $s7, $a0, 2	#skip \r \n
	
#STORE one hot encoding
move $s5, $a1		#save $a1
move $a0, $v0		#pass class number 
move $t3, $a1		#get index of set
sll $t3, $t3, 2 	#convert to bytes

lw $t2, Y		
addu $a1, $t2, $t3	#calculate address location of one hot vector
lw $a1, 0($a1)		#pass the address
lw $a2, k		#pass vector size
jal one_hot_encoding

move $a1, $s5		#return the saved a1
li $a2, 0		#reset feature counter for next line


addiu $a1, $a1, 1	#i++
bne $a1, $s3, loop2 	#all training sets have been read? if no read another





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
lw $a0, Wi	# a0 = address of vector
li $a1, 0	#i pointer
loop4:
jal read_float
move $a2, $v0		#pass value
jal set_in_vector
addi $a1, $a1, 1	#next index
addi $s0, $s0, -1 	#decrement counter of weights
bnez $s0, loop4



#initialize weights matrix 
lw $a0, W	#destination matrixx
lw $a1, Wi	#soucre vector
lw $a2, k	
lw $a3, _j
jal initialize_weights


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

li $v0, 10
syscall


#address in $a0__________________
read_float_file:
#result in v0
#a0 = address in memory
addiu $sp, $sp -4
sw $ra, 0($sp)		#save return address

li $v0, 0
jal read_int

mtc1 $v0, $f0		#store the charactaristic int in f0
cvt.s.w $f0, $f0	#convert to float 

lb $t0, 0($a0)		#get next byte
bne $t0, 46, integer 	#if it isnt '.' then the number is an integer

addiu $a0, $a0, 1		#skip the '.'
move $t5, $a0		#save the address to calculate the exponent
jal read_int
mtc1 $v0, $f1		#store the fraction int in f1
cvt.s.w $f1, $f1	#convert to float

sub $t5, $a0, $t5	#t5 = number of fractional digits

move $t6, $a0		#save a0
li $a0, 10		#pass 10 to the power procedure		
move $a1, $t5		#pass the exponent
jal calc_power
move $a0, $t6		#restore a0
mtc1 $v0, $f2		#the number to divide the fraction part by so it becomes a fraction
cvt.s.w $f2, $f2	#convert to float

div.s $f1, $f1, $f2	#make fraction
add.s $f0, $f0, $f1	#add the characteristic and fraction to make the float


integer:
mfc1 $v0, $f0		#result in v0
lw $ra, 0($sp)
addiu $sp, $sp, 4
jr $ra
#___________________________________




#calculate exponents_________________________
calc_power:
#result in v0
#a0 = x
#a1 = power

li $v0, 1		#construct result in v0
po:
mul $v0, $v0, $a0	#v = v*y
addiu $a1, $a1, -1	#decrement counter
bnez $a1, po		#if not 0 loop again

jr $ra
#___________________________________



#read an integer from buffer__________________
read_int:
#result in v0
#a0 = address
li $v0, 0

strt:
lb $t0, 0($a0)
blt $t0, 48, end_of_num	#if not a number, finish
bgt $t0, 57, end_of_num
addi $a0, $a0, 1 	#increment pointer
addi $t0,$t0, -48 	# convert to int
addu $v0, $v0, $t0	#build integer
mul $v0, $v0, 10	#build integer
j strt

end_of_num:
div $v0, $v0, 10	#reverse last multiplication
jr $ra
#___________________________________



#read a float from user___________________
read_float:
li $v0, 6		#call to read float	
syscall			#read float weight
mfc1 $v0, $f0

jr $ra
#___________________________________


jal fit



