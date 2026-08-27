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

  IF p_save IS NOT INITIAL AND p_del IS NOT INITIAL AND p_test IS INITIAL.
    PERFORM delete_target_pernr.
  ENDIF.

  IF p_save IS NOT INITIAL.
    PERFORM write_data_to_tables.
  ENDIF.

  IF p_down IS NOT INITIAL.
    PERFORM save_lt_xstring_to_file.
  ENDIF.
  PERFORM show_result.
  PERFORM liste.

END-OF-SELECTION.
  WRITE:/ 'Programmlauf beendet.'.

  INCLUDE /stb99/clonetool2_forms.
