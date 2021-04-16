  .globl read_csv
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

