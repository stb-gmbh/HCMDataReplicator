*&---------------------------------------------------------------------*
*&  Include           /STB99/CLONETOOL2_D
*&---------------------------------------------------------------------*

TABLES: t777d,pernr.


DATA: ldo_data   TYPE REF TO data.
FIELD-SYMBOLS: <lt_itab>    TYPE table.
DATA:
  lx  TYPE xstring,
  lt  TYPE TABLE OF t001,
  lt2 TYPE TABLE OF t001.
DATA: l_lines TYPE i,
      l_size  TYPE i.
DATA: cmsg TYPE string.

DATA: lt_xstring TYPE /stb99/xtab.

DATA: lt_cloned TYPE  /stb99/tables_t,
      ls_cloned TYPE  /stb99/tables.

DATA: clonetool2 TYPE REF TO /stb99/clonetool2.

DATA: ls_tables_to_clone TYPE /stb99/tables_to_clone.

DATA: p_custom TYPE /stb99/ct2_cust,
      lt_pernr TYPE /stb99/range_pernr_t.

TYPES: tr_infty TYPE RANGE OF infty.
DATA:  gr_infty TYPE tr_infty.
