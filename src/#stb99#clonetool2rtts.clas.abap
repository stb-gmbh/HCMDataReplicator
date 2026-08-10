CLASS /stb99/clonetool2rtts DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_component,
        level     TYPE i,
        path      TYPE string,
        name      TYPE string,
        typekind  TYPE c LENGTH 1,
        length    TYPE i,
        decimals  TYPE i,
      END OF ty_component,

      tt_components TYPE STANDARD TABLE OF ty_component
                    WITH DEFAULT KEY.

    "Strukturbeschreibung einer internen Tabelle erzeugen
    CLASS-METHODS describe_table
      IMPORTING
        it_table       TYPE ANY TABLE
      RETURNING
        VALUE(rt_desc) TYPE tt_components.

    "Strukturbeschreibung einer Struktur erzeugen
    CLASS-METHODS describe_structure
      IMPORTING
        io_struct      TYPE REF TO cl_abap_structdescr
      RETURNING
        VALUE(rt_desc) TYPE tt_components.

    "Struktur aus übertragener Beschreibung rekonstruieren
    CLASS-METHODS create_structure
      IMPORTING
        it_desc          TYPE tt_components
      RETURNING
        VALUE(ro_struct) TYPE REF TO cl_abap_structdescr.

    "Tabellentyp aus übertragener Beschreibung rekonstruieren
    CLASS-METHODS create_table
      IMPORTING
        it_desc         TYPE tt_components
      RETURNING
        VALUE(ro_table) TYPE REF TO cl_abap_tabledescr.


  PRIVATE SECTION.

    "Rekursives Zerlegen einer Struktur
    CLASS-METHODS describe_recursive
      IMPORTING
        io_struct TYPE REF TO cl_abap_structdescr
        iv_level  TYPE i
        iv_path   TYPE string
      CHANGING
        ct_desc   TYPE tt_components.

    "Rekursives Wiederaufbauen einer Struktur
    CLASS-METHODS create_structure_recursive
      IMPORTING
        it_desc          TYPE tt_components
        iv_level         TYPE i
        iv_path          TYPE string
      RETURNING
        VALUE(ro_struct) TYPE REF TO cl_abap_structdescr.

    "Elementaren Datentyp erzeugen
    CLASS-METHODS create_element
      IMPORTING
        is_desc        TYPE ty_component
      RETURNING
        VALUE(ro_elem) TYPE REF TO cl_abap_datadescr.

ENDCLASS.



CLASS /STB99/CLONETOOL2RTTS IMPLEMENTATION.


  METHOD create_element.

    DATA:
      lo_element TYPE REF TO cl_abap_elemdescr.

    CASE is_desc-typekind.


      "--------------------------------------------------------
      "CHAR
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_char.

        lo_element =
          cl_abap_elemdescr=>get_c(
            p_length = is_desc-length ).


      "--------------------------------------------------------
      "NUMC
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_num.

        lo_element =
          cl_abap_elemdescr=>get_n(
            p_length = is_desc-length ).


      "--------------------------------------------------------
      "DATS
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_date.

        lo_element =
          cl_abap_elemdescr=>get_d( ).


      "--------------------------------------------------------
      "TIMS
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_time.

        lo_element =
          cl_abap_elemdescr=>get_t( ).


      "--------------------------------------------------------
      "INT4
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_int.

        lo_element =
          cl_abap_elemdescr=>get_i( ).


      "--------------------------------------------------------
      "INT1
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_int1.

        lo_element =
          cl_abap_elemdescr=>get_int1( ).


      "--------------------------------------------------------
      "INT2
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_int2.

        lo_element =
          cl_abap_elemdescr=>get_int2( ).


      "--------------------------------------------------------
      "INT8
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_int8.

        lo_element =
          cl_abap_elemdescr=>get_int8( ).


      "--------------------------------------------------------
      "PACKED / DEC
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_packed.

        lo_element =
          cl_abap_elemdescr=>get_p(
            p_length   = is_desc-length
            p_decimals = is_desc-decimals ).


      "--------------------------------------------------------
      "FLOAT
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_float.

        lo_element =
          cl_abap_elemdescr=>get_f( ).


      "--------------------------------------------------------
      "RAW / X
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_hex.

        lo_element =
          cl_abap_elemdescr=>get_x(
            p_length = is_desc-length ).


      "--------------------------------------------------------
      "STRING
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_string.

        lo_element =
          cl_abap_elemdescr=>get_string( ).


      "--------------------------------------------------------
      "XSTRING
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_xstring.

        lo_element =
          cl_abap_elemdescr=>get_xstring( ).


      WHEN OTHERS.

        RAISE EXCEPTION TYPE cx_sy_create_data_error.

    ENDCASE.

    ro_elem = lo_element.

  ENDMETHOD.


  METHOD create_structure.

    ro_struct =
      create_structure_recursive(
        it_desc  = it_desc
        iv_level = 1
        iv_path  = '' ).

  ENDMETHOD.


  METHOD create_structure_recursive.

    DATA:
      lt_components TYPE cl_abap_structdescr=>component_table,
      ls_component  LIKE LINE OF lt_components,
      ls_desc       TYPE ty_component,
      lo_substruct  TYPE REF TO cl_abap_structdescr,
      lo_element    TYPE REF TO cl_abap_datadescr,
      lv_subpath    TYPE string.

    CLEAR lt_components.

    LOOP AT it_desc INTO ls_desc
      WHERE level = iv_level
        AND path  = iv_path.

      CLEAR:
        ls_component,
        lv_subpath.

      ls_component-name = ls_desc-name.


      "--------------------------------------------------------
      "Komponente ist wiederum eine Struktur
      "--------------------------------------------------------
      IF ls_desc-typekind =
           cl_abap_typedescr=>typekind_struct1
      OR ls_desc-typekind =
           cl_abap_typedescr=>typekind_struct2.

        IF iv_path IS INITIAL.

          lv_subpath = ls_desc-name.

        ELSE.

          CONCATENATE
            iv_path
            ls_desc-name
            INTO lv_subpath
            SEPARATED BY '.'.

        ENDIF.

        lo_substruct =
          create_structure_recursive(
            it_desc  = it_desc
            iv_level = iv_level + 1
            iv_path  = lv_subpath ).

        ls_component-type = lo_substruct.


      ELSE.

        "------------------------------------------------------
        "Elementares Feld
        "------------------------------------------------------
        lo_element =
          create_element(
            is_desc = ls_desc ).

        ls_component-type = lo_element.

      ENDIF.

      APPEND ls_component TO lt_components.

    ENDLOOP.


    ro_struct =
      cl_abap_structdescr=>create(
        p_components = lt_components ).

  ENDMETHOD.


  METHOD create_table.

    DATA:
      lo_struct TYPE REF TO cl_abap_structdescr.

    lo_struct =
      create_structure(
        it_desc = it_desc ).

    ro_table =
      cl_abap_tabledescr=>create(
        p_line_type = lo_struct ).

  ENDMETHOD.


  METHOD describe_recursive.

    DATA:
      lt_components TYPE cl_abap_structdescr=>component_table,
      ls_component  LIKE LINE OF lt_components,
      ls_desc       TYPE ty_component,
      lo_substruct  TYPE REF TO cl_abap_structdescr,
      lv_path       TYPE string.

    lt_components =
      io_struct->get_components( ).

    LOOP AT lt_components INTO ls_component.

      CLEAR:
        ls_desc,
        lv_path.

      ls_desc-level     = iv_level.
      ls_desc-path      = iv_path.
      ls_desc-name      = ls_component-name.
      ls_desc-typekind  = ls_component-type->type_kind.
      ls_desc-length    = ls_component-type->length.
      ls_desc-decimals  = ls_component-type->decimals.

      APPEND ls_desc TO ct_desc.


      "--------------------------------------------------------
      "Komponente ist selbst wieder eine Struktur
      "--------------------------------------------------------
      IF ls_component-type->type_kind =
           cl_abap_typedescr=>typekind_struct1
      OR ls_component-type->type_kind =
           cl_abap_typedescr=>typekind_struct2.

        lo_substruct ?= ls_component-type.

        IF iv_path IS INITIAL.

          lv_path = ls_component-name.

        ELSE.

          CONCATENATE
            iv_path
            ls_component-name
            INTO lv_path
            SEPARATED BY '.'.

        ENDIF.

        describe_recursive(
          EXPORTING
            io_struct = lo_substruct
            iv_level  = iv_level + 1
            iv_path   = lv_path
          CHANGING
            ct_desc   = ct_desc ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD describe_structure.

    CLEAR rt_desc.

    describe_recursive(
      EXPORTING
        io_struct = io_struct
        iv_level  = 1
        iv_path   = ''
      CHANGING
        ct_desc   = rt_desc ).

  ENDMETHOD.


  METHOD describe_table.

    DATA:
      lo_type   TYPE REF TO cl_abap_typedescr,
      lo_table  TYPE REF TO cl_abap_tabledescr,
      lo_struct TYPE REF TO cl_abap_structdescr.

    lo_type =
      cl_abap_typedescr=>describe_by_data( it_table ).

    lo_table ?= lo_type.

    lo_struct ?=
      lo_table->get_table_line_type( ).

    rt_desc =
      describe_structure(
        io_struct = lo_struct ).

  ENDMETHOD.
ENDCLASS.
