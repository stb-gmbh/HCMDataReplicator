FUNCTION /stb99/clone_data.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(P_CUSTOM) TYPE  /STB99/CT2_CUST
*"     VALUE(GR_INFTY) TYPE  /STB99/STB_INFTY_RANGE_T
*"  EXPORTING
*"     VALUE(XSTRTAB) TYPE  /STB99/XTAB
*"     VALUE(CLONED_TABLES) TYPE  /STB99/TABLES_T
*"  CHANGING
*"     VALUE(S_PERNR) TYPE  /STB99/RANGE_PERNR_T
*"  EXCEPTIONS
*"      NO_DATA
*"      NOTHINGSELECTED
*"----------------------------------------------------------------------
  DATA: clonetool2 TYPE REF TO /stb99/clonetool2.

  CREATE OBJECT clonetool2.

  clonetool2->customizing = p_custom.

  REFRESH: cloned_tables.
  REFRESH: xstrtab.

  CALL METHOD clonetool2->read_tables_to_clone
    EXPORTING
      gr_infty      = gr_infty
    CHANGING
      s_pernr       = s_pernr
      cloned_tables = cloned_tables
      xstrtab       = xstrtab.

ENDFUNCTION.
