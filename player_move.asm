# player_move.asm
.include "SysCalls.asm"   # Include system call definitions

.text   # Start of text (code) section
.globl player_move   # Declare player_move as global

# Input: 	$a0 = number on upper slider
#			$a1 = number on lower slider
#			$a2 = board address
#			$a3 = markings address
# Output: 	$v0 = resulting number on upper slider
#			$v1 = resulting number on lower slider

player_move:
	# Store return address and other data on stack
	addi $sp, $sp, -32   # Allocate 32 bytes stack space
	sw $ra, 0($sp)       # Save return address
	sw $s0, 4($sp)       # Save s0
	sw $s1, 8($sp)       # Save s1
	sw $s2, 12($sp)      # Save s2
	sw $s3, 16($sp)      # Save s3
	sw $s4, 20($sp)      # Save s4
	sw $s5, 24($sp)      # Save s5
	sw $s6, 28($sp)      # Save s6
	
	# Copy the input arguments to preserve them
	# through function calls
	move $s0, $a0        # Move upper slider number to s0
	move $s1, $a1        # Move lower slider number to s1
	move $s2, $a2        # Move board address to s2
	move $s3, $a3        # Move markings address to s3

	# Print the info
    li $v0, SysPrintString   # Set syscall code for print string
    la $a0, text_player      # Load "Player's Turn" text
    syscall                  # Print "Player's Turn"
    
	# Print the slider with numbers
	move $a0, $s0             # Move upper slider to a0
	move $a1, $s1             # Move lower slider to a1
	jal draw_slider           # Call draw_slider
	
	# If the number on upper slider is 0, this is the first move
	# Set slider choice to 0 (upper), and skip to choosing the number
	li $s4, 0                 # Assume upper slider
	beqz $s0, pm_choose_number # If upper slider is 0, skip to number choice
	
	# Else, first choose the slider
pm_choose_slider:
	li $v0, SysPrintString    # Prepare print string syscall
    la $a0, text_choosesld    # Load "Choose a slider" text
    syscall                   # Print prompt
    
    li $v0, SysReadInt        # Prepare read integer syscall
    syscall                   # Read slider choice from user
    
    # Check range
    blt $v0, $0, pm_choose_slider  # If less than 0, re-prompt
    li $t0, 1                     # Set t0 to 1
    bgt $v0, $t0, pm_choose_slider # If greater than 1, re-prompt
    
    move $s4, $v0	             # Save chosen slider into s4

pm_choose_number:
    li $v0, SysPrintString        # Prepare print string syscall
    la $a0, text_choosenum         # Load "Choose a number" text
    syscall                        # Print prompt

    li $v0, SysReadInt             # Prepare read integer syscall
    syscall                        # Read number from user
    
    # Check range
    li $t1, 1                      # Lower bound 1
    blt $v0, $t1, pm_choose_number # If less than 1, re-prompt
    li $t1, 9                      # Upper bound 9
    bgt $v0, $t1, pm_choose_number # If greater than 9, re-prompt
    move $s5, $v0	               # Save chosen number into s5
    
    # If upper slider was chosen, multiply it with the
    # number from the lower slider
    beqz $s4, pm_mul_lower         # If upper slider chosen, branch
    
    # Otherwise, multiply it with the number from the
    # upper slider
    mul $s6, $v0, $s0              # Multiply lower number * upper slider 
    j pm_validate                  # Jump to validate
    
pm_mul_lower:
    mul $s6, $v0, $s1              # Multiply upper number * lower slider
    
    # Validate the product
pm_validate:
	move $a0, $s2                  # Load board address
	move $a1, $s3                  # Load markings address
    move $a2, $s6                  # Load product
    jal validate_move              # Call validate_move
    
    # If valid, jump to mark it
    bnez $v0, pm_mark              # If valid, branch to pm_mark
    
    # Otherwise, print the info and ask the user to
    # choose again    
    li $v0, SysPrintString         # Prepare print string syscall
    la $a0, text_invalid           # Load "Invalid move" text
    syscall                        # Print error
    j pm_choose_slider             # Re-prompt slider choice
    
pm_mark:
    # Mark move
    move $a0, $s2                  # Board address
    move $a1, $s3                  # Markings address
    move $a2, $s6                  # Product
    li $a3, 'X'                    # Mark with 'X'
    jal mark_move                  # Call mark_move
    
    # Set the return values, depending on the chosen slider
	beqz $s4, pm_store_upper       # If upper slider, branch
	
	# If lower slider was chosen, copy the chosen number
	# to $v1
	move $v1, $s5                  # Copy chosen number to v1
	move $v0, $s0                  # Return unchanged upper slider
	j pm_done                      # Jump to done
	
	# If upper slider was chosen, copy the chosen number
	# to $v0	
pm_store_upper:
	move $v0, $s5                  # Copy chosen number to v0
	move $v1, $s1                  # Return unchanged lower slider

pm_done:
    # Restore return address and other data from stack
    lw $ra, 0($sp)                 # Restore return address
    lw $s0, 4($sp)                 # Restore s0
    lw $s1, 8($sp)                 # Restore s1
    lw $s2, 12($sp)                # Restore s2
    lw $s3, 16($sp)                # Restore s3
    lw $s4, 20($sp)                # Restore s4
    lw $s5, 24($sp)                # Restore s5
    lw $s6, 28($sp)                # Restore s6
    addi $sp, $sp, 32              # Restore stack pointer
    
    jr $ra                         # Return from procedure

.data   # Start data section
text_player: 	.asciiz "Player's Turn:\n"    # Text for player's turn
text_choosesld: .asciiz "Choose a slider (0 - upper, 1 - lower): "  # Prompt for slider
text_choosenum: .asciiz "Choose a number (1-9): "  # Prompt for number
text_invalid: 	.asciiz "Invalid move. Try again.\n"  # Error message for invalid move
