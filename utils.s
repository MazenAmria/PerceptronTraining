.globl memset

memset:
  # set all words in certain memory segment
  # to a specific value.
  # Parameters:
  # $a0 = address of the first word (begin)
  # $a1 = address of the word after the last word (end)
  # $a2 = step size in words (1 for contiguous segment)
  # $a3 = desired value

  # Addresses should be divisible by 4
  andi $a0, $a0, -4
  andi $a1, $a1, -4

  # calculate step size in bytes
  li $t0, 4
  multu $a2, $t0
  mflo $a2

  set:
    # break if all entries have been set
    bgeu $a0, $a1, stop

    # set the entry otherwise
    sw $a3, 0($a0)

    # forward the pointer
    addu $a0, $a0, $a2

    # continue
    j set
  end_set:

  jr $ra

.globl copy

copy:
  # Copies all words from source memory segment to destination
  # Parameters:
  # 0($sp) = destnation begin address
  # 4($sp) = destnation end address
  # 8($sp) = destnation step (in words)
  # 12($sp) = source begin address
  # 16($sp) = source end address
  # 20($sp) = source step (in words)

  # pop the parameters
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $t2, 8($sp)
  lw $t3, 12($sp)
  lw $t4, 16($sp)
  lw $t5, 20($sp)

  addiu $sp, $sp, 24

  # start copying
  copying:
    # check if no more words to copy
    beq $t0, $t1, end_copying
    beq $t3, $t4, end_copying

    # copy the word
    lw $t6, 0($t3)
    sw $t6, 0($t0)

    # forward the pointers
    addu $t0, $t0, $t2
    addu $t3, $t3, $t5

    # continue
    j copying
  end_copying:

  jr $ra

.globl exit

exit:
  # utility function to exit 
  # with certain exit code
  # Parameters:
  # $v1 = exit code

  li $v0, 10
  syscall
