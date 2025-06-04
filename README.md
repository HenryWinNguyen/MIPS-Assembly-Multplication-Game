# Multiplication 4-in-a-Row (MIPS Assembly Game)

Multiplication 4-in-a-Row is a turn-based strategy game written in MIPS assembly for the MARS simulator. A human player competes against a computer by selecting numbers on sliders to mark multiplication products on a 6×6 board. The goal is to be the first to align four marks in a row—horizontally, vertically, or diagonally.

This project demonstrates practical low-level programming and computer architecture concepts through a fully interactive game.

## Skills Demonstrated

Game Design and Logic:
- Interactive 6x6 game board rendered using ASCII formatting
- Two dynamic sliders (upper and lower) to select numbers from 1 to 9
- Turn-based player vs computer gameplay
- Win detection for horizontal, vertical, and diagonal sequences
- Tie detection when no valid moves remain

Assembly Programming Techniques:
- Modular program structure across multiple assembly source files
- Stack frame setup and teardown for procedure calls
- Use of system calls for string printing, integer input, and random number generation
- Arithmetic operations and control flow using loops and conditionals
- Memory access and address calculation using pointer arithmetic

Artificial Intelligence:
- Computer player checks for winning opportunities
- If no immediate win, chooses a valid move randomly
- Validates all moves against current board state before applying

Input and Display:
- Real-time slider markers drawn using ASCII characters
- Clear prompts for player interaction
- Formatted output for clean game state display

## Project Structure
main.asm: The entry point; contains the main game loop and turn handling

board_data.asm: Defines the board values and game-related strings

draw_board.asm: Displays the 6×6 board with current markings

draw_slider.asm: Shows the number slider and selection marker

player_move.asm: Handles player input, slider logic, and move validation

computer_move.asm: Contains AI logic to select and validate moves

check_win.asm: Checks for 4-in-a-row wins or a tie

mark_move.asm: Places or removes a mark on the board

validate_move.asm: Confirms whether a product is on the board and unmarked



