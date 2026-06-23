*&---------------------------------------------------------------------*
*& Report /STB99/C2_CUST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /stb99/c2_cust.

TABLES /stb99/ct2_cust.

DATA gs_custom TYPE /stb99/ct2_cust.

PARAMETERS p_dest TYPE /stb99/ct2_cust-destination."

SELECTION-SCREEN BEGIN OF TABBED BLOCK tabs FOR 10 LINES.
SELECTION-SCREEN TAB (20) tab_gen  USER-COMMAND gen DEFAULT SCREEN 0100.
SELECTION-SCREEN TAB (20) tab_pay  USER-COMMAND pay DEFAULT SCREEN 0200.
SELECTION-SCREEN TAB (20) tab_sv   USER-COMMAND sv  DEFAULT SCREEN 0300.
SELECTION-SCREEN TAB (20) tab_tax  USER-COMMAND tax DEFAULT SCREEN 0400.
SELECTION-SCREEN TAB (20) tab_time USER-COMMAND tim DEFAULT SCREEN 0500.
SELECTION-SCREEN END OF BLOCK tabs.

SELECTION-SCREEN BEGIN OF SCREEN 0100 AS SUBSCREEN.
PARAMETERS p_numkr TYPE /stb99/ct2_cust-numkr AS CHECKBOX.
PARAMETERS p_wegid TYPE /stb99/ct2_cust-wegid.
PARAMETERS p_plvar TYPE /stb99/ct2_cust-plvar.
PARAMETERS p_depth TYPE /stb99/ct2_cust-depth.
PARAMETERS p_org   TYPE /stb99/ct2_cust-org   AS CHECKBOX.
PARAMETERS p_test  TYPE xfeld AS CHECKBOX.
PARAMETERS p_det  TYPE xfeld AS CHECKBOX.
PARAMETERS p_del  TYPE xfeld AS CHECKBOX.

SELECTION-SCREEN END OF SCREEN 0100.

SELECTION-SCREEN BEGIN OF SCREEN 0200 AS SUBSCREEN.
PARAMETERS p_pa03 TYPE /stb99/ct2_cust-pa03 AS CHECKBOX.
PARAMETERS p_calc TYPE /stb99/ct2_cust-calc AS CHECKBOX.
PARAMETERS p_pcp0 TYPE /stb99/ct2_cust-pcp0 AS CHECKBOX.
PARAMETERS p_lohn TYPE /stb99/ct2_cust-lohn AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 0200.

SELECTION-SCREEN BEGIN OF SCREEN 0300 AS SUBSCREEN.
PARAMETERS p_deuv TYPE /stb99/ct2_cust-deuv AS CHECKBOX.
PARAMETERS p_bv   TYPE /stb99/ct2_cust-bv   AS CHECKBOX.
PARAMETERS p_ea   TYPE /stb99/ct2_cust-ea   AS CHECKBOX.
PARAMETERS p_ee   TYPE /stb99/ct2_cust-ee   AS CHECKBOX.
PARAMETERS p_rbm  TYPE /stb99/ct2_cust-rbm  AS CHECKBOX.
PARAMETERS p_sv   TYPE /stb99/ct2_cust-sv   AS CHECKBOX.
PARAMETERS p_zs   TYPE /stb99/ct2_cust-zs   AS CHECKBOX.
PARAMETERS p_bav  TYPE /stb99/ct2_cust-bav  AS CHECKBOX.
PARAMETERS p_a1   TYPE /stb99/ct2_cust-a1   AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 0300.

SELECTION-SCREEN BEGIN OF SCREEN 0400 AS SUBSCREEN.
PARAMETERS p_lstb  TYPE /stb99/ct2_cust-lstb  AS CHECKBOX.
PARAMETERS p_elsta TYPE /stb99/ct2_cust-elsta AS CHECKBOX.
PARAMETERS p_elena TYPE /stb99/ct2_cust-elena AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 0400.

SELECTION-SCREEN BEGIN OF SCREEN 0500 AS SUBSCREEN.
PARAMETERS p_time TYPE /stb99/ct2_cust-time AS CHECKBOX.
PARAMETERS p_trvl TYPE /stb99/ct2_cust-trvl AS CHECKBOX.
SELECTION-SCREEN END OF SCREEN 0500.

INITIALIZATION.
  tab_gen  = 'Allgemein'.
  tab_pay  = 'Abrechnung'.
  tab_sv   = 'SV / Meldewesen'.
  tab_tax  = 'Steuer'.
  tab_time = 'Zeit / Reise'.
  tabs-activetab = 'GEN'.

AT SELECTION-SCREEN OUTPUT.
  PERFORM load_data.

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


START-OF-SELECTION.
  PERFORM save_data.

FORM load_data.

  SELECT SINGLE *
    FROM /stb99/ct2_cust
    INTO @gs_custom
    WHERE destination = @p_dest.

  IF sy-subrc = 0.
    p_dest = gs_custom-destination.
    p_numkr = gs_custom-numkr.
    p_wegid = gs_custom-wegid.
    p_plvar = gs_custom-plvar.
    p_depth = gs_custom-depth.
    p_org   = gs_custom-org.
    p_pa03  = gs_custom-pa03.
    p_calc  = gs_custom-calc.
    p_pcp0  = gs_custom-pcp0.
    p_deuv  = gs_custom-deuv.
    p_lstb  = gs_custom-lstb.
    p_elsta = gs_custom-elsta.
    p_elena = gs_custom-elena.
    p_bv    = gs_custom-bv.
    p_ea    = gs_custom-ea.
    p_ee    = gs_custom-ee.
    p_rbm   = gs_custom-rbm.
    p_sv    = gs_custom-sv.
    p_zs    = gs_custom-zs.
    p_bav   = gs_custom-bav.
    p_time  = gs_custom-time.
    p_lohn  = gs_custom-lohn.
    p_trvl  = gs_custom-trvl.
    p_a1    = gs_custom-a1.
  ENDIF.

ENDFORM.

FORM save_data.

  DATA lv_answer TYPE c LENGTH 1.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Einstellungen sichern'
      text_question         = 'Sollen die Einstellungen gespeichert werden?'
      text_button_1         = 'Ja'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = 'Nein'
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '2'
      display_cancel_button = abap_true
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    MESSAGE 'Speichern abgebrochen' TYPE 'S'.
    RETURN.
  ENDIF.


  CLEAR gs_custom.

  gs_custom-destination  = p_dest.
  gs_custom-numkr        = p_numkr.
  gs_custom-wegid        = p_wegid.
  gs_custom-plvar        = p_plvar.
  gs_custom-depth        = p_depth.
  gs_custom-org          = p_org.
  gs_custom-pa03         = p_pa03.
  gs_custom-calc         = p_calc.
  gs_custom-pcp0         = p_pcp0.
  gs_custom-deuv         = p_deuv.
  gs_custom-lstb         = p_lstb.
  gs_custom-elsta        = p_elsta.
  gs_custom-elena        = p_elena.
  gs_custom-bv           = p_bv.
  gs_custom-ea           = p_ea.
  gs_custom-ee           = p_ee.
  gs_custom-rbm          = p_rbm.
  gs_custom-sv           = p_sv.
  gs_custom-zs           = p_zs.
  gs_custom-bav          = p_bav.
  gs_custom-time         = p_time.
  gs_custom-lohn         = p_lohn.
  gs_custom-trvl         = p_trvl.
  gs_custom-a1           = p_a1.

  MODIFY /stb99/ct2_cust FROM gs_custom.

  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE 'Einstellungen gespeichert' TYPE 'S'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE 'Fehler beim Speichern' TYPE 'E'.
  ENDIF.

ENDFORM.
