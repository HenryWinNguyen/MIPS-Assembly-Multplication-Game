# check_win.asm

.text                     # Start of text (code) section
.globl check_win          # Make check_win visible to other files

# Input: 	$a0 = number on upper slider
#			$a1 = number on lower slider
#			$a2 = board address
#			$a3 = markings address
# Output: 	$v0 = 0 no win, 1 player win, 2 computer win, 3 tie

check_win:                # Main procedure to check win/tie
	addi $sp, $sp, -20         # Allocate space on stack
	sw $ra, 0($sp)             # Save return address
	sw $s0, 4($sp)             # Save s0
	sw $s1, 8($sp)             # Save s1
	sw $s2, 12($sp)            # Save s2
	sw $s3, 16($sp)            # Save s3
	
	move $s0, $a0              # Copy upper slider value to s0
	move $s1, $a1              # Copy lower slider value to s1
	move $s2, $a2              # Copy board address to s2
	move $s3, $a3              # Copy markings address to s3
	
	jal count_valid_moves      # Call subroutine to count valid moves
	beqz $v0, cw_tie           # If no moves left, it's a tie

    move $t0, $s3              # Load markings address into t0

    # --- Horizontal check ---
    li $t1, 0                  # Set row counter to 0

cw_hrow_loop:                 # Loop through each row
    li $t2, 0                  # Set column counter to 0

cw_hcol_loop:                 # Loop through each column
    lb $t3, 0($t0)             # Load current cell's marking

    beqz $t3, cw_next_hcol     # If unmarked, skip this cell

    lb $t4, 1($t0)             # Load marking to the right
    lb $t5, 2($t0)             # Load two to the right
    lb $t6, 3($t0)             # Load three to the right

    beq $t3, $t4, cw_check_horiz2  # Check first match
    j cw_next_hcol             # Otherwise go to next column
cw_check_horiz2:              
    beq $t3, $t5, cw_check_horiz3  # Check second match
    j cw_next_hcol
cw_check_horiz3:
    beq $t3, $t6, cw_winner_found  # All match, winner found
    j cw_next_hcol

cw_next_hcol:                 # Increment column and continue
    addi $t0, $t0, 1           # Move to next marking
    addi $t2, $t2, 1           # Increment column counter
    li $t7, 3                  # Only first 3 columns can be start
    blt $t2, $t7, cw_hcol_loop # Loop if within bounds

    addi $t0, $t0, 3           # Skip unused cells in row
    addi $t1, $t1, 1           # Move to next row
    li $t8, 6                  # Total 6 rows
    blt $t1, $t8, cw_hrow_loop # Loop through rows

    # --- Vertical check ---
	move $t0, $s3              # Reset markings pointer
    li $t1, 0                  # Reset row counter

cw_vrow_loop:                 # Loop rows for vertical check
    li $t2, 0                  # Reset column counter

cw_vcol_loop:                 # Loop columns
    lb $t3, 0($t0)             # Load current marking

    beqz $t3, cw_next_vcol     # If unmarked, skip

    lb $t4, 6($t0)             # Load marking one row down
    lb $t5, 12($t0)            # Two rows down
    lb $t6, 18($t0)            # Three rows down

    beq $t3, $t4, cw_check_vert2   # If current mark equals 1st mark below, continue checking
    j cw_next_vcol                 # Otherwise, move to next vertical column
cw_check_vert2:                    # Label to check second vertical match
    beq $t3, $t5, cw_check_vert3   # If current mark equals 2nd mark below, continue checking
    j cw_next_vcol                 # Otherwise, move to next vertical column
cw_check_vert3:                    # Label to check third vertical match
    beq $t3, $t6, cw_winner_found  # If current mark equals 3rd mark below, winner found
    j cw_next_vcol                 # Otherwise, move to next vertical column

cw_next_vcol:                      # Label to continue to next vertical column
    addi $t0, $t0, 1               # Move to next cell (right by 1 column)
    addi $t2, $t2, 1               # Increment column counter
    li $t7, 6                      # Load 6 (total columns) into $t7
    blt $t2, $t7, cw_vcol_loop     # If not finished columns, continue vertical checking

    addi $t1, $t1, 1               # Move to next row
    li $t8, 3                      # Load 3 (only first 3 rows valid for vertical wins)
    blt $t1, $t8, cw_vrow_loop     # If more rows to check, loop again


    # --- Diagonal NW-SE check ---
	move $t0, $s3              # Reset markings
    li $t1, 0                  # Reset row counter

cw_drow_loop1:                            # Label for diagonal NW-SE row loop (starts top-left to bottom-right)
    li $t2, 0                  # Reset column counter to 0

cw_dcol_loop1:                            # Label for diagonal NW-SE column loop
    lb $t3, 0($t0)             # Load current marking from memory

    beqz $t3, cw_next_dcol1    # If current cell is unmarked (zero), skip diagonal check
    
    lb $t4, 7($t0)             # Load diagonal cell 1 step down-right (+7 bytes)
    lb $t5, 14($t0)            # Load diagonal cell 2 steps down-right (+14 bytes)
    lb $t6, 21($t0)            # Load diagonal cell 3 steps down-right (+21 bytes)

    beq $t3, $t4, cw_check_diag2   # If first matches, continue check
    j cw_next_dcol1                # Otherwise, go to next column
cw_check_diag2:                       # Label to check second diagonal match
    beq $t3, $t5, cw_check_diag3    # If second matches, continue
    j cw_next_dcol1 # Otherwise, go to next column

cw_check_diag3:                       # Label to check third diagonal match
    beq $t3, $t6, cw_winner_found    # If third matches, winner found
    j cw_next_dcol1 # Otherwise, go to next column


cw_next_dcol1:                         # Label to advance to next diagonal column
    addi $t0, $t0, 1           # Move to next cell in row
    addi $t2, $t2, 1           # Increment column counter
    li $t7, 3                  # Max starting col for NW-SE diag is 3
    blt $t2, $t7, cw_dcol_loop1   # Loop if still within column limit

    addi $t0, $t0, 3           # Skip remaining cells in row
    addi $t1, $t1, 1           # Increment row counter
    li $t8, 3                  # Max starting row for NW-SE diag is 3
    blt $t1, $t8, cw_drow_loop1   # Loop to next diagonal row

	# --- Diagonal NE-SW check ---
	move $t0, $s3              # Reset markings pointer to beginning
    li $t1, 0                  # Reset row counter

cw_drow_loop2:                            # Label for diagonal NE-SW row loop (starts top-right to bottom-left)
    li $t2, 3                  # Start column index at 3 (4th column)
    addi $t0, $t0, 3           # Advance pointer to skip first 3 columns

cw_dcol_loop2:                            # Label for diagonal NE-SW column loop
    lb $t3, 0($t0)             # Load current marking

    beqz $t3, cw_next_dcol2    # Skip if current cell is unmarked
    
    lb $t4, 5($t0)             # Load diagonal 1 step down-left (+5 bytes)
    lb $t5, 10($t0)            # Load diagonal 2 steps down-left
    lb $t6, 15($t0)            # Load diagonal 3 steps down-left

    beq $t3, $t4, cw_check_diag4   # First match?
    j cw_next_dcol2
cw_check_diag4:
    beq $t3, $t5, cw_check_diag5   # Second match?
    j cw_next_dcol2
cw_check_diag5:
    beq $t3, $t6, cw_winner_found  # Third match -> winner
    j cw_next_dcol2
        
cw_next_dcol2:                         # Label to go to next NE-SW column
    addi $t0, $t0, 1           # Move to next cell
    addi $t2, $t2, 1           # Increment column counter
    li $t7, 6
    blt $t2, $t7, cw_dcol_loop2   # Loop while within grid

    addi $t1, $t1, 1           # Move to next row
    li $t8, 3                  # Max valid rows for NE-SW diagonal
    blt $t1, $t8, cw_drow_loop2   # Loop to next diagonal

cw_no_win:                               # Label for no winner
    li $v0, 0                   # Set result to 0 = no win
    j cw_done                   # Jump to cleanup/return
    
cw_tie:                                   # Label for tie condition
	li $v0, 3                   # Set result to 3 = tie
	j cw_done

cw_winner_found:                         # Label when winner is detected
    li $v0, 1                   # Assume player is the winner
    li $t9, 'O'                 # Load ASCII for 'O' (used by computer)
    beq $t3, $t9, cw_set_computer_win  # If it was 'O', computer wins
    j cw_done

cw_set_computer_win:                    # Label to set computer win result
    li $v0, 2                   # Set result to 2 = computer win

    
cw_done:
    lw $ra, 0($sp)              # Restore return address
    lw $s0, 4($sp)              # Restore s0
    lw $s1, 8($sp)              # Restore s1
    lw $s2, 12($sp)             # Restore s2
    lw $s3, 16($sp)             # Restore s3
    addi $sp, $sp, 20           # Deallocate stack
    jr $ra                      # Return to caller

# Input: 	$a0 = upper slider
#			$a1 = lower slider
#			$a2 = board address
#			$a3 = markings address
# Output: 	$v0 = count of valid moves

count_valid_moves:
	addi $sp, $sp, -28         # Allocate stack
	sw $ra, 0($sp)             # Save return address
	sw $s0, 4($sp)             # Save s0
	sw $s1, 8($sp)             # Save s1
	sw $s2, 12($sp)            # Save s2
	sw $s3, 16($sp)            # Save s3
	sw $s4, 20($sp)            # Save s4
	sw $s5, 24($sp)            # Save s5
	
	move $s0, $a0              # Save inputs
	move $s1, $a1              # Save inputs
	move $s2, $a2              # Save inputs
	move $s3, $a3              # Save inputs
	
    li $s4, 1                  # Number 1-9
    li $s5, 0                  # Valid move counter
    
cvm_upper_loop:                            # Label for upper slider loop start
	mul $t0, $s4, $s1          # Multiply current number ($s4) by lower slider value ($s1), store result in $t0
	
	move $a0, $s2              # Load board address into $a0 for validate_move
	move $a1, $s3              # Load markings address into $a1
	move $a2, $t0              # Load product to validate into $a2
	jal validate_move          # Call validate_move to check if move is valid
	
	beqz $v0, cvm_upper_cont   # If move is invalid ($v0 == 0), skip increment
    addi $s5, $s5, 1           # If valid, increment valid move counter in $s5
	
cvm_upper_cont:                            # Label for continuation after upper move check
	addi $s4, $s4, 1           # Increment current number for upper slider (1 to 9)
	li $t0, 9                  # Load upper limit value 9 into $t0
	ble $s4, $t0, cvm_upper_loop  # Loop again if $s4 <= 9
	
    li $s4, 1                  # Reset $s4 to 1 for use in lower slider loop


cvm_lower_loop:                            # Label for lower slider loop start
	mul $t0, $s0, $s4          # Multiply upper slider ($s0) by current number ($s4), store product in $t0
	
	move $a0, $s2              # Load board address into $a0 for validate_move
	move $a1, $s3              # Load markings address into $a1
	move $a2, $t0              # Load product to validate into $a2
	jal validate_move          # Call validate_move to check if move is valid
	
	beqz $v0, cvm_lower_cont   # If not valid ($v0 == 0), skip incrementing valid move counter
    addi $s5, $s5, 1           # If valid, increment valid move counter in $s5
	
cvm_lower_cont:                            # Label for continuation after lower move check
	addi $s4, $s4, 1           # Increment the current lower slider candidate number
	li $t0, 9                  # Load constant 9 (loop limit)
	ble $s4, $t0, cvm_lower_loop  # If $s4 <= 9, continue loop
	
	move $v0, $s5              # Move total valid moves count into $v0 (return value)


cvm_done:
    lw $ra, 0($sp)             # Restore return address
    lw $s0, 4($sp)             # Restore return 
    lw $s1, 8($sp)             # Restore return 
    lw $s2, 12($sp)             # Restore return 
    lw $s3, 16($sp)             # Restore return 
    lw $s4, 20($sp)             # Restore return 
    lw $s5, 24($sp)                 # Restore return 
    addi $sp, $sp, 28          # Restore stack
    jr $ra                     # Return
