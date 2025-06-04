# mark_move.asm

.text   # Start of text (code) section
.globl mark_move   # Declare mark_move as a global label

# Input: 	$a0 = board address
#			$a1 = markings address
#			$a2 = product of chosen numbers
#			$a3 = character to mark with
# Output: 	none

mark_move:
    li $t0, 0         	# Initialize index counter to 0
    li $t1, 36			# Set total number of board entries to 36

	# Look for the number in the board
mm_loop:
    lw $t2, 0($a0)     	# Load current board number into $t2
    beq $t2, $a2, mm_do_mark   # If current number matches product, branch to marking
    addi $a0, $a0, 4        	# Move to next board entry (4 bytes forward)
    addi $t0, $t0, 1        	# Increment index counter
    blt $t0, $t1, mm_loop    	# If not reached end of board, continue loop
    
    jr $ra  # Should never happen   # Return if number not found (error case)

	# When found, mark it with the character in $a3
mm_do_mark:
	add $t3, $a1, $t0            # Calculate marking array address
    sb $a3, 0($t3)               # Store marking character ('X' or 'O') at marking location

	jr $ra                       # Return from mark_move
