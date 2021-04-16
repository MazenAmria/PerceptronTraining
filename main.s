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
    BUFSIZ: .word 2048
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

debug_matrix:
  # Debugs a matrix of floats
  # $a0 = address of the matrix
  # $a1 = number of rows (i)
  # $a2 = number of columns (j)
  # $a3 = address of the message
    
  addiu $sp, $sp, -24
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $a2, 16($fp)                           # save i
  sw $a3, 20($fp)                           # save msg
                  
  jal print_hr                  
                  
  lw $a0, 20($fp)                           # load msg
  addiu $v0, $zero, 4                 
  syscall                                   # print msg
                  
  jal print_hr                  
                      
  lw $a0, 8($fp)                            # load vec
  lw $a1, 12($fp)                           # load i
  lw $a2, 16($fp)                           # load j
  jal print_matrix                 
                
  jal print_hr                 
                
  addiu $a0, $zero, 10                      # load '\n'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\n'
                  
  move $sp, $fp                 
  lw $fp, 0($sp)                  
  lw $ra, 4($sp)                            # pop the return address
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return

debug_vector:
  # Debugs a vector of floats
  # $a0 = address of the vector
  # $a1 = size of the vector
  # $a2 = address of the message
    
  addiu $sp, $sp, -20
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $a2, 16($fp)                           # save msg

  jal print_hr                  

  lw $a0, 16($fp)                           # load msg
  addiu $v0, $zero, 4                 
  syscall                                   # print msg

  jal print_hr                  

  lw $a0, 8($fp)                            # load vec
  lw $a1, 12($fp)                           # load i
  jal print_vector                  

  jal print_hr                  

  addiu $a0, $zero, 10                      # load '\n'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\n'

  move $sp, $fp                 
  lw $fp, 0($sp)                  
  lw $ra, 4($sp)                            # pop the return address
  addiu $sp, $sp, 20                        # free the stack
  jr $ra                                    # return

forward_token:
  # Forwards the pointer to the next token in a tokenized string.
  # $a0 = pointer of the tokenized string
  # Returns:
  # $v0 = pointer to the next token

  addiu $sp, $sp, -12
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save str
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j forward_token_i_check

forward_token_i_body:

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

forward_token_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 8($fp)                            # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t2, 0($t0)                            # load str[_i]
  bne $t2, $zero, forward_token_i_body      # if str[_i] != '\0' continue
  # else
  move $sp, $fp
  addu $v0, $t0, 1                          # return (str + _i + 1)
  lw $fp, 4($sp)
  addiu $sp, $sp, 12                        # free the stack
  jr $ra                                    # return

parse_dims:
  # Parses and save the dimensions of the inputs
  # with format (i,j,k)
  # $a0 = pointer to the string
  # Returns:
  # $v0 = i
  # $v1 = j
  # -4($fp) = k

  addiu $sp, $sp, -24
  sw $ra, 16($sp)
  sw $fp, 12($sp)
  move $fp, $sp
  sw $a0, 20($fp)                           # save str

  lw $a0, 20($fp)                           # pass str
  li $a1, 44                                # pass ','
  jal tokenize                              # split

  lw $a0, 20($fp)                           # pass str
  jal parse_int
  sw $v0, 8($fp)

  lw $a0, 20($fp)                           # pass str
  jal forward_token
  sw $v0, 20($fp)

  lw $a0, 20($fp)                           # pass str
  jal parse_int
  sw $v0, 4($fp)

  lw $a0, 20($fp)                           # pass str
  jal forward_token
  sw $v0, 20($fp)

  lw $a0, 20($fp)                           # pass str
  jal parse_int
  sw $v0, 0($fp)

  move $sp, $fp
  lw $ra, 16($sp)
  lw $fp, 12($sp)
  lw $v0, 8($sp)                            # return i
  lw $v1, 4($sp)                            # return j
  lw $t0, 0($sp)
  sw $t0, -4($fp)                           # return k
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return 

parse_float:
  # Parses a float from a null terminated string
  # $a0 = pointer to the string
  # Returns:
  # $v0 = the parsed float

  addiu $sp, $sp, -28
  sw $ra, 20($sp)
  sw $fp, 16($sp)
  move $fp, $sp
  sw $a0, 24($fp)                           # save str
  sw $zero, 12($fp)                         # float res = 0

  lw $a0, 24($fp)                           # pass str
  li $a1, 46                                # pass '.'
  jal tokenize                              # separate the integer part and the fraction part

  lw $a0, 24($fp)                           # pass str
  jal parse_int                             # parse the integer part
  mtc1 $v0, $f0
  cvt.s.w $f0, $f0                          # convert it to float
  s.s $f0, 12($fp)                          # res = integer part of the float

  lw $a0, 24($fp)                           # pass str
  jal forward_token
  sw $v0, 24($fp)                           # str = next_token (fraction part)

  lw $a0, 24($fp)                           # pass str
  jal strlen
  sw $v0, 8($fp)                            # save len

  lw $a0, 24($fp)                           # pass str
  jal parse_int                             # parse the fraction part
  mtc1 $v0, $f0
  cvt.s.w $f0, $f0                          # convert it to float
  s.s $f0, 4($fp)                           # save fraction

  lw $t0, 12($fp)                           # load res
  lui $t1, 0x8000                           # bitmask to check the sign bit
  and $t0, $t0, $t1
  beq $t0, $zero, parse_float_positive      # if res is positive continue
  # else
  lw $t0, 4($fp)                            # load fraction
  or $t0, $t0, $t1                          # set the sign bit
  sw $t0, 4($fp)

parse_float_positive:

  li $a0, 10                                # pass 10
  lw $a1, 8($fp)                            # pass len
  jal pow_int                               # calculate 10^len
  mtc1 $v0, $f0
  cvt.s.w $f0, $f0                          # convert it to float
  s.s $f0, 0($fp)                           # save denominator

  l.s $f0, 12($fp)                          # load res
  l.s $f2, 4($fp)                           # load fraction
  l.s $f4, 0($fp)                           # load denominator
  div.s $f2, $f2, $f4                       # fraction /= denominator
  add.s $f0, $f0, $f2                       # res += fraction
  s.s $f0, 12($fp)                          # save res

  move $sp, $fp
  lw $ra, 20($sp)
  lw $fp, 16($sp)
  lw $v0, 12($sp)                           # return res
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return 

parse_input:
  # Parses a list of tuples of data with the format 
  # (float,float,float,float,...,int)
  # $a0 = pointer to the input
  # $a1 = address of the features matrix
  # $a2 = address of classes matrix
  # $a3 = number of tuples (i)
  # -8($sp) = number of features (j)
  # -4($sp) = number of features (k)

  addiu $sp, $sp, -36
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save buff
  sw $a1, 16($fp)                           # save X
  sw $a2, 20($fp)                           # save Yd
  sw $a3, 24($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0

  lw $a0, 12($fp)                           # pass buff
  li $a1, 10                                # pass '\n'
  jal tokenize                              # split

  j parse_input_i_check

parse_input_i_body:

  lw $a0, 12($fp)                           # pass buff
  jal forward_token
  lw $a0, 12($fp)                           # pass buff
  sw $v0, 12($fp)                           # buff <-- next token

  lw $t1, 0($fp)                            # load _i
  sll $t1, $t1, 2                           # convert to bytes address
  lw $t0, 16($fp)                           # load X
  addu $t0, $t0, $t1                        # calculate the address
  lw $a1, 0($t0)                            # pass X[_i]

  lw $a2, 28($fp)                           # pass j

  jal parse_tuple

  lw $t0, 32($fp)                           # load k
  li $t1, 2                                 # load 2
  sltu $t0, $t0, $t1                        # if k < 2
  bne $t0, $zero, parse_input_encoded       # already encoded
  # else
  move $a0, $v0                             # pass class number

  lw $t1, 0($fp)                            # load _i
  sll $t1, $t1, 2                           # convert to bytes offset
  lw $t0, 20($fp)                           # load Yd
  addu $t0, $t0, $t1                        # calculate the address
  lw $a1, 0($t0)                            # pass Yd[_i]

  lw $a2, 32($fp)                           # pass k
  
  jal one_hot_encoding
  
  j parse_input_i_forward

parse_input_encoded:

  lw $a0, 20($fp)                           # pass Yd
  lw $a1, 0($fp)                            # pass _i
  move $a2, $zero                           # pass _j = 0
  mtc1 $v0, $f0
  cvt.s.w $f0, $f0
  mfc1 $a3, $f0                             # pass class number
  jal set_in_matrix

parse_input_i_forward:

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

parse_input_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 24($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, parse_input_i_body        # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 36                        # free the stack
  jr $ra                                    # return 

parse_int:
  # Parses an integer from a null terminated string
  # $a0 = pointer to the string
  # Returns:
  # $v0 = the parsed integer

  addiu $sp, $sp, -16
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save str
  sw $zero, 4($fp)                          # int res = 0
  sw $zero, 0($fp)                          # unsigned int _i = 0

  lw $t0, 12($fp)                           # load str
  lb $t0, 0($t0)                            # load str[0]
  li $t1, 45                                # load '-'
  bne $t0, $t1, parse_int_i_check           # if str[0] != '-' start parsing
  # else
  li $t0, 1
  sw $t0, 0($fp)
  j parse_int_i_check                       # start from str[1]

parse_int_i_body:

  lw $t0, 4($fp)                            # load res
  mul $t0, $t0, 10                          # res *= 10
  sw $t0, 4($fp)

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t0, 0($t0)                            # load str[_i]
  addiu $t0, $t0, -48                       # T = str[_i] - '0'
  lw $t1, 4($fp)                            # load res
  addu $t1, $t1, $t0                        # res += T
  sw $t1, 4($fp)

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

parse_int_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t0, 0($t0)                            # load str[_i]
  bne $t0, $zero, parse_int_i_body          # if str[_i] != '\0' continue
  # else
  lw $t0, 12($fp)                           # load str
  lb $t0, 0($t0)                            # load str[0]
  li $t1, 0x2D                              # load '-'
  bne $t0, $t1, parse_int_return            # if str[0] != '-' parsing done
  # else
  lw $t0, 4($fp)
  li $t1, -1
  mul $t0, $t0, $t1
  sw $t0, 4($fp)                            # res *= -1

parse_int_return:

  move $sp, $fp
  lw $fp, 8($sp)
  lw $v0, 4($sp)                            # return res
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

parse_tuple:
  # Parses a tuple of data with the format 
  # (float,float,float,float,...,int)
  # $a0 = pointer to the tuple
  # $a1 = address of the feature vector
  # $a2 = number of features (j)
  # Returns:
  # $v0 = class number

  addiu $sp, $sp, -28
  sw $ra, 12($sp)
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 24($fp)                           # save str
  sw $a1, 20($fp)                           # save X[_i]
  sw $a2, 16($fp)                           # save j
  sw $zero, 4($fp)                          # unsigned int _j = 0

  lw $a0, 24($fp)                           # pass str
  li $a1, 44                                # pass ','
  jal tokenize                              # split

  j parse_tuple_j_check

parse_tuple_j_body:

  lw $a0, 24($fp)                           # pass str
  jal forward_token
  lw $a0, 24($fp)                           # pass str
  sw $v0, 24($fp)                           # str <-- next token
  jal parse_float

  lw $t1, 4($fp)                            # load _j
  sll $t1, $t1, 2                           # convert to bytes address
  lw $t0, 20($fp)                           # load X[_i]
  addu $t0, $t0, $t1                        # calculate the address
  sw $v0, 0($t0)                            # X[_i][_j] = parsed float

  lw $t0, 4($fp)
  addiu $t0, $t0, 1
  sw $t0, 4($fp)                            # _j++

parse_tuple_j_check:

  lw $t1, 4($fp)                            # load _j
  lw $t0, 16($fp)                           # load j
  sltu $t0, $t1, $t0                        # if _j < j
  bne $t0, $zero, parse_tuple_j_body        # continue
  # else
  lw $a0, 24($fp)                           # pass str
  jal parse_int                             # parse the class number
  sw $v0, 0($fp)

  move $sp, $fp
  lw $ra, 12($sp)
  lw $fp, 8($sp)
  lw $v0, 0($sp)                            # return class number
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return 

print_hr:
  # Prints a horizontal rule
    
  addiu $sp, $sp, -8
  sw $fp, 4($sp)
  move $fp, $sp
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j print_hr_i_check

print_hr_i_body:

  addiu $a0, $zero, '#'                     # load '#'
  addiu $v0, $zero, 11    
  syscall                                   # print '#' 

  lw $t0, 0($fp)           
  addiu $t0, $t0, 1           
  sw $t0, 0($fp)                            # _i++

print_hr_i_check:             

  lw $t0, 0($fp)                            # load _i
  sltiu $t0, $t0, 50                        # if _i < 50
  bne $t0, $zero, print_hr_i_body           # continue
  # else              
  addiu $a0, $zero, 10                      # load '\n'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\n'
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 8
  jr $ra

print_matrix:
  # Prints a matrix of floats
  # $a0 = address of the matrix
  # $a1 = number of rows (i)
  # $a2 = number of columns (j)

  addiu $sp, $sp, -24
  sw $fp, 4($sp)
  sw $ra, 8($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save mat
  sw $a1, 16($fp)                           # save i
  sw $a2, 20($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j print_matrix_i_check                
          
print_matrix_i_body:                
          
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load mat
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass mat[_i]
  lw $a1, 20($fp)                           # pass j
  jal print_vector                          # prints the row
          
  lw $t0, 0($fp)               
  addiu $t0, $t0, 1               
  sw $t0, 0($fp)                            # _i++
          
print_matrix_i_check:    

  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, print_matrix_i_body       # continue
  # else          
  move $sp, $fp         
  lw $fp, 4($sp)          
  lw $ra, 8($sp)                            # pop the return address
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return

print_vector:
  # Prints a vector of floats
  # $a0 = address of the vector
  # $a1 = size of the vector
    
  addiu $sp, $sp, -16
  sw $fp, 4($sp)
  move $fp, $sp         
  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j print_vector_i_check                  
          
print_vector_i_body:                  

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load vec
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f12, 0($t0)                          # load vec[_i]
  addiu $v0, $zero, 2                 
  syscall                                   # print vec[_i]

  addiu $a0, $zero, 9                       # load '\t'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\t'      

  lw $t0, 0($fp)                 
  addiu $t0, $t0, 1                 
  sw $t0, 0($fp)                            # _i++

print_vector_i_check:                 

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, print_vector_i_body       # continue
  # else          
  addiu $a0, $zero, 10                      # load '\n'
  addiu $v0, $zero, 11                  
  syscall                                   # print '\n' 
  move $sp, $fp         
  lw $fp, 4($sp)          
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

read_csv:
  # Reads a CSV file data
  # $a0 = pointer to filename
  # Returns:
  # $v0 = address of X
  # $v1 = address of Yd
  # -4($fp) = i
  # -8($fp) = j
  # -12($fp) = k

  addiu $sp, $sp, -36
  sw $ra, 28($sp)
  sw $fp, 24($sp)
  move $fp, $sp
  sw $a0, 32($sp)                           # save filename

  lw $a0, BUFSIZ
  li $v0, 9                                 # sbrk()
  syscall

  sw $v0, 20($fp)                           # save buff

  lw $a0, 32($sp)                           # pass filename
  move $a1, $zero                           # set flags
  move $a2, $zero                           # set mode
  li $v0, 13                                # open file
  syscall

  move $a0, $v0                             # pass file descriptor
  lw $a1, 20($fp)                           # pass buff
  lw $a2, BUFSIZ
  li $v0, 14                                # read file
  syscall

  move $t1, $v0                             # number of read characters n
  lw $t0, 20($fp)                           # buff
  addu $t0, $t0, $t1                        # $t0 points to buff[n]
  sb $zero, 0($t0)                          # null terminating the buffer

  lw $a0, 20($fp)                           # pass buff
  li $a1, 10                                # pass '\n'
  jal tokenize

  lw $a0, 20($fp)                           # pass buff
  jal forward_token
  lw $a0, 20($fp)                           # pass buff
  sw $v0, 20($fp)                           # buff <-- next token 'line'
  jal parse_dims

  sw $v0, 8($fp)                            # save i
  sw $v1, 4($fp)                            # save j
  lw $t0, -4($fp)
  sw $t0, 0($fp)                            # save k

  lw $a0, 8($fp)                            # pass i
  lw $a1, 4($fp)                            # pass j
  jal allocate_matrix
  sw $v0, 16($fp)                           # save X

  lw $a0, 8($fp)                            # pass i
  lw $a1, 0($fp)                            # pass k
  jal allocate_matrix
  sw $v0, 12($fp)                           # save Yd

  lw $a0, 20($fp)                           # pass buff
  lw $a1, 16($fp)                           # pass X
  lw $a2, 12($fp)                           # pass Yd
  lw $a3, 8($fp)                            # pass i
  lw $t0, 4($fp)
  sw $t0, -8($sp)                           # pass j
  lw $t0, 0($fp)
  sw $t0, -4($sp)                           # pass k
  jal parse_input

  move $sp, $fp
  lw $ra, 28($sp)
  lw $fp, 24($sp)
  lw $v0, 16($sp)                           # return X
  lw $v1, 12($sp)                           # return Yd
  lw $t0, 8($sp)
  sw $t0, -4($fp)                           # return i
  lw $t0, 4($sp)
  sw $t0, -8($fp)                           # return j
  lw $t0, 0($sp)
  sw $t0, -12($fp)                          # return k
  addiu $sp, $sp, 36                        # free the stack
  jr $ra                                    # return 

strlen:
  # Returns the length of a null terminated string.
  # $a0 = pointer of the string
  # Returns:
  # $v0 = length of the string

  addiu $sp, $sp, -12
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save str
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j strlen_i_check

strlen_i_body:

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

strlen_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 8($fp)                            # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t2, 0($t0)                            # load str[_i]
  bne $t2, $zero, strlen_i_body             # if str[_i] != '\0' continue
  # else
  move $sp, $fp
  lw $v0, 0($fp)                            # return _i
  lw $fp, 4($sp)
  addiu $sp, $sp, 12                        # free the stack
  jr $ra                                    # return

tokenize:
  # Tokenizes a string by a certain delimiter
  # $a0 = pointer to the string
  # $a1 = the delimiter

  addiu $sp, $sp, -16
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save str
  sw $a1, 8($fp)                            # save deli
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j tokenize_i_check

tokenize_i_body:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t0, 0($t0)                            # load str[_i]
  lw $t1, 8($fp)                            # load deli
  bne $t0, $t1, tokenize_i_forward          # if str[_i] != deli continue
  # else
  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  sb $zero, 0($t0)                          # str[_i] = '\0' 

tokenize_i_forward:

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

tokenize_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load str
  addu $t0, $t0, $t1                        # calculate the address
  lb $t0, 0($t0)                            # load str[_i]
  bne $t0, $zero, tokenize_i_body           # if str[_i] != '\0' continue
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

add_matrix:
  # Adds a matrix to another
  # Aij += Bij
  # $a0: address of the destination matrix (ixj size)
  # $a1: address of the source matrix (ixj size)
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)
    
  addiu $sp, $sp, -28
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save B
  sw $a2, 20($fp)                           # save i
  sw $a3, 24($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j add_matrix_i_check

add_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass A[_i]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 16($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass B[_i]

  lw $a2, 24($fp)                           # pass j

  jal add_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

add_matrix_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 20($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, add_matrix_i_body         # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

add_vector:
  # Adds a vector to another
  # Ai += Bi
  # $a0: address of the destination vector (i size)
  # $a1: address of the source vector (i size)
  # $a2: i (4-bytes integer)
    
  addiu $sp, $sp, -20
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save A
  sw $a1, 12($fp)                           # save B
  sw $a2, 16($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j add_vector_i_check

add_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # load B[_i]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load A
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)
  add.s $f0, $f2, $f0                       # T = A[_i] + B[_i]
  s.s $f0, 0($t0)                           # A[_i] = T

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

add_vector_i_check:
  
  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, add_vector_i_body
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 20                        # free the stack
  jr  $ra                                   # return

allocate_matrix:
  # Alocates a matrix
  # returns $v0 = Aij
  # $a0: i (4-bytes integer)
  # $a1: j (4-bytes integer)
    
  addiu $sp, $sp, -28
  sw $ra, 16($sp)
  sw $fp, 12($sp)
  move $fp, $sp
  sw $a0, 24($fp)                           # save i
  sw $a1, 20($fp)                           # save j
      
  lw $a0, 24($fp)                           # load i
  jal allocate_vector                       # T = allocate_vector(i) 
      
  sw $v0, 4($fp)                            # float ** matrix = T
      
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j allocate_i_check      
      
allocate_i_body:      
      
  lw $a0, 20($fp)                           # load j
  jal allocate_vector                       # T = allocate_vector(j)
        
  sw $v0, 8($fp)                            # float * temp = T
        
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 4($fp)                            # load matrix
  addu $t0, $t1, $t0                        # calculate the address
  lw $t1, 8($fp)                            # load temp
  sw $t1, 0($t0)                            # matrix[_i] = temp
      
  lw $t0, 0($fp)      
  addiu $t0, $t0, 1     
  sw $t0, 0($fp)                            # _i++
      
allocate_i_check:     
      
  lw $t1, 0($fp)                            # load _i
  lw $t0, 24($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, allocate_i_body           # continue
  # else      
  move $sp, $fp     
  lw $v0, 4($sp)                            # return matrix
  lw $fp, 12($sp)     
  lw $ra, 16($sp)                           # reset the return address
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

allocate_vector:
  # Alocates a vector
  # returns $v0 = Ai
  # $a0: i (4-bytes integer)

  sll $a0, $a0, 2                           # convert to bytes size
  
  li $v0, 9                                 # sbrk()
  syscall
  
  jr $ra

assign_matrix:
  # Assigns a matrix to another
  # $a0: address of the destination matrix (ixj size)
  # $a1: address of the soruce matrix (ixj size)
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)

  addiu $sp, $sp, -28
  sw $ra, 4($sp)                            # save $ra
  sw $fp, 8($sp)                            # save $fp
  move $fp, $sp
  sw $a0, 12($fp)                           # save dest
  sw $a1, 16($fp)                           # save src
  sw $a2, 20($fp)                           # save i
  sw $a3, 24($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
 
  j  assign_matrix_i_check

assign_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load dest
  addu $t0, $t1, $t0                        # calculate the address 
  lw $a0, 0($t0)                            # pass dest[_i]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 16($fp)                           # load src
  addu $t0, $t1, $t0                        # calculate the address 
  lw $a1, 0($t0)                            # pass src[_i]

  lw $a2, 24($fp)                           # pass j
  jal assign_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

assign_matrix_i_check:
  
  lw $t0, 20($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, assign_matrix_i_body      # continue
  # else
  move $sp, $fp
  lw $ra, 4($sp)                            # pop $ra
  lw $fp, 8($sp)                            # pop $fp
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

assign_vector:
  # Assigns a vector to another
  # $a0: address of the destination vector (i size)
  # $a1: address of the soruce vector (i size)
  # $a2: i (4-bytes integer)

  addiu $sp, $sp, -20
  sw $fp, 4($sp)                            # save $fp
  move $fp, $sp
  sw $a0, 8($fp)                            # save dest
  sw $a1, 12($fp)                           # save src
  sw $a2, 16($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  
  j assign_vector_i_check

assign_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load src
  addu $t1, $t1, $t0                        # calculate the address

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t2, 8($fp)                            # load dest
  addu $t0, $t2, $t0                        # calculate the address

  lw $t2, 0($t1)                            # T = src[_i]
  sw $t2, 0($t0)                            # dest[_i] = T

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

assign_vector_i_check:

  lw $t0, 16($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, assign_vector_i_body      # continue
  # else
  move $sp, $fp
  lw $fp, 4($sp)                            # pop $fp
  addiu $sp, $sp, 20                        # free the stack
  jr $ra                                    # return

copy_matrix:
  # Copies a matrix to another
  # returns $v0 = address of clone(src)
  # $a0: address of the soruce matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)

  addiu $sp, $sp, -28
  sw $ra, 12($sp)                           # save $ra
  sw $fp, 8($sp)                            # save $fp
  move $fp, $sp         
  sw $a0, 16($fp)                           # save src
  sw $a1, 20($fp)                           # save i
  sw $a2, 24($fp)                           # save j

  lw $a0, 20($fp)                           # pass i to allocate_vector
  jal allocate_vector                 

  sw $v0, 4($fp)                            # save dest
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j copy_matrix_i_check         

copy_matrix_i_body:         

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 16($fp)                           # load src
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass src[_i]

  lw $a1, 24($fp)                           # pass j
  jal copy_vector                           # $t0 = copy_vector(src[_i], j)

  lw $t1, 0($fp)                            # load _i
  sll $t1, $t1, 2                           # convert to bytes offset
  lw $t0, 4($fp)                            # load dest
  addu $t1, $t0, $t1                        # calculate the address

  sw $v0, 0($t1)                            # dest[_i] = $t0

  lw $t0, 0($fp)          
  addiu $t0, $t0, 1         
  sw $t0, 0($fp)                            # _i++
      
copy_matrix_i_check:                  
      
  lw $t0, 20($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i

  bne $t0, $zero, copy_matrix_i_body        # continue

  move $sp, $fp
  lw $v0, 4($fp)                            # return dest
  lw $ra, 12($sp)                           # pop $ra
  lw $fp, 8($sp)                            # pop $fp
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

copy_vector:
  # Copies a vector to another
  # returns $v0 = address of clone(src)
  # $a0: address of the soruce vector (i size)
  # $a1: i (4-bytes integer)

  addiu $sp, $sp, -24
  sw $ra, 12($sp)                           # save $ra
  sw $fp, 8($sp)                            # save $fp
  move $fp, $sp               
  sw $a0, 16($fp)                           # save src
  sw $a1, 20($fp)                           # save i

  lw $a0, 20($fp)                           # pass i to allocate_vector
  jal allocate_vector               

  sw $v0, 4($fp)                            # save dest
  sw $zero, 0($fp)                          # unsigned int _i = 0
    
  j copy_vector_i_check

copy_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 16($fp)                           # load src
  addu $t1, $t1, $t0                        # calculate the address

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t2, 4($fp)                            # load dest
  addu $t0, $t2, $t0                        # calculate the address

  lw $t2, 0($t1)                            # T = src[_i]
  sw $t2, 0($t0)                            # dest[_i] = T

  lw $t0, 0($fp)                
  addiu $t0, $t0, 1               
  sw $t0, 0($fp)                            # _i++

copy_vector_i_check:

  lw $t0, 20($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i

  bne $t0, $zero, copy_vector_i_body        # continue

  move $sp, $fp
  lw $v0, 4($fp)                            # return dest
  lw $ra, 12($sp)                           # pop $ra
  lw $fp, 8($sp)                            # pop $fp
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return

div_matrix:
  # Divides a matrix by another (element wise)
  # Aij /= Bij
  # $a0: address of the destination matrix (ixj size)
  # $a1: address of the source matrix (ixj size)
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)
    
  addiu $sp, $sp, -28
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save B
  sw $a2, 20($fp)                           # save i
  sw $a3, 24($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j div_matrix_i_check

div_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass A[_i]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 16($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass B[_i]

  lw $a2, 24($fp)                           # pass j

  jal div_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

div_matrix_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 20($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, div_matrix_i_body         # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

div_vector:
  # Divides a vector by another (element wise)
  # Ai /= Bi
  # $a0: address of the destination vector (i size)
  # $a1: address of the source vector (i size)
  # $a2: i (4-bytes integer)
    
  addiu $sp, $sp, -20
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save A
  sw $a1, 12($fp)                           # save B
  sw $a2, 16($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j div_vector_i_check

div_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # load B[_i]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load A
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)
  mul.s $f0, $f2, $f0                       # T = A[_i] * B[_i]
  s.s $f0, 0($t0)                           # A[_i] = T

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

div_vector_i_check:
  
  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, div_vector_i_body
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 20                        # free the stack
  jr  $ra                                   # return

fill_matrix:
  # Fills a matrix with a value
  # $a0: address of the destination matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)
  # $a3: value (4-bytes float)

  addiu $sp, $sp, -28
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp

  sw $a0, 12($fp)                           # save mat
  sw $a1, 16($fp)                           # save i
  sw $a2, 20($fp)                           # save j
  sw $a3, 24($fp)                           # save val
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j fill_matrix_i_check             

fill_matrix_i_body:             

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load mat     
  addu $t0, $t1, $t0                        # calculate the address  

  lw $a0, 0($t0)                            # pass $a0 = mat[_i]
  lw $a1, 20($fp)                           # pass $a1 = j
  lw $a2, 24($fp)                           # pass $a2 = val
  jal fill_vector                           # fill the row

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

fill_matrix_i_check:

  lw $t0, 16($fp)                           # load i
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, fill_matrix_i_body        # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

fill_vector:
  # Fills a vector with a value
  # $a0: address of the destination vector (i size)
  # $a1: i (4-bytes integer)
  # $a2: value (4-bytes float)

  addiu $sp, $sp, -20
  sw $fp, 4($sp)
  move $fp, $sp

  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $a2, 16($fp)                           # save val
  sw $zero, 0($fp)                          # unsigned int _i = 0

  j fill_vector_i_check

fill_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load vec     
  addu $t0, $t1, $t0                        # calculate the address  
  l.s $f0, 16($fp)                          # T = val
  s.s $f0, 0($t0)                           # vec[_i] = val

  lw $t0, 0($fp)                
  addiu $t0, $t0, 1               
  sw $t0, 0($fp)                            # _i++

fill_vector_i_check:                

  lw $t0, 12($fp)                           # load i
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, fill_vector_i_body        # continue
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 20                        # free the stack
  jr $ra                                    # return

linear_transform:
  # Linear Transformation of a vector (Change Basis)
  # Wij * Xj = Yi
  # $a0: address of the input vector (j size)
  # $a1: address of the change of basis matrix (ixj size)
  # $a2: address of the output vector (i size)
  # $a3: i (4-bytes integer)
  # -4($sp): j (4-bytes integer)
    
  addiu $sp, $sp, -32
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save X
  sw $a1, 16($fp)                           # save W
  sw $a2, 20($fp)                           # save Y
  sw $a3, 24($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j linear_transform_i_check

linear_transform_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 20($fp)                           # load Y
  addu $t0, $t1, $t0                        # calculate the address
  sw $zero, 0($t0)                          # Y[_i] = 0

  sw $zero, 4($fp)                          # unsigned int _j = 0
  j linear_transform_j_check

linear_transform_j_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 16($fp)                           # load W
  addu $t0, $t1, $t0                        # calculate the address of the row
  lw $t1, 0($t0)                            # load W[_i]

  lw $t0, 4($fp)                            # load _j
  sll $t0, $t0, 2                           # convert to byte offset
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f4, 0($t0)                           # load W[_i][_j]

  lw $t0, 4($fp)                            # load _j
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load X
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)                           # load X[_j]

  mul.s $f0, $f4, $f0                       # T = W[_i][_j] * X[_j]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 20($fp)                           # load Y
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # load Y[_i]
  add.s $f0, $f2, $f0                       # Y[_i] += T
  s.s $f0, 0($t0)                           # save Y[_i]

  lw $t0, 4($fp)                    
  addiu $t0, $t0, 1                   
  sw $t0, 4($fp)                            # _j++

linear_transform_j_check:

  lw $t1, 4($fp)                            # load _j
  lw $t0, 28($fp)                           # load j
  sltu $t0, $t1, $t0                        # if _j < j
  bne $t0, $zero, linear_transform_j_body   # continue
  # else 
  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

linear_transform_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 24($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, linear_transform_i_body   # continue
  # else
  move $sp, $fp
  lw $fp, 8($sp)
  addiu $sp, $sp, 32                        # free the stack
  jr $ra                                    # return

mul_matrix:
  # Multiplies a matrix to another (element wise)
  # Aij *= Bij
  # $a0: address of the destination matrix (ixj size)
  # $a1: address of the source matrix (ixj size)
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)
    
  addiu $sp, $sp, -28
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save B
  sw $a2, 20($fp)                           # save i
  sw $a3, 24($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j mul_matrix_i_check

mul_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass A[_i]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 16($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass B[_i]

  lw $a2, 24($fp)                           # pass j

  jal mul_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

mul_matrix_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 20($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, mul_matrix_i_body         # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

mul_vector:
  # Multiplies a vector to another (element wise)
  # Ai *= Bi
  # $a0: address of the destination vector (i size)
  # $a1: address of the source vector (i size)
  # $a2: i (4-bytes integer)
    
  addiu $sp, $sp, -20
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save A
  sw $a1, 12($fp)                           # save B
  sw $a2, 16($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j mul_vector_i_check

mul_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # load B[_i]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load A
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)
  mul.s $f0, $f2, $f0                       # T = A[_i] * B[_i]
  s.s $f0, 0($t0)                           # A[_i] = T

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

mul_vector_i_check:
  
  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, mul_vector_i_body
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 20                        # free the stack
  jr  $ra                                   # return

scale_matrix:
  # Scales a matrix by constant value
  # Aij *= K
  # $a0: address of the destination matrix (ixj size)
  # $a1: value of the scalar
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)
    
  addiu $sp, $sp, -28
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save K
  sw $a2, 20($fp)                           # save i
  sw $a3, 24($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j scale_matrix_i_check

scale_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass A[_i]

  lw $a1, 16($fp)                           # pass K

  lw $a2, 24($fp)                           # pass j
  jal scale_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

scale_matrix_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 20($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, scale_matrix_i_body       # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

scale_vector:
  # Scales a vector by constant value
  # Ai *= K
  # $a0: address of the destination vector (i size)
  # $a1: value of the scalar
  # $a2: i (4-bytes integer)
    
  addiu $sp, $sp, -20
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save A
  sw $a1, 12($fp)                           # save K
  sw $a2, 16($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j scale_vector_i_check

scale_vector_i_body:

  l.s $f2, 12($fp)                          # load K
                        
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load A
  addu $t0, $t1, $t0                            # calculate the address
  l.s $f0, 0($t0)                           # load A[_i]
                      
  mul.s $f0, $f0, $f2                       # T = K * A[_i]
  s.s $f0, 0($t0)                           # A[_i] = T
                    
  lw $t0, 0($fp)                    
  addiu $t0, $t0, 1                   
  sw $t0, 0($fp)                            # _i++
                    
scale_vector_i_check:
                   
  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, scale_vector_i_body
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 20                        # free the stack
  jr  $ra                                   # return

set_in_matrix:
  # Sets an element in a matrix with a value
  # mat[_i] = val
  # $a0: address of the destination matrix
  # $a1: _i (4-bytes integer)
  # $a2: _j (4-bytes integer)
  # $a3: value (4-bytes float)

  addiu $sp, $sp, -24
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp

  sw $a0, 8($fp)                            # save mat
  sw $a1, 12($fp)                           # save _i
  sw $a2, 16($fp)                           # save _j
  sw $a3, 20($fp)                           # save val
                  
  lw $t0, 12($fp)                           # load _i
  sll $t0, $t0, 2                           # converts to bytes offset
  lw $t1, 8($fp)                            # load mat
  addu $t0, $t1, $t0                        # calculate the address
                  
  lw $a0, 0($t0)                            # pass mat[_i]
  lw $a1, 16($fp)                           # pass _j
  lw $a2, 20($fp)                           # pass val
  jal set_in_vector                         # mat[_i][_j] = val
                  
  move $sp, $fp                 
  lw $ra, 4($sp)                  
  lw $fp, 0($sp)                  
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return

set_in_vector:
  # Sets an element in a vector with a value
  # vec[_i] = val
  # $a0: address of the destination vector
  # $a1: _i (4-bytes integer)
  # $a2: value (4-bytes float)

  addiu $sp, $sp, -16
  sw $fp, 0($sp)
  move $fp, $sp

  sw $a0, 4($fp)                            # save vec
  sw $a1, 8($fp)                            # save _i
  sw $a2, 12($fp)                           # save val
                  
  lw $t0, 8($fp)                            # load _i
  sll $t0, $t0, 2                           # converts to bytes offset
  lw $t1, 4($fp)                            # load vec
  addu $t0, $t1, $t0                        # calculate the address
                  
  lw $t1, 12($fp)                           # T = val
  sw $t1, 0($t0)                            # vec[_i] = val
                  
  move $sp, $fp                 
  lw $fp, 0($sp)                  
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

sqrt_matrix:
  # Square root of a matrix (element wise)
  # Aij = sqrt(Aij)
  # $a0: address of the matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)
    
  addiu $sp, $sp, -24
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save i
  sw $a2, 20($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j sqrt_matrix_i_check

sqrt_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass A[_i]

  lw $a1, 20($fp)                           # pass j

  jal sqrt_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

sqrt_matrix_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, sqrt_matrix_i_body        # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 24                        # free the stack
  jr $ra                                    # return

sqrt_vector:
  # Sqaure root of a vector
  # Ai = sqrt(Ai)
  # $a0: address of the vector (i size)
  # $a1: i (4-bytes integer)

  addiu $sp, $sp, -20
  sw $ra, 8($sp)                            # save $ra
  sw $fp, 4($sp)                            # save $fp
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a2, 16($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  
  j sqrt_vector_i_check

sqrt_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address

  lw $a0, 0($t0)                            # pass A[_i]
  jal sqrt

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $a0, 12($fp)                           # load A
  addu $t0, $a0, $t0                        # calculate the address

  sw $v0, 0($t0)                            # A[_i] = $v0

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

sqrt_vector_i_check:

  lw $t0, 16($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, sqrt_vector_i_body        # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)                            # pop $ra
  lw $fp, 4($sp)                            # pop $fp
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

square_matrix:
  # Squares a matrix (element wise)
  # Aij = Aij^2
  # $a0: address of the matrix (ixj size)
  # $a1: i (4-bytes integer)
  # $a2: j (4-bytes integer)
    
  addiu $sp, $sp, -24
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save i
  sw $a2, 20($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j square_matrix_i_check

square_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass A[_i]

  lw $a1, 20($fp)                           # pass j

  jal square_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

square_matrix_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, square_matrix_i_body      # continue
  # else
  move $sp, $fp
  lw $ra, 8($sp)
  lw $fp, 4($sp)
  addiu $sp, $sp, 24                        # free the stack
square_vector:
  # Squares a vector (element wise)
  # Ai = Ai^2
  # $a0: address of the vector (i size)
  # $a1: i (4-bytes integer)
    
  addiu $sp, $sp, -16
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save A
  sw $a1, 12($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j square_vector_i_check

square_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load A
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)
  mul.s $f0, $f0, $f0                       # T = A[_i] * A[_i]
  s.s $f0, 0($t0)                           # A[_i] = T

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

square_vector_i_check:
  
  lw $t1, 0($fp)                            # load _i
  lw $t0, 12($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, square_vector_i_body
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

sub_matrix:
  # Subtracts a matrix from another
  # Aij -= Bij
  # $a0: address of the destination matrix (ixj size)
  # $a1: address of the source matrix (ixj size)
  # $a2: i (4-bytes integer)
  # $a3: j (4-bytes integer)
    
  addiu $sp, $sp, -28
  sw $ra, 8($sp)
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save B
  sw $a2, 20($fp)                           # save i
  sw $a3, 24($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j sub_matrix_i_check
  
sub_matrix_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass A[_i]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to byte offset
  lw $t1, 16($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass B[_i]

  lw $a2, 24($fp)                           # pass j

  jal sub_vector      

  lw $t0, 0($fp)      
  addiu $t0, $t0, 1     
  sw $t0, 0($fp)                            # _i++

sub_matrix_i_check:     
  
  lw $t1, 0($fp)                            # load _i
  lw $t0, 20($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, sub_matrix_i_body         # continue
  # else      
  move $sp, $fp     
  lw $ra, 8($sp)                            # pop the return address
  lw $fp, 4($sp)      
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

sub_vector:
  # Subtracts a vector from another
  # Ai -= Bi
  # $a0: address of the destination vector (i size)
  # $a1: address of the source vector (i size)
  # $a2: i (4-bytes integer)
    
  addiu $sp, $sp, -20
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save A
  sw $a1, 12($fp)                           # save B
  sw $a2, 16($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j sub_vector_i_check

sub_vector_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # load B[_i]
                    
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 8($fp)                            # load A
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)                     
  sub.s $f0, $f0, $f2                       # T = A[_i] - B[_i]
  s.s $f0, 0($t0)                           # A[_i] = T

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

sub_vector_i_check:

  lw $t1, 0($fp)                            # load _i
  lw $t0, 16($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, sub_vector_i_body
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  addiu $sp, $sp, 20                        # free the stack
  jr  $ra                                   # return

vector_cross:
  # Obtain the matrix from multiplying two vectors
  # Mij = Ai * Bj
  # $a0: address of the first vector (i size)
  # $a1: address of the second vector (j size)
  # $a2: address of the destination matrix (ixj size)
  # $a3: i (4-bytes integer)
  # -4($sp): j (4-bytes integer)

  addiu $sp, $sp, -32
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save A
  sw $a1, 16($fp)                           # save B
  sw $a2, 20($fp)                           # save M
  sw $a3, 24($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
  j vector_cross_i_check                

vector_cross_i_body:                

  sw $zero, 4($fp)                          # unsigned int _j = 0
  j vector_cross_j_check                

vector_cross_j_body:                

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load A
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # T1 = A[_i]

  lw $t0, 4($fp)                            # load _j
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 16($fp)                           # load B
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)                           # T2 = B[_j]

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 20($fp)                           # load M
  addu $t0, $t1, $t0                        # calculate the address
  lw $t1, 0($t0)                            # load M[_i]     
  lw $t0, 4($fp)                            # load _j
  sll $t0, $t0, 2                           # convert to bytes address
  addu $t0, $t1, $t0                        # calculate the address of M[_i][_j]

  mul.s $f0, $f2, $f0                       # T = T1 * T2
  s.s $f0, 0($t0)                           # M[_i][_j] = T

  lw $t0, 4($fp)
  addiu $t0, $t0, 1
  sw $t0, 4($fp)                            # _j++

vector_cross_j_check:

  lw $t0, 28($fp)                           # load j
  lw $t1, 4($fp)                            # load _j
  sltu $t0, $t1, $t0                        # if _j < j
  bne $t0, $zero, vector_cross_j_body       # continue
  # else
  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

vector_cross_i_check:               

  lw $t0, 24($fp)                           # load i
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, vector_cross_i_body       # continue
  # else
  move $sp, $fp
  lw $fp, 8($sp)
  addiu $sp, $sp, 32                        # free the stack
  jr $ra                                    # return

pow_int:
  # Raises an integer number to another integer number
  # using Binary Exponentiation Algorithm
  # res = x^y
  # $a0 = x
  # $a1 = y
  # Returns:
  # $v0 = res

  addiu $sp, $sp, -12
  sw $fp, 4($sp)
  move $fp, $sp
  sw $a0, 12($fp)                           # save x
  sw $a1, 8($fp)                            # save y

  li $t0, 1
  sw $t0, 0($fp)                            # int res = 1

  j pow_int_i_check

pow_int_i_body:

  lw $t0, 8($sp)                            # load y
  andi $t0, 1
  beq $t0, $zero, pow_int_i_forward         # if !(y & 1) continue
  # else
  lw $t0, 0($fp)                            # load res
  lw $t1, 12($fp)                           # load x
  mul $t0, $t0, $t1
  sw $t0, 0($fp)                            # res *= x

pow_int_i_forward:

  lw $t0, 12($fp)                           # load x
  mul $t0, $t0, $t0
  sw $t0, 12($fp)                           # x *= x
  lw $t0, 8($fp)                            # load y
  sra $t0, $t0, 1
  sw $t0, 8($fp)                            # y /= 2

pow_int_i_check:

  lw $t0, 8($fp)                            # load y
  bne $t0, $zero, pow_int_i_body            # if y != 0 continue
  # else
  move $sp, $fp
  lw $fp, 4($sp)
  lw $v0, 0($sp)                            # return res
  addiu $sp, $sp, 12                        # free the stack
  jr $ra                                    # return

sqrt:
  # Calculates the square root of a float
  # $a0: float number n
  # Returns:
  # $v0: square root of n

  addiu $sp, $sp, -8
  sw $fp, 0($sp)
  move $fp, $sp
  sw $a0, 4($sp)                            # save n

  lw $t0, 4($sp)                            # load n
  li $t1, 0xFF
  sll $t1, $t1, 23                          # bitmask to extract the exponent
  and $t2, $t0, $t1                         # $t2 = extracted exponent
  li $t3, 127
  sll $t3, $t3, 23
  subu $t2, $t2, $t3                        # unbias the exponent
  srl $t2, $t2, 1                           # exponent /= 2
  addu $t2, $t2, $t3                        # rebias the exponent
  and $t2, $t2, $t1                         # mask the unwanted bits
  lui $t1, 0x807F
  ori $t1, 0xFFFF
  and $t0, $t0, $t1                         # mask the old exponent
  addu $v0, $t0, $t2                        # add the new exponent

  move $sp, $fp
  lw $fp, 0($sp)
  addiu $sp, $sp, 8                         # free the stack
  jr  $ra                                   # return

fit:
  # Fits a Neural Network Transformer with the training data
  # All needed data must be in the .data:
  # W: address to the matrix of the weights (kxj matrix)
  # Wi: the initial value of the weights (float)
  # T: address to the vector of thresholds (k vector)
  # Ti: the initial value of the thresholds (float)
  # X: address to the matrix of the inputs (ixj matrix)
  # Y: address to the matrix of the desired outputs (ixk matrix)
  # i: number of instances (4-bytes integer)
  # _j: number of features (4-bytes integer)
  # k: number of classes (4-bytes integer)
  # EP: number of epochs (4-bytes integer)
  # LR: learning rate (float)
  # B: momentum (float)
  # activation: the address of the activation function
  # ONE: constant (1.0 as float)
  # debugging messages
  # Result:
  # W and T are trained properly to fit the data

  addiu $sp, $sp, -68
  sw $ra, 64($sp)                           # save $ra
  sw $fp, 60($sp)               
  move $fp, $sp

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 56($fp)                           # save Y

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 52($fp)                           # save E                  

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix               

  sw $v0, 48($fp)                           # save dC

  lw $t1, ONE
  sw $t1, 44($fp)                           # Bc = 1.0 for the first iteration

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  

  sw $v0, 40($fp)                           # save dW
  move $a0, $v0                             # pass dW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass _j
  move $a3, $zero                           # pass 0
  jal fill_matrix                           # dW = 0         

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 36($fp)                           # save dT
  move $a0, $v0                             # pass dT
  lw $a1, k                                 # pass k
  move $a2, $zero                           # pass 0
  jal fill_vector                           # dT = 0

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  

  sw $v0, 32($fp)                           # save sdW2
  move $a0, $v0                             # pass sdW2
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass _j
  move $a3, $zero                           # pass 0
  jal fill_matrix                           # sdW2 = 0    

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 28($fp)                           # save sdT2
  move $a0, $v0                             # pass sdT2
  lw $a1, k                                 # pass k
  move $a2, $zero                           # pass 0
  jal fill_vector                           # sdT2 = 0 

  sw $zero, 24($fp)                         # float n = 0

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  
  sw $v0, 20($fp)                           # save rmsW  

  lw $a0, k                                 # pass k
  jal allocate_vector               
  sw $v0, 16($fp)                           # save rmsT

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  

  sw $v0, 12($fp)                           # save lrW   

  lw $a0, k                                 # pass k
  jal allocate_vector               

  sw $v0, 8($fp)                            # save lrT

  sw $zero, 4($fp)                          # unsigned int e = 0

  addiu $sp, $sp, -8

  lw $a0, k                                 # load k
  lw $a1, _j                                # load j
  jal allocate_matrix  
  sw $v0, -4($fp)                           # save dW2  

  lw $a0, k                                 # pass k
  jal allocate_vector               
  sw $v0, -8($fp)                           # save dT2

  j fit_e_check               

fit_e_body:               

  sw $zero, 0($fp)                          # unsigned int _i = 0
  j fit_i_check               

fit_i_body: 

  lw $a0, 12($fp)                           # pass lrW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass _j
  lw $a3, LR                                # pass LR
  jal fill_matrix                           # lrW = LR 

  lw $a0, 8($fp)                            # pass lrT
  lw $a1, k                                 # pass k
  lw $a2, LR                                # pass LR
  jal fill_vector                           # lrT = LR

  l.s $f0, 24($fp)
  l.s $f2, ONE
  add.s $f0, $f0, $f2
  s.s $f0, 24($fp)                          # n++                             

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, X                                 # load the inputs matrix (X)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass X[_i]
  lw $a1, 56($fp)                           # pass Y
  jal transform                                           

  lw $a0, 52($fp)                           # pass E
  lw $a1, 56($fp)                           # pass Y
  lw $a2, k                                 # pass k
  jal assign_vector               

  lw $a0, 52($fp)                           # pass E (= Y) 
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, Yd                                # load the desired output matrix (Yd)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass Yd[_i]
  jal sub_vector                            # E = Y - Yd 

  lw $a0, 56($fp)                           # pass Y
  lw $a1, k                                 # pass k
  la $a2, PREDICTION                        # pass the message
  jal debug_vector 

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, Yd                                # load the desired output matrix (Yd)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a0, 0($t0)                            # pass Yd[_i]
  lw $a1, k                                 # pass k
  la $a2, DESIRED                           # pass the message
  jal debug_vector 

  lw $a0, 52($fp)                           # pass E
  lw $a1, k                                 # pass k
  la $a2, ERROR                             # pass the message
  jal debug_vector                              
               
  lw $a0, 52($fp)                           # pass E (k size)
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, X                                 # load the inputs matrix (X)
  addu $t0, $t1, $t0                        # calculate the address
  lw $a1, 0($t0)                            # pass X[_i] (j size)
  lw $a2, 48($fp)                           # pass dC (kxj size)
  lw $a3, k                                 # pass k
  lw $t0, _j               
  sw $t0, -4($sp)                           # pass j
  jal vector_cross                            

  lw $a0, 48($fp)                           # pass dC
  lw $a1, 44($fp)                           # pass (1 - B)
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal scale_matrix   

  lw $a0, 40($fp)                           # pass dW
  lw $a1, B                                 # pass B
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal scale_matrix                

  lw $a0, 40($fp)                           # pass dW
  lw $a1, 48($fp)                           # pass dC
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal add_matrix                

  lw $a0, -4($fp)                           # pass dW2
  lw $a1, 40($fp)                           # pass dW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal assign_matrix

  lw $a0, -4($fp)                           # pass dW2
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  jal square_matrix

  lw $a0, 32($fp)                           # pass sdW2
  lw $a1, -4($fp)                           # pass dW2
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal add_matrix

  lw $a0, 20($fp)                           # pass rmsW
  lw $a1, 32($fp)                           # pass sdW2
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal assign_matrix

  l.s $f0, 24($fp)                          # load n
  l.s $f2, ONE                              # load 1.0
  div.s $f0, $f2, $f0                       # $f0 = 1.0 / n

  lw $a0, 20($fp)                           # pass rmsW
  mfc1 $a1, $f0                             # pass 1.0 / n
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal scale_matrix

  lw $a0, 20($fp)                           # pass rmsW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  jal sqrt_matrix

  lw $a0, 12($fp)                           # pass lrW
  lw $a1, 20($fp)                           # pass rmsW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal div_matrix

  lw $a0, 40($fp)                           # pass dW
  lw $a1, 12($fp)                           # pass lrW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal mul_matrix                  

  lw $a0, W                                 # pass W
  lw $a1, 40($fp)                           # pass dW
  lw $a2, k                                 # pass k
  lw $a3, _j                                # pass j
  jal sub_matrix                

  lw $a0, W                                 # pass W
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  la $a3, WEIGHTS                           # pass the message
  jal debug_matrix  

  lw $a0, 12($fp)                           # pass lrW
  lw $a1, k                                 # pass k
  lw $a2, _j                                # pass j
  la $a3, WEIGHTS_LR                        # pass the message
  jal debug_matrix               

  lw $a0, 36($fp)                           # pass dT
  lw $a1, B                                 # pass B
  lw $a2, k                                 # pass k
  jal scale_vector

  lw $a0, 52($fp)                           # pass E
  lw $a1, 44($fp)                           # pass (1 - B)
  lw $a2, k                                 # pass k
  jal scale_vector                

  lw $a0, 36($fp)                           # pass dT
  lw $a1, 52($fp)                           # pass E
  lw $a2, k                                 # pass k
  jal sub_vector                

  lw $a0, -8($fp)                           # pass dT2
  lw $a1, 36($fp)                           # pass dT
  lw $a2, k                                 # pass k
  jal assign_vector

  lw $a0, -8($fp)                           # pass dT2
  lw $a1, k                                 # pass k
  jal square_vector

  lw $a0, 28($fp)                           # pass sdT2
  lw $a1, -8($fp)                           # pass dT2
  lw $a2, k                                 # pass k
  jal add_vector

  lw $a0, 16($fp)                           # pass rmsW
  lw $a1, 28($fp)                           # pass sdW2
  lw $a2, k                                 # pass k
  jal assign_vector

  l.s $f0, 24($fp)                          # load n
  l.s $f2, ONE                              # load 1.0
  div.s $f0, $f2, $f0                       # $f0 = 1.0 / n

  lw $a0, 16($fp)                           # pass rmsW
  mfc1 $a1, $f0                             # pass 1.0 / n
  lw $a2, k                                 # pass k
  jal scale_vector

  lw $a0, 16($fp)                           # pass rmsW
  lw $a1, k                                 # pass k
  jal sqrt_vector

  lw $a0, 8($fp)                            # pass lrW
  lw $a1, 16($fp)                           # pass rmsW
  lw $a2, k                                 # pass k
  jal div_vector         

  lw $a0, 36($fp)                           # pass dT
  lw $a1, 8($fp)                            # pass lrT
  lw $a2, k                                 # pass k
  jal mul_vector  

  lw $a0, T                                 # pass T
  lw $a1, 36($fp)                           # pass dT
  lw $a2, k                                 # pass k
  jal sub_vector                

  lw $a0, T                                 # pass T
  lw $a1, k                                 # pass k
  la $a2, THRESHOLDS                        # pass the message
  jal debug_vector

  lw $a0, 8($fp)                            # pass lrT
  lw $a1, k                                 # pass k
  la $a2, THRESHOLDS_LR                     # pass the message
  jal debug_vector           

  lw $t0, 0($fp)                
  addiu $t0, $t0, 1               
  sw $t0, 0($fp)                            # _i++

  l.s $f0, ONE
  l.s $f2, B
  sub.s $f0, $f0, $f2
  s.s $f0, 44($fp)                          # Bc = 1 - B              

fit_i_check:   

  lw $t1, i                                 # load i
  lw $t0, 0($fp)                            # load _i
  sltu $t0, $t0, $t1                        # if _i < i
  bne $t0, $zero, fit_i_body                # continue
  # else                
  lw $t0, 4($fp)               
  addiu $t0, $t0, 1               
  sw $t0, 4($fp)                            # e++

fit_e_check:  

  lw $t1, EP                                # load EP
  lw $t0, 4($fp)                            # load e
  sltu $t0, $t0, $t1                        # if e < EP
  bne $t0, $zero, fit_e_body                # continue
  # else                
  move $sp, $fp               
  lw $fp, 60($sp)               
  lw $ra, 64($sp)                           # pop the return address
  addiu $sp, $sp, 68                        # free the stack
  jr $ra                                    # return

hard_limiter:
  # Applies the hard limiting activation function to a vector
  # $a0 = destination vector (4-bytes address)
  # $a1 = size of the vector (4-bytes unsigned integer)
    
  addiu $sp, $sp, -16
  sw $fp, 4($sp)
  move $fp, $sp     
  sw $a0, 8($fp)                            # save vec
  sw $a1, 12($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int _i = 0
    
  j hard_limiter_i_check                  
    
hard_limiter_i_body:  
                
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, 8($fp)                            # load vec
  addu $t0, $t1, $t0                        # claculate the address
  l.s $f0, 0($t0)                           # load vec[_i]
  mtc1 $zero, $f2                           # load the 0
  c.le.s $f2, $f0                           # if 0 <= vec[_i]
  bc1f hard_limiter_else                    # else              
  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, 8($fp)                            # load vec
  addu $t0, $t1, $t0                        # caldulate the address
  l.s $f0, ONE                  
  s.s $f0, 0($t0)                           # dest[y] = 1.0
  j hard_limiter_i_increment                

hard_limiter_else:      

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes address
  lw $t1, 8($fp)                            # load vec[_i]
  addu $t0, $t1, $t0                        # calculate the address
  sw $zero, 0($t0)                          # vec[_i] = 0

hard_limiter_i_increment: 

  lw $t0, 0($fp) 
  addiu $t0, $t0, 1 
  sw $t0, 0($fp)                            # _i++

hard_limiter_i_check: 

  lw $t1, 0($fp)                            # load i
  lw $t0, 12($fp)                           # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, hard_limiter_i_body       # continue
  # else          
  move $sp, $fp         
  lw $fp, 4($sp)          
  addiu $sp, $sp, 16                        # free the stack
  jr $ra                                    # return

initialize_weights:
  # Initializes the weights matrix with features weights vector
  # $a0: address of the destination matrix (jxk size)
  # $a1: address of the soruce vector (j size)
  # $a2: k (4-bytes integer)
  # $a3: j (4-bytes integer)

  addiu $sp, $sp, -28
  sw $ra, 4($sp)                            # save $ra
  sw $fp, 8($sp)                            # save $fp
  move $fp, $sp
  sw $a0, 12($fp)                           # save dest
  sw $a1, 16($fp)                           # save src
  sw $a2, 20($fp)                           # save k
  sw $a3, 24($fp)                           # save j
  sw $zero, 0($fp)                          # unsigned int _i = 0
 
  j initialize_weights_i_check

initialize_weights_i_body:

  lw $t0, 0($fp)                            # load _i
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load dest
  addu $t0, $t1, $t0                        # calculate the address 
  lw $a0, 0($t0)                            # pass dest[_i]

  lw $a1, 16($fp)                           # pass src

  lw $a2, 24($fp)                           # pass j
  jal assign_vector

  lw $t0, 0($fp)
  addiu $t0, $t0, 1
  sw $t0, 0($fp)                            # _i++

initialize_weights_i_check:
  
  lw $t0, 20($fp)                           # load i 
  lw $t1, 0($fp)                            # load _i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, initialize_weights_i_body # continue
  # else
  move $sp, $fp
  lw $ra, 4($sp)                            # pop $ra
  lw $fp, 8($sp)                            # pop $fp
  addiu $sp, $sp, 28                        # free the stack
  jr $ra                                    # return

max_wsum:
  # Assigns 1 to the maximum weighted sum in the neurons
  # and 0 for the others
  # $a0 = destination vector (4-bytes address)
  # $a1 = size of the vector (4-bytes unsigned integer)

  addiu $sp, $sp, -24
  sw $ra, 12($sp)
  sw $fp, 8($sp)
  move $fp, $sp
  sw $a0, 16($fp)                           # save vec
  sw $a1, 20($fp)                           # save i
  sw $zero, 0($fp)                          # unsigned int max_w = 0
  sw $zero, 4($fp)                          # unsigned int _i = 0
  
  j max_wsum_i_check

max_wsum_i_body:

  lw $t0, 4($fp)                            # load _i
  sll $t0, $t0, 2                           # converts to bytes offset
  lw $t1, 16($fp)                           # load vec
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f2, 0($t0)                           # load vec[_i]

  lw $t0, 0($fp)                            # load max_w
  sll $t0, $t0, 2                           # converts to bytes offset
  lw $t1, 16($fp)                           # load vec
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, 0($t0)                           # load vec[max_w]
  c.lt.s $f0, $f2                           # if vec[max_w] < vec[_i]
  bc1f max_wsum_else                        # else
  
  lw $t0, 4($fp)                            # load _i
  sw $t0, 0($fp)                            # store it in max_w

max_wsum_else:

  lw $t0, 4($fp)
  addiu $t0, $t0, 1
  sw $t0, 4($fp)                            # _i++

max_wsum_i_check:

  lw $t1, 4($fp)                            # load _i
  lw $t0, 20($fp)                           # load i
  sltu $t0, $t1, $t0                        # if _i < i
  bne $t0, $zero, max_wsum_i_body           # continue
  # else
  lw $a0, 0($fp)                            # pass max_w as class number
  lw $a1, 16($fp)                           # pass vec
  lw $a2, 20($fp)                           # pass i
  jal one_hot_encoding

  move $sp, $fp
  lw $ra, 12($sp)
  lw $fp, 8($sp)
  addiu $sp, $sp, 24
  jr $ra

one_hot_encoding:
  # Fills a vector with the one hot encoding of the class
  # $a0 = class number (4-bytes unsigned integer)
  # $a1 = destination vector (4-bytes address)
  # $a2 = size of the vector (4-bytes unsigned integer)
    
  addiu $sp, $sp, -20
  sw $ra, 4($sp)                            # save $ra
  sw $fp, 0($sp)                            # save $fp
  move $fp, $sp                           
  sw $a0, 8($fp)                            # save y
  sw $a1, 12($fp)                           # save dest
  sw $a2, 16($fp)                           # save i
                    
  move $a2, $zero                           # pass 0
  lw $a1, 16($fp)                           # pass i
  lw $a0, 12($fp)                           # pass dest
  jal fill_vector                           # (dest, i, 0)
                    
  lw $t0, 8($fp)                            # load y
  sll $t0, $t0, 2                           # convert to bytes offset
  lw $t1, 12($fp)                           # load dest        
  addu $t0, $t1, $t0                        # calculate the address
  l.s $f0, ONE                    
  s.s $f0, 0($t0)                           # dest[y] = 1.0
                        
  move $sp, $fp                   
  lw $ra, 4($sp)                    
  lw $fp, 0($sp)                    
  addiu $sp, $sp, 20                    
  jr $ra                                    # return

transform:
  # Transforms an input to the output using the neural network
  # $a0 = X the input vector (j size)
  # $a1 = Y the output vector (k size)
  # .data section:
  # W: the weights matrix (kxj size)
  # T: the thresholds vector (k size)
  # k: 4-bytes unsigned integer
  # _j: 4-bytes unsigned integer
  # activation: the address of the used activation function

  addiu $sp, $sp, -20
  sw $ra, 4($sp)
  sw $fp, 0($sp)
  move $fp, $sp
  sw $a0, 8($fp)                            # save X
  sw $a1, 16($fp)                           # save Y
                                
  lw $a0, 8($fp)                            # pass X
  lw $a1, W                                 # pass W
  lw $a2, 16($fp)                           # pass Y
  lw $a3, k                                 # pass k
  lw $t0, _j               
  sw $t0, -4($sp)                           # pass j
  jal linear_transform                      # Y = W * X (linear transformation)
                  
  lw $a0, 16($fp)                           # pass Y
  lw $a1, T                                 # pass T
  lw $a2, k                                 # pass k
  jal sub_vector                            # Y -= T
                  
  lw $a0, 16($fp)                           # pass Y
  lw $a1, k                                 # pass k
  lw $t0, activation               
  jalr $t0                                  # activation(Y)

  move $sp, $fp
  lw $ra, 4($sp)
  lw $fp, 0($sp)
  addiu $sp, $sp, 20
  jr $ra

