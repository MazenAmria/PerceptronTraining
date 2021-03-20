.globl allocate_matrix

allocate_matrix:
  # allocates a matrix in the memory
  # Parameters:
  # $a0 = 1st dimension (number of rows)
  # $a1 = 2nd dimension (number of cols)
  
  # matrix representaion in memory:
  # 1st word: 1st dimension
  # 2nd word: 2nd dimension
  # entries in row-wise (i.e. contiguous rows)

  # calculate the total number of entries 
  multu $a0, $a1
  mflo $t0

  # calculate the total number of bytes
  addiu $t1, $t1, 4
  multu $t0, $t1
  mflo $t0

  # save the value of $a0
  move $t1, $a0

  # add headers (2 words) and pass the size
  # in bytes to sbrk system call
  addiu $a0, $t0, 8

  # allocate the matrix
  li $v0, 9
  syscall

  # store the headers
  sw $t1, 0($v0)
  sw $a1, 4($v0)

  jr $ra

.globl allocate_vector

allocate_vector:
  # allocates a vector in the memory
  # Parameters:
  # $a0 = size of the vector
  
  # vector representaion in memory:
  # a single column matrix

  # set the 2nd dim = 1
  addiu $a1, $zero, 1

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # allocate a matrix
  jal allocate_matrix

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl fill

fill:
  # fill a matrix (or vector) 
  # with specific value
  # Parameters:
  # $a0 = address of the matrix
  # $a1 = desired value

  move $a3, $a1
  li $a2, 1

  # save the pointer to the matrix
  move $t0, $a0

  # calculate the begin address
  addiu $a0, $a0, 8

  # calculate the size of the matrix (in bytes)
  lw $t1, 0($t0)
  lw $t2, 4($t0)

  multu $t1, $t2
  mflo $t1
  
  li $t2, 4

  multu $t1, $t2
  mflo $t1

  # calculate the end address
  addu $a1, $a0, $t1 

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # memset
  jal memset

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl fill_row

fill_row:
  # fill a row in matrix with specific value
  # Parameters:
  # $a0 = address of the matrix
  # $a1 = row number (zero indexing)
  # $a2 = desired value

  move $a3, $a2
  li $a2, 1 # row is contiguous

  # save the pointer to the matrix
  move $t0, $a0

  # calculate the begin address
  addiu $a0, $a0, 8

  lw $t1, 4($t0) # number of columns
  multu $t1, $a1 # number of entries before the desired row
  mflo $t1

  li $t2, 4
  multu $t1, $t2 # number of bytes before desired row
  mflo $t1 

  addu $a0, $a0, $t1 # begin address

  # calculate the end address
  lw $t1, 4($t0) # number of columns
  multu $t1, $t2 # number of bytes in a single row
  mflo $t1
  
  addu $a1, $a0, $t1 # end address

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # memset
  jal memset

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl fill_col

fill_col:
  # fill a column in matrix with specific value
  # Parameters:
  # $a0 = address of the matrix
  # $a1 = col number (zero indexing)
  # $a2 = desired value

  move $a3, $a2

  # save the pointer to the matrix
  move $t0, $a0

  # calculate the begin address
  addiu $a0, $a0, 8
  
  move $t1, $a1
  li $t2, 4
  multu $t1, $t2
  mflo $t1

  addu $a0, $a0, $t1 # begin address

  lw $a2, 4($t0) # number of columns (step size)

  # calculate the end address
  lw $t1, 4($t0) # number of columns
  lw $t2, 0($t0) # number of rows
  multu $t1, $t2 # addressing range in single column
  mflo $t1

  li $t2, 4
  multu $t1, $t2 # number of bytes before end
  mflo $t1

  addu $a1, $a0, $t1 # end address

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # memset
  jal memset

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl matrix_mult

matrix_mult:
  # multiply two matrices (or vectors)
  # Parameters:
  # $a0 = the address of the left matrix (vector)
  # $a1 = the address of the right matrix (vector)
  # $a2 = the address of the result matrix (vector)

  # TODO: implement :)
