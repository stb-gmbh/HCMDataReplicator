*&---------------------------------------------------------------------*
*&  Include           /STB99/CLONETOOL2_S
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Selektionsbild - Personalnummer
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_pernr for pernr-pernr.
PARAMETERS: p_list AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_det AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_del AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 010 AS SUBSCREEN.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selektionsbild - zusätzliche Optionen
*----------------------------------------------------------------------*
*selection-screen begin of block b3 with frame title text-002.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 01.
PARAMETERS: p_numkr AS CHECKBOX.
SELECTION-SCREEN COMMENT 03(25) text-nkr.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 01.
SELECTION-SCREEN COMMENT 03(15) text-inf.
SELECT-OPTIONS: s_infty for t777d-infty.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF SCREEN 010.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 020 AS SUBSCREEN.
*----------------------------------------------------------------------*
* Selektionsbild - Org.-Management
PARAMETERS: p_wegid TYPE wegid.
PARAMETERS: p_plvar LIKE pchdy-plvar NO-DISPLAY.              "StB-CP
PARAMETERS: p_depth LIKE pchdy-depth.
PARAMETERS: p_org AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 020.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 030 AS SUBSCREEN.
*----------------------------------------------------------------------*
* Radiobuttonblock fuer Abrechnung
PARAMETERS: p_pa03    AS CHECKBOX.
PARAMETERS: p_calc AS CHECKBOX.
PARAMETERS: p_pcp0 AS CHECKBOX.
PARAMETERS: p_deuv AS CHECKBOX.
PARAMETERS: p_lstb AS CHECKBOX.
PARAMETERS: p_elsta AS CHECKBOX.
PARAMETERS: p_elena AS CHECKBOX.
PARAMETERS: p_bv AS CHECKBOX.
PARAMETERS: p_ea AS CHECKBOX.
PARAMETERS: p_ee AS CHECKBOX.
PARAMETERS: p_rbm AS CHECKBOX.
PARAMETERS: p_sv AS CHECKBOX.
PARAMETERS: p_zs AS CHECKBOX.
PARAMETERS: p_bav AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 030.


*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 040 AS SUBSCREEN.
*----------------------------------------------------------------------*
* Radiobuttonblock fuer Zeitwirtschaft
PARAMETERS:p_time AS CHECKBOX.
PARAMETERS: p_lohn AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 040.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 050 AS SUBSCREEN.
*----------------------------------------------------------------------*
PARAMETERS: p_trvl AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 050.


* hier kann die Reihenfolge der Tab-Stripped verändert werden
SELECTION-SCREEN:
  BEGIN OF TABBED BLOCK mytab FOR 13 LINES,
    TAB (20) button1 USER-COMMAND push1 DEFAULT SCREEN 010,
    TAB (20) button2 USER-COMMAND push2 DEFAULT SCREEN 020,
    TAB (20) button3 USER-COMMAND push3 DEFAULT SCREEN 030,
    TAB (20) button4 USER-COMMAND push4 DEFAULT SCREEN 040,
    TAB (20) button5 USER-COMMAND push5 DEFAULT SCREEN 050,
  END OF BLOCK mytab.


*----------------------------------------------------------------------*
* Selektionsbild - Testoptionen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-006.
PARAMETERS: p_dest TYPE RFCDEST.
PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK b4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dest.

  DATA lt_return TYPE TABLE OF ddshretval.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname    = 'RFCDES'
      fieldname  = 'RFCDEST'
      dynpprog   = sy-repid
      dynpnr     = sy-dynnr
      dynprofield = 'P_DEST'
    TABLES
      return_tab = lt_return.

  READ TABLE lt_return INTO DATA(ls_return) INDEX 1.
  IF sy-subrc = 0.
    p_dest = ls_return-fieldval.
  ENDIF.

  PERFORM get_customizing.


*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*

  button1 = text-pad.
  button2 = text-org.
  button3 = text-cal.
  button4 = text-tim.
  button5 = text-trv.

  mytab-prog = sy-repid.
  mytab-dynnr = 010.
  mytab-activetab = 'BUTTON1'.

  CALL FUNCTION 'RH_GET_ACTIVE_WF_PLVAR'                     "StB-CP
     EXPORTING                                                "StB-CP
       set_default_plvar = 'X'                                "StB-CP
     IMPORTING                                                "StB-CP
       act_plvar         = p_plvar                            "StB-CP
     EXCEPTIONS                                               "StB-CP
       no_active_plvar   = 0                                  "StB-CP
       OTHERS            = 0.                                 "StB-CP


  if p_dest IS NOT INITIAL.
    PERFORM get_customizing.
  endif.
