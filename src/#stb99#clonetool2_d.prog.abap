*&---------------------------------------------------------------------*
*&  Include           /STB99/CLONETOOL2_D
*&---------------------------------------------------------------------*

TABLES: t777d,pernr.


DATA: ldo_data   TYPE REF TO data.
FIELD-SYMBOLS: <lt_itab>    TYPE table.

DATA:
  lx  TYPE xstring,
  lt  TYPE TABLE OF t001,
  lt2 TYPE TABLE OF t001,
  l_lines TYPE i,
  l_size  TYPE i,
  cmsg TYPE string.

DATA: lt_xstring TYPE /stb99/xtab.

DATA: lt_cloned TYPE  /stb99/tables_t,
      ls_cloned TYPE  /stb99/tables.

DATA: clonetool2 TYPE REF TO /stb99/clonetool2.

DATA: ls_tables_to_clone TYPE /stb99/tables_to_clone.

DATA: lt_pernr TYPE /stb99/range_pernr_t,
      p_custom TYPE /stb99/ct2_cust.

TYPES: tr_infty TYPE RANGE OF infty.
DATA:  gr_infty TYPE tr_infty.

DATA pernr_anzhl TYPE i.
DATA lv_msg TYPE text256.

TYPES:
  BEGIN OF ty_result,
    status       TYPE icon_d,
    tabname      TYPE tabname,
    add_info     TYPE char100,
    lines_read   TYPE i,
    size_kb      TYPE p LENGTH 10 DECIMALS 2,
    lines_write  TYPE i,
    message      TYPE char200,
  END OF ty_result.

DATA:
  gt_result TYPE STANDARD TABLE OF ty_result,
  gs_result TYPE ty_result.

CONSTANTS lc_chunk_size TYPE i VALUE 10485760.
