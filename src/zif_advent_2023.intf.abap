INTERFACE zif_advent_2023
  PUBLIC .

  TYPES ty_input_table TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  METHODS solve
    IMPORTING
      input          TYPE string
    EXPORTING
      result_part_1  TYPE string
      result_part_2  TYPE string
      runtime_part_1 TYPE tzntstmpl
      runtime_part_2 TYPE tzntstmpl
      runtime_total  TYPE tzntstmpl.

  METHODS part_1
    IMPORTING
      input         TYPE ty_input_table
    RETURNING
      VALUE(result) TYPE string.

  METHODS part_2
    IMPORTING
      input         TYPE ty_input_table
    RETURNING
      VALUE(result) TYPE string.

ENDINTERFACE.
