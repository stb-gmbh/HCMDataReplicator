FUNCTION /STB99/GET_PERNR.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(P_CUSTOM) TYPE  /STB99/CT2_CUST
*"  CHANGING
*"     VALUE(S_PERNR) TYPE  /STB99/RANGE_PERNR_T
*"  EXCEPTIONS
*"      NO_DATA
*"      NOTHINGSELECTED
*"----------------------------------------------------------------------
  DATA: clonetool2 TYPE REF TO /stb99/clonetool2.

  CREATE OBJECT clonetool2.

  clonetool2->customizing = p_custom.

  CALL METHOD clonetool2->get_selected_pernr
    CHANGING
      s_pernr       = s_pernr.

ENDFUNCTION.
