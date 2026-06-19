*&---------------------------------------------------------------------*
*& Report /STB99/CLONETOOL2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /stb99/clonetool2 USING DATABASE pnp.


INCLUDE /stb99/clonetool2_d.
INCLUDE /stb99/clonetool2_s.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  CREATE OBJECT clonetool2.

  PERFORM overwrite_customizing_with_sel.

  lt_pernr[] = s_pernr[].
  gr_infty[] = s_infty[].

  CALL FUNCTION '/STB99/CLONE_DATA'
    DESTINATION p_desti
    EXPORTING
      p_custom        = p_custom
      gr_infty        = gr_infty
    IMPORTING
      xstrtab         = lt_xstring
      cloned_tables   = lt_cloned
    CHANGING
      s_pernr         = lt_pernr
    EXCEPTIONS
      no_data         = 1
      nothingselected = 2
*     OTHERS          = 3
    .
  IF sy-subrc <> 0.

  ENDIF.

  s_pernr[] = lt_pernr[].

  IF p_del IS NOT INITIAL AND p_test IS INITIAL.
    PERFORM delete_target_pernr.
  ENDIF.

  PERFORM liste.

  PERFORM write_data_to_tables.

END-OF-SELECTION.
  WRITE:/ 'Programmlauf beendet'.
*&---------------------------------------------------------------------*
*&      Form  OVERWRITE_CUSTOMIZING_WITH_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM overwrite_customizing_with_sel .

  IF p_numkr IS NOT INITIAL.p_custom-numkr = p_numkr.ENDIF.
  IF p_wegid IS NOT INITIAL.p_custom-wegid = p_wegid.ENDIF.
  IF p_plvar IS NOT INITIAL.p_custom-plvar = p_plvar.ENDIF.
  IF p_depth IS NOT INITIAL.p_custom-depth = p_depth.ENDIF.
  IF p_org IS NOT INITIAL.p_custom-org = p_org.ENDIF.
  IF p_pa03 IS NOT INITIAL.p_custom-pa03 = p_pa03.ENDIF.
  IF p_calc IS NOT INITIAL.p_custom-calc = p_calc.ENDIF.
  IF p_pcp0 IS NOT INITIAL.p_custom-pcp0 = p_pcp0.ENDIF.
  IF p_deuv IS NOT INITIAL.p_custom-deuv = p_deuv.ENDIF.
  IF p_lstb IS NOT INITIAL.p_custom-lstb = p_lstb.ENDIF.
  IF p_elsta IS NOT INITIAL.p_custom-elsta = p_elsta.ENDIF.
  IF p_elena IS NOT INITIAL.p_custom-elena = p_elena.ENDIF.
  IF p_bv IS NOT INITIAL.p_custom-bv = p_bv.ENDIF.
  IF p_ea IS NOT INITIAL.p_custom-ea = p_ea.ENDIF.
  IF p_ee IS NOT INITIAL.p_custom-ee = p_ee.ENDIF.
  IF p_rbm IS NOT INITIAL.p_custom-rbm = p_rbm.ENDIF.
  IF p_sv IS NOT INITIAL.p_custom-sv = p_sv.ENDIF.
  IF p_zs IS NOT INITIAL.p_custom-zs = p_zs.ENDIF.
  IF p_bav IS NOT INITIAL.p_custom-bav = p_bav.ENDIF.
  IF p_time IS NOT INITIAL.p_custom-time = p_time.ENDIF.
  IF p_lohn IS NOT INITIAL.p_custom-lohn = p_lohn.ENDIF.
  IF p_trvl IS NOT INITIAL.p_custom-trvl = p_trvl.ENDIF.
  p_custom-destination = p_desti.

ENDFORM.                    " OVERWRITE_CUSTOMIZING_WITH_SEL

INCLUDE /stb99/clonetool2_forms.
