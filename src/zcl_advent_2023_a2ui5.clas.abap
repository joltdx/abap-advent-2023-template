CLASS zcl_advent_2023_a2ui5 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_aoc_day,
        day            TYPE i,
        input          TYPE string,
        completed      TYPE abap_bool,
        day_title      TYPE string,
        class_name     TYPE string,
        result_part_1  TYPE string,
        result_part_2  TYPE string,
        runtime_part_1 TYPE tzntstmpl,
        runtime_part_2 TYPE tzntstmpl,
        runtime_total  TYPE tzntstmpl,
        solution_run   TYPE abap_bool,
      END OF ty_aoc_day.

    DATA aoc_day TYPE ty_aoc_day.
    DATA app_is_initialized TYPE abap_bool.
    DATA form_visible TYPE abap_bool.

    TYPES:
      BEGIN OF ty_day_tile_data,
        day       TYPE string,
        random    TYPE i,
        completed TYPE abap_bool,
      END OF ty_day_tile_data.

    DATA day_tile_data TYPE STANDARD TABLE OF ty_day_tile_data WITH EMPTY KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF event_id,
        solve           TYPE string VALUE 'SOLVE',
        tile_pressed    TYPE string VALUE 'TILE_PRESSED',
        toggle_complete TYPE string VALUE 'TOGGLE_COMPLETE',
      END OF event_id.

    DATA client TYPE REF TO z2ui5_if_client .

    METHODS initialize_app
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS handle_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS set_completed_flag
      IMPORTING
        day    TYPE i
        status TYPE abap_bool.

ENDCLASS.



CLASS zcl_advent_2023_a2ui5 IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF app_is_initialized = abap_false.
      DATA(page) = initialize_app( ).
      client->view_display( page->stringify( ) ).

      app_is_initialized = abap_true.

    ELSE.
      handle_event( client ).

      client->view_model_update( ).

    ENDIF.

  ENDMETHOD.

  METHOD handle_event.

    CASE client->get( )-event.
      WHEN event_id-tile_pressed.
        DATA(event_arguments) = client->get( )-t_event_arg.
        DATA(pressed_tile) = VALUE #( event_arguments[ 1 ] OPTIONAL ).

        DATA(existing_day_data) = NEW zcl_advent_2023_dao( )->load_day_data( CONV #( pressed_tile ) ).

        aoc_day = VALUE #( day        = existing_day_data-day
                           input      = existing_day_data-input
                           completed  = existing_day_data-completed
                           day_title  = |{ existing_day_data-day } December|
                           class_name = |ZCL_ADVENT_2023_{ aoc_day-day WIDTH = 2 PAD = '0' ALIGN = RIGHT }| ).

        form_visible = abap_true.

      WHEN event_id-solve.
        TRY.
            DATA day_instance TYPE REF TO zif_advent_2023.
            CREATE OBJECT day_instance TYPE (aoc_day-class_name).

            NEW zcl_advent_2023_dao( )->store_day_data( CORRESPONDING #( aoc_day ) ).

            day_instance->solve( EXPORTING input          = aoc_day-input
                                 IMPORTING result_part_1  = aoc_day-result_part_1
                                           result_part_2  = aoc_day-result_part_2
                                           runtime_part_1 = aoc_day-runtime_part_1
                                           runtime_part_2 = aoc_day-runtime_part_2
                                           runtime_total  = aoc_day-runtime_total ).
            aoc_day-solution_run = abap_true.

          CATCH cx_root INTO DATA(lcx_root).
            lcx_root->get_text( ).
            client->message_box_display( text = lcx_root->get_text( )
                                         type = 'error' ).
        ENDTRY.

      WHEN event_id-toggle_complete.
        aoc_day-completed = xsdbool( aoc_day-completed = abap_false ).
        NEW zcl_advent_2023_dao( )->store_day_data( CORRESPONDING #( aoc_day ) ).

        set_completed_flag( day    = aoc_day-day
                            status = aoc_day-completed ).

    ENDCASE.

  ENDMETHOD.

  METHOD initialize_app.


    DATA(all_days_data) = NEW zcl_advent_2023_dao( )->load_all_days_data( ).

    " Random placement of the tiles
    DATA(random) = cl_abap_random_int=>create( seed = CONV i( sy-uzeit )
                                               min  = 1
                                               max  = cl_abap_math=>max_int4 ).

    DO 25 TIMES.
      DATA(this_day_data) = VALUE ty_day_tile_data( day       = sy-index
                                                    random    = random->get_next( )
                                                    completed = VALUE #( all_days_data[ day = sy-index ]-completed OPTIONAL ) ).

      INSERT this_day_data INTO TABLE day_tile_data.

    ENDDO.
    SORT day_tile_data BY random.

    aoc_day-day_title = 'Find the tile for the day... :)'.

    DATA(view) = z2ui5_cl_xml_view=>factory( client ).

    DATA(page) = view->shell(
                         )->page(
                              id = 'page'
                              title = 'ABAP Advent of Code 2023'
                            ).

    DATA(top_hbox) = page->hbox(
                             width = '100%'
                             aligncontent = 'SpaceBetween'
                           ).

    DATA(panel) = top_hbox->hbox(
                              width = '48%'
                              class = 'sapUiTinyMarginEnd sapUiTinyMarginTop'
                            )->panel(
                                 expandable = abap_false
                                 expanded   = abap_true
                                 headertext = 'December 2023'
                               ).

    LOOP AT day_tile_data ASSIGNING FIELD-SYMBOL(<day>).
      DATA(tabix) = sy-tabix.
      DATA(day) = <day>-day.

      panel->generic_tile(
               class     = 'sapUiTinyMarginBegin sapUiTinyMarginTop'
               press     = client->_event( val   = event_id-tile_pressed
                                           t_arg = VALUE #( ( day ) ) )
               frametype = 'OneByHalf'
               header    = '{= $' && client->_bind_edit( val = <day>-completed tab = day_tile_data tab_index = tabix ) && ' ? "Completed" : "" }'
             )->get(
                )->tile_content(
                   )->get(
                      )->numeric_content(
                           value = day
                         ).

    ENDLOOP.

    panel = top_hbox->hbox(
                        width = '52%'
                        class = 'sapUiTinyMarginTop'
                      )->panel(
                           expandable = abap_false
                           expanded   = abap_true
                           headertext = client->_bind( val = aoc_day-day_title ) ).

    panel->simple_form(
             layout      = 'ResponsiveGridLayout'
             editable    = abap_true
             labelspans  = '12'
             labelspanm  = '12'
             labelspanl  = '12'
             labelspanxl = '12'
             visible     = client->_bind( val = form_visible )
           )->label(
                text      = 'Input'
                design    = 'Bold'
                showcolon = abap_true
           )->text_area(
                value = client->_bind_edit( val = aoc_day-input )
                rows  = '20'
                cols  = '80'
           )->label(
           )->hbox(
                width          = '100%'
                justifycontent = 'SpaceBetween'
                wrap           = 'Wrap'
             )->hbox(
                  wrap           = 'Wrap'
               )->button(
                    text  = 'Run'
                    type  = 'Emphasized'
                    press = client->_event( val = event_id-solve )
                    class = 'sapUiTinyMarginEnd'
                    width = '100px'
               )->button(
                    text    = 'Completed'
                    type    = '{= $' && client->_bind( aoc_day-completed ) && ' ? "Success" : "Default"}'
                    enabled = client->_bind( val = aoc_day-solution_run )
                    press   = client->_event( val = event_id-toggle_complete )
                    width   = '150px'
               )->get_parent(
             )->text(
                  text      = '{= "Total runtime: " + $' && client->_bind( aoc_day-runtime_total ) && ' + " s"}'
                  textalign = 'End'
                  width     = '200px'
             )->get_parent(
           )->label(
                text      = 'Result part 1'
                design    = 'Bold'
                showcolon = abap_true
           )->hbox(
                width          = '100%'
                justifycontent = 'SpaceBetween'
                wrap           = 'Wrap'
             )->input(
                  value    = client->_bind( val = aoc_day-result_part_1 )
                  editable = abap_false
                  width    = '360px'
             )->text(
                  text      = '{= $' && client->_bind( aoc_day-runtime_part_1 ) && ' + " s"}'
                  textalign = 'End'
                  width     = '200px'
             )->get_parent(
           )->label(
                text      = 'Result part 2'
                design    = 'Bold'
                showcolon = abap_true
           )->hbox(
                width          = '100%'
                justifycontent = 'SpaceBetween'
                wrap           = 'Wrap'
             )->input(
                  value    = client->_bind( val = aoc_day-result_part_2 )
                  editable = abap_false
                  width    = '360px'
             )->text(
                  text      = '{= $' && client->_bind( aoc_day-runtime_part_2 ) && ' + " s"}'
                  textalign = 'End'
                  width     = '200px'
             )->get_parent(
           )->label(
                text      = 'Useful links'
                design    = 'Bold'
                showcolon = abap_true
           )->vbox(
             )->link(
                  text   = 'adventofcode.com'
                  href   = 'https://adventofcode.com'
                  target = '_blank'
             )->link(
                  text   = 'This days puzzle'
                  href   = '{= "https://adventofcode.com/2023/day/" + $' && client->_bind( aoc_day-day ) && '}'
                  target = '_blank'
             )->link(
                  text   = 'This days puzzle input'
                  href   = '{= "https://adventofcode.com/2023/day/" + $' && client->_bind( aoc_day-day ) && ' + "/input" }'
                  target = '_blank'
             )->link(
                  text   = '{= "Display " + $' && client->_bind( aoc_day-class_name ) && '}'
                  href   = '{= "/sap/bc/adt/oo/classes/" + $' && client->_bind( aoc_day-class_name ) && ' + "/source/main" }'
                  target = '_blank'
             )->link(
                  text   = 'regex101.com'
                  href   = 'https://regex101.com/'
                  target = '_blank'
           ).

    result = page.

  ENDMETHOD.


  METHOD set_completed_flag.

    TRY.
        day_tile_data[ day = day ]-completed = status.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
