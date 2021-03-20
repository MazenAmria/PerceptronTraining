.globl memset

memset:
  # set all words in certain memory segment
  # to a specific value.
  # Parameters:
  # $a0 = address of the first word (begin)
  # $a1 = address of the word after the last word (end)
  # $a2 = desired value

  # Addresses should be divisible by 4
  andi $a0, $a0, -4
  andi $a1, $a1, 4

  iterate:
    # break if all entries have been set
    beq $a0, $a1, stop
    # set the entry otherwise
    sw $a2, 0($a0)
    # forward the pointer
    addiu $a0, $a0, 4
    j iterate
  stop:

  jr $ra

.globl exit

exit:
  # utility function to exit 
  # with certain exit code
  # Parameters:
  # $v1 = exit code

  li $v0, 10
  syscall