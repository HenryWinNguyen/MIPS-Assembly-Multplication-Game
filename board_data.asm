# board_data.asm
.data   # Start of the data segment

board:  # Label for the multiplication board array
    .word 1, 2, 3, 4, 5, 6   # First row of board numbers (products)
    .word 7, 8, 9, 10, 12, 14   # Second row of board numbers
    .word 15, 16, 18, 20, 21, 24   # Third row of board numbers
    .word 25, 27, 28, 30, 32, 35   # Fourth row of board numbers
    .word 36, 40, 42, 45, 48, 49   # Fifth row of board numbers
    .word 54, 56, 63, 64, 72, 81   # Sixth row of board numbers

markings: .space 36	# Allocate 36 bytes for markings (one byte per board cell, 6x6 grid)

text_player:   		.asciiz "Player's Turn:\n"   # String for indicating player's turn
text_computer:  	.asciiz "Computer's Turn:\n"   # String for indicating computer's turn
text_invalid:   	.asciiz "Invalid move. Try again.\n"   # String shown when player inputs invalid move
text_welcome:   	.asciiz "Welcome to Multiplication 4-in-a-Row!\n"   # Welcome message at game start
text_playerwin: 	.asciiz "You win!\n"   # Message when player wins the game
text_computerwin: 	.asciiz "Computer wins!\n"   # Message when computer wins the game
text_tie:       	.asciiz "It's a tie!\n"   # Message when the game results in a tie
text_boardline: 	.asciiz "---------------------------------------\n"   # Horizontal line for board formatting
text_space: 		.asciiz " "   # Single space character for formatting output
