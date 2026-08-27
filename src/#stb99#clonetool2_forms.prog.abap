*&---------------------------------------------------------------------*
*&  Include           /STB99/CLONETOOL2_FORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DELETE_TARGET_PERNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_target_pernr .
  DATA: jobname TYPE  btch2170-jobname,  "Name eines Hintergrundjobs
        num     TYPE  tbtcjob-jobcount.  "Kennummer eines Jobs

  DATA: p_aborted     TYPE tbtcv-abort,
        p_finished    TYPE tbtcv-fin,
        p_preliminary TYPE tbtcv-prelim,
        p_ready       TYPE tbtcv-ready,
        p_running     TYPE tbtcv-run,
        p_scheduled   TYPE tbtcv-sched.

  DATA: gr_loeschen TYPE /stb99/range_pernr_t,
        ls_loeschen TYPE /stb99/range_pernr.

  DATA: sec TYPE i VALUE '1'.

  REFRESH: gr_loeschen.
  CLEAR ls_loeschen.
  ls_loeschen-sign = 'I'.
  ls_loeschen-option = 'EQ'.

  SELECT pernr FROM pa0003 INTO ls_loeschen-low WHERE pernr IN s_pernr.
    APPEND ls_loeschen TO gr_loeschen.
  ENDSELECT.

  CHECK gr_loeschen[] IS NOT INITIAL.

  jobname = 'STB-Clone: DELPN'.
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = jobname
    IMPORTING
      jobcount         = num
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    RAISE job_fault.
  ENDIF.



* Personalnummer vorher löschen
  SUBMIT rpudelpn AND RETURN
          WITH selpernr IN gr_loeschen
          WITH protocol  = space
          WITH testx     = space
          WITH jname     = jobname
          USER sy-uname
          VIA JOB jobname NUMBER num.

*---------------------------------------------------------------------
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = num
      jobname              = jobname
      strtimmed            = 'X'
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      OTHERS               = 8.
  IF sy-subrc <> 0.
    RAISE job_fault.
  ENDIF.
********* Job beebden **********************************
  p_ready = 'X'.
* Warten bis RPUDELPN beendet ist
  WHILE p_running IS NOT INITIAL
     OR p_ready IS NOT INITIAL.
    WAIT UP TO sec SECONDS.
    CALL FUNCTION 'SHOW_JOBSTATE'
      EXPORTING
        jobcount         = num
        jobname          = jobname
      IMPORTING
        aborted          = p_aborted
        finished         = p_finished
        preliminary      = p_preliminary
        ready            = p_ready
        running          = p_running
        scheduled        = p_scheduled
      EXCEPTIONS
        jobcount_missing = 1
        jobname_missing  = 2
        job_notex        = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      RAISE job_fault.
    ENDIF.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = TEXT-del.
  ENDWHILE.
  IF p_aborted IS NOT INITIAL.           "Daten nicht schreiben
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = TEXT-a01
        txt1  = TEXT-a02
        txt2  = TEXT-a03
        txt3  = TEXT-a04
        txt4  = TEXT-a05.
    RAISE job_aborted.
  ENDIF.
  IF    p_preliminary IS NOT INITIAL
     OR p_scheduled   IS NOT INITIAL.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = TEXT-b01
        txt1  = TEXT-b02
        txt2  = TEXT-b03
        txt3  = TEXT-a04
        txt4  = TEXT-a05.
    RAISE job_not_started.
  ENDIF.
  IF p_det IS NOT INITIAL.WRITE: / 'Job', jobname, 'zum Löschen der Daten ausgeführt'.ENDIF.

ENDFORM.                    " DELETE_TARGET_PERNR
*&---------------------------------------------------------------------*
*&      Form  LISTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM liste .
  CLEAR pernr_anzhl.
  IF p_list IS NOT INITIAL.
    LOOP AT s_pernr.
      IF p_test IS INITIAL.
        WRITE:/ 'Personalnummer', s_pernr-low, 'kopiert'.
      ELSE.
        WRITE:/ 'Personalnummer', s_pernr-low, 'getestet'.
      ENDIF.
      ADD 1 TO pernr_anzhl.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " LISTE

*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA_TO_TABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_data_to_tables .
  FIELD-SYMBOLS: <ls_line>, <l_relid> TYPE any.
  DATA: add_info TYPE text20.

  "Schreiben der übermittelten Daten aus dem Produktivsystem
  LOOP AT lt_cloned INTO ls_cloned. "Tabellennamen

    CASE ls_cloned-mode.
      WHEN 'G'. "GOS
        PERFORM write_gos.
        CONTINUE.
      WHEN 'M'.
        PERFORM read_dynamic_table.
      WHEN OTHERS.
        "interne Tabelle erzeugen
        CREATE DATA ldo_data TYPE TABLE OF (ls_cloned-tabname).
        ASSIGN ldo_data->* TO <lt_itab>.
        READ TABLE lt_xstring INTO lx INDEX ls_cloned-index. "Tabelle füllen aus xstring
        REFRESH <lt_itab>.

        "Bei Strukturunterschied
        TRY.
            IMPORT p1 = <lt_itab> FROM DATA BUFFER lx. "itab Tabelle füllen dekodiert aus lx
          CATCH cx_root.
            PERFORM add_result
              USING ls_cloned-tabname add_info l_lines l_size sy-dbcnt 2 'konnte wegen Strukturunterschied nicht importiert werden.' .
            CONTINUE. "nächster Loop
        ENDTRY.
    ENDCASE.

    DESCRIBE TABLE <lt_itab> LINES l_lines. "Datensätze
    CLEAR add_info.
    IF ls_cloned-tabname BETWEEN 'PCL1' AND 'PCL5'.
      READ TABLE <lt_itab> ASSIGNING <ls_line> INDEX 1.
      ASSIGN COMPONENT 'RELID' OF STRUCTURE <ls_line> TO <l_relid>.
      add_info = <l_relid>.
    ENDIF.

    cmsg = |Tabelle schreiben: { ls_cloned-tabname } ({ sy-tabix }/{ lines( lt_cloned ) })|.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = sy-tabix * 100 / lines( lt_cloned )
        text       = cmsg.


    "Schreiben
    l_size = xstrlen( lx ) / 1024.

    TRY.
        IF p_test IS INITIAL.
          INSERT (ls_cloned-tabname) FROM TABLE <lt_itab>.
          IF sy-subrc EQ 0.
            IF p_det IS NOT INITIAL.
              PERFORM add_result
                USING ls_cloned-tabname add_info l_lines l_size sy-dbcnt 0 'geklont'.
            ENDIF.
          ENDIF.
        ELSE.
          IF p_det IS NOT INITIAL.
            PERFORM add_result
              USING ls_cloned-tabname add_info l_lines l_size 0 4 'getestet' .
          ENDIF.
        ENDIF.

      CATCH cx_sy_open_sql_db.
        IF p_test IS INITIAL.
          DELETE (ls_cloned-tabname) FROM TABLE <lt_itab>.
          INSERT (ls_cloned-tabname) FROM TABLE <lt_itab>.
          IF sy-subrc EQ 0.
            IF p_det IS NOT INITIAL.
              PERFORM add_result
                USING ls_cloned-tabname add_info l_lines l_size sy-dbcnt 0 'geklont. Sätze gelöscht'.
            ENDIF.
          ENDIF.
        ELSE.
          IF p_det IS NOT INITIAL.
            PERFORM add_result
              USING ls_cloned-tabname add_info l_lines l_size 0 4 'getestet'.
          ENDIF.
        ENDIF.
    ENDTRY.

  ENDLOOP.

ENDFORM.                    " WRITE_DATA_TO_TABLES
*&---------------------------------------------------------------------*
*&      Form  CHECK_PERNR_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_pernr_selection .
  DATA lv_answer TYPE c LENGTH 1.
  IF s_pernr[] IS INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Nachfrage'
        text_question         = 'Sollen wirklich alle Personalnummern kopiert werden?'
        text_button_1         = 'Ja'
        icon_button_1         = 'ICON_OKAY'
        text_button_2         = 'Nein'
        icon_button_2         = 'ICON_CANCEL'
        default_button        = '2'
        display_cancel_button = abap_true
      IMPORTING
        answer                = lv_answer.

    IF lv_answer <> '1'.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_MANDT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_mandt .
  DATA ls_t000 TYPE t000.

  SELECT SINGLE cccategory
    INTO @ls_t000-cccategory
    FROM t000
    WHERE mandt = @sy-mandt.

  IF ls_t000-cccategory EQ 'P'.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = 'Abbruch'
        txt1  = 'Das Programm darf nicht auf'
        txt2  = 'Produktivsystemen gestartet werden.'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.

*-----------------------------------------------------------------------
* Ergebniszeile hinzufügen
*-----------------------------------------------------------------------
FORM add_result
  USING
    iv_tabname  TYPE tabname
    iv_add_info TYPE text20
    iv_lines    TYPE i
    iv_size     TYPE i
    iv_dbcnt    TYPE i
    iv_subrc    TYPE sysubrc
    iv_error    TYPE char200.

  CLEAR gs_result.

  gs_result-tabname     = iv_tabname.
  gs_result-add_info    = iv_add_info.
  gs_result-lines_read  = iv_lines.
  gs_result-size_kb     = iv_size.
  gs_result-lines_write = iv_dbcnt.

  "---------------------------------------------------------------------
  " Ampellogik
  "---------------------------------------------------------------------
  CASE iv_subrc.
    WHEN 4.
      gs_result-status  = icon_yellow_light.
      gs_result-message = iv_error.
    WHEN 0.
      gs_result-status  = icon_green_light.
      gs_result-message = iv_error.
    WHEN 2.
      gs_result-status  = icon_red_light.
      gs_result-message = iv_error.

    WHEN OTHERS.
  ENDCASE.

  APPEND gs_result TO gt_result.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SHOW_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_result .
  DATA:
    lo_alv       TYPE REF TO cl_salv_table,
    lo_columns   TYPE REF TO cl_salv_columns_table,
    lo_column    TYPE REF TO cl_salv_column_table,
    lo_functions TYPE REF TO cl_salv_functions_list,
    lo_display   TYPE REF TO cl_salv_display_settings,
    lo_sort      TYPE REF TO cl_salv_sorts.

  IF gt_result IS INITIAL.
*    MESSAGE 'Es sind keine Protokolleinträge vorhanden' TYPE 'S'.
    RETURN.
  ENDIF.

  TRY.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_result ).

      "-----------------------------------------------------------------
      " Funktionen aktivieren
      "-----------------------------------------------------------------
      lo_functions = lo_alv->get_functions( ).
      lo_functions->set_all( abap_true ).

      "-----------------------------------------------------------------
      " Anzeigeoptionen
      "-----------------------------------------------------------------
      lo_display = lo_alv->get_display_settings( ).
      lo_display->set_striped_pattern( abap_true ).
      lo_display->set_list_header(
        'Protokoll der Tabellen- und Clusterverarbeitung'
      ).

      "-----------------------------------------------------------------
      " Spalten optimieren
      "-----------------------------------------------------------------
      lo_columns = lo_alv->get_columns( ).
*      lo_columns->set_optimize( abap_true ).

      "-----------------------------------------------------------------
      " Status
      "-----------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'STATUS' ).

          lo_column->set_short_text( 'St.' ).
          lo_column->set_medium_text( 'Status' ).
          lo_column->set_long_text( 'Verarbeitungsstatus' ).
          lo_column->set_output_length( 8 ).

        CATCH cx_salv_not_found.
      ENDTRY.

      "-----------------------------------------------------------------
      " Tabelle
      "-----------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'TABNAME' ).

          lo_column->set_short_text( 'Tabelle' ).
          lo_column->set_medium_text( 'Tabelle' ).
          lo_column->set_long_text( 'Tabellenname' ).

        CATCH cx_salv_not_found.
      ENDTRY.

      "-----------------------------------------------------------------
      " RELID
      "-----------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'RELID' ).

          lo_column->set_short_text( 'RELID' ).
          lo_column->set_medium_text( 'Cluster-ID' ).
          lo_column->set_long_text( 'Clusterbereich RELID' ).

        CATCH cx_salv_not_found.
      ENDTRY.

      "-----------------------------------------------------------------
      " Zusatzinformation
      "-----------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'ADD_INFO' ).

          lo_column->set_short_text( 'Info' ).
          lo_column->set_medium_text( 'Information' ).
          lo_column->set_long_text( 'Zusätzliche Information' ).
          lo_column->set_output_length( 10 ).

        CATCH cx_salv_not_found.
      ENDTRY.

      "-----------------------------------------------------------------
      " Gelesene Datensätze
      "-----------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'LINES_READ' ).

          lo_column->set_short_text( 'Gelesen' ).
          lo_column->set_medium_text( 'Gelesen' ).
          lo_column->set_long_text( 'Anzahl gelesener Datensätze' ).

        CATCH cx_salv_not_found.
      ENDTRY.

      "-----------------------------------------------------------------
      " Datenmenge
      "-----------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'SIZE_KB' ).

          lo_column->set_short_text( 'Größe' ).
          lo_column->set_medium_text( 'Größe kB' ).
          lo_column->set_long_text( 'Datenmenge in Kilobyte' ).

        CATCH cx_salv_not_found.
      ENDTRY.

      "-----------------------------------------------------------------
      " Geschriebene Datensätze
      "-----------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'LINES_WRITE' ).

          lo_column->set_short_text( 'Geschr.' ).
          lo_column->set_medium_text( 'Geschrieben' ).
          lo_column->set_long_text( 'Anzahl geschriebener Datensätze' ).

        CATCH cx_salv_not_found.
      ENDTRY.

      "-----------------------------------------------------------------
      " Meldung
      "-----------------------------------------------------------------
      TRY.
          lo_column ?= lo_columns->get_column( 'MESSAGE' ).

          lo_column->set_short_text( 'Meldung' ).
          lo_column->set_medium_text( 'Meldung' ).
          lo_column->set_long_text( 'Verarbeitungsmeldung' ).
          lo_column->set_output_length( 60 ).

        CATCH cx_salv_not_found.
      ENDTRY.

*      "-----------------------------------------------------------------
*      " Nach Status sortieren
*      "-----------------------------------------------------------------
*      lo_sort = lo_alv->get_sorts( ).
*
*      TRY.
*          lo_sort->add_sort(
*            columnname = 'STATUS'
*            position   = 1
*            sequence   = if_salv_c_sort=>sort_down ).
*
*        CATCH cx_salv_existing
*              cx_salv_data_error
*              cx_salv_not_found.
*      ENDTRY.

      lo_alv->display( ).

    CATCH cx_salv_msg INTO DATA(lx_salv).
      MESSAGE lx_salv->get_text( ) TYPE 'I'.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  WRITE_GOS
*&---------------------------------------------------------------------*
FORM write_gos .


*---------------------------------------------------------------------*
* Typen
*---------------------------------------------------------------------*
  TYPES:
    BEGIN OF ty_attachment,
      pernr        TYPE pernr_d,
      instid_a     TYPE srgbtbrel-instid_a,
      typeid_a     TYPE srgbtbrel-typeid_a,
      instid_b     TYPE srgbtbrel-instid_b,
      typeid_b     TYPE srgbtbrel-typeid_b,
      reltype      TYPE srgbtbrel-reltype,

      objtp        TYPE sood-objtp,
      objyr        TYPE sood-objyr,
      objno        TYPE sood-objno,
      objdes       TYPE sood-objdes,

      filename     TYPE string,
      file_ext     TYPE string,
      file_size    TYPE i,

      content_hex  TYPE solix_tab,
      content_xstr TYPE xstring,
    END OF ty_attachment,

    tt_attachment TYPE STANDARD TABLE OF ty_attachment
                  WITH DEFAULT KEY.

*---------------------------------------------------------------------*
* Daten
*---------------------------------------------------------------------*
  DATA:
    gt_attachments TYPE tt_attachment.

  DATA:
    ls_attachment TYPE ty_attachment,
    ls_folder_id  TYPE soodk,
    ls_docdata    TYPE sodocchgi1,
    ls_docinfo    TYPE sofolenti1,
    lv_doc_type   TYPE so_obj_tp,
    lt_hex        TYPE solix_tab,
    ls_obj_a      TYPE borident,
    ls_obj_b      TYPE borident,
    ls_binrel     TYPE gbinrel,
    lt_binatt     TYPE STANDARD TABLE OF brelattr,
    lv_size       TYPE i,
    lv_filename   TYPE string,
    lv_descr      TYPE so_obj_des,
    lv_obj_name   TYPE so_obj_nam,
    lt_objhead    TYPE STANDARD TABLE OF soli,
    ls_objhead    TYPE soli.

  "import binär
  TRY.
      READ TABLE lt_xstring INTO lx INDEX ls_cloned-index. "Tabelle füllen aus xstring
      IMPORT p1 = gt_attachments FROM DATA BUFFER lx. "itab Tabelle füllen dekodiert aus lx
    CATCH cx_root.
      PERFORM add_result
        USING ls_cloned-tabname 'G' l_lines l_size sy-dbcnt 2 'GOS konnte nicht importiert werden.' .

  ENDTRY.
  DESCRIBE TABLE gt_attachments LINES l_lines. "Datensätze

  "Schreiben
  l_size = xstrlen( lx ) / 1024.
  DESCRIBE TABLE gt_attachments LINES l_lines.

  LOOP AT gt_attachments INTO ls_attachment.

    cmsg = |GOS schreiben: { ls_cloned-tabname } ({ sy-tabix }/{ lines( gt_attachments ) })|.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = sy-tabix * 100 / lines( lt_cloned )
        text       = cmsg.


*--------------------------------------------------------------------*
* Personalnummer normalisieren
*--------------------------------------------------------------------*

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_attachment-pernr
      IMPORTING
        output = ls_attachment-pernr.


*--------------------------------------------------------------------*
* SAPoffice Root-Folder holen
*
* Region B = Business Documents
*--------------------------------------------------------------------*
    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
      EXPORTING
        region    = 'B'
      IMPORTING
        folder_id = ls_folder_id
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc <> 0.
      WRITE: / 'Fehler bei SO_FOLDER_ROOT_ID_GET:', sy-subrc.
      RETURN.
    ENDIF.


*--------------------------------------------------------------------*
* Alle übertragenen Anlagen anlegen
*--------------------------------------------------------------------*
    CLEAR:
      ls_docdata,
      ls_docinfo,
      lt_hex,
      ls_obj_a,
      ls_obj_b,
      ls_binrel,
      lt_binatt,
      lv_size,
      lv_filename,
      lv_descr,
      lv_obj_name.


*--------------------------------------------------------------------*
* Binärdaten
*--------------------------------------------------------------------*
    IF ls_attachment-content_hex IS NOT INITIAL.

      lt_hex = ls_attachment-content_hex.

      lv_size = ls_attachment-file_size.

    ELSEIF ls_attachment-content_xstr IS NOT INITIAL.

*--------------------------------------------------------------------*
* XSTRING -> SOLIX
*--------------------------------------------------------------------*
      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer        = ls_attachment-content_xstr
        IMPORTING
          output_length = lv_size
        TABLES
          binary_tab    = lt_hex.

      IF sy-subrc <> 0.
        WRITE: / 'Fehler XSTRING -> SOLIX bei',
                 ls_attachment-filename.
        CONTINUE.
      ENDIF.

    ELSE.

      WRITE: / 'Kein Inhalt vorhanden:',
               ls_attachment-filename.

      CONTINUE.

    ENDIF.


*--------------------------------------------------------------------*
* Dateiname
*--------------------------------------------------------------------*
    lv_filename = ls_attachment-filename.

    IF lv_filename IS INITIAL.

      lv_filename = ls_attachment-objdes.

      IF lv_filename IS INITIAL.
        lv_filename = 'Attachment'.
      ENDIF.

      IF ls_attachment-file_ext IS NOT INITIAL.
        CONCATENATE lv_filename
                    '.'
                    ls_attachment-file_ext
               INTO lv_filename.
      ENDIF.

    ENDIF.


*--------------------------------------------------------------------*
* Beschreibung
*--------------------------------------------------------------------*
    lv_descr = ls_attachment-objdes.

    IF lv_descr IS INITIAL.
      lv_descr = lv_filename.
    ENDIF.


*--------------------------------------------------------------------*
* OBJ_NAME hat eine relativ kurze SAPoffice-Länge.
* Deshalb nicht blind kompletten Dateinamen hineinpacken.
*--------------------------------------------------------------------*
    lv_obj_name = lv_filename.


*--------------------------------------------------------------------*
* SAPoffice Dokumentdaten
*--------------------------------------------------------------------*
    ls_docdata-obj_name  = lv_obj_name.
    ls_docdata-obj_descr = lv_descr.
    ls_docdata-doc_size  = lv_size.

    lv_doc_type = ls_attachment-file_ext.
    TRANSLATE   lv_doc_type  TO UPPER CASE.


*--------------------------------------------------------------------*
* SAPoffice Header
*--------------------------------------------------------------------*
    CLEAR ls_objhead.
    REFRESH: lt_objhead.

    CONCATENATE '&SO_FILENAME='
                lv_filename
           INTO ls_objhead-line.

    APPEND ls_objhead TO lt_objhead.

    IF p_test IS NOT INITIAL.

*--------------------------------------------------------------------*
* SAPoffice-Dokument erzeugen
*--------------------------------------------------------------------*
      CALL FUNCTION 'SO_DOCUMENT_INSERT_API1'
        EXPORTING
          folder_id                  = ls_folder_id
          document_data              = ls_docdata
          document_type              = lv_doc_type
        IMPORTING
          document_info              = ls_docinfo
        TABLES
          object_header              = lt_objhead
          contents_hex               = lt_hex
        EXCEPTIONS
          folder_not_exist           = 1
          document_type_not_exist    = 2
          operation_no_authorization = 3
          parameter_error            = 4
          x_error                    = 5
          enqueue_error              = 6
          OTHERS                     = 7.

      IF sy-subrc <> 0.

        WRITE: / 'Fehler SO_DOCUMENT_INSERT_API1:',
                 sy-subrc,
                 lv_filename.

        CONTINUE.

      ENDIF.


*--------------------------------------------------------------------*
* Business Object A:
*
* PA30 Mitarbeiter = BUS1065
*--------------------------------------------------------------------*
      ls_obj_a-objtype = 'BUS1065'.
      ls_obj_a-objkey  = ls_attachment-pernr.


*--------------------------------------------------------------------*
* Business Object B:
*
* Neu angelegtes SAPoffice-Dokument
*
* DOCUMENT_INFO-DOC_ID liefert den kompletten Schlüssel:
*
* z.B.
* FOL2600000000024EXT5100000000033
*--------------------------------------------------------------------*
      ls_obj_b-objtype = 'MESSAGE'.
      ls_obj_b-objkey  = ls_docinfo-doc_id.


*--------------------------------------------------------------------*
* GOS Beziehung erzeugen
*
* ATTA = Attachment
*--------------------------------------------------------------------*
      CALL FUNCTION 'BINARY_RELATION_CREATE_COMMIT'
        EXPORTING
          obj_rolea      = ls_obj_a
          obj_roleb      = ls_obj_b
          relationtype   = 'ATTA'
        IMPORTING
          binrel         = ls_binrel
        TABLES
          binrel_attrib  = lt_binatt
        EXCEPTIONS
          no_model       = 1
          internal_error = 2
          unknown        = 3
          OTHERS         = 4.

      IF sy-subrc <> 0.

        WRITE: / 'Fehler BINARY_RELATION_CREATE_COMMIT:',
                 sy-subrc,
                 lv_filename.

        CONTINUE.

      ENDIF.
    ENDIF.
*    WRITE: / 'Anlage angelegt:',
*             lv_filename,
*             'PERNR:',
*             ls_attachment-pernr,
*             'DOC_ID:',
*             ls_docinfo-doc_id.

  ENDLOOP.

  PERFORM add_result
    USING ls_cloned-tabname 'G' l_lines l_size 0 0 'GOS angelegt'.

ENDFORM.
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
FORM save_lt_xstring_to_file.

  DATA: lv_file_xstr   TYPE xstring,
        lt_bin         TYPE solix_tab,
        lv_bin_size    TYPE i,
        lv_filename    TYPE string,
        lv_path        TYPE string,
        lv_fullpath    TYPE string,
        lv_action      TYPE i,
        lv_defaultname TYPE string.

  IF lt_xstring IS INITIAL.
    MESSAGE 'Keine XSTRING-Daten zum Speichern vorhanden.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF sy-batch IS NOT INITIAL.
    MESSAGE 'Lokaler Download ist im Hintergrund nicht möglich.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  lv_defaultname = |clonetool2_{ sy-datum }_{ sy-uzeit }.bin|.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      window_title      = 'Clone-Daten speichern'
      default_extension = 'bin'
      default_file_name = lv_defaultname
      file_filter       = 'Binärdatei (*.bin)|*.bin|Alle Dateien (*.*)|*.*'
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath
      user_action       = lv_action
    EXCEPTIONS
      OTHERS            = 1 ).

  IF sy-subrc <> 0
     OR lv_action = cl_gui_frontend_services=>action_cancel
     OR lv_fullpath IS INITIAL.
    RETURN.
  ENDIF.

  EXPORT lt_xstring = lt_xstring
         lt_cloned  = lt_cloned
         lt_pernr   = lt_pernr
    TO DATA BUFFER lv_file_xstr.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_file_xstr
    IMPORTING
      output_length = lv_bin_size
    TABLES
      binary_tab    = lt_bin.

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      bin_filesize = lv_bin_size
      filename     = lv_fullpath
      filetype     = 'BIN'
    CHANGING
      data_tab     = lt_bin
    EXCEPTIONS
      OTHERS       = 1 ).

  IF sy-subrc <> 0.
    MESSAGE |Datei konnte nicht gespeichert werden. Fehler { sy-subrc }| TYPE 'E'.
  ENDIF.

  MESSAGE |Clone-Daten gespeichert: { lv_fullpath }| TYPE 'S'.

ENDFORM.
