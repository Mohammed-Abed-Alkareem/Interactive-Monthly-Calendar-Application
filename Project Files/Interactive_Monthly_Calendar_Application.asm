.data

welcome: .asciiz "\nWelcome to my Interactive Monthly Calendar Application ^_^  \n\n"
thanks: .asciiz "\nThanks for using my Interactive Monthly Calendar Application ^_^ \n"
main_menu: .asciiz "\nPlease select an option:\n1. View calendar\n2. View statistics\n3. Add appointment\n4. Delete appointment\n5. Exit program\n"
inputf: .asciiz "Calendar.txt "	# filename for input
outputf: .asciiz "Calendar.txt "	# filename for output
failmsg : .asciiz "fail to open the file *_*\n"
sucsess_msg : .asciiz "success to open the file ^_^\n"	
invalid_choice: .asciiz "Invalid choice *_*.\n"
show_options: .asciiz "Please select an option:\n1. View the calendar per day or per set of days \n2.view the calendar for a given slot in a given day\n"
day_number_show: .asciiz "view the calendar of day(n or x,y,z,...,w): "
day_number_msg: .asciiz "\nEnter the day number (1-31): "
start_time_msg: .asciiz "\nEnter the start time (8am - 4pm): "
end_time_msg: .asciiz "\nEnter the end time (9am - 5pm): "
add_succes: .asciiz "\nthe appointment added successfully  ^_^ \n"    
conflict_msg:   .asciiz "\nError: Conflicting appointmen *_*\n"
appointment_in_day : .asciiz "==> Your appointment in day "
appointment_type_msg: .asciiz "\nEnter the appointment type (L, OH, M): "
num_of_lectures: .asciiz "\nNumber of Lectures (in hours) :  "
num_of_meetings: .asciiz "\nNumber of Meetings (in hours) :  "
num_of_officehoures: .asciiz "\nNumber of Office Houres (in hours) :  "
avg_of_lectures: .asciiz "\nAverage Lectures per day :  "
ratio: .asciiz "\nRatio between Total Lecture Hours and Total Office Hours:  "
appointment_deleted_msg: .asciiz "\nAppointment deleted successfully.^_^\n"
appointment_not_found_msg: .asciiz "\nAppointment not found.*_*\n"
invalid_date_msg: .asciiz  ": is not a valid date within the month  *_*\n\n"
saving_msg: .asciiz "Saving the Data from the input file ......\n"
saved_msg: .asciiz "\nThe Data Saved sucessfully ^_^ \n"
node_size:  .word  20   # Size of each node in bytes  | int day  | int start | int end | char[2]  type| ptr*
chosen_days: .space 64 #in case of typeng the 31 day seperated by commas
type_input: .space 3
buffer: .space 1024 #store file content in
out_buffer: .space 1024 #store data to save to file 

.text

main: 		#main function

	la $a0, welcome #Print welcome message
   	li $v0, 4
  	syscall
	
	#read and save data from file
	jal read_file
	
	la $a0, saving_msg #Print  message
   	li $v0, 4
  	syscall
	
	jal create_list	
	jal save_data
	
	la $a0, saved_msg #Print  message
   	li $v0, 4
  	syscall
			
	main_loop: #while(1)
	
   		la $a0, main_menu #Print menu
   		li $v0, 4
  		syscall

   		li $v0, 5 #scan user chioce as an integer
  		syscall

   		move $t0, $v0  # Save the input to $t0

   		#switch(choice)
  		beq $t0, 1, show_cal #case 1: View the calendar
  		beq $t0, 2, view_stat #case 2: View Statistics
   		beq $t0, 3, add_app #case 3: Add a new appointment
   		beq $t0, 4, delete_app #case 4: Delete an appointment
   		beq $t0, 5, exit #case 5: Exit
   			 
   		la $a0, invalid_choice #default : print invalid choice
   		li $v0, 4
  		syscall

   		j main_loop #braek 
			
		show_cal:  #case 1: View the calendar
		
			la $a0, show_options #Print option masseges
   			li $v0, 4
  			syscall
  			  
			li $v0, 5  #scan user chioce as an integer
  			syscall
  			  
  			move $t0, $v0  # Save the input to $t0
  			  
  			beq $t0, 1, show_by_day  #case 1: view the calendar per day or per set of days
  			beq $t0, 2, show_by_time  #case 2: View the calendar for a given slot in a given day.
  			  
  			j main_loop #default break
  			  
  			show_by_day:	
  			 	jal print_by_day	
  				 j main_loop	#break
	
			show_by_time:
				jal print_by_slot
  				j main_loop #break
			
		view_stat: #View Statistics
		
			jal calculate_statistics
			j main_loop #break
			
		add_app: #Add appointment
		
			jal get_info
			jal check_info
			
			jal save_to_buffer  #save to output buffer from heap
		jal store_to_file
		
			j main_loop #break
						
		delete_app:
		
			jal get_info
			jal find_prev_node
			
			#after find prev the address of the prev code will be in t0 but if t1 = Null then the node not found
			
			beqz $t1 not_found
			
			j found 
		
			not_found:
				
				la $a0, appointment_not_found_msg  #print message
   				li $v0, 4
  				syscall
  				
  				j main_loop #break
  			
			found:
				jal delete_node
				
				jal save_to_buffer  #save to output buffer from heap
				jal store_to_file
				
				la $a0, appointment_deleted_msg  #print message
   				li $v0, 4
  				syscall
		
				j main_loop #break												
			
		exit:
		
			la $a0, thanks #Print thanks message
   			li $v0, 4
  			syscall
  		
			li $v0 , 10	#return 0;
			syscall
			
#________________________________________________________________________________________________
#read From File			
			
read_file:		#function to open the file

	la $a0 , inputf  #address of null-terminated filename string
	li $a1 , 0 #read only
	li $a2 , 0 #ignored
	li $v0 , 13 #open file
	syscall
		
	blt $v0 , $zero , fail 
	j success
	
	fail: 	# if file descriptor  < 0 
		la $a0 , failmsg #print message
		li $v0 , 4
		syscall
			
		jr  $ra
	
	
	success: #else
		move $t0 , $v0  #save file descriptor in $t0
		
		la $a0 , sucsess_msg #print message
		li $v0 , 4
		syscall
	
		move $a0 , $t0  #File descriptor		
		la $a1, buffer	# address of input buffer
		li $a2, 1024	# maximum number of characters to read
		li $v0 , 14 # read from file
		syscall			
			
		 move $a0, $t0 #File descriptor      
  		 li $v0, 16   # close the file
  		 syscall
			
		jr $ra			
#________________________________________________________________________________________________			
			
create_list: #making empty List
	
  	li $a0, 20   # load size of the node structure
  	li $v0, 9    # syscall for memory allocation 
	syscall # the address of the new node is at $v0
   			 
   	move $s0 ,$v0 #set the address of the head in  $s0
   	move $s1 ,$v0 #set the address of the  last node (head) in  $s1
   			  
   	sw $zero, 16($s0)        # head -> next = NULL
   			  
   	jr  $ra
#________________________________________________________________________________________________

save_data: #extract the data from the readed data from the file 
   	
	la $t0 , buffer #load the address of the data that has been read from the file
	
   	move $t3 , $zero # register to store the day
   	move $t4 , $zero #register to store the start time
   	move $t5 , $zero #register to store the  end time
   	move $t6 , $zero #register to store the first char in the type
   	move $t7 , $zero #register to store the second char in the type
 
   	loop:	
   		lb $t1 , 0($t0) # load $t1 = buffer[i]
   			
   		beqz $t1, end_of_buffer #branch if the EOF reached
   		beq $t1 , ':', parse_start  #branch if the : reached (new strat time)
   			
   		parse_day:
   			sub	$t1, $t1, 48	# Convert character to digit
			mul	$t3, $t3, 10	# $v0 = sum * 10
			addu	$t3, $t3, $t1	# $v0 = sum * 10 + digit
			
			addiu	$t0, $t0, 1	# $t0 = address of next char
			lb $t1 , 0($t0) # load $t1 = buffer[i]
			
			j loop
			
		parse_start:
		
		 	beq $t1 , '\n', end_of_line
		 	beq $t1 , '\r', end_of_line
		 	beqz $t1 ,  end_of_buffer
		 
			addiu   $t0, $t0, 2      # # Skip the : and the space
   		 
   			 lb $t1, 0($t0)      # Load the first character of the start time
   			 
   			parse_start_digits:	
   
				sub $t1, $t1, 48	# Convert character to digit	
				mul $t4, $t4, 10      # $t4 = start time * 10
  				addu $t4, $t4, $t1     # $t4 = start time * 10 + digit
  		  
  		  		addiu $t0, $t0, 1	# $t0 = address of next char
				lb $t1 , 0($t0) # load $t1 = buffer[i]
			
				beq $t1 , '-' parse_end #branch if the - reached (new end time)
			
			j parse_start_digits
			
		parse_end:
		
			addiu   $t0, $t0, 1      # Move to the next character after -

   			 lb      $t1, 0($t0)      # Load the first character of the  end time	
		
			parse_end_digits:
	
				sub $t1, $t1, 48	# Convert character to digit	
				mul $t5, $t5, 10      # $t4 = start time * 10
  				addu $t5, $t5, $t1     # $t4 = start time * 10 + digit
  		  
  		  		addiu $t0, $t0, 1	# $t0 = address of next char
				lb $t1 , 0($t0) # load $t1 = buffer[i]
			
				beq $t1 , ' ' save_char  #branch if the '  ' reached (first char in the type)
			
			j parse_end_digits
   			
   		save_char:
   		
   			addiu   $t0, $t0, 1      # Move to the next character after  ' ' 
   			lb      $t1, 0($t0)      # Load the first character of the  type
   			
   			move $t6 , $t1 #save the first char in $t6
   			
   			addiu $t0, $t0, 1 # $t0 = address of next char
			lb $t1 , 0($t0) # load $t1 = buffer[i]
			
			 # if it was one leter (L / M) dont save the next char as the second char in the type
			beq $t1 , ',' one_latter
			beq $t1 , '\n' one_latter
			
			
			move $t7 , $t1
			
			addiu $t0, $t0, 1	# $t0 = address of next char
			lb $t1 , 0($t0) # load $t1 = buffer[i]
			
			j insert #all data for the node are ready in the registers so inser it in the linked list
			
			one_latter: #if the type is one letter so add ' ' in the next char from the type
				li $t7 , 32
			
   		insert:	#all the data for an appoitment are in the regesters so insert then in the list 
   		
   			sw $ra, 0($sp)  # Save $ra on the stack
			addiu $sp, $sp, -4  # Adjust the stack pointer
			jal insert_node
			 # Restore the return address
			addiu $sp, $sp, 4  # Adjust the stack pointer
			lw $ra, 0($sp)  # Restore $ra from the stack
   			
   			j parse_start #continueu to the next appoitment
   			
   		end_of_line:
   		
   			 bne $t1, '\r' no_r #haqndle the case of  there is \r  because some ti,es there is \r\n or just \n
   			addiu   $t0, $t0, 1      # Move to the next character after  \r
   			no_r:
   		
   			addiu   $t0, $t0, 1      # Move to the next character after  \n
   			move $t3 , $zero #this is an indication that new day starts
   			 j loop
   			  
   		 end_of_buffer:	  		  
	 		jr $ra #all data are saved
#________________________________________________________________________________________________	 		
	 			
#insert node at the end of the linked list  the address of the last node is saved at $s1
#the day at $t3		
#the start time at $t4	
#the end time at $t5	
#the first char at $t6
#the second char at $t7
	 		
insert_node:
	# Allocate memory for the new node
  	li $a0, 20     # load size of the node structure
  	li $v0, 9             # syscall for memory allocation
   	syscall # the address of the new node is at $v0
   			 
   	sw $v0, 16($s1)        # store the address of the last node in the prev
   			 
   	move $s1 , $v0 #set the address of the  new last node  in  $s1
   	
   	
	sw $t3, 0($s1)        # store day
	
	bgt $t4 , 5 store_start  #convert time to 24 hour format
	addiu $t4 , $t4 , 12
	store_start:
    	sw $t4, 4($s1)        # store start time
    	
    	bgt $t5 , 5 store_end#convert time to 24 hour format
    	addiu $t5 , $t5 , 12 
    	store_end:
   	sw $t5, 8($s1)        # store end time
   	
   	sb $t6, 12($s1)       # store first characte
   	sb $t7, 13($s1)       # store second character	
   	sw $zero, 16($s1)        # store Null Pointer,  node -> next = NULL
   			
   	#reset the registers	
   	move $t4 , $zero #start time
   	move $t5 , $zero #start end						
	 		
	 jr	$ra
#________________________________________________________________________________________________		 		

	#read input from the user in the format : x,y,z,....,w   \   n     
	#extracting each day value and pushing it in the stack
	# when reaching \n begin popping from the stack and printing the appointments	
	 		
print_by_day:
	la $a0, day_number_show #print message
   	li $v0, 4
  	syscall 
  			  
  	la $a0 , chosen_days #address of input buffer
  	li $a1 , 62 #maximum number of characters to read	  
	li $v0, 8 #Read String
	syscall 
					 		
	la $t0 , chosen_days #load the address of the input text to $t0
	 
   	move $t3 , $zero #save day number in $t3
   			
   	move $t1 , $zero #day counter
   			
   	move $t2 , $zero #store the char from the input string (digit)
   			
   	next_day:	
   		lb $t2 , 0($t0) # load $t2 = buffer[i]
   		
       		beq $t2, '\n', end_of_input #branch if the \n reached (finish)
   		beq $t2 , ',', new_day  #branch if the : reached (new day)
   			
   		sub	$t2, $t2, 48	# Convert character to digit
		mul	$t3, $t3, 10	# $v0 = sum * 10
		addu	$t3, $t3, $t2	# $v0 = sum * 10 + digit
			
		addiu	$t0, $t0, 1	# $t0 = address of next char
			
	j next_day
					
	 new_day:
		 bgt $t3 , 31 ,  error_day #the day must be <= 31
		 blt $t3 , 1 ,  error_day #the day must be >= 1
  		
	 	sw $t3, 0($sp)  # Save day on the stack
		addiu $sp, $sp, -4  # Adjust the stack pointer
	
		 addiu $t1 , $t1 , 1	#day counter++ 		 		
	 		 		 		 		 		
		 move $t3 , $zero #day 	
		 addiu	$t0, $t0, 1	# $t0 = address of next char 		 		 		
	 j next_day	 		 		 		 		 		
	 		 		 		 		 		 		 		 		
	 end_of_input: #last day
	 
		bgt $t3 , 31 ,  error_day #the day must be <= 31
	 	blt $t3 , 1 ,  error_day #the day must be >= 1
	 	  
	 	sw $t3, 0($sp)  # Save day on the stack
		addiu $sp, $sp, -4  # Adjust the stack pointer
	 	addiu $t1 , $t1 , 1	#day counter++
	 	 	 
	 	 j extract	
	 	 	 	
	error_day:	 			
	 	 	  #the day must be between 1 - 31
  		  #else ignor it
  		move $a0 , $t3
   		li $v0, 1
  		syscall 
  		  
  		 la $a0, invalid_date_msg #print message
   		 li $v0, 4
  		 syscall
  		  
  		 beq $t2, '\n' ,extract
  		   
  		   move $t3 , $zero #day 	
	 	   addiu	$t0, $t0, 1	# $t0 = address of next char 
		j next_day 	 			 	 						 	 			 	 			
	 	 
	#finish parsing and saving in the stack	
	 	
	extract: # poping from the stack 
	 	  
		li $t8, 0         # i = 0
		
	 	loop_start:
   			bge $t8, $t1, loop_end  # Branch out of the loop if $t8 is greater than or equal to $t1 the day counter

			addiu $sp, $sp, 4  # Adjust the stack pointer
			lw $t3, 0($sp)  # Restore day from the stack
		
    			sw $ra, 0($sp)  # Save $ra on the stack
			addiu $sp, $sp, -4  # Adjust the stack pointer
			jal    print_list 
			 # Restore the return address
			addiu $sp, $sp, 4  # Adjust the stack pointer
			lw $ra, 0($sp)  # Restore $ra from the stack

  			  # Update: Increment $t8 by 1
   			 addi $t8, $t8, 1

    		j loop_start   # Jump back to the beginning of the loop

		loop_end: 
		 jr $ra		 		 		 		 		 		 		 		 		 		 		
#________________________________________________________________________________________________	
	
	 #print all nodes with same day that is stored in $t3
 print_list:

	la $a0, appointment_in_day  #print message
	li $v0, 4
	syscall 
  			  
	move $a0 , $t3  #load day number to $a0
	li $v0, 1 #Print Integer
	syscall 
  			  
	li $a0 , '\n'
	li $v0, 11 #Print char
	syscall 
  			  
	move $t0, $s0   # temp pointer. temp = head  	
	loop_ptr:
		lw $t0, 16($t0)   # temp pointer. temp = temp ->next
		beqz $t0 , exit_print
	 		
		lw $s3, 0($t0)  # Load day from the node
	 		
		bne $s3 , $t3 loop_ptr #if the day in the node does not equal the required day skip to the next node
			 
			 # Save the return address
		sw $ra, 0($sp)  # Save $ra on the stack
		addiu $sp, $sp, -4  # Adjust the stack pointer
		jal print_node
		# Restore the return address
		addiu $sp, $sp, 4  # Adjust the stack pointer
		lw $ra, 0($sp)  # Restore $ra from the stack
		
	j loop_ptr
	
	 exit_print:
		jr $ra		
#________________________________________________________________________________________________	 				
	#print node thats address in t0 in appropriate way

print_node:
	lw $a0, 0($t0)  # Load day from the node
  	li $v0, 1 #Print Integer
	syscall

	li $a0, ' '
	li $v0, 11 #Print char
	syscall
		
	li $a0, '|' 
	li $v0, 11 #Print char
	syscall
	
  	li $a0, ' '
   	li $v0, 11 #Print char
   	syscall
   	
   	lw $a0, 4($t0)  # Load start time from the node
  	ble $a0 , 12 print_start  #convert time to 12 hour format
	subiu $a0 , $a0 , 12
	print_start:
   	
    	li $v0, 1 #Print Integer
	syscall

  	li $a0, '-'
  	li $v0, 11 #Print char
  	syscall

 	lw $a0, 8($t0)  # Load end time from the node
  	ble $a0 , 12 print_end  #convert time to 12 hour format
	subiu $a0 , $a0 , 12
	print_end:
   	li $v0, 1 #Print Integer
  	syscall

 	li $a0, ' '
   	li $v0, 11 #Print char
   	syscall
   	
  	li $a0, '|'
  	li $v0, 11 #Print char
  	syscall
  	
  	li $a0, ' '
   	li $v0, 11 #Print char
   	syscall

 	lb $a0, 12($t0)  # Load char[0]
 	li $v0, 11 #Print char
  	syscall
    
   	lb $a0, 13($t0)  # Load char[1]
  	li $v0, 11 #Print char
   	syscall

	li $a0, '\n'
	li $v0, 11 #Print char
	syscall

    jr $ra
#________________________________________________________________________________________________	

	#get a valid day and start time and end time
	#iterate throu ech node  untill find a match node then print it			
 print_by_slot:
 
 	wrong_day:
		la $a0, day_number_msg #ask for the day
   		li $v0, 4
  		syscall
		
		li $v0, 5 #Read Integer
  		syscall
  			  
  		move $t3 ,$v0 # store the day in $t3
  		
  		#check if it is a day within the month if not ask again
  		blt $t3 , 1 ,   wrong_day 
  		bgt $t3 , 31 ,   wrong_day
		
	wrong_start_time:
		la $a0, start_time_msg #ask for the start time
   		li $v0, 4
  		syscall
		
		li $v0, 5 #Read Integer
  		syscall
  			  
  		move $t4 ,$v0 # store the start time in $t4
  		 bgt $t4 , 5 slot_start  #convert time to 24 hour format
		addiu $t4 , $t4 , 12
		slot_start:
  		
  		#check if it is a start tme  within the working day hours
  		blt $t4 , 8 ,  wrong_start_time
  		bgt $t4 , 16 , wrong_start_time
  		
  	wrong_end_time:  
  		la $a0, end_time_msg #ask for the end time
   		li $v0, 4
  		syscall
  			  
		li $v0, 5 #Read Integer
  		syscall
  			  
  		move $t5 ,$v0 # store the end time in $t5
  			 
  		bgt $t5 , 5 slot_end  #convert time to 24 hour format
	addiu $t5 , $t5 , 12
	slot_end: 
  			 
  		#check if it is an end tme  within the working day hours	 and after the start time   
  		blt $t5 , 9 ,    wrong_end_time 
  		bgt $t5 , 17 ,   wrong_end_time 
  		blt $t5 , $t4 ,   wrong_end_time
  		    		    
  #iterate and print
  move $t0, $s0   # temp pointer. temp = head  
	 		
	loop_ptr_slot:
	 	
		lw $t0, 16($t0)   # temp pointer. temp = temp ->next
		beqz $t0 , exit_print_slot  #iterate untill temp  -> next == Null
	 		
		lw $s3, 0($t0)  # Load day from the node
	 		
		bne $s3 , $t3 loop_ptr_slot	
			
			#to check if it is in the slot 	 
 		# Initialize i with the value of t4 the start time
		move $t1, $t4

		for_loop:
  			  # iterate untill reaching the end time
			bge $t1, $t5, end_for_loop
    
			lw $s4, 4($t0)  # Load end time from the node
 			lw $s5, 8($t0)  # Load end time from the node
   				
			#check if any hour between the start time and end time requiered are within the slot of the node
			beq $t1, $s4, print_slot
			beq $t1, $s5, print_slot

			# Increment i
			addi $t1, $t1, 1
    		j for_loop

	print_slot:
		sw $ra, 0($sp)  # Save $ra on the stack
		addiu $sp, $sp, -4  # Adjust the stack pointer
    
		jal print_node
		# Restore the return address
		addiu $sp, $sp, 4  # Adjust the stack pointer
		lw $ra, 0($sp)  # Restore $ra from the stack
    
    
		# Increment i
		addi $t1, $t1, 1
	j loop_ptr_slot

	end_for_loop:
		j loop_ptr_slot	 	    	    	    
  		    
 	exit_print_slot:
 		jr $ra
 
 #________________________________________________________________________________________________	
calculate_statistics:

	# Save the return address
	sw $ra, 0($sp)  # Save $ra on the stack
	addiu $sp, $sp, -4  # Adjust the stack pointer
    
	jal calculate_num_of_days # calculate how many days are in the linked list and store the rresult in $s6
	# Restore the return address
	addiu $sp, $sp, 4  # Adjust the stack pointer
	lw $ra, 0($sp)  # Restore $ra from the stack

	move $t0, $s0   # temp pointer. temp = head  
		 
	move $s2 , $zero #store houres of L
	move $s3 , $zero #store houres of M
	move $s4 , $zero #store houres of OH
		   
	 move $s5 , $zero #store total houres 
		    
	loop_ptr_calculate:
	 	
		lw $t0, 16($t0)   # temp pointer. temp = temp ->next
		beqz $t0 , print_reults #iterate on all the linked list
	 		
		lb $t6, 12($t0)  # Load char[0]
 			   
		beq $t6 , 'L' , is_lecture
		beq $t6 , 'M' , is_meeting
		beq $t6 , 'O' , is_officehour
  			    
		is_lecture:
			
			lw $t4, 4($t0)  # Load start time from the node
			lw $t5, 8($t0)  # Load end time from the node
			subu $t8 ,$t5 , $t4 #store number of hours = end - start in t8
				
			addu $s2 , $s2 , $t8 # total += hours
				
		j loop_ptr_calculate #continue to the next node
				
		is_meeting:
			
			lw $t4, 4($t0)  # Load start time from the node
			lw $t5, 8($t0)  # Load end time from the node
			subu $t8 ,$t5 , $t4 #store number of hours in t8
				
			addu $s3 , $s3 , $t8 # total += hours
				
		j loop_ptr_calculate #continue to the next node	
				
		is_officehour:
			
			lw $t4, 4($t0)  # Load start time from the node
			lw $t5, 8($t0)  # Load end time from the node
			subu $t8 ,$t5 , $t4 #stour nimber oh hours in t8
				
			addu $s4 , $s4 , $t8 # total += hours
				
			j loop_ptr_calculate #continue to the next node		

	print_reults:
		
		la $a0, num_of_lectures  #print message
		li $v0, 4
		syscall 
  			  
		move $a0 , $s2 #load number oof lectures in $a0
		li $v0, 1 #print integer
		syscall 
  			  
		li $a0 , '\n'
		li $v0, 11 #print char
		syscall 
	
		la $a0, num_of_meetings #print message
		li $v0, 4
		syscall 
  			  
		move $a0 , $s3 #load number of meetings in $a0
		li $v0, 1  #print integer
		syscall 
  			  
		li $a0 , '\n'
		li $v0, 11 #print char
		syscall 
  			  
  			  
		la $a0, num_of_officehoures #print message
		li $v0, 4
		syscall 
  			  
		move $a0 , $s4 #load number of office hours in $a0
		li $v0, 1 #print integer
		syscall 
  			  
		li $a0 , '\n'
		li $v0, 11 #print char
		syscall 
  			  
		la $a0, avg_of_lectures #print message
		li $v0, 4
		syscall   
  			
  			   #calculation of average of lectures   
		#convert int to float to make the float divisuion
		mtc1  $s2 , $f2
		mtc1  $s6 , $f6
  			 
		div.s $f12, $f2, $f6  # $f12 will hold the result
		li $v0, 2 #print float
		syscall 
  			  
		li $a0 , '\n'
		li $v0, 11 #print char
		syscall 
  			  
		la $a0, ratio #print message
		li $v0, 4
		syscall   
	 
			 #calculation of ratio
		#convert int to float to make the float divisuion
		mtc1  $s2 , $f2
		mtc1  $s4 , $f6
  			 
		div.s $f12, $f2, $f6  # $f12 will hold the result
		li $v0, 2 #print float
		syscall 
  			  
		li $a0 , '\n'
		li $v0, 11 #print char
		syscall 
	
	jr $ra

calculate_num_of_days:

	 # Initialize loop counter
	li $t2, 1  # $t0 is used as a loop counter that represent the days form 1 - 31
    
	move $s6 , $zero #store number of days
 
	loop_day:

 
		move $t0, $s0   # temp pointer = head
	 		
		loop_ptr_count:
			lw $t0, 16($t0)   # temp pointer. temp = temp -> next
			beqz $t0 , exit_count 
	 		
			lw $t3, 0($t0)  # Load day from the node
	 		 
			bne $t3 , $t2 , loop_ptr_count # if the day number exist in the list 
	 		 
			addiu $s6 , $s6 , 1 #increament the day counter
	 		  
			addi $t2, $t2, 1 # Increment lto the next day
	 		  j loop_day

		exit_count: #if reaching the end of the list and the day does not exists kepp on to the next day
			addi $t2, $t2, 1 # Increment loop counter
			 # Check loop condition
			ble $t2, 31, loop_day  # Branch to 'loop' intill day = 31
        
        			jr $ra
#________________________________________________________________________________________________	
#ask the user for the data to be added and check if it is acceptable
#store day in t3
#store start time in t4
#store end time in t5
#store first char in t6
#store second char in t7
get_info:
		ask_for_day:
			la $a0, day_number_msg #ask for the day
			li $v0, 4
			syscall
		
			li $v0, 5 #raed integer
  			syscall
  			  
  			move $t3 ,$v0	
  		
  			#check if it is a day within the month if not ask again
  		  	blt $t3 , 1 ,  ask_for_day
  		  	bgt $t3 , 31 ,  ask_for_day
		
		ask_for_start_time:
			la $a0, start_time_msg #ask for the start time
   			li $v0, 4
  			syscall
		
			li $v0, 5  #Read Integer
  			syscall
  			  
  			move $t4 ,$v0	  # store the start time in $t4
  			
  			bgt $t4 , 5 get_start  #convert time to 24 hour format
	addiu $t4 , $t4 , 12
	get_start:
  			
  			  
  		 	blt $t4 , 8 ,  ask_for_start_time
  		  	bgt $t4 , 16 , ask_for_start_time
  		
  		ask_for_end_time:  
  			la $a0, end_time_msg #ask for the end time
   			li $v0, 4
  			syscall
  			  
			li $v0, 5  #Read Integer
  			syscall
  			  
  			move $t5 ,$v0  # store the end time in $t5
  			
  			bgt $t5 , 5 get_end  #convert time to 24 hour format
			addiu $t5 , $t5 , 12
		get_end:
  			
  			  #check if it is an end tme  within the working day hours  and after the start time   
  		 	blt $t5 , 9 ,  ask_for_end_time
  		 	bgt $t5 , 17 , ask_for_end_time
  		    	ble $t5 , $t4 , ask_for_end_time	  
			
		  ask_for_app_type: 
		   
		  	la $a0, appointment_type_msg  #ask for the type
   			li $v0, 4
  			syscall
  			  
  			la $a0 , type_input 
  			li $a1 , 3	  
			li $v0, 8  #Read string
  			syscall
  			  
      			la $t0 , type_input #load the address of the data that has been read from the user
   		
   			lb   $t1, 0($t0)      # Load the first character of the  type
   
   			move $t6 , $t1 #save the first char in $t6
   			
   			#check if it is M or L or O atorwise it is wrong type so ask again to enter it
   			beq $t6 , 76 , accepted #if(char[0] == 'L')
   			beq $t6 , 77 , accepted #if(char[0] == 'M')
   			beq $t6 , 79 , accepted #if(char[0] == 'O')
   			 
   		j  ask_for_app_type
   			
   			accepted:	
   				addiu $t0, $t0, 1 # $t0 = address of next char
				lb $t1 , 0($t0) # load $t1 
			
				 # if it was one leter (L / M) dont save the next char as the second char in the type
				beq $t1 , '\n' one
			
				move $t7 , $t1
				bne $t7 , 72 , ask_for_app_type #if(char[1] != 'H')
	
				jr $ra
			
				one: #if the type is one letter so add ' ' in the next char from the type
					li $t7 , 32
				jr $ra
#________________________________________________________________________________________________	
# check if there is conflict or not
check_info:
	 move $t0, $s0   # temp pointer = head
	 		
	 loop_ptr_check:
	 	lw $t0, 16($t0)   # temp pointer. temp = temp -> next
	 	beqz $t0 , exit_check
	 		
	 	lw $s3, 0($t0)  # Load day from the node
	 		
		bne $s3 , $t3 loop_ptr_check #if it was from another day so continue to the next node
  
   		lw $s4, 4($t0)  # Load start time from the node
  
 		lw $s5, 8($t0)  # Load end time from the node
		
# First loop
# for(int i = s1; i < e1; i++) {
#     if(s2 == i)
#        there is conflict

   	 move $t8, $s4            # Initialize i to s1
   	 loop1:
       		 bge $t8, $s5, end_loop1  # Exit loop if i >= e1
       		 beq $t4, $t8, error   # Branch if s2 == i
       		 addi $t8, $t8, 1         # Increment i
        j loop1

    end_loop1:

# Second loop
# for(int i = s2; i < e2; i++) {
#     if(s1 == i)
#      there is conflict

    move $t8, $t4            # Initialize i to s2
    loop2:
        bge $t8, $t5,loop_ptr_check  # Exit loop if i >= e2
        beq $s4, $t8, error   # Branch if s1 == i
        addi $t8, $t8, 1         # Increment i
        j loop2


error:
 # Error message for conflict
        li $v0, 4               # System call code for print_str
        la $a0, conflict_msg    # Load address of the conflict message
        syscall
         jr $ra
 
exit_check:  #after reaching end of the list and there is no conflict
    
	# Save the return address
	sw $ra, 0($sp)  # Save $ra on the stack
	addiu $sp, $sp, -4  # Adjust the stack pointer
    
     	jal insert_node  #insert the new node
	# Restore the return address
	addiu $sp, $sp, 4  # Adjust the stack pointer
	lw $ra, 0($sp)  # Restore $ra from the stack

 	la $a0, add_succes #print message
	li $v0, 4 
	 syscall
     
      jr $ra
#________________________________________________________________________________________________
#find the prev node of the node that is going to be deleted
find_prev_node:
 	#t0 prev
 	#t1 node
	move $t1, $s0   # temp prev pointer = head t1	
	loop_ptr_find:
	 	
		move $t0 , $t1 #prev  = node 
		lw $t1, 16($t1)  #node = node -> next
	 		
		beqz $t1 , exit_find #if the node ==Null exit
	 		
		lw $s3, 0($t1)  # Load day from the node
	 		 
		bne $t3 , $s3 , loop_ptr_find  #check the day 
	 		 
		lw $s4, 4($t1)  # Load start from the node
	 		 
		bne $t4 , $s4 , loop_ptr_find
	 		 
		lw $s5, 8($t1)  # Load end from the node
	 		 
		bne $t5 , $s5 , loop_ptr_find
	 		 
		lw $s6, 12($t1)  # Load char[0] from the node
	 		 
		beq $t6 , 'L' , exit_find
		beq $t6 , 'M' , exit_find
		beq $t6 , 'O' , exit_find
	 		   
	j loop_ptr_find
		  	
	exit_find:

        		jr $ra
#________________________________________________________________________________________________

#the prev node of the node that will be deleted is in t0
#and the node address in t1
#t0 -> next = t1 ->next
delete_node:
	lw $t2 , 16 ($t1)
	sw $t2 , 16($t0)
	jr $ra
#________________________________________________________________________________________________


store_to_file:

la $a0 , outputf  #address of null-terminated filename string
	li $a1 , 1 #write only with create
	li $a2 , 0 #ignored
	li $v0 , 13 #open file
	syscall
		
	blt $v0 , $zero , out_fail 
	j out_success
	
	out_fail: 	# if file descriptor  < 0 
		la $a0 , failmsg #print message
		li $v0 , 4
		syscall
			
		jr  $ra
	
	out_success: #else
		move $t0 , $v0  #save file descriptor in $t0
	
		
		move $a0 , $t0  #File descriptor		
		la $a1,out_buffer	# address of output buffer
		move $a2, $t9	#  number of characters to write that were stored
		li $v0 , 15 # write to file
		syscall			
			
		 move $a0, $t0 #File descriptor      
  		 li $v0, 16   # close the file
  		 syscall
			
		jr $ra		
		
#________________________________________________________________________________________________		
save_to_buffer:

addiu $t9 , $zero , 0 #store 0 to count characters
addiu $t8 , $zero , 10 #store 10 in t8 to divid by it
# Initialize loop counter
li $t2, 1  # $t2 is used as a loop counter that represent the days form 1 - 31
    
loop_day_store:
	move $t0, $s0   # temp pointer = head
	 		
	loop_ptr_store:
		lw $t0, 16($t0)   # temp pointer. temp = temp -> next
		beqz $t0 , exit_store 
	 		
		lw $t3, 0($t0)  # Load day from the node
	 		 
		bne $t3 , $t2 , loop_ptr_store # if the day number exist in the list 
	 		 
		# store node in day 
		div $t3 , $t8 
		mfhi $s6 # load remainder ( first digit)
		mflo $s7 # load quotient ( tens digit)
			
		addiu $s6 , $s6 , 48 #convert to ascii
		addiu $s7 , $s7 , 48 #convert to ascii
			
		sb $s7 , out_buffer($t9)
		addiu $t9 , $t9 , 1 
			
		sb $s6 , out_buffer($t9)
		addiu $t9 , $t9 , 1
			
		addiu $s3 , $zero , ':' #store :
		sb  $s3 , out_buffer($t9)
		addiu $t9 , $t9 , 1
			
		addiu $s3 , $zero , ' ' #store space
		sb $s3 , out_buffer($t9)
		addiu $t9 , $t9 , 1
			
		j time_store #store the time slot and type
			
		same_day:
			addiu $s3 , $zero , ','
			sb $s3 , out_buffer($t9)
			addiu $t9 , $t9 , 1
			addiu $s3 , $zero , ' '
			sb $s3 , out_buffer($t9)
			addiu $t9 , $t9 , 1
			
		time_store:
			lw $t4, 4($t0)  # Load start time from the node
			ble  $t4 , 12 dont_convert_start
			sub $t4 ,$t4 ,12 #convert to 12 hour format
			
			dont_convert_start:
			div $t4 , $t8 
			mfhi $s6 # load remainder ( first digit)
			mflo $s7 # load quotient ( tens digit)
			
			addiu $s6 , $s6 , 48 #convert to ascii
			addiu $s7 , $s7 , 48 #convert to ascii
			
			sb $s7 , out_buffer($t9)
			addiu $t9 , $t9 , 1 
			
			sb $s6 , out_buffer($t9)
			addiu $t9 , $t9 , 1
			
			addiu $s3 , $zero , '-' # store - 
			sb $s3 , out_buffer($t9)
			addiu $t9 , $t9 , 1
			
 			lw $t5, 8($t0)  # Load end time from the node
 			ble  $t5 , 12 dont_convert_end
			sub $t5 ,$t5 ,12 #convert to 12 hour format
			
			dont_convert_end:
 			div $t5 , $t8 
			mfhi $s6 # load remainder ( first digit)
			mflo $s7 # load quotient ( tens digit)
			
			addiu $s6 , $s6 , 48 #convert to ascii
			addiu $s7 , $s7 , 48 #convert to ascii
			
			sb $s7 , out_buffer($t9)
			addiu $t9 , $t9 , 1 
			
			sb $s6 , out_buffer($t9)
			addiu $t9 , $t9 , 1
			
			addiu $s3 , $zero , ' ' #store space
			sb $s3 , out_buffer($t9)
			addiu $t9 , $t9 , 1
			
			lb $t6, 12($t0) #store the first letter of the type
			sb $t6 , out_buffer($t9) 
			addiu $t9 , $t9 , 1
			
			lb $t7, 13($t0)
			bne $t7 , 'H' ,next_node 
			sb $t7 , out_buffer($t9) #store the second letter of the type if it was H
			addiu $t9 , $t9 , 1
			
			next_node:
				lw $t0, 16($t0)   # temp pointer. temp = temp -> next
				beqz $t0 , day_end 
	 		
				lw $t5, 0($t0)  # Load day from the node
	 		 
				bne $t3 , $t5 , next_node # if the day number exist in the list 
				beq $t3 , $t5, same_day
			
	
		day_end:
			addiu $s3 , $zero , '\n' #add new line to store the next day
			sb $s3 , out_buffer($t9)
			addiu $t9 , $t9 , 1

		exit_store: #if reaching the end of the list and the day does not exists kepp on to the next day
		
			addi $t2, $t2, 1 # Increment loop counter
			 # Check loop condition
			ble $t2, 31, loop_day_store  # Branch to 'loop' intill day  <= 31
			jr $ra
