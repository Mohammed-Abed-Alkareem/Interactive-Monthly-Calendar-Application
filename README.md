# Interactive Monthly Calendar Application (MIPS)

This MIPS assembly code is designed for viewing, editing, and managing appointments within a monthly calendar. The application provides a user-friendly interface to interact with the calendar functionality, allowing users to add, edit, and view appointments for specific dates.

## Summary
The objective of this assignment is to implement a MIPS code for managing appointments within a monthly calendar. This project was developed for a Computer Architecture Course.

## Specifications
### Calendar Format
- The calendar is stored in a text file with each line representing a day.
- Each line starts with an index indicating the day in the month.
- Working hours are from 8 AM to 5 PM.
- Three types of appointments: Lectures (L), Office Hours (OH), Meetings (M).
- To reserve a slot, provide the start and end time with the type of appointment separated by a comma.
- Example line with appointments:
    ```
    11: 8-9 L, 10-12 OH, 12-2 M
    ```

### Functionality
1. **View the Calendar:** View the calendar per day, per set of days, or for a given slot in a given day.
2. **View Statistics:** Display the number of lectures, OH, and Meetings in hours. Show the average lectures per day and the ratio between total lecture hours and total OH hours.
3. **Add a New Appointment:** Provide day number, slot, and type. Check for conflicts with existing appointments.
4. **Delete an Appointment:** Provide day number, slot, and type. If there are two slots of the same type, delete the first one.

## Implementation Details

### Loading Calendar
- Calendar data is read and parsed from a text file.
- Appointments for each day are stored in a linked list structured as:
    ```
    int day | int start time | int end time | char [2] type | pointer to next
    ```

### Save Data Process
- **Parsing Data:** Input data is parsed from a buffer, extracting day index, start time, end time, and appointment type.
- **Inserting into Linked List:** Parsed data is then inserted into the linked list using the following process:

    #### Insert Node at the End of the List
    - Memory is allocated for a new node.
    - The new node is inserted at the end of the linked list, updating pointers.
    - Day index, start time, end time, and appointment type are stored in the new node.
      ##### Example
Suppose we have the following two days in the text file:
 ```
02: 09-11 OH
13: 10-12 M, 02-04 L
 ```
This will be translated into the linked list structure as follows:

Linked List Structure:
![Linked List](/pic/linkedlist.png)

Note: Hours are converted to 24-hour format before being stored in the linked list.


### Viewing Appointments

#### View by Day or Set of Days

1. Users input day numbers or a set of days separated by commas (e.g., "2" or "3,7,14").
2. The program splits, parses, and stores the input in the stack.
3. The program then pops each day from the stack, searches the linked list, and prints the appointments for the specified day(s).
4. If a day is not within the month range, the program notifies the user.

#### View by Specific Slot

1. Users input a specific day, start time, and end time sequentially.
2. The program validates each input before proceeding to the next, ensuring accuracy and avoiding invalid entries.
3. The program first validates the day input, prompting the user until a valid day within the month is entered.
4. Then, it validates the start time input, continuously prompting until a valid value between 8 AM and 4 PM is provided.
5. Finally, the end time input is validated, ensuring a valid value between 9 AM and 5 PM.
6. Once all valid inputs are received, the program iterates through the linked list, checking for any appointments that intersect with the specified slot.
7. Appointments with intersections are printed, providing a clear overview of activities scheduled during the specified time slot.

### View Statistics

- **Total Lectures (L) Duration:**
  - Iterates through the linked list, counting the number of lecture appointments and summing their durations (end time - start time).

- **Total Office Hours (OH) Duration:**
  - Similar to lectures, iterates through the linked list, counting the number of office hour appointments and summing their durations.
  
- **Total Meetings Duration:**
  - Iterates through the linked list, counting the number of meeting appointments and summing their durations.
 
- **Average Lectures per Day:**
  - The program calculates the total number of days represented in the calendar file.
  - Calculates the average by dividing the total lecture hours by the number of days.
 
- **Ratio of Lecture Hours to Office Hour Hours:**
  - Calculates the ratio by dividing the total number of hours reserved for lectures by the total number of hours reserved for office hours.

These statistics provide valuable insights into the distribution and balance of different appointment types within the calendar.

