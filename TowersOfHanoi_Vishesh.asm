;;;;;;NOTE;;;;;;;;;;;;;;;;;;;;;;;
;;;;;My Approach and the stack/Activation Record Pseudocode Written at the end;;;;;;;;;
            .ORIG x3000
            
   ;; Clearing all registers
       
    AND R0, R0, #0  ;   
    AND R1, R1, #0  ;   Contains the Number of disks inputted by the user
    AND R2, R2, #0  ;   
    AND R3, R3, #0  ;   
    AND R4, R4, #0  ;
    AND R5, R5, #0  ;   R5 used as a Frame Pointer
    AND R6, R6, #0  ;   R6 used as a Stack Pointer
    AND R7, R7, #0  ;   And R7 is the std return Address register
    
    ADD R3, R3, #-1
    ADD R3, R3, #-1
    ADD R3, R3, #-1
    ADD R3, R3, #-1
    ADD R3, R3, #-1
    ADD R3, R3, #-1
    ADD R3, R3, #-1
    ADD R3, R3, #-1
    ADD R3, R3, #-1


   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;;;;;Below part build the stack in the main();;;;;;;
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    LD  R0, MAIN_STACK_START   ;Store the starting address of our runtime stack in R0
    LD  R6, MAIN_STACK_START   ;Initialize R6 to the top of our stack (initializing the stack pointer)

    ADD R5, R0, #-1                 ;; Now the stack pointer points to teh first LC
                                        ;Dynamic link does not exist, but we left space for it.
MAIN_STACK_START    .FILL x5000 ;; Put the label values in b/w because for some reason
                                ;; the assembler was not detecting them from teh bottom. No idea why, maybe because the code is a bit long. 

    ;;User_Inputs
    
    LEA R0, DISKS_PROMPT    ;Load the address of  prompt into R0
    PUTS                            
    
DISKS_PROMPT    .STRINGZ    "\n--Towers of Hanoi--\nHow many disks do you want to be shifted?: "

    
    GETC    ; Store th character entered by the user in R0
    OUT     ;Display the entered input strored in R0 to the user
    ADD R1, R1, R0  ; R1=R0=UserInput
    
    ;To Print the other prompts
    
    LEA R0, MOVES_OUTPUT_1
    PUTS
    
    AND R0, R0, #0 
    ADD R0, R0, R1 ; Get the value of no_of_disks, as entered by the user
    OUT
    LEA R0, MOVES_OUTPUT_2
    PUTS
    
    ;Converting the ASCII valkue to binary by -30
    LD  R2, ASCII_TO_BINARY   ;#-48
    ADD R0, R1, R2                  ;R0 = ASCII - x30 = binary form
    
    ADD R6, R6, #-1                 ;make r6 point to the top of the stack 
    STR R0, R6, #0                  ; Push the value from R0 to the stack    
    
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;CALLER ACTIVATION RECORD FOR MOVEDISK;;;
    ;;;;;;;;;INSIDE THE MAIN FUNCTION;;;;;;;;;
    
    ;; Arguments to be pushed from the function call in the order of last to first
    ;;Element Pushed First=2
    ;;Element Pushed Second=3
    ;;Element Pushed third=1
    ;;Element Pushed Fourth=n
    
    
    ;R0 = last argument
    AND R0, R0, #0
    ADD R0, R0, #2  ; Store 2 as it is a const argument in the move disk 
    ADD R6, R6, #-1 ; pUsh this value to the top of the stack
    STR R0, R6, #0
    
    ;R0 = 2nd Last argument
    AND R0, R0, #0
    ADD R0, R0, #3  
    
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    ;R0 = 3rd Last argument
    AND R0, R0, #0
    ADD R0, R0, #1  
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    ;R0 = no_of_disks
    LDR R0, R5, #0  
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    ;; Calling the function, after populating the stack for the main function
    
    ;We call the function
    JSR MOVEDISK_FUNCTION

    ;At this point, R6 should be pointing to the retVal of MOVEDISK with proper stack implementation
    
    LDR R0, R6, #0
    
    ;Set R6 back to it's original position, fully unwinding the stack
    ADD R6, R6, #1

    HALT
            
MOVEDISK_FUNCTION

    ;;;BUILDing the MOVE_DISK FUNCTION(which is being called);;;
    ;;;;;ACTIVATION RECORD;;;

    ADD R6, R6, #-1  ;Reserving space for the return value, maybe not needed as it is a void function
    
    ADD R6, R6, #-1
    STR R7, R6, #0
    
    
    ADD R6, R6, #-1      ;;Pushing the Dynamic link to the STack

    STR R5, R6, #0      
    
    ;;;;;;R6 has to point to the DL, therefore R5 points to the location just above the DL/R6
    ADD R5, R6, #-1
    
   ;; No local variables in the move disk
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;Stepping in to execute the function;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    

    ;;;BASE CASE:
        ;disk_number<=1
        ;disk_number-1<=0
    LDR R1, R6, #4      
    
    AND R0, R0, #0      
    ADD R0, R0, #-1  


    BRz MOVEDISK_BASE_CASE  
    

MOVES_OUTPUT_1  .STRINGZ    "\nInstructions to move "
MOVES_OUTPUT_2  .STRINGZ    " disks from post 1 to post 3:\n"  
; Building am activatyion record when the movedisk is called

MOVEDISK_RECURSIVE_STEP
    ;R0 = last argument

    AND R0, R0, #0
    LDR R0, R5, #6  
    ADD R6, R6, #-1  ; Move the stack pointer down to make space for the argument
    STR R0, R6, #0 ; Push the value of end_post onto the stack
    
    AND R0, R0, #0
    LDR R0, R5, #7  
    ADD R6, R6, #-1
    STR R0, R6, #0 ; Push the value of start_post onto the stack
    
    AND R0, R0, #0
    LDR R0, R5, #5  
    ADD R6, R6, #-1
    STR R0, R6, #0 ; Push the value of midPost onto the stack
    
    AND R0, R0, #0
    LDR R0, R5, #4
    ADD R6, R6, #-1
    STR R0, R6, #0 ; Push the value of diskNumber-1 onto the stack
    

    JSR MOVEDISK_FUNCTION
    
        ; Retrieve the return value from the stack
    LDR R0, R6, #0
    ADD R6, R6, #1
    
   ; POPPing all values below when we are done buiilding the activation record
    ADD R6, R6, #1
    ADD R6, R6, #1
    ADD R6, R6, #1
    ADD R6, R6, #1              
    

;;;;;;;;;;;;ACTIVATION RECORD FOR PSOLSTEP;;;;;;;;;;;;;;;
    
; Pushing arguments onto the stack for PSOLSTEP_FUNCTION

    LDR R0, R5, #6  ; Loading the last argument (end_post) into R0 from the caller's activation record

    ADD R6, R6, #-1 ; Move the stack pointer down to make space for the argument
    STR R0, R6, #0 ; Push the value of end_post onto the stack
    
    LDR R0, R5, #5  
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    LDR R0, R5, #4  
    ADD R6, R6, #-1
    STR R0, R6, #0
    

    JSR PSOLSTEP_FUNCTION ; Calling the PSOLSTEP_FUNCTION with the arguments on the stack

    LDR R0, R6, #0
    ADD R6, R6, #1
    ; Pop all of our arguments from the stack  

    ADD R6, R6, #1
    ADD R6, R6, #1
    ADD R6, R6, #1
    
;;;;;;;Similar process to build another record for another call of MOVE_DISK_FUNCTION;;;;;;;

    AND R0, R0, #0
    LDR R0, R5, #5  
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    AND R0, R0, #0
    LDR R0, R5, #6  ;
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    AND R0, R0, #0
    LDR R0, R5, #7  
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    AND R0, R0, #0
    LDR R0, R5, #4  
    ADD R0, R0, #-1 
    ADD R6, R6, #-1
    STR R0, R6, #0
    

    JSR MOVEDISK_FUNCTION
    
    
    LDR R0, R6, #0
    ADD R6, R6, #1
    
    ;Poppping of all the values from our stack;;;;;
    ADD R6, R6, #1
    ADD R6, R6, #1
    ADD R6, R6, #1
    ADD R6, R6, #1
    
    BRnzp   MOVEDISK_END
    
MOVEDISK_BASE_CASE
;;;;;;;;;;;;ACTIVATION RECORD FOR PSOLSTEP;;;;;;;;;;;;;;;

    ;;Similar process for building the below record
    ;;Arguments from last tpo first
    ;; last one being end_post and the first one being number_of_disks again
    
    ;Last element
    LDR R0, R5, #6  
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    ;Second Last element
    LDR R0, R5, #5  
    ADD R6, R6, #-1
    STR R0, R6, #0
    
    ; tHIRD lAST ELEMENT
    ;;Default value as specified in the C function for disk number =1
    AND R0, R0, #0 ; clearing R0
    ADD R0, R0, #1 ; Storing the value as 1 for n

    ADD R6, R6, #-1
    STR R0, R6, #0
    

    JSR PSOLSTEP_FUNCTION ; PSOLSTEP_FUNCTION call 

    LDR R0, R6, #0
    ADD R6, R6, #1
    
;; Unwind the Stack    
    ADD R6, R6, #1
    ADD R6, R6, #1
    ADD R6, R6, #1
    
    BRnzp   MOVEDISK_END ;; Chabge PC and branch in any case to MOPVEDISK_END

MOVEDISK_END
    STR R0, R5, #3 ; Store the result R0 into the previous stack frame's return value slot

    ADD R6, R5, #1 
    LDR R5, R6, #0 ; Recover the caller's frame pointer from the stack pointer
    ADD R6, R6, #1 ; increment the stack pointer.
    ;; The stack pointer now points to the return address
    LDR R7, R6, #0 
    ADD R6, R6, #1 ;; Now the stack pointer points to the ret value 
    RET            ;; Return control to the caller function
    

PSOLSTEP_FUNCTION        
      ; Start of the PSOLSTEP_FUNCTION subroutine.    ;starts at an address labeled PSOLSTEP. It should take three parameters, 
    ;Functionality
    ;It should print, on a new line, the message:
    ;Move disk <disk_number> from post <start_post> to post <end_post>
    
    ;;;BUILDING ACTIVATION RECORD;;;

    ADD R6, R6, #-1  ; Decrease the stack pointer to reserve space for the return value.
    
    
    ADD R6, R6, #-1
    STR R7, R6, #0    ; r7 CONTAINS THE RFET ADD
    

    ADD R6, R6, #-1   ; Decrement the stack pointer to store the dynamic link.
    STR R5, R6, #0      ; Store the dynamic link in memory.


    ADD R5, R6, #-1 ; Set the frame pointer to the dynamic link.

    
    ;; Again no LC variables in any of the recursive calls so wont have to worry bout them
    
    ;;;;;;;;;;;;;;IMPLEMENTING THE SUBROUTINE FUNCTIONALITY;;;;;;;;;

    ; Load the prompt for disk_number into R0 for printing.

    LEA R0, PSOLSTEP_1    
    PUTS                    ; tRAP X21 TO PRINT TO THE CONSOLE
    
    ; Load disk_number from the frame pointer and convert from binary to ASCII for printing.
    LDR R0, R5, #4          ; Load disk_number from the frame pointer.
    LD  R3, BINARY_TO_ASCII
    ADD R0, R0, R3  ; Convert disk_number to ASCII.
    OUT
    
    ; Load the prompt for start_post into R0 for printing.
    LEA R0, PSOLSTEP_2   
    PUTS                   
    
    LDR R0, R5, #5          ;Get start_post (at R5 + #5) using a frame pointer reference into R0 or printing
    LD  R3, BINARY_TO_ASCII
    ADD R0, R0, R3
    OUT
    
        ; Load the prompt for end_post into R0 for printing.

    LEA R0, PSOLSTEP_3    
    PUTS                    
    ; retriev the strat post using the FP and then convert teh same to ASCII to be displayed on the console 
    
    LDR R0, R5, #6      
    LD  R3, BINARY_TO_ASCII
    ADD R0, R0, R3
    OUT
    
    ; Putting back the return value
    ;; All steps similar as in the prev activation record
    STR R0, R5, #3 
    ADD R6, R5, #1 
    LDR R5, R6, #0 
    ADD R6, R6, #1 
    LDR R7, R6, #0 
    ADD R6, R6, #1 
    RET 
    
PSOLSTEP_1            .STRINGZ    "Move the disk "
PSOLSTEP_2            .STRINGZ    " from post: "
PSOLSTEP_3            .STRINGZ    " to post: "
ASCII_TO_BINARY   .FILL x-30
BINARY_TO_ASCII    .FILL x30

.END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;My Approach and the STACK Diagram;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MOve DIsk Stack

                            ;;Local Vars(None in our case)
                            ;;Local Vars
;R5->                       ;;Local Vars
;R6->    Dynamic Link      ;;Bookeeping
;        ret Address     ;;Bookeeping
;        ret Val     ;;Bookeeping
;    n(disk number)     ;; Arguments
;    1(Start Post)     ;; Arguments
;    3(End POst)    ;; Arguments
;    2(Mid POst)       ;; Arguments
;    Main Local Variables
;x5000    



;; PsolStep Activation Record

                            ;;Local Vars(None in our case)
                            ;;Local Vars
;R5->                       ;;Local Vars
;R6->    Dynamic Link      ;;Bookeeping
;        ret Address     ;;Bookeeping
;        ret Val     ;;Bookeeping
;    n(disk number)     ;; Arguments
;    (Start Post)     ;; Arguments
;    (End POst)    ;; Arguments
;x5000    



;;Approach;;

;;Carry out BASIC main functionality
        ;;base Case:
        ;;Push Values
        ;;Pop Values
        ;;Pop Dynamic link
        ;;Stack pointer to ret add
        ;;pop R7
        ;;Stack pointer to retVal
            ;;;;;;;RET;;;;;;;;
            
;;Recursion;;
    ;;Start building the Activayion Record
    ;;call the function
    ;; Pop off teh retVal off the stack
    
;; Stack in memory (Verified by stepping through the code) at address x5000, like specified in canvas

;dynamic link x4FF8    
;retAdd x4FF9    27708
;retVal x4FFA    52157
;args            3
;args            1
;args            3
;args            2 
;local x4FFF     3
