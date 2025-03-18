
.model small
.stack 100h

.data

 column db 0  ;Column position
 row db    9  ;Row position 
 tail db   0  ;Tail position
 head db   0  ;Head position 
 Endmessage db "It’s not a bug;it’s an undocumented feature $" ;String to display at the end       


.code
main proc
    ;Maria Stella Mademli  mariastel@csd.auth.gr
                                  
    mov ax, @data ;Initialize data segment
    mov ds, ax  
      
    ;This program works for video memory (80x25 chars)
    
    ;For the implementation of the program, we will use a variable column and
    ;a variable row so that we can control the position of the snake and the road.
    
    ;The idea is as follows: We have a variable head, which increases by 1 so that
    ; we can print a piece of the snake's body B, and once the green box turns red, we print another B.
    
    ;The use of the variable tail helps us delete a piece of the tail
    ;each time a new one is added in front, in order to create the illusion of movement
    
    ;In each iteration, we display 2 B at the head and remove 1 B from the tail
    ;Therefore, at some point, the head will meet the tail
    ;At this moment, the program will terminate.
    
    
    ;First print the Road  
    
    ;Print the upper side of the road 
    mov row,7 ;The upper part of the road will appear in row 7
    CALL SetCursor ;We need to call the SetCursor function to position the cursor at the desired display point      
    CALL PrintRoad ;Function to print the road
    
    ;;;;; Print the down side of the road ;;;;;;
    mov row,11 ;The down part of the road will appear in row 11 
    CALL SetCursor ;We need to call the SetCursor function to position the cursor at the desired display point
    CALL PrintRoad ;Function to print the road  
                 
    ;;;; Draw the red box ;;;;;
    CALL DrawRedBox
    
    ;;; Set the cursor to its initial position to start the snakes path ;;;  
    mov column,0 ;Snake starts from the begining of the line
    mov row ,9   ;Snake walks in the 9 row
    CALL SetCursor ;Set the cursor to the desired display point
                                      
    ;;;; Print the first part of the body of the snake ;;;;;
    CALL printSnakeBody
    
    sub column,4 ;Set the cursor back to remove the tail of the snake   
    CALL SetCursor ;Set the cursor to the desired display point
    CALL removeFromScreen ;Remove the tail
                                           
    ;Head and tail variables control the movment of the snake by adding in head and removing from tail                                       
    mov head,4 ; Next position to print B   
    mov tail,1 ; Next position to remove B
    
    ;Snake walks until the end of the video memory witch is in the 80 column position.
    ;When it reaches the end of the video memory it appears again from the left side of the video memory
    mov cx,80 ;Correct initialization of the cx register witch is the register that controls the number of loop iterations
    SnakePrintLoop: 
      
       ;If the head of the snake reaches the end of the video memory we have to go from the left side of the video memory again 
       cmp head,80
       je GoAgainLeft
       
       ;Here we compare head and tail (if( head == tails) goto ClearScreen)
       ;This happend when the snake gets big enough that the tail touches the head so we have to end the program
       ;Save the values of register so that we dont overwrite it  
       push ax
       push cx
       ;We cant directly compare memory with memory so first we have to save the values of the head and tail to registers 
       mov al,head ;Save the head value in the al register
       mov cl,tail ;Save the tail value in the cl register
       cmp  al,cl ;if( head == tails) goto ClearScreen 
       je  ClearScreen ;Jump to clear the entire snake
       
       ;Restore the cx and ax registers    
       pop cx
       pop ax
       
       ;Now its time to make the box green
       CALL DrawGreenBox
       
       ;Because we cant do: mov column,head we have to fist save the head value to al   
       mov al,head   ;Save the value of head into al
       mov column,al ;Move column,head
                   
       CALL SetCursor  ;Set the cursor to the desired display point
       CALL PrintSnake ;Print a Single part of the snake 
       
                      
       CALL Generate1SecDelay ;Wait for 1 second 
       CALL DrawRedBox ;Make the box red again
       
       ;Now tha the box turns red we have to add another B into the snake
                                      
       add head,1    ;Move the head to the right again
       mov al,head   ;Save the value of head into al
       mov column,al ;Move column,head  
       add head,1
        
       call SetCursor  ;Set the cursor to the desired display point
       call PrintSnake ;Print a Single part of the snake 
        
       mov al,tail ;Save the tail value into al to prepare for removing    
       mov  column,al ;mov column,tail
      
       CALL SetCursor ;Set the cursor to the desired display point 
       CALL removeFromScreen ;Remove a part of the tail 
       add  tail,1 ;Move the tail position to prepare for the next remove
                                  
       sub cx,1 ;Update the cx register 
    
     jmp SnakePrintLoop ; Continue the loop
 
 
    ;When the snake reaches the end of the window enters here
    GoAgainLeft:
        mov column,0   ;Start again the printing from the start of the video memory 
        CALL SetCursor ;Set the cursor to the desired display point
        CALL PrintSnake ;Print a Single part of the snake
        mov head,1 ;Move the snakes head 
 
        mov cx,80 ;Set again the loop to run 80 times
        jmp SnakePrintLoop ;Go to loop again 
    
    ;When the program reaches this part of the code it means tha thenake fills the entire screen
    ClearScreen:
        ;Now we have to clear the screen from the snake and print the ending message
        mov column,0 ;Go again to the start to remove the snake
        
        ;Loop to run 80 times to remove the entire snake   
        ClearScreenLoop:
            
            cmp column,80 ;When we removed all the parts of the snakes body we have to end the program
            je  EndProgram ; if(column == 0 ) goto EndProgram                                                                   
            CALL SetCursor ;Set the cursor to the desired display point
            CALL removeFromScreen ;Call the function to remove a singe parte of the snakes body
            add column,1 ;Go to the next column 
            jmp ClearScreenLoop ;Repeat the removing process
                
       
    EndProgram:
        
       ;;Dispaly the message;;
       mov ah, 09h        
       lea dx, Endmessage
       int 21h
         
       mov ah,4Ch ;Exit program
       int 21h  
    
 
      
main endp 
 
 
;This function deletes an element on the screen depending on where the cursor is positioned
;It is useful to  remove a piece of the snakes tail and in the end to remove all the snake from the screen
removeFromScreen proc 
    
    push ax ;We add the ax to the stack so that we dont overwrite it
    
    mov al, ' ' ; Character to print,the empty character here to clear the screen
    mov ah, 0Eh ; Output function
    int 10h     ; BIOS interrupt 
    
    pop ax ;Restore ax
       
    ret ;Return
       
removeFromScreen endp 

;This function moves the cursor to the desired position 
;This position is defined by the variables row and column    
SetCursor proc
     
     ;;We add the ax and cx to the stack so that we dont overwrite it
     push ax   
     push cx
     
     mov ah,02h ;Function number,Set cursor position,BH = Page Number, DH = Row, DL = Column	
     mov dh,row ;Row value position 
     mov dl,column ;Column value position
     mov bh,0 ;Page Number(always 0)
     int 10h  ;BIOS interrupt for video services 
     
     ;Restore cx and ax      
     pop cx
     pop ax
     
     ret ;Return
      
SetCursor endp

;This function prints a piece of the snakes body,a letter B
PrintSnake proc
    
   push ax ;We add the ax to the stack so that we dont overwrite it 
     
   mov al,'B' ;Character to print
   mov ah,0Eh ;Output function
   int 10h  
   
   pop ax ;restore ax
   
   ret ;Return 
       
PrintSnake endp 

;Display 80 A 
PrintRoad proc 
                
    push ax ;We add the ax to the stack so that we dont overwrite it         
    mov column,0 ;We start from the beginning (the first element of the row)  
    mov cx,80 ;The Video Memory has 80 elements,so we have to display until the end witch is 80
    L2: 
        ;Set the cursor to the correct position                    
        mov ah,02h ;Function number
        mov dh,row ;Row position         
        mov dl,column ;Column position
        mov bh,0 ;Page Number(always 0)
        int 10h 
        
        ;Display a piece of the road.
        mov al, 'A' ; Character to print
        mov ah, 0Eh ; Output function
        int 10h
         
        add column,1 ;Go to the next column to preaper correct display 
    loop L2 
    pop ax ;restore ax
    ret ;Return
PrintRoad endp 

;This function displays the red box on the screen at the desired position
DrawRedBox proc       
    
    ;We add the ax,dx and cx to the stack so that we dont overwrite it           
    push bx 
    push cx
    push dx
    
    ;AL = lines to scroll (0 = clear, CH, CL, DH, DL are used)
    ;BH = Background Color and Foreground color
    ;CH = Upper row number, CL = Left column number
    ;DH = Lower row number, DL = Right column number
     
    mov ah,06h ;Scroll up window
    mov bh,43h ;Red colour
    mov ch,2   ;Upper row number 
    mov cl,70  ;Left column number
    mov dh,4   ;Lower row number
    mov dl,73  ;Right column number
    int 10h    ;BIOS interrupt call 
    
    ;Restore cx,dx and ax in the correct order  
    pop dx 
    pop cx
    pop bx
    ret ;Return
    
DrawRedBox endp 

;This function displays the green box on the screen at the desired position
DrawGreenBox proc  
    
    ;We add the ax,dx and cx to the stack so that we dont overwrite it
    push bx
    push cx
    push dx
     
    ;AL = lines to scroll (0 = clear, CH, CL, DH, DL are used)
    ;BH = Background Color and Foreground color
    ;CH = Upper row number, CL = Left column number
    ;DH = Lower row number, DL = Right column number 
    
    mov ah,06h ;Scroll up window
    mov bh,23h ;Green Colour
    mov ch,2   ;Upper row number 
    mov cl,70  ;Left column number
    mov dh,4   ;Lower row number
    mov dl,73  ;Right column number
    int 10h 
    
    ;Restore cx,dx and ax in the correct order 
    pop dx
    pop cx 
    pop bx 
    ret ;Return
      
DrawGreenBox endp 
 
;This function generates 1 second delay 
Generate1SecDelay proc
       
    push ax ;We add the ax to the stack so that we dont overwrite it
    
    ;input:CX:DX = interval in microseconds
    MOV  CX, 0FH
    MOV  DX, 4240H
    MOV  AH, 86H ;function number for the "Wait"
    INT  15H  ;INT 15h / AH = 86h - BIOS wait function.
     
    pop ax ;Restore ax 
    ret ;Return
    
Generate1SecDelay endp

;This function displays 4 pieces of the snakes body representing the snake in its initial state                               
printSnakeBody proc      
    
    ;We add the axand cx to the stack so that we dont overwrite it    
    push ax  
    push cx 
    
    mov cx,4 ;Loop runs for 4 times 
    mov column,0 ;Start from the begining of the line
    L1:
      CALL PrintSnake ;Print single B
      add column,1    ;Go to the next column to print the next B
      CALL SetCursor  ;Set the cursor to the next position for correct printing
    loop L1
      
    ;Restore ax ad cx
    pop ax
    pop cx
    ret ;Return 

printSnakeBody endp    


end main  
              
              