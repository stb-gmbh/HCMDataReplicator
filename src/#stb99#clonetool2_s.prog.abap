*&---------------------------------------------------------------------*
*&  Include           /STB99/CLONETOOL2_S
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Selektionsbild - Personalnummer
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_pernr FOR pernr-pernr.
PARAMETERS: p_list AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_det AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_del AS CHECKBOX DEFAULT ' '.
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
SELECTION-SCREEN COMMENT 03(25) TEXT-nkr.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 01.
SELECTION-SCREEN COMMENT 03(15) TEXT-inf.
SELECT-OPTIONS: s_infty FOR t777d-infty.
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
PARAMETERS: p_org TYPE /stb99/ct2_cust_org AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 020.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 030 AS SUBSCREEN.
*----------------------------------------------------------------------*
* Radiobuttonblock fuer Abrechnung
PARAMETERS: p_calc TYPE /stb99/ct2_cust_calc AS CHECKBOX.
PARAMETERS: p_pcp0 TYPE /stb99/ct2_cust_pcp0 AS CHECKBOX.
PARAMETERS: p_deuv TYPE /stb99/ct2_cust_deuv AS CHECKBOX.
PARAMETERS: p_lstb TYPE /stb99/ct2_cust_lstb AS CHECKBOX.
PARAMETERS: p_elsta TYPE /stb99/ct2_cust_elsta AS CHECKBOX.
PARAMETERS: p_elena TYPE /stb99/ct2_cust_elena AS CHECKBOX.
PARAMETERS: p_bv TYPE /stb99/ct2_cust_bv AS CHECKBOX.
PARAMETERS: p_ea TYPE /stb99/ct2_cust_ea AS CHECKBOX.
PARAMETERS: p_ee TYPE /stb99/ct2_cust_ee AS CHECKBOX.
PARAMETERS: p_rbm TYPE /stb99/ct2_cust_rbm AS CHECKBOX.
PARAMETERS: p_sv TYPE /stb99/ct2_cust_sv AS CHECKBOX.
PARAMETERS: p_zs TYPE /stb99/ct2_cust_zs AS CHECKBOX.
PARAMETERS: p_bav TYPE /stb99/ct2_cust_bav AS CHECKBOX.
PARAMETERS: p_a1 TYPE /stb99/ct2_cust_a1 AS CHECKBOX.
PARAMETERS: p_eau TYPE /stb99/ct2_cust_eau AS CHECKBOX.
PARAMETERS: p_krank TYPE /stb99/ct2_cust_krank AS CHECKBOX.
PARAMETERS: p_rent TYPE /stb99/ct2_cust_rent AS CHECKBOX.
PARAMETERS: p_lsta TYPE /stb99/ct2_cust_lsta AS CHECKBOX.
PARAMETERS: p_eubp TYPE /stb99/ct2_cust_eubp AS CHECKBOX.
PARAMETERS: p_betri TYPE /stb99/ct2_cust_betri AS CHECKBOX.
PARAMETERS: p_beitr TYPE /stb99/ct2_cust_beitr AS CHECKBOX.
PARAMETERS: p_agkto TYPE /stb99/ct2_cust_agkto AS CHECKBOX.
PARAMETERS: p_DaBPV TYPE /stb99/ct2_cust_DaBPV AS CHECKBOX.
PARAMETERS: p_t596m TYPE /stb99/ct2_cust_t596m AS CHECKBOX.
PARAMETERS: p_gos TYPE /stb99/ct2_cust_gos AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 030.


*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 040 AS SUBSCREEN.
*----------------------------------------------------------------------*
* Radiobuttonblock fuer Zeitwirtschaft
PARAMETERS: p_time TYPE /stb99/ct2_cust_time AS CHECKBOX.
PARAMETERS: p_lohn TYPE /stb99/ct2_cust_lohn AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 040.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 050 AS SUBSCREEN.
*----------------------------------------------------------------------*
PARAMETERS: p_trvl TYPE /stb99/ct2_cust_trvl AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 050.


* hier kann die Reihenfolge der Tab-Stripped verändert werden
SELECTION-SCREEN:
  BEGIN OF TABBED BLOCK mytab FOR 25 LINES,
    TAB (20) button1 USER-COMMAND push1 DEFAULT SCREEN 010,
    TAB (20) button2 USER-COMMAND push2 DEFAULT SCREEN 020,
    TAB (20) button3 USER-COMMAND push3 DEFAULT SCREEN 030,
    TAB (20) button4 USER-COMMAND push4 DEFAULT SCREEN 040,
    TAB (20) button5 USER-COMMAND push5 DEFAULT SCREEN 050,
  END OF BLOCK mytab.


*----------------------------------------------------------------------*
* Selektionsbild - Testoptionen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-006.
PARAMETERS: p_dest TYPE rfcdest.
PARAMETERS: p_test TYPE /stb99/ct2_cust_test AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dest.

  DATA lt_return TYPE TABLE OF ddshretval.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname     = 'RFCDES'
      fieldname   = 'RFCDEST'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'P_DEST'
    TABLES
      return_tab  = lt_return.

  READ TABLE lt_return INTO DATA(ls_return) INDEX 1.
  IF sy-subrc = 0.
    p_dest = ls_return-fieldval.
  ENDIF.

  PERFORM get_customizing.


*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*

  button1 = TEXT-pad.
  button2 = TEXT-org.
  button3 = TEXT-cal.
  button4 = TEXT-tim.
  button5 = TEXT-trv.

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

 PERFORM get_customizing.
