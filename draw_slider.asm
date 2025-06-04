# draw_slider.asm
.include "SysCalls.asm"   # Include system call definitions

.text   # Start of text (code) section
.globl draw_slider   # Declare draw_slider as a global symbol

# Input: 	$a0 = number on upper slider
#			$a1 = number on lower slider
# Output: 	none

draw_slider:
	# Store return address and $a1 to stack
	addi $sp, $sp, -8       # Allocate 8 bytes on stack
	sw $ra, 0($sp)           # Save return address
	sw $a1, 4($sp)           # Save lower slider number
	
	# Print the first marker above the numbers
	jal draw_marker          # Call draw_marker for upper slider
    
    # Print the numbers
    li $v0, SysPrintString   # Set syscall for printing string
    la $a0, text_numbers     # Load address of numbers text
    syscall                  # Print "1 2 3 4 5 6 7 8 9"
    
   	# Print the second marker below the numbers
   	lw $a0, 4($sp)          # Load saved lower slider number
	jal draw_marker          # Call draw_marker for lower slider
    
    # Restore return address from stack
    lw $ra, 0($sp)           # Restore return address
    addi $sp, $sp, 8         # Restore stack pointer

	jr $ra                   # Return from draw_slider

# Input: 	$a0 = number where marker should be positioned
# Output: 	none

draw_marker:
	move $t0, $a0            # Move marker number to t0
	
	# If zero, do not draw anything
	beqz $t0, dm_done        # If 0, skip drawing marker
	
	# Subtract 1 to get the offset position
	addi $t0, $t0, -1        # Decrement t0 to make it zero-based
	
dm_check:
	# If zero now, jump to print it
	beqz $t0, dm_print       # If t0 is 0, draw marker
	
	# Else, print two spaces
    li $v0, SysPrintChar     # Syscall to print character
    li $a0, 32	           # Load ASCII space character
    syscall                  # Print first space
    li $v0, SysPrintChar     # Syscall to print character
    li $a0, 32	           # Load ASCII space character
    syscall                  # Print second space
    
    # Decrement the value and jump back
    addi $t0, $t0, -1        # Decrement t0
    j dm_check               # Loop back to check
    
dm_print:
	# Draw marker as '|' symbol
    li $v0, SysPrintChar     # Syscall to print character
    li $a0, 124	           # Load ASCII value for '|'
    syscall                  # Print '|'
	
dm_done:
	# Print a new line
    li $v0, SysPrintChar     # Syscall to print character
    li $a0, 10	           # Load ASCII value for newline
    syscall                  # Print newline

	jr $ra                   # Return from draw_marker
	
.data   # Start of data section
text_numbers:	.asciiz "1 2 3 4 5 6 7 8 9\n"   # Text string containing numbers 1-9
