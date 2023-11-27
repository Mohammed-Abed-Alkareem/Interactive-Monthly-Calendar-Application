# Interactive-Monthly-Calendar-Application
MIPS code for viewing, editing, and managing appointments within a monthly calendar


# Summary
The objective of this assignment is to write a MIPS code for viewing, editing, and managing appointments within a monthly calendar. The application should provide users with a user-friendly interface to interact with the calendar functionality, allowing them to add, edit, and view appointments for specific dates.
for Computer Architecture Course

# Specifications
### Calendar Format:
The calendar will be stored in text file with the following format:
1. Each line represents a day
2. The line starts with an index indication the day in the month
3. The working day start from 8AM to 5PM.
4. There are three types of an appointments: Lectures (L), Office Hours (OH), Meetings (M)
5. To reserve a slot, provide the start and the end time with the type of appointments separated by a comma. For example, the following line have the following appointments:
11: 8-9 L, 10-12 OH, 12-2 M
From 8 to 9 there is a lecture, from 10 to 12 reserved for an office hour, and from 12-2 for meeting. The other slots are free.
### Functionality:
The program will provide the following functionality:
1. View the calendar: the program will let the user view the calendar per day or per set of days or for a given slot in a given day.
2. View Statistics: number of lectures (in hours), number of OH (in hours), and the number of Meetings (in hour). In addition, the program will show the average lectures per day and the ratio between total number of hours reserved for lectures and the total number of hours reserved OH.
3. Add a new appointment: the user will provide the required information: day number, slot, and type. The program will check if there is a conflict with the existing appointments.
4. Delete an appointment: the user will provide the required information: day number, slot, and type. If there are two slots of the same type, the program will delete the first one.

# Authors

### Mohammed Abed Alkareem

