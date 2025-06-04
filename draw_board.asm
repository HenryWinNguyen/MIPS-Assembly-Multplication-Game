# drawboard.asm
.include "SysCalls.asm"   # Include system call definitions

.data   # Start of data section (no variables defined here)

.text   # Start of text (code) section
.globl draw_board   # Declare draw_board as a global label

# Input:	$a0 = board address
# 		 	$a1 = markings address
# Output:	none

draw_board:
	move $t0, $a0		# Move board address into $t0
	move $t1, $a1		# Move markings address into $t1
    li $t2, 0          	# Initialize row counter to 0
    
db_row:
    li $t3, 0          	# Initialize column counter to 0

db_col:
    # Load marking
    lb $t4, 0($t1)      # Load marking value (X, O, or 0) from markings array
    beqz $t4, db_print_number   # If no marking, jump to print the number

    # If marking (X or O), print it
    
    # Space before marking
    li $v0, SysPrintChar   # Set syscall code for printing character
    li $a0, 32	# Load ASCII space character
    syscall                # Print space
    
    # Marking
    li $v0, SysPrintChar   # Set syscall code for printing character
    move $a0, $t4          # Move marking (X or O) into $a0
    syscall                # Print marking

    # Space after marking
    li $v0, SysPrintChar   # Set syscall code for printing character
    li $a0, 32	# Load ASCII space character
    syscall                # Print space
    j db_next              # Jump to db_next to advance to next cell

db_print_number:
    # Load the number
    lw $t5, 0($t0)         # Load board number from board array
    
    li $t6, 9              # Load constant 9 into $t6
    bgt $t5, $t6, db_print_double   # If number > 9, skip space printing
    
    # If less than 9, print a space before the number
    li $v0, SysPrintChar   # Set syscall code for printing character
    li $a0, 32	# Load ASCII space character
    syscall                # Print space

db_print_double:
    # Print number
    li $v0, SysPrintInt    # Set syscall code for printing integer
    move $a0, $t5          # Move board number into $a0
    syscall                # Print number

    # Space after number
    li $v0, SysPrintChar   # Set syscall code for printing character
    li $a0, 32	# Load ASCII space character
    syscall                # Print space

db_next:
    addi $t0, $t0, 4       # Move board pointer to next number
    addi $t1, $t1, 1       # Move markings pointer to next marking
    addi $t3, $t3, 1       # Increment column counter
    li $t6, 6              # Load constant 6 (6 columns)
    blt $t3, $t6, db_col   # If not end of row, continue db_col loop

    # End of row -> Newline
    li $v0, SysPrintChar   # Set syscall code for printing character
    li $a0, 10	# Load ASCII newline character
    syscall                # Print newline

    addi $t2, $t2, 1       # Increment row counter
    li $t6, 6              # Load constant 6 (6 rows)
    blt $t2, $t6, db_row   # If not end of board, continue db_row loop

    jr $ra                 # Return from procedure
