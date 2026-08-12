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
*&      Form  GET_CUSTOMIZING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_customizing .
  DATA: ls_tmp   TYPE /stb99/ct2_cust,
        lr_desc  TYPE REF TO cl_abap_structdescr,
        lv_param TYPE string.

  FIELD-SYMBOLS:
    <field> TYPE any,
    <param> TYPE any.

  SELECT SINGLE *
    FROM /stb99/ct2_cust
    INTO @ls_tmp
   WHERE destination = @p_dest.

  IF sy-subrc <> 0.
    SELECT  *
      FROM /stb99/ct2_cust UP TO 1 ROWS
      INTO @ls_tmp ORDER BY destination ASCENDING.
      EXIT.
    ENDSELECT.
  ENDIF.

  lr_desc ?= cl_abap_typedescr=>describe_by_data( ls_tmp ).

  LOOP AT lr_desc->components INTO DATA(ls_comp).

    ASSIGN COMPONENT ls_comp-name OF STRUCTURE ls_tmp TO <field>.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    IF ls_comp-name = 'DESTINATION'.
      lv_param = 'P_DEST'.
    ELSE.
      CONCATENATE 'P_' ls_comp-name INTO lv_param.
    ENDIF.

    ASSIGN (lv_param) TO <param>.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    <param> = <field>.

  ENDLOOP.
ENDFORM.
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

  PERFORM add_result
    USING ls_cloned-tabname 'G' l_lines l_size sy-dbcnt 0 'geklont. Sätze gelöscht'.

ENDFORM.
