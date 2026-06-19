*&---------------------------------------------------------------------*
*&  Include           /STB99/CLONETOOL2_S
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Selektionsbild - Personalnummer
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_pernr TYPE pernr_d OBLIGATORY.
PARAMETERS: p_target TYPE pernr_d OBLIGATORY.
PARAMETERS: p_anzhl TYPE i NO-DISPLAY.
PARAMETERS: p_list NO-DISPLAY.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 010 AS SUBSCREEN.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Selektionsbild - zusätzliche Optionen
*----------------------------------------------------------------------*
**selection-screen begin of block b3 with frame title text-002.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN POSITION 01.
*PARAMETERS: p_numkr AS CHECKBOX.
*SELECTION-SCREEN COMMENT 03(25) text-nkr.
*SELECTION-SCREEN COMMENT 60(65) text-105.
*SELECTION-SCREEN END OF LINE.
*
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 60(65) text-106.
*SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 60(65) text-120.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 60(65) text-121.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 60(65) text-122.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF SCREEN 010.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 020 AS SUBSCREEN.
*----------------------------------------------------------------------*
*Selektionsbild - Org.-Management
PARAMETERS: p_wegid TYPE wegid.
PARAMETERS: p_plvar LIKE pchdy-plvar NO-DISPLAY.              "StB-CP
PARAMETERS: p_depth LIKE pchdy-depth.
PARAMETERS: p_org AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 020.

*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 030 AS SUBSCREEN.
*----------------------------------------------------------------------*
* Radiobuttonblock fuer Abrechnung
*PARAMETERS: p_pa03    AS CHECKBOX.
PARAMETERS: p_calc AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_pcp0 AS CHECKBOX.
PARAMETERS: p_deuv AS CHECKBOX DEFAULT 'X'.
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
PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK b4.

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*

  button1 = text-pad.
  button2 = text-org.
  button3 = text-cal.
  button4 = text-tim.
  button5 = text-trv.
*
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

  DATA: ls_tmp TYPE /stb99/ct2_cust.
  SELECT SINGLE * FROM /stb99/ct2_cust INTO ls_tmp.

  p_anzhl = ls_tmp-anzhl.
*  p_numkr = ls_tmp-numkr.
  p_wegid = ls_tmp-wegid.
  p_plvar = ls_tmp-plvar.
  p_depth = ls_tmp-depth.
  p_org = ls_tmp-org.
*  p_pa03 = ls_tmp-pa03.
  p_calc = ls_tmp-calc.
  p_pcp0 = ls_tmp-pcp0.
  p_deuv = ls_tmp-deuv.
  p_lstb = ls_tmp-lstb.
  p_elsta = ls_tmp-elsta.
  p_elena = ls_tmp-elena.
  p_bv = ls_tmp-bv.
  p_ea = ls_tmp-ea.
  p_ee = ls_tmp-ee.
  p_rbm = ls_tmp-rbm.
  p_sv = ls_tmp-sv.
  p_zs = ls_tmp-zs.
  p_bav = ls_tmp-bav.
  p_time = ls_tmp-time.
  p_lohn = ls_tmp-lohn.
  p_trvl = ls_tmp-trvl.
*  p_desti = ls_tmp-destination.
