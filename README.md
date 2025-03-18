# Snake-Animation-in-assembly-x86
This is a motion scenario implemented in the emu8086 emulator, written in x86 assembly.
The goal is to create a motion scenario that will be displayed in the Video Memory of a microcomputer system based on the x86 architecture in order to become familiar with low-level code writing.
The idea is as follows;

*Initially, the following string "AA.....AA" is printed on two lines of the video memory,these two lines will define the road of the snake.
*Then, in the upper left part of the video memory we are printing a red or green square.This square should change color every 1 second ,and we are using the interrupt timer to measure the time.
*Next, we create the moving "snake" that moves within the road.The body of the snake consists of the character "B", and its size increases each time the square in the upper left part of the video memory changes color.The snake moves step by step, one position at a time.
*Each time the snake reaches the end of the line (the rightmost point), it should continue its movement from the beginning of the line (reappearing from the left side of the line).
*The process should continue until the size of the snake occupies the entire line.At this point, the program terminates and displays the following message: "It’s not a bug; it’s an undocumented feature."






































