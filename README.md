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
![Linked List](list.png)


