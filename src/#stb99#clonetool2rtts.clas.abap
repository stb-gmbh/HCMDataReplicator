CLASS /stb99/clonetool2rtts DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_component,
        name      TYPE fieldname,
        typekind  TYPE c LENGTH 1,
        length    TYPE i,
        decimals  TYPE i,
      END OF ty_component,

      tt_components TYPE STANDARD TABLE OF ty_component
                    WITH DEFAULT KEY.


    "----------------------------------------------------------
    " Tabellenstruktur beschreiben
    " INCLUDE-Strukturen werden aufgelöst
    "----------------------------------------------------------
    CLASS-METHODS describe_table
      IMPORTING
        it_table       TYPE ANY TABLE
      RETURNING
        VALUE(rt_desc) TYPE tt_components.


    "----------------------------------------------------------
    " Aus Beschreibung wieder einen flachen Tabellentyp erzeugen
    "----------------------------------------------------------
    CLASS-METHODS create_table
      IMPORTING
        it_desc         TYPE tt_components
      RETURNING
        VALUE(ro_table) TYPE REF TO cl_abap_tabledescr.


  PRIVATE SECTION.

    "----------------------------------------------------------
    " Elementaren ABAP-Typ erzeugen
    "----------------------------------------------------------
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
      " CHAR
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_char.

        lo_element =
          cl_abap_elemdescr=>get_c(
            p_length = is_desc-length ).


      "--------------------------------------------------------
      " NUMC
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_num.

        lo_element =
          cl_abap_elemdescr=>get_n(
            p_length = is_desc-length ).


      "--------------------------------------------------------
      " DATS
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_date.

        lo_element =
          cl_abap_elemdescr=>get_d( ).


      "--------------------------------------------------------
      " TIMS
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_time.

        lo_element =
          cl_abap_elemdescr=>get_t( ).


      "--------------------------------------------------------
      " INT4
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_int.

        lo_element =
          cl_abap_elemdescr=>get_i( ).


      "--------------------------------------------------------
      " INT1
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_int1.

        lo_element =
          cl_abap_elemdescr=>get_int1( ).


      "--------------------------------------------------------
      " INT2
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_int2.

        lo_element =
          cl_abap_elemdescr=>get_int2( ).


      "--------------------------------------------------------
      " INT8
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_int8.

        lo_element =
          cl_abap_elemdescr=>get_int8( ).


      "--------------------------------------------------------
      " PACKED
      "
      " Darunter fallen auf ABAP-Ebene typischerweise
      " DEC/CURR/QUAN-artige Felder.
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_packed.

        lo_element =
          cl_abap_elemdescr=>get_p(
            p_length   = is_desc-length
            p_decimals = is_desc-decimals ).


      "--------------------------------------------------------
      " FLOAT
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_float.

        lo_element =
          cl_abap_elemdescr=>get_f( ).


      "--------------------------------------------------------
      " RAW / X
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_hex.

        lo_element =
          cl_abap_elemdescr=>get_x(
            p_length = is_desc-length ).


      "--------------------------------------------------------
      " STRING
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_string.

        lo_element =
          cl_abap_elemdescr=>get_string( ).


      "--------------------------------------------------------
      " XSTRING
      "--------------------------------------------------------
      WHEN cl_abap_typedescr=>typekind_xstring.

        lo_element =
          cl_abap_elemdescr=>get_xstring( ).


      "--------------------------------------------------------
      " Typ wird bislang nicht unterstützt
      "--------------------------------------------------------
      WHEN OTHERS.

        RAISE EXCEPTION TYPE cx_sy_create_data_error.

    ENDCASE.


    ro_elem = lo_element.

  ENDMETHOD.


  METHOD create_table.

    DATA:
      lt_components TYPE cl_abap_structdescr=>component_table,
      ls_component  LIKE LINE OF lt_components,
      ls_desc       TYPE ty_component,
      lo_element    TYPE REF TO cl_abap_datadescr,
      lo_struct     TYPE REF TO cl_abap_structdescr.


    CLEAR lt_components.


    "----------------------------------------------------------
    " Komponenten aus der übertragenen Beschreibung erzeugen
    "----------------------------------------------------------
    LOOP AT it_desc INTO ls_desc.

      IF ls_desc-name IS INITIAL.
        CONTINUE.
      ENDIF.


      CLEAR ls_component.

      ls_component-name = ls_desc-name.


      "Elementaren Typ wieder erzeugen
      lo_element =
        create_element(
          is_desc = ls_desc ).


      ls_component-type = lo_element.

      APPEND ls_component TO lt_components.

    ENDLOOP.


    "----------------------------------------------------------
    " Flache Struktur erzeugen
    "----------------------------------------------------------
    lo_struct =
      cl_abap_structdescr=>create(
        p_components = lt_components ).


    "----------------------------------------------------------
    " Standard-Tabellentyp erzeugen
    "----------------------------------------------------------
    ro_table =
      cl_abap_tabledescr=>create(
        p_line_type  = lo_struct
        p_table_kind = cl_abap_tabledescr=>tablekind_std
        p_unique     = abap_false ).

  ENDMETHOD.


  METHOD describe_table.

    DATA:
      lo_type   TYPE REF TO cl_abap_typedescr,
      lo_table  TYPE REF TO cl_abap_tabledescr,
      lo_struct TYPE REF TO cl_abap_structdescr,
      ls_desc   TYPE ty_component.


    "----------------------------------------------------------
    " Typ der übergebenen internen Tabelle bestimmen
    "----------------------------------------------------------
    lo_type =
      cl_abap_typedescr=>describe_by_data( it_table ).

    lo_table ?= lo_type.


    "----------------------------------------------------------
    " Zeilentyp der internen Tabelle bestimmen
    "----------------------------------------------------------
    lo_struct ?=
      lo_table->get_table_line_type( ).


    "----------------------------------------------------------
    " INCLUDE-Strukturen auflösen
    "
    " WICHTIG:
    " Der Rückgabetyp ist NICHT component_table.
    " Deshalb Inline-Deklaration verwenden.
    "----------------------------------------------------------
    DATA(lt_components) =
      lo_struct->get_included_view( ).


    CLEAR rt_desc.


    "----------------------------------------------------------
    " Referenzfreie Beschreibung erzeugen
    "----------------------------------------------------------
    LOOP AT lt_components INTO DATA(ls_component).

      "Leere Komponentennamen nicht übernehmen
      IF ls_component-name IS INITIAL.
        CONTINUE.
      ENDIF.


      CLEAR ls_desc.

      ls_desc-name      = ls_component-name.
      ls_desc-typekind  = ls_component-type->type_kind.
      ls_desc-length    = ls_component-type->length.
      ls_desc-decimals  = ls_component-type->decimals.

      APPEND ls_desc TO rt_desc.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
