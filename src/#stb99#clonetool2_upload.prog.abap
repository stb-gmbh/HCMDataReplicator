*&---------------------------------------------------------------------*
*& Report /STB99/CLONETOOL2_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /stb99/clonetool2_upload.

INCLUDE /stb99/clonetool2_d.

SELECTION-SCREEN BEGIN OF BLOCK bup WITH FRAME TITLE TEXT-upl.
SELECT-OPTIONS: s_pernr FOR pernr-pernr NO-DISPLAY.
PARAMETERS: p_list NO-DISPLAY.
PARAMETERS: p_det TYPE xfeld DEFAULT 'X' NO-DISPLAY.
PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.
PARAMETERS p_folder TYPE string LOWER CASE OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bup.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_folder.
  cl_gui_frontend_services=>directory_browse(
      EXPORTING
        window_title    = 'Zielverzeichnis auswählen'
      CHANGING
        selected_folder = p_folder
      EXCEPTIONS
        OTHERS          = 1 ).

  IF sy-subrc <> 0 OR p_folder IS INITIAL.
    RETURN.
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
  DATA: lv_manifest TYPE xstring,
        lv_file     TYPE string,
        lv_exists   TYPE abap_bool,
        lv_xpart    TYPE xstring,
        lv_table    TYPE xstring,
        lv_idx      TYPE n LENGTH 6,
        lv_prt      TYPE n LENGTH 4,
        lv_part     TYPE i.

  lv_file = |{ p_folder }\\manifest.bin|.

  PERFORM upload_xstring_file USING lv_file CHANGING lv_manifest.

  IMPORT lt_cloned = lt_cloned
         lt_pernr  = lt_pernr
    FROM DATA BUFFER lv_manifest.

  REFRESH lt_xstring.

  LOOP AT lt_cloned INTO ls_cloned.

    cmsg = |Tabelle verarbeiten: { ls_cloned-tabname } ({ sy-tabix }/{ lines( lt_cloned ) })|.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = sy-tabix * 100 / lines( lt_cloned )
        text       = cmsg.

    CLEAR lv_table.
    lv_idx = ls_cloned-index.
    lv_part = 1.

    DO.
      lv_prt = lv_part.
      lv_file = |{ p_folder }\\data_{ lv_idx }_{ lv_prt }.bin|.

      PERFORM frontend_file_exists USING lv_file CHANGING lv_exists.

      IF lv_exists IS INITIAL.
        EXIT.
      ENDIF.

      PERFORM upload_xstring_file USING lv_file CHANGING lv_xpart.

      CONCATENATE lv_table lv_xpart INTO lv_table IN BYTE MODE.

      lv_part = lv_part + 1.
    ENDDO.

    IF lv_table IS INITIAL.
      MESSAGE |Keine Datendatei gefunden für Index { ls_cloned-index }| TYPE 'E'.
    ENDIF.

    DO ls_cloned-index - lines( lt_xstring ) TIMES.
      APPEND INITIAL LINE TO lt_xstring.
    ENDDO.

    MODIFY lt_xstring FROM lv_table INDEX ls_cloned-index.

  ENDLOOP.

ENDFORM.
FORM frontend_file_exists
  USING iv_file TYPE string
  CHANGING cv_exists TYPE abap_bool.

  CLEAR cv_exists.

  cl_gui_frontend_services=>file_exist(
    EXPORTING
      file   = iv_file
    RECEIVING
      result = cv_exists
    EXCEPTIONS
      OTHERS = 1 ).

ENDFORM.

FORM upload_xstring_file
  USING iv_file TYPE string
  CHANGING cv_xstring TYPE xstring.

  DATA: lt_bin TYPE solix_tab,
        lv_len TYPE i.

  CLEAR cv_xstring.


  cl_gui_frontend_services=>gui_upload(
    EXPORTING
      filename   = iv_file
      filetype   = 'BIN'
    IMPORTING
      filelength = lv_len
    CHANGING
      data_tab   = lt_bin
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 20 ).

  IF sy-subrc <> 0.
    MESSAGE |GUI_UPLOAD fehlgeschlagen. Datei: { iv_file }, Fehler: { sy-subrc }| TYPE 'E'.
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_len
    IMPORTING
      buffer       = cv_xstring
    TABLES
      binary_tab   = lt_bin.

ENDFORM.
