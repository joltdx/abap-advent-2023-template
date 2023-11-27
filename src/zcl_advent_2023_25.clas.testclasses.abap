CLASS ltcl_test DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zif_advent_2023.

    METHODS setup.
    METHODS part_1 FOR TESTING.
    METHODS part_2 FOR TESTING.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD setup.

    cut = NEW zcl_advent_2023_25( ).

  ENDMETHOD.

  METHOD part_1.

    DATA(part_1_result) = cut->part_1(
VALUE #(
( || )
( || )
( || )
( || )
( || )
( || )
( || )
( || )
) ).

    cl_abap_unit_assert=>assert_equals( act = part_1_result
                                        exp = |todo| ).

  ENDMETHOD.

  METHOD part_2.

    DATA(part_2_result) = cut->part_2(
VALUE #(
( || )
( || )
( || )
( || )
( || )
( || )
( || )
( || )
) ).

    cl_abap_unit_assert=>assert_equals( act = part_2_result
                                        exp = |todo| ).

  ENDMETHOD.

ENDCLASS.
