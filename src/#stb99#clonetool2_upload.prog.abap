*&---------------------------------------------------------------------*
*& Report /STB99/CLONETOOL2_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /stb99/clonetool2_upload.

INCLUDE /stb99/clonetool2_d.

SELECTION-SCREEN BEGIN OF BLOCK bup WITH FRAME TITLE TEXT-upl.
SELECT-OPTIONS: s_pernr FOR pernr-pernr no-DISPLAY.
PARAMETERS: p_list no-DISPLAY.
PARAMETERS: p_det TYPE xfeld DEFAULT 'X' NO-DISPLAY.
PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.
PARAMETERS p_file TYPE string LOWER CASE OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bup.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  DATA: lt_filetable TYPE filetable,
        ls_filetable TYPE file_table,
        lv_rc        TYPE i,
        lv_action    TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title = 'Clone-Datei auswählen'
      file_filter  = 'Binärdatei (*.bin)|*.bin|Alle Dateien (*.*)|*.*'
    CHANGING
      file_table   = lt_filetable
      rc           = lv_rc
      user_action  = lv_action
    EXCEPTIONS
      OTHERS       = 1 ).

  IF sy-subrc = 0
     AND lv_action <> cl_gui_frontend_services=>action_cancel.

    READ TABLE lt_filetable INTO ls_filetable INDEX 1.
    IF sy-subrc = 0.
      p_file = ls_filetable-filename.
    ENDIF.

  ENDIF.

START-OF-SELECTION.
  PERFORM check_mandt.

  PERFORM upload_clone_file.

  IF lt_xstring IS INITIAL OR lt_cloned IS INITIAL.
    MESSAGE 'Die Datei enthält keine gültigen Clone-Daten.' TYPE 'E'.
  ENDIF.

  PERFORM write_data_to_tables.
  PERFORM show_result.

END-OF-SELECTION.

  WRITE: / 'Upload-Programmlauf beendet.'.

  INCLUDE /stb99/clonetool2_forms.

FORM upload_clone_file.

  DATA: lt_bin       TYPE solix_tab,
        lv_file_xstr TYPE xstring,
        lv_file_len  TYPE i.

  IF sy-batch IS NOT INITIAL.
    MESSAGE 'Lokaler Upload ist im Hintergrund nicht möglich.' TYPE 'E'.
  ENDIF.

  cl_gui_frontend_services=>gui_upload(
    EXPORTING
      filename   = p_file
      filetype   = 'BIN'
    IMPORTING
      filelength = lv_file_len
    CHANGING
      data_tab   = lt_bin
    EXCEPTIONS
      OTHERS     = 1 ).

  IF sy-subrc <> 0.
    MESSAGE |Datei konnte nicht hochgeladen werden. Fehler { sy-subrc }| TYPE 'E'.
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_file_len
    IMPORTING
      buffer       = lv_file_xstr
    TABLES
      binary_tab   = lt_bin.

  TRY.
      IMPORT lt_xstring = lt_xstring
             lt_cloned  = lt_cloned
             lt_pernr   = lt_pernr
        FROM DATA BUFFER lv_file_xstr.

    CATCH cx_root INTO DATA(lx_error).
      MESSAGE lx_error->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.
