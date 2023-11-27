# abap-advent-2023-template
Template for Advent of Code 2023, in ABAP + abap2ui5

This repo will not contain my solutions, but is intended to store:
- The prepared "empty" solution classes, including
  - A method for each expected part
  - An inherited generic 'solve' method, splitting input string into table, calling each parts solution method, and measuring runtime
  - Prepared local test class with test methods for each part
- Frontend app built in ABAP using [ABAP2UI5](https://github.com/abap2UI5/abap2UI5) (separate installation required), featuring
  - Randomized tile layout for each day of the puzzle, like the paper advent calendars of old :)
  - Puzzle input
  - Running of the solution in backend
  - Completion toggling
  - Storing of input data and completion flag
  - Note: I made this for single user use, but it should be a quick thing to expand on it if needed...


Have fun!
