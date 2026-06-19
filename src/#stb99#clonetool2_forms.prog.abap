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
  if p_det IS NOT INITIAL.WRITE: / 'Job', jobname, 'zum Löschen der Daten ausgeführt'.endif.

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

  IF p_list IS NOT INITIAL.
    LOOP AT s_pernr.
      WRITE:/ 'Personalnummer', s_pernr-low, 'kopiert'.
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
  "Schreiben der übermittelten Daten aus dem Produktivsystem
  LOOP AT lt_cloned INTO ls_cloned. "Tabellennamen

    CREATE DATA ldo_data TYPE TABLE OF (ls_cloned-tabname).
    ASSIGN ldo_data->* TO <lt_itab>.

    READ TABLE lt_xstring INTO lx INDEX ls_cloned-index. "Tabelle füllen aus xstring

    REFRESH <lt_itab>.
    "Bei Strukturunterschied
    TRY.
        IMPORT p1 = <lt_itab> FROM DATA BUFFER lx. "itab Tabelle füllen dekodiert aus lx
      CATCH cx_root.
        WRITE:/ 'Tabelle:' , ls_cloned-tabname, l_lines, 'konnte wegen Strukturunterschied nicht importiert werden.' COLOR COL_NEGATIVE.
        CONTINUE. "nächster Loop
    ENDTRY.

    DESCRIBE TABLE <lt_itab> LINES l_lines. "Datensätze

    CONCATENATE 'Tabelle schreiben:' ls_cloned-tabname INTO cmsg.
    CALL FUNCTION 'PROGRESS_INDICATOR'
      EXPORTING
        i_text               = cmsg
        i_output_immediately = 'X'.

    "Schreiben
    l_size = xstrlen( lx ) / 1024.

    TRY.
        IF p_test IS INITIAL.
          INSERT (ls_cloned-tabname) FROM TABLE <lt_itab>.
          IF sy-subrc EQ 0.
            if p_det IS NOT INITIAL. WRITE:/ 'Tabelle:' , ls_cloned-tabname, l_lines, 'Einträge geklont. Länge:', l_size, 'kB', 'geschrieben: ', sy-dbcnt, 'Sätze'.endif.
          ENDIF.
        ELSE.
          if p_det IS NOT INITIAL. WRITE:/ 'Tabelle:' , ls_cloned-tabname, l_lines, 'Einträge getestet. Länge:', l_size, 'kB'.endif.
        ENDIF.

      CATCH cx_sy_open_sql_db.
        IF p_test IS INITIAL.
          DELETE (ls_cloned-tabname) FROM TABLE <lt_itab>.
          INSERT (ls_cloned-tabname) FROM TABLE <lt_itab>.
          IF sy-subrc EQ 0.
            if p_det IS NOT INITIAL. WRITE:/ 'Tabelle:' , ls_cloned-tabname, l_lines, 'Einträge geklont. Länge:', l_size, 'kB', 'geschrieben: ', sy-dbcnt, 'Sätze. Sätze wurden vorher gelöscht'.endif.
          ENDIF.
        ELSE.
          if p_det IS NOT INITIAL. WRITE:/ 'Tabelle:' , ls_cloned-tabname, l_lines, 'Einträge getestet. Länge:', l_size, 'kB'.endif.
        ENDIF.
    ENDTRY.

  ENDLOOP.

ENDFORM.                    " WRITE_DATA_TO_TABLES
