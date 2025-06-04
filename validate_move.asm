# validate_move.asm

.text   # Start of text (code) section
.globl validate_move   # Declare validate_move as a global label

# Input: 	$a0 = board address
#			$a1 = markings address
#			$a2 = number to validate (product)			
# Output: 	$v0 = 1 if valid, 0 if invalid

validate_move:
    li $t0, 0         	# Initialize index counter to 0
    li $t1, 36			# Total number of entries on the board

	# Look for the number in the board
vm_loop:
    lw $t2, 0($a0)     	# Load current board number into $t2
    beq $t2, $a2, vm_found   # If found matching number, branch to vm_found
    addi $a0, $a0, 4         # Move board pointer to next number (word size 4 bytes)
    addi $t0, $t0, 1         # Increment index counter
    blt $t0, $t1, vm_loop    # If not end of board, continue loop
    
    li $v0, 0          	# Set return value to 0 (invalid - number not found)
	jr $ra                # Return from function

	# When found, check the markings
vm_found:
	add $t3, $a1, $t0      # Calculate marking address for the found index
    lb $t1, 0($t3)         # Load marking (X, O, or 0)
    
    # If not 0 (then it must be X or O), it is invalid
    beqz $t1, vm_valid     # If marking is 0 (unoccupied), branch to vm_valid
    li $v0, 0              # Else set return value to 0 (occupied, invalid)
	jr $ra                 # Return from function

vm_valid:
    li $v0, 1              # Set return value to 1 (valid move)
    jr $ra                 # Return from function
