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

  iterate:
    # break if all entries have been set
    bgeu $a0, $a1, stop
    # set the entry otherwise
    sw $a3, 0($a0)
    # forward the pointer
    addu $a0, $a0, $a2
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
