CLASS zcl_advent_2023_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_day_data,
        day       TYPE i,
        input     TYPE string,
        completed TYPE boolean,
      END OF ty_day_data.

    TYPES ty_day_data_tt TYPE STANDARD TABLE OF ty_day_data WITH EMPTY KEY.

    METHODS load_day_data
      IMPORTING
        day           TYPE i
      RETURNING
        VALUE(result) TYPE ty_day_data.

    METHODS load_all_days_data
      RETURNING
        VALUE(result) TYPE ty_day_data_tt.


    METHODS store_day_data
      IMPORTING
        day_data TYPE ty_day_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_advent_2023_dao IMPLEMENTATION.

  METHOD load_day_data.

    SELECT SINGLE
      FROM zadvent_2023
      FIELDS aoc_day AS day,
             aoc_input AS input,
             aoc_completed AS completed
      WHERE aoc_day = @day
      INTO CORRESPONDING FIELDS OF @result.

    IF sy-subrc <> 0.
      result-day = day.
    ENDIF.

  ENDMETHOD.

  METHOD store_day_data.

    DATA(advent_2023) = VALUE zadvent_2023( aoc_day       = day_data-day
                                            aoc_input     = day_data-input
                                            aoc_completed = day_data-completed ).

    MODIFY zadvent_2023
      FROM advent_2023.

    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD load_all_days_data.

    SELECT
      FROM zadvent_2023
      FIELDS aoc_day AS day,
             aoc_input AS input,
             aoc_completed AS completed
      INTO CORRESPONDING FIELDS OF TABLE @result.

  ENDMETHOD.

ENDCLASS.
