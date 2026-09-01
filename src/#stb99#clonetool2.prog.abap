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

  IF p_save IS NOT INITIAL AND
     p_del IS NOT INITIAL AND
     p_test IS INITIAL.
    PERFORM delete_target_pernr.
  ENDIF.

  PERFORM write_data_to_tables.

  IF p_down IS NOT INITIAL.
    PERFORM save_lt_xstring_to_package.
  ENDIF.
  PERFORM show_result.
  PERFORM liste.

END-OF-SELECTION.
  WRITE:/ 'Programmlauf beendet.'.

  INCLUDE /stb99/clonetool2_forms.
FORM overwrite_customizing_with_sel .
  p_custom-destination = p_dest.

  IF p_org   IS NOT INITIAL. p_custom-org   = p_org.   ENDIF.
  IF p_wegid IS NOT INITIAL. p_custom-wegid = p_wegid. ENDIF.
  IF p_calc  IS NOT INITIAL. p_custom-calc  = p_calc.  ENDIF.
  IF p_pcp0  IS NOT INITIAL. p_custom-pcp0  = p_pcp0.  ENDIF.
  IF p_deuv  IS NOT INITIAL. p_custom-deuv  = p_deuv.  ENDIF.
  IF p_lstb  IS NOT INITIAL. p_custom-lstb  = p_lstb.  ENDIF.
  IF p_elsta IS NOT INITIAL. p_custom-elsta = p_elsta. ENDIF.
  IF p_elena IS NOT INITIAL. p_custom-elena = p_elena. ENDIF.
  IF p_bv    IS NOT INITIAL. p_custom-bv    = p_bv.    ENDIF.
  IF p_ea    IS NOT INITIAL. p_custom-ea    = p_ea.    ENDIF.
  IF p_ee    IS NOT INITIAL. p_custom-ee    = p_ee.    ENDIF.
  IF p_rbm   IS NOT INITIAL. p_custom-rbm   = p_rbm.   ENDIF.
  IF p_sv    IS NOT INITIAL. p_custom-sv    = p_sv.    ENDIF.
  IF p_zs    IS NOT INITIAL. p_custom-zs    = p_zs.    ENDIF.
  IF p_bav   IS NOT INITIAL. p_custom-bav   = p_bav.   ENDIF.
  IF p_time  IS NOT INITIAL. p_custom-time  = p_time.  ENDIF.
*  IF p_lohn  IS NOT INITIAL. p_custom-lohn  = p_lohn.  ENDIF.
  IF p_trvl  IS NOT INITIAL. p_custom-trvl  = p_trvl.  ENDIF.
  IF p_a1    IS NOT INITIAL. p_custom-a1    = p_a1.    ENDIF.
  IF p_test  IS NOT INITIAL. p_custom-test  = p_test.  ENDIF.
  IF p_det   IS NOT INITIAL. p_custom-det   = p_det.   ENDIF.
  IF p_del   IS NOT INITIAL. p_custom-del   = p_del.   ENDIF.
  IF p_eau   IS NOT INITIAL. p_custom-eau   = p_eau.   ENDIF.
  IF p_krank IS NOT INITIAL. p_custom-krank = p_krank. ENDIF.
  IF p_rent  IS NOT INITIAL. p_custom-rent  = p_rent.  ENDIF.
  IF p_lsta  IS NOT INITIAL. p_custom-lsta  = p_lsta.  ENDIF.
  IF p_eubp  IS NOT INITIAL. p_custom-eubp  = p_eubp.  ENDIF.
  IF p_betri IS NOT INITIAL. p_custom-betri = p_betri. ENDIF.
  IF p_beitr IS NOT INITIAL. p_custom-beitr = p_beitr. ENDIF.
  IF p_agkto IS NOT INITIAL. p_custom-agkto = p_agkto. ENDIF.
  IF p_dabpv IS NOT INITIAL. p_custom-dabpv = p_dabpv. ENDIF.
  IF p_rvbf  IS NOT INITIAL. p_custom-rvbf  = p_rvbf.  ENDIF.
  IF p_gos   IS NOT INITIAL. p_custom-gos   = p_gos.   ENDIF.
  IF p_b2a   IS NOT INITIAL. p_custom-b2a   = p_b2a.   ENDIF.
  IF p_uvm   IS NOT INITIAL. p_custom-uvm   = p_uvm.   ENDIF.
  IF p_uvm   IS NOT INITIAL. p_custom-uvm   = p_uvm.   ENDIF.
  IF p_rvBEA IS NOT INITIAL. p_custom-rvBEA = p_rvBEA. ENDIF.
  IF p_BEA   IS NOT INITIAL. p_custom-BEA   = p_BEA.   ENDIF.

ENDFORM.                    " OVERWRITE_CUSTOMIZING_WITH_SEL
*&---------------------------------------------------------------------*
*&      Form  SAVE_LT_XSTRING_TO_PACKAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_lt_xstring_to_package.

  DATA: lv_folder   TYPE string,
        lv_manifest TYPE xstring,
        lv_file     TYPE string.

  IF lt_xstring IS INITIAL.
    MESSAGE 'Keine XSTRING-Daten zum Speichern vorhanden.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  cl_gui_frontend_services=>directory_browse(
    EXPORTING
      window_title    = 'Zielverzeichnis auswählen'
    CHANGING
      selected_folder = lv_folder
    EXCEPTIONS
      OTHERS          = 1 ).

  IF sy-subrc <> 0 OR lv_folder IS INITIAL.
    RETURN.
  ENDIF.



  LOOP AT lt_xstring INTO lx.
    DATA(lv_index) = sy-tabix.
    cmsg = |Download verarbeiten: ({ sy-index }/{ lines( lt_xstring ) })|.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = sy-tabix * 100 / lines( lt_cloned )
        text       = cmsg.
    PERFORM download_xstring_chunks USING lx lv_folder lv_index.
  ENDLOOP.

  EXPORT lt_cloned = lt_cloned
          lt_pernr  = lt_pernr
          gt_package_parts  = gt_package_parts
     TO DATA BUFFER lv_manifest.

  lv_file = |{ lv_folder }\\manifest.bin|.
  PERFORM download_xstring_file USING lv_manifest lv_file.



  MESSAGE |Clone-Paket gespeichert: { lv_folder }| TYPE 'S'.

ENDFORM.

FORM download_xstring_chunks
  USING
    iv_xstring TYPE xstring
    iv_folder  TYPE string
    iv_index   TYPE i.

  DATA: lv_size   TYPE i,
        lv_offset TYPE i,
        lv_len    TYPE i,
        lv_part   TYPE i VALUE 1,
        lv_xpart  TYPE xstring,
        lv_file   TYPE string,
        lv_idx    TYPE n LENGTH 6,
        lv_prt    TYPE n LENGTH 4.

  lv_size = xstrlen( iv_xstring ).
  lv_idx = iv_index.

  WHILE lv_offset < lv_size.

    lv_len = lc_chunk_size.

    IF lv_offset + lv_len > lv_size.
      lv_len = lv_size - lv_offset.
    ENDIF.

    lv_xpart = iv_xstring+lv_offset(lv_len).
    lv_prt = lv_part.
    lv_file = |{ iv_folder }\\data_{ lv_idx }_{ lv_prt }.bin|.

    PERFORM download_xstring_file USING lv_xpart lv_file.

    lv_offset = lv_offset + lv_len.
    lv_part = lv_part + 1.

  ENDWHILE.

  ls_package_part-index = iv_index.
  ls_package_part-parts = lv_part - 1.
  APPEND ls_package_part TO gt_package_parts.

ENDFORM.

FORM download_xstring_file
  USING
    iv_xstring TYPE xstring
    iv_file    TYPE string.

  DATA: lt_bin  TYPE solix_tab,
        lv_size TYPE i.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = iv_xstring
    IMPORTING
      output_length = lv_size
    TABLES
      binary_tab    = lt_bin.

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      bin_filesize = lv_size
      filename     = iv_file
      filetype     = 'BIN'
    CHANGING
      data_tab     = lt_bin
    EXCEPTIONS
      OTHERS       = 1 ).

  IF sy-subrc <> 0.
    MESSAGE |Datei konnte nicht gespeichert werden: { iv_file }| TYPE 'E'.
  ENDIF.


ENDFORM.
