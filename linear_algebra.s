.globl allocate_matrix

allocate_matrix:
  # allocates a matrix in the memory
  # Parameters:
  # $a0 = 1st dimension (number of rows)
  # $a1 = 2nd dimension (number of cols)
  # Return values:
  # $v0 = address of the allocated matrix
  
  # matrix representaion in memory:
  # 1st word: 1st dimension
  # 2nd word: 2nd dimension
  # entries in row-wise (i.e. contiguous rows)

  # calculate the total number of entries 
  multu $a0, $a1
  mflo $t0

  # calculate the total number of bytes
  sll $t0, $t0, 2

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

.globl allocate_matrix

allocate_vector:
  # allocates a vector in the memory
  # Parameters:
  # $a0 = size of the vector
  # Return values:
  # $v0 = address of the allocated vector
  
  # vector representaion in memory:
  # 1st word: size of the vector
  # entries

  # calculate the total number of bytes
  sll $t0, $a0, 2

  # save the value of $a0
  move $t1, $a0

  # add headers (1 word) and pass the size
  # in bytes to sbrk system call
  addiu $a0, $t0, 4

  # allocate the vector
  li $v0, 9
  syscall

  # store the headers
  sw $t1, 0($v0)

  jr $ra

.globl copy_matrix

copy_matrix:
  # copies a matrix from source to destination
  # Parameters:
  # $a0 = destination matrix address
  # $a1 = source matrix address

  # check if the size matches
  lw $t0, 0($a0)
  lw $t1, 4($a0)
  
  # total words in destination
  multu $t0, $t1
  mflo $t0
  
  lw $t1, 0($a1)
  lw $t2, 4($a1)
  
  # total words in source
  multu $t1, $t2
  mflo $t1

  beq $t0, $t1, copying_matrix

  # unmatched size (exit)
  li $v1, -1
  jal exit

  copying_matrix:

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # pass arguments
  addiu $sp, $sp, -24       # 6 arguments
  
  addiu $a0, $a0, 8
  sw $a0, 0($sp)            # dest.begin

  sll $t0, $t0, 2
  addu $a0, $a0, $t0
  sw $a0, 4($sp)            # dest.end

  li $a0, 1
  sw $a0, 8($sp)            # dest.step

  addiu $a1, $a1, 8
  sw $a1, 12($sp)           # src.begin

  addu $a1, $a1, $t0
  sw $a1, 16($sp)           # src.end

  li $a1, 1
  sw $a1, 20($sp)           # src.step

  # copy
  jal copy

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl copy_row

copy_row:
  # copies a vector to a row in matrix
  # Parameters:
  # $a0 = destination matrix address
  # $a1 = row number (zero indexed)
  # $a2 = source vector address

  # check if the size matches
  lw $t0, 4($a0)
  lw $t1, 0($a2)

  beq $t0, $t1, copying_row

  # unmatched size (exit)
  li $v1, -1
  jal exit

  copying_row:

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # pass arguments
  addiu $sp, $sp, -24       # 6 arguments
  
  multu $t0, $a1
  mflo $a1
  sll $a1, $a1, 2
  
  addiu $a0, $a0, 8
  addu $a0, $a0, $a1
  sw $a0, 0($sp)            # dest.begin

  sll $t0, $t0, 2
  addu $a0, $a0, $t0
  sw $a0, 4($sp)            # dest.end

  li $a0, 1
  sw $a0, 8($sp)            # dest.step

  addiu $a2, $a2, 4
  sw $a2, 12($sp)           # src.begin

  addu $a2, $a2, $t0
  sw $a2, 16($sp)           # src.end

  li $a2, 1
  sw $a2, 20($sp)           # src.step

  # copy
  jal copy

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl copy_col

copy_col:
  # copies a vector to a column in matrix
  # Parameters:
  # $a0 = destination matrix address
  # $a1 = col number (zero indexed)
  # $a2 = source vector address

  # check if the size matches
  lw $t0, 0($a0)
  lw $t1, 0($a2)

  beq $t0, $t1, copying_col

  # unmatched size (exit)
  li $v1, -1
  jal exit

  copying_col:

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # pass arguments
  addiu $sp, $sp, -24       # 6 arguments
  
  sll $a1, $a1, 2
  
  addiu $a0, $a0, 8
  addu $a0, $a0, $a1
  sw $a0, 0($sp)            # dest.begin

  lw $t1, 4($a0)
  multu $t0, $t1
  mflo $t2
  sll $t2, $t2, 2

  addu $a0, $a0, $t2
  sw $a0, 4($sp)            # dest.end

  sw $t1, 8($sp)            # dest.step

  addiu $a2, $a2, 4
  sw $a2, 12($sp)           # src.begin

  addu $a2, $a2, $t0
  sw $a2, 16($sp)           # src.end

  li $a2, 1
  sw $a2, 20($sp)           # src.step

  # copy
  jal copy

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl fill_matrix

fill_matrix:
  # fills a matrix with specific value
  # Parameters:
  # $a0 = address of the matrix
  # $a1 = desired value

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  move $a3, $a1             # value

  lw $t0, 0($a0)
  lw $t1, 4($a0)

  addiu $a0, $a0, 8         # dest.begin

  multu $t0, $t1
  mflo $t2
  sll $t2, $t2, 2

  addu $a1, $a0, $t2        # dest.end

  move $a2, 1               # dest.step

  # memset
  jal memset

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl fill_row

fill_row:
  # fills a row in matrix with specific value
  # Parameters:
  # $a0 = address of the matrix
  # $a1 = row number (zero indexing)
  # $a2 = desired value

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  move $a3, $a2             # value

  lw $t0, 0($a0)
  lw $t1, 4($a0)

  multu $a1, $t1
  mflo $t2
  sll $t2, $t2, 2

  addiu $a0, $a0, 8
  addu $a0, $a0, $t2        # dest.begin

  addu $a1, $a0, $t1        # dest.end

  move $a2, 1               # dest.step

  # memset
  jal memset

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl fill_col

fill_col:
  # fills a column in matrix with specific value
  # Parameters:
  # $a0 = address of the matrix
  # $a1 = col number (zero indexing)
  # $a2 = desired value

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  move $a3, $a2             # value

  lw $t0, 0($a0)
  lw $t1, 4($a0)

  addiu $a0, $a0, 8
  sll $a1, $a1, 2
  addu $a0, $a0, $a1        # dest.begin

  multu $t0, $t1
  mflo $t2
  sll $t2, $t2, 2
  addu $a1, $a0, $t2        # dest.end

  move $a2, $t1             # dest.step

  # memset
  jal memset

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl extract_row

extract_row:
  # Extracts a row from source matrix to a destination vector
  # Parameters:
  # $a0 = destination vector address
  # $a1 = source matrix address
  # $a2 = row number (zero indexed)

  # check if the size matches
  lw $t0, 0($a0)
  lw $t1, 4($a1)

  beq $t0, $t1, extracting_row

  # unmatched size (exit)
  li $v1, -1
  jal exit

  extracting_row:

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # pass arguments
  addiu $sp, $sp, -24       # 6 arguments
  
  addiu $a0, $a0, 4
  sw $a0, 0($sp)            # dest.begin

  addu $a0, $a0, $t0
  sw $a0, 4($sp)            # dest.end

  li $a0, 1
  sw $a0, 8($sp)            # dest.step

  multu $t1, $a2
  mflo $a2
  sll $a2, $a2, 2
  
  addiu $a1, $a1, 8
  addu $a1, $a1, $a2
  sw $a1, 0($sp)            # src.begin

  sll $t1, $t1, 2
  addu $a1, $a1, $t1
  sw $a1, 4($sp)            # src.end

  li $a1, 1
  sw $a1, 8($sp)            # src.step

  # copy
  jal copy

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

.globl extract_col

extract_col:
  # Extracts a column from source matrix to a destination vector
  # Parameters:
  # $a0 = destination vector address
  # $a1 = source matrix address
  # $a2 = col number (zero indexed)

  # check if the size matches
  lw $t0, 0($a0)
  lw $t1, 0($a1)

  beq $t0, $t1, extracting_col

  # unmatched size (exit)
  li $v1, -1
  jal exit

  extracting_col:

  # push $ra
  addiu $sp, $sp, -4
  sw $ra, 0($sp)

  # pass arguments
  addiu $sp, $sp, -24       # 6 arguments
  
  addiu $a0, $a0, 4
  sw $a0, 0($sp)            # dest.begin

  addu $a0, $a0, $t0
  sw $a0, 4($sp)            # dest.end

  li $a0, 1
  sw $a0, 8($sp)            # dest.step
  
  addiu $a1, $a1, 8
  sll $a2, $a2, 2
  addu $a1, $a1, $a2
  sw $a1, 12($sp)           # src.begin

  lw $t2, 4($a0)
  multu $t1, $t2
  mflo $t3
  sll $t3, $t3, 2
  addu $a1, $a1, $t3
  sw $a1, 16($sp)           # src.end

  sw $t2, 20($sp)           # src.step

  # copy
  jal copy

  # pop $ra
  lw $ra, 0($sp)
  addiu $sp, $sp, 4

  jr $ra

# add_vector
# add_matrix
# sub_vector
# sub_matrix
# scale_vector
# scale_matrix
# transpose
# vector_dot
# vector_transform
# matrix_dot

.globl matrix_mult

matrix_mult:
  # multiply two matrices (or vectors)
  # Parameters:
  # $a0 = the address of the left matrix (vector)
  # $a1 = the address of the right matrix (vector)
  # $a2 = the address of the result matrix (vector)

  # check matrices dimensions:
  # left 1st = result 1st
  lw $t0, 0($a0)
  lw $t3, 0($a2)
  bne $t0, $t3, value_error
  # left 2nd = right 1st
  lw $t1, 4($a0)
  lw $t4, 0($a1)
  bne $t1, $t4, value_error
  # right 2nd = result 2nd
  lw $t2, 4($a1)
  lw $t5, 4($a2)
  beq $t2, $t5, evaluate

  value_error:
  li $v1, -1 # should be replaced with constant
  jal exit

  evaluate:
  # define pointers to the matrices
  addiu $t3, $a0, 8 # left matrix' pointer
  addiu $t4, $a1, 8 # right matrix' pointer
  addiu $t5, $a2, 8 # result matrix' pointer

  # define step size for the right matrix
  li $t6, 4
  multu $t2, $t6
  mflo $t6

  # define step size for the left matrix
  li $t9, 4
  multu $t1, $t9
  mflo $t9

  left_rows:
    # check if no more rows to iterate
    beq $t0, $zero, end_rows
    
    # save the columns counter to use it in the next iteration
    addiu $sp, $sp, -4
    sw $t2, 0($sp)

    # return to the first column
    move $t8, $t4

    right_cols:
      # check if no more columns to iterate
      beq $t2, $zero, end_cols

      # return to the beginning of the row
      move $t7, $t3

      # save the entries counter to use it in the next iteration
      addiu $sp, $sp, -8
      sw $t1, 4($sp)
      # save the beginning of the column
      sw $t8, 0($sp)

      # initialize the result by zero
      mtc1 $zero, $f2

      entries:
        # check if no more entries to iterate
        beq $t1, $zero, end_entries

        # multiply the entries and add to the result
        l.s $f0, 0($t7)
        l.s $f1, 0($t8)

        mul.s $f3, $f0, $f1
        add.s $f2, $f2, $f3
        
        # move to the next entries
        addiu $t7, $t7, 4
        addu $t8, $t8, $t6

        # decrement the entries counter 
        addiu $t1, $t1, -1

        # loop
        j entries
      end_entries:

      # save the result
      s.s $f2, 0($t5)
      
      # move to the next entry in the result
      addiu $t5, $t5, 4

      # retrieve the entries counter
      lw $t1, 4($sp)
      # retrieve the beginning of the column
      lw $t8, 0($sp)
      addiu $sp, $sp, 8

      # move to the next column
      addiu $t8, $t8, 4

      # decrement the columns counter 
      addiu $t2, $t2, -1

      # loop
      j right_cols
    end_cols:

    # move to the next row
    addu $t3, $t3, $t9
    
    # retrieve the columns counter
    lw $t2, 0($sp)
    addiu $sp, $sp, 4

    # decrement the rows counter
    addiu $t0, $t0, -1

    # loop
    j left_rows
  end_rows:

  jr $ra

.globl print_matrix

print_matrix:
  # Prints a matrix (or vector) on screen
  # Parameters:
  # $a0 = the address of the matrix (vector)

  lw $t0, 0($a0)
  lw $t1, 4($a0)

  addiu $t3, $a0, 8

  print_row:
    # check if no more rows to print
    beq $t0, $zero, end_rows
    
    # get the count of entries in each row
    move $t2, $t1
    
    print_col:
      # check if no more entries to print
      beq $t2, $zero, p_end_col

      # print the entry
      l.s $f12, 0($t3)
      li $v0, 2
      syscall

      # print \t
      li $a0, 9
      li $v0, 11
      syscall

      # move to next entry
      addiu $t3, $t3, 4

      # decrement the count of entries
      addiu $t2, $t2, -1

      # loop
      j print_col
    p_end_col:

    # print new line
    li $a0, 10
    li $v0, 11
    syscall

    # decrement the count of rows
    addiu $t0, $t0, -1

    # loop
    j print_row
  p_end_rows: