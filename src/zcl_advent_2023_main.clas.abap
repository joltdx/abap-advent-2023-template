CLASS zcl_advent_2023_main DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_advent_2023.

    ALIASES part_1 FOR zif_advent_2023~part_1.
    ALIASES part_2 FOR zif_advent_2023~part_2.
    ALIASES solve FOR zif_advent_2023~solve.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_advent_2023_main IMPLEMENTATION.

  METHOD zif_advent_2023~part_1.

    result = |please redefine in day class|.

  ENDMETHOD.

  METHOD zif_advent_2023~part_2.

    result = |please redefine in day class|.

  ENDMETHOD.

  METHOD zif_advent_2023~solve.

    DATA input_table TYPE zif_advent_2023~ty_input_table.
    DATA time_stamp_start TYPE timestampl.
    DATA time_stamp_part_1 TYPE timestampl.
    DATA time_stamp_part_2 TYPE timestampl.

    SPLIT input AT |\n| INTO TABLE input_table.

    GET TIME STAMP FIELD time_stamp_start.

    result_part_1 = zif_advent_2023~part_1( input_table ).

    GET TIME STAMP FIELD time_stamp_part_1.

    result_part_2 = zif_advent_2023~part_2( input_table ).

    GET TIME STAMP FIELD time_stamp_part_2.

    runtime_part_1 = cl_abap_tstmp=>subtract( tstmp1 = time_stamp_part_1
                                              tstmp2 = time_stamp_start ).

    runtime_part_2 = cl_abap_tstmp=>subtract( tstmp1 = time_stamp_part_2
                                              tstmp2 = time_stamp_part_1 ).

    runtime_total = cl_abap_tstmp=>subtract( tstmp1 = time_stamp_part_2
                                             tstmp2 = time_stamp_start ).

  ENDMETHOD.

ENDCLASS.
