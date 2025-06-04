.include "SysCalls.asm"   # Include system call definitions
.extern board, 144        # Declare external board symbol (144 bytes for board and markings)

.text   # Begin text (code) section
.globl main   # Declare main as a global symbol

main:
	# Print the welcome message
    li $v0, SysPrintString   # Set syscall code for printing string
    la $a0, text_welcome     # Load address of welcome text
    syscall                  # Print welcome message
    
    # Computer picks first number on lower slider
    li $a0, 0                # Set lower bound 0
    li $a1, 9                # Set upper bound 9
    li $v0, SysRandIntRange  # Set syscall for random integer range
    syscall                  # Generate random number between 0 and 9
    
    # Add 1 to adjust the range to 1-9
    addi $a0, $a0, 1         # Increment random number to range 1–9
    move $s1, $a0            # Store initial number on lower slider
        
   	# Store 0 as the initial number on upper slider
    li $s0, 0                # Initialize upper slider to 0

game_loop:
	la $a0, board             # Load board address into $a0
	la $a1, markings          # Load markings address into $a1
    jal draw_board            # Call draw_board to display current board

    # Player move
    move $a0, $s0             # Move upper slider number into $a0
    move $a1, $s1             # Move lower slider number into $a1
	la $a2, board             # Load board address into $a2
	la $a3, markings          # Load markings address into $a3
    jal player_move           # Call player_move to get player's move
    
    move $s0, $v0             # Update upper slider with returned value
    move $s1, $v1             # Update lower slider with returned value

    move $a0, $s0             # Move upper slider number for win check
    move $a1, $s1             # Move lower slider number for win check
	la $a2, board             # Load board address
	la $a3, markings          # Load markings address
    jal check_win             # Call check_win to check if player wins
    beq $v0, 1, player_wins   # If player wins, branch to player_wins
    beq $v0, 2, computer_wins # If computer wins (somehow), branch to computer_wins
    beq $v0, 3, game_tied     # If tie, branch to game_tied

    # Computer move
    move $a0, $s0             # Move upper slider number into $a0
    move $a1, $s1             # Move lower slider number into $a1
	la $a2, board             # Load board address into $a2
	la $a3, markings          # Load markings address into $a3
    jal computer_move         # Call computer_move for computer's move
    
    move $s0, $v0             # Update upper slider with returned value
    move $s1, $v1             # Update lower slider with returned value

    move $a0, $s0             # Move upper slider number for win check
    move $a1, $s1             # Move lower slider number for win check
	la $a2, board             # Load board address
	la $a3, markings          # Load markings address
    jal check_win             # Call check_win to check if computer wins
    beq $v0, 1, player_wins   # If player wins, branch to player_wins
    beq $v0, 2, computer_wins # If computer wins, branch to computer_wins
    beq $v0, 3, game_tied     # If tie, branch to game_tied

    j game_loop               # Repeat the game loop

player_wins:
    li $v0, SysPrintString    # Set syscall for printing string
    la $a0, text_playerwin    # Load address of player win text
    syscall                   # Print "You win!" message
    li $v0, SysExit           # Set syscall for exit
    syscall                   # Exit program

computer_wins:
    li $v0, SysPrintString    # Set syscall for printing string
    la $a0, text_computerwin  # Load address of computer win text
    syscall                   # Print "Computer wins!" message
    li $v0, SysExit           # Set syscall for exit
    syscall                   # Exit program
   
game_tied:
    li $v0, SysPrintString    # Set syscall for printing string
    la $a0, text_tie          # Load address of tie text
    syscall                   # Print "It's a tie!" message
    li $v0, SysExit           # Set syscall for exit
    syscall                   # Exit program

.data   # Begin data section
.include "board_data.asm"   # Include board data definitions
