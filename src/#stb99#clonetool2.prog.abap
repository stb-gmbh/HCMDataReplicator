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
  PERFORM check_pernr_selection.
  PERFORM check_mandt.

  CREATE OBJECT clonetool2.

  PERFORM overwrite_customizing_with_sel.

  lt_pernr[] = s_pernr[].
  gr_infty[] = s_infty[].


  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     percentage = 10
      text = |Die Daten werden gelesen...|.

  TRY.

      CALL FUNCTION '/STB99/CLONE_DATA'
        DESTINATION p_dest
        EXPORTING
          p_custom              = p_custom
          gr_infty              = gr_infty
        IMPORTING
          xstrtab               = lt_xstring
          cloned_tables         = lt_cloned
        CHANGING
          s_pernr               = lt_pernr
        EXCEPTIONS
          no_data               = 1
          nothingselected       = 2
          communication_failure = 3 MESSAGE lv_msg
          system_failure        = 4 MESSAGE lv_msg.

      CASE sy-subrc.
        WHEN 0.
          "alles ok

        WHEN 1.
          MESSAGE 'Keine Daten gefunden.' TYPE 'E'.

        WHEN 2.
          MESSAGE 'Nichts selektiert.' TYPE 'E'.

        WHEN 3 OR 4.
          MESSAGE lv_msg TYPE 'E'.
      ENDCASE.

    CATCH cx_root INTO DATA(lx_root).
      MESSAGE lx_root->get_text( ) TYPE 'E'.

  ENDTRY.

  s_pernr[] = lt_pernr[].

  IF p_del IS NOT INITIAL AND p_test IS INITIAL.
    PERFORM delete_target_pernr.
  ENDIF.

  PERFORM write_data_to_tables.
  PERFORM show_result.

  IF sy-sysid EQ 'H4D'.
    SUBMIT zhr_after_import
  AND RETURN.

    IF sy-subrc = 0.
      WRITE: / 'ZHR_AFTER_IMPORT erfolgreich ausgeführt'.
    ELSE.
      WRITE: / 'Fehler beim Aufruf von ZHR_AFTER_IMPORT'.
    ENDIF.
  ENDIF.

  PERFORM liste.

END-OF-SELECTION.
  WRITE:/ 'Programmlauf beendet. Gesamtanzahl Personalnummern:' , pernr_anzhl.
*&---------------------------------------------------------------------*
*&      Form  OVERWRITE_CUSTOMIZING_WITH_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM overwrite_customizing_with_sel .
  IF p_org IS NOT INITIAL. p_custom-org       = p_org. ENDIF.
  IF p_wegid IS NOT INITIAL. p_custom-wegid       = p_wegid. ENDIF.
  IF p_calc IS NOT INITIAL. p_custom-calc       = p_calc. ENDIF.
  IF p_pcp0 IS NOT INITIAL. p_custom-pcp0       = p_pcp0. ENDIF.
  IF p_deuv IS NOT INITIAL. p_custom-deuv       = p_deuv. ENDIF.
  IF p_lstb IS NOT INITIAL. p_custom-lstb       = p_lstb. ENDIF.
  IF p_elsta IS NOT INITIAL. p_custom-elsta       = p_elsta. ENDIF.
  IF p_elena IS NOT INITIAL. p_custom-elena       = p_elena. ENDIF.
  IF p_bv IS NOT INITIAL. p_custom-bv       = p_bv. ENDIF.
  IF p_ea IS NOT INITIAL. p_custom-ea       = p_ea. ENDIF.
  IF p_ee IS NOT INITIAL. p_custom-ee       = p_ee. ENDIF.
  IF p_rbm IS NOT INITIAL. p_custom-rbm       = p_rbm. ENDIF.
  IF p_sv IS NOT INITIAL. p_custom-sv       = p_sv. ENDIF.
  IF p_zs IS NOT INITIAL. p_custom-zs       = p_zs. ENDIF.
  IF p_bav IS NOT INITIAL. p_custom-bav       = p_bav. ENDIF.
  IF p_time IS NOT INITIAL. p_custom-time       = p_time. ENDIF.
  IF p_lohn IS NOT INITIAL. p_custom-lohn       = p_lohn. ENDIF.
  IF p_trvl IS NOT INITIAL. p_custom-trvl       = p_trvl. ENDIF.
  IF p_a1 IS NOT INITIAL. p_custom-a1       = p_a1. ENDIF.
  IF p_test IS NOT INITIAL. p_custom-test       = p_test. ENDIF.
  IF p_det IS NOT INITIAL. p_custom-det       = p_det. ENDIF.
  IF p_del IS NOT INITIAL. p_custom-del       = p_del. ENDIF.
  IF p_eau IS NOT INITIAL. p_custom-eau       = p_eau. ENDIF.
  IF p_krank IS NOT INITIAL. p_custom-krank       = p_krank. ENDIF.
  IF p_rent IS NOT INITIAL. p_custom-rent       = p_rent. ENDIF.
  IF p_lsta IS NOT INITIAL. p_custom-lsta       = p_lsta. ENDIF.
  IF p_eubp IS NOT INITIAL. p_custom-eubp       = p_eubp. ENDIF.
  IF p_betri IS NOT INITIAL. p_custom-betri       = p_betri. ENDIF.
  IF p_beitr IS NOT INITIAL. p_custom-beitr       = p_beitr. ENDIF.
  IF p_agkto IS NOT INITIAL. p_custom-agkto       = p_agkto. ENDIF.
  IF p_t596m IS NOT INITIAL. p_custom-t596m       = p_t596m. ENDIF.
  IF p_gos IS NOT INITIAL. p_custom-gos       = p_gos. ENDIF.

  p_custom-destination = p_dest.

ENDFORM.                    " OVERWRITE_CUSTOMIZING_WITH_SEL

INCLUDE /stb99/clonetool2_forms.
*&---------------------------------------------------------------------*
*&      Form  READ_DYNAMIC_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_dynamic_table .

  DATA:
    lt_desc        TYPE /stb99/clonetool2rtts=>tt_components,
    lo_table_descr TYPE REF TO cl_abap_tabledescr,
    lr_source_data TYPE REF TO data.

  FIELD-SYMBOLS:
    <lt_source> TYPE table.

    "interne Tabelle erzeugen
    CREATE DATA ldo_data TYPE TABLE OF (ls_cloned-tabname).
    ASSIGN ldo_data->* TO <lt_itab>.
    READ TABLE lt_xstring INTO lx INDEX ls_cloned-index. "Tabelle füllen aus xstring
    REFRESH <lt_itab>.

  READ TABLE lt_xstring
    INTO lx
    INDEX ls_cloned-index.

  IF sy-subrc <> 0.

  ENDIF.

  CLEAR lt_desc.

  IMPORT
    p2 = lt_desc
    FROM DATA BUFFER lx.

  lo_table_descr =
    /stb99/clonetool2rtts=>create_table(
      it_desc = lt_desc ).

  CREATE DATA lr_source_data
    TYPE HANDLE lo_table_descr.

  ASSIGN lr_source_data->* TO <lt_source>.

  TRY.

      IMPORT
        p1 = <lt_source>
        FROM DATA BUFFER lx.

    CATCH cx_root INTO DATA(lx_error).

      PERFORM add_result
        USING
          ls_cloned-tabname
          space
          l_lines
          l_size
          sy-dbcnt
          2
          'Originaldaten konnten nicht importiert werden.'.
  ENDTRY.

  FIELD-SYMBOLS:
    <ls_source> TYPE any,
    <ls_target> TYPE any.

  LOOP AT <lt_source> ASSIGNING <ls_source>.

    APPEND INITIAL LINE TO <lt_itab>
      ASSIGNING <ls_target>.

    MOVE-CORRESPONDING <ls_source> TO <ls_target>.

  ENDLOOP.

ENDFORM.
