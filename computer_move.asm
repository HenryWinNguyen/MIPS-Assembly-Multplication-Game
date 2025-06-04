# computer_move.asm
.include "SysCalls.asm"   # Include system call definitions

.text   # Begin text (code) section
.globl computer_move   # Declare computer_move as global

# Input: 	$a0 = number on upper slider
#			$a1 = number on lower slider
#			$a2 = board address
#			$a3 = markings address
# Output: 	$v0 = resulting number on upper slider
#			$v1 = resulting number on lower slider

computer_move:
	# Store return address and other data on stack
	addi $sp, $sp, -36   # Allocate 36 bytes stack space
	sw $ra, 0($sp)       # Save return address
	sw $s0, 4($sp)       # Save register s0
	sw $s1, 8($sp)       # Save register s1
	sw $s2, 12($sp)      # Save register s2
	sw $s3, 16($sp)      # Save register s3
	sw $s4, 20($sp)      # Save register s4
	sw $s5, 24($sp)      # Save register s5
	sw $s6, 28($sp)      # Save register s6
	sw $s7, 32($sp)      # Save register s7
	
	# Copy the input arguments to preserve them
	# through function calls
	move $s0, $a0        # Move upper slider number to s0
	move $s1, $a1        # Move lower slider number to s1
	move $s2, $a2        # Move board address to s2
	move $s3, $a3        # Move markings address to s3

	# Print the info
    li $v0, SysPrintString   # Load SysPrintString syscall code
    la $a0, text_computer    # Load address of text_computer
    syscall                  # Print "Computer's Turn..."

    # Check every possible move with upper slider
    # Lower slider staying fixed
    la $s4, comp_moves       # Load address of comp_moves array
    li $s5, 1	            # Initialize number on upper slider to 1
    li $s7, 0                # Initialize counter for valid moves
    
cm_upper_loop:
	mul $s6, $s5, $s1         # Calculate product of upper number × lower slider
	
	# Validate the move
	move $a0, $s2             # Load board address
	move $a1, $s3             # Load markings address
	move $a2, $s6             # Load calculated product
	jal validate_move         # Call validate_move
	beqz $v0, cm_upper_invalid # If invalid move, jump
	
	# If valid, mark it and check if it leads to victory
	move $a0, $s2             # Load board address
    move $a1, $s3             # Load markings address
    move $a2, $s6             # Load calculated product
    li $a3, 'O'               # Indicate computer move
    jal mark_move             # Call mark_move to temporarily mark move
    
    move $a0, $s5             # Move upper slider number
    move $a1, $s1             # Move lower slider number
    move $a2, $s2             # Board address
    move $a3, $s3             # Markings address
    jal check_win             # Check if this move wins the game
    
    # If no win, jump to unmark it
    bne $v0, 2, cm_upper_unmark # If not a computer win, unmark

    # If win, set the return values and jump to finish
    move $v0, $s5             # Return upper slider number
    move $v1, $s1             # Return lower slider number
    j cm_done                 # Jump to completion
    
cm_upper_unmark:
	# Unmark the move
	move $a0, $s2             # Load board address
    move $a1, $s3             # Load markings address
    move $a2, $s6             # Load product
    li $a3, 0                 # Set marking to 0 (clear mark)
    jal mark_move             # Call mark_move to unmark
    
    # Store it to the list of the moves, and continue
    sw $s6, 0($s4)            # Save product to moves list
    addi $s7, $s7, 1          # Increment valid move counter
    j cm_upper_cont           # Continue upper loop
	
	# If invalid, store 0 to the array of moves
cm_upper_invalid:
	sw $0, 0($s4)             # Store 0 (invalid move) in moves array
	
cm_upper_cont:
	addi $s4, $s4, 4          # Advance to next move slot
	addi $s5, $s5, 1          # Increment number on upper slider
	li $t0, 9                 # Compare with 9 (max number)
	ble $s5, $t0, cm_upper_loop # Continue loop if number <= 9
	
    # Check every possible move with lower slider
    # Lower slider staying fixed
    li $s5, 1	            # Reset number on lower slider to 1
    
cm_lower_loop:
	mul $s6, $s0, $s5         # Multiply lower slider by number
	
	# Validate the move
	move $a0, $s2             # Load board address
	move $a1, $s3             # Load markings address
	move $a2, $s6             # Load product
	jal validate_move         # Validate the move
	beqz $v0, cm_lower_invalid # If invalid, branch
	
	# If valid, mark it and check if it leads to victory
	move $a0, $s2             # Board address
    move $a1, $s3             # Markings address
    move $a2, $s6             # Product
    li $a3, 'O'               # Computer move marker
    jal mark_move             # Mark move temporarily
    
    move $a0, $s0             # Upper slider
    move $a1, $s5             # Lower number
    move $a2, $s2             # Board address
    move $a3, $s3             # Markings address
    jal check_win             # Check if this move wins
    
    # If no win, jump to unmark it
    bne $v0, 2, cm_lower_unmark # If not a win, unmark

    # If win, set the return values and jump to finish
    move $v0, $s0             # Return upper slider
    move $v1, $s5             # Return lower number
    j cm_done                 # Finish
    
cm_lower_unmark:
	# Unmark the move
	move $a0, $s2             # Board address
    move $a1, $s3             # Markings address
    move $a2, $s6             # Product
    li $a3, 0                 # Clear mark
    jal mark_move             # Unmark move
    
    # Store it to the list of the moves, and continue
    sw $s6, 0($s4)            # Save move
    addi $s7, $s7, 1          # Increment valid move counter
    j cm_lower_cont           # Continue lower loop
	
	# If invalid, store 0 to the array of moves
cm_lower_invalid:
	sw $0, 0($s4)             # Store 0 for invalid move
	
cm_lower_cont:
	addi $s4, $s4, 4          # Advance to next slot
	addi $s5, $s5, 1          # Increment number
	li $t0, 9                 # Max number 9
	ble $s5, $t0, cm_lower_loop # Continue if <=9

	# If reached here, no move leads to victory
	# so choose a random valid move from the list
	
	# Choose a random number in the range [0, number of valid moves-1]
    li $a0, 0                 # Lower bound 0
    move $a1, $s7             # Upper bound (number of valid moves)
    li $v0, SysRandIntRange   # Load random syscall
    syscall                   # Generate random number
    
    move $s7, $a0             # Save random index
    
    la $t0, comp_moves        # Reload moves array
    li $t1, 0                 # Counter of moves
    li $t2, 0                 # Row counter
    
cm_rows_loop:
    li $t3, 1                 # Start number at 1
    
cm_cols_loop:
	lw $t4, 0($t0)             # Load move value
	
	# If invalid value, skip it
	beqz $t4, cm_skip          # If zero, skip
	
	# Else, check if it matches the random index
	beq $t1, $s7, cm_found     # If match, found move
	addi $t1, $t1, 1           # Increment move index
	
cm_skip:
	addi $t0, $t0, 4           # Move to next slot
	addi $t3, $t3, 1           # Increment column counter
	li $t5, 9                  # Limit at 9
	ble $t3, $t5, cm_cols_loop # Loop over columns
	
	addi $t2, $t2, 1           # Increment row
	li $t5, 1                  # Max row 1
	ble $t2, $t5, cm_rows_loop # Loop rows
	
	# When found, mark the move
cm_found:
	# First store the slider and number values
	# to preserve them across the function call
	move $s4, $t2              # Store row
	move $s5, $t3              # Store column

	move $a0, $s2              # Board address
    move $a1, $s3              # Markings address
    move $a2, $t4              # Selected move
    li $a3, 'O'                # Mark with 'O'
    jal mark_move              # Mark move
	
	# Check which slider was chosen
	beqz $s4, cm_store_upper   # If row=0, upper slider
	
	# If lower slider was chosen, copy the chosen number
	move $v1, $s5              # Lower slider number
	move $v0, $s0              # Upper slider value
	j cm_done                  # Done
	
	# If upper slider was chosen, copy the chosen number
cm_store_upper:
	move $v0, $s5              # Upper slider number
	move $v1, $s1              # Lower slider value

cm_done:
    # Restore return address and other data from stack
    lw $ra, 0($sp)             # Restore return address
    lw $s0, 4($sp)             # Restore s0
    lw $s1, 8($sp)             # Restore s1
    lw $s2, 12($sp)            # Restore s2
    lw $s3, 16($sp)            # Restore s3
    lw $s4, 20($sp)            # Restore s4
    lw $s5, 24($sp)            # Restore s5
    lw $s6, 28($sp)            # Restore s6    
    lw $s7, 32($sp)            # Restore s7  
    addi $sp, $sp, 36          # Restore stack pointer

    jr $ra                     # Return from function

.data   # Start data section
comp_moves: .space 72	        # 2×9 grid for the possible moves
text_computer: .asciiz "Computer's Turn...\n"   # String for "Computer's Turn..."
