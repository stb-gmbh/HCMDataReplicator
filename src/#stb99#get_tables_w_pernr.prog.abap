*&---------------------------------------------------------------------*
*& Report  /STB99/ALV_MUSTER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  /stb99/get_tables_w_pernr USING DATABASE pnp.


TABLES: dd03l.


rp-lowdate-highdate.
TYPE-POOLS: slis.


DATA:
      wa_data TYPE /stb99/get_tables_w_pernr,
      t_data TYPE TABLE OF /stb99/get_tables_w_pernr.

DATA:
      t_fields TYPE slis_t_fieldcat_alv,
      wa_fields LIKE LINE OF t_fields.

DATA:
      t_criteria TYPE slis_t_sortinfo_alv,
      wa_criteria LIKE LINE OF t_criteria.

DATA:
      t_layout TYPE slis_layout_alv.

*-----Fehlertabelle
DATA: error_tab LIKE hrerror OCCURS 0 WITH HEADER LINE.


DATA: is_variant LIKE disvariant,
      es_variant LIKE disvariant.


DATA: lt_dd03l TYPE TABLE OF dd03l,
      ls_dd03l TYPE dd03l.

DATA: lt_dd02l TYPE TABLE OF dd02l,
      ls_dd02l TYPE dd02l.


DATA: lt_dd02t TYPE TABLE OF dd02t,
      ls_dd02t TYPE dd02t.
DATA: l_ddtext LIKE ls_dd02t-ddtext.


* Selection Screen ----------------------------------------------------


SELECTION-SCREEN BEGIN OF BLOCK 011 WITH FRAME.
SELECT-OPTIONS: s_tabnam FOR dd03l-tabname.
SELECTION-SCREEN END OF BLOCK 011.



SELECTION-SCREEN BEGIN OF BLOCK 010 WITH FRAME TITLE text-or3.
PARAMETERS: variant LIKE disvariant-variant.    " DEFAULT '/LISTE'.
SELECTION-SCREEN END OF BLOCK 010.


*----------------------------------------------------------------------*
*                      AT SELECTION-SCREEN                             *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF NOT variant IS INITIAL.
    es_variant-variant = variant.

    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = es_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE e225(72).
    ENDIF.
  ELSE.
    CLEAR es_variant.
    es_variant-report = sy-repid.
  ENDIF.


*----------------------------------------------------------------------*
*       AT SELECTION-SCREEN ON VALUE-REQUEST FOR VARIANT               *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR variant.
  is_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = is_variant
      i_save        = 'A'
    IMPORTING
      es_variant    = es_variant
    EXCEPTIONS
      not_found     = 1
      program_error = 2
      OTHERS        = 3.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    variant = es_variant-variant.
  ENDIF.


*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  s_tabnam-low = 'PA*'.
  s_tabnam-sign = 'E'.
  s_tabnam-option = 'CP'.
  APPEND s_tabnam.
  s_tabnam-low = 'PB*'.
  APPEND s_tabnam.
  s_tabnam-low = 'HRP*'.
  APPEND s_tabnam.
  s_tabnam-low = '/*'.
  APPEND s_tabnam.

*-----Variante initialisieren
  is_variant-report = sy-repid.
  es_variant = is_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save        = 'A'
    CHANGING
      cs_variant    = es_variant
    EXCEPTIONS
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      OTHERS        = 4.
  IF sy-subrc EQ 0.
    variant = es_variant-variant.
  ENDIF.



*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*


  SELECT  dd03l~tabname
          dd03l~fieldname
  FROM    dd03l
  JOIN    dd02l
    ON    dd03l~tabname = dd02l~tabname
  INTO  CORRESPONDING FIELDS OF TABLE lt_dd03l
  WHERE dd03l~tabname IN s_tabnam
    AND dd03l~fieldname = 'PERNR'
    AND dd02l~tabclass = 'TRANSP'
    AND dd02l~clidep = 'X'.


  LOOP AT lt_dd03l INTO ls_dd03l.
    MOVE-CORRESPONDING ls_dd03l TO wa_data.
    SELECT SINGLE ddtext INTO wa_data-ddtext
      FROM dd02t
      WHERE tabname EQ ls_dd03l-tabname
        AND ddlanguage EQ 'DE'.
    APPEND wa_data TO t_data.

  ENDLOOP.


**----------------------------------------------------------------------*
*GET pernr.
**----------------------------------------------------------------------*


*----------------------------------------------------------------------*
END-OF-SELECTION.
*----------------------------------------------------------------------*

  PERFORM display_errors.
  PERFORM alv_feldkatalog.
  PERFORM alv_criteria.
  PERFORM alv_ausgabe.


*&---------------------------------------------------------------------*
*&      Form  alv_feldkatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_feldkatalog.
*
*  DATA  : et_dfies TYPE icl_dfies_tab.
*  DATA  : wa_dfies TYPE LINE OF icl_dfies_tab.
*  DATA  : et_dfies_key_fields TYPE icl_dfies_tab.
*  DATA  : tmp_fields TYPE slis_t_fieldcat_alv.

  DATA  : et_dfies TYPE dfies_tab.
  DATA  : wa_dfies TYPE LINE OF dfies_tab.
  DATA  : et_dfies_key_fields TYPE dfies_tab.
  DATA  : tmp_fields TYPE slis_t_fieldcat_alv.

*Aus dem DDIC lesen und einzelne Strukturen auflösen und anfügen
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname              = '/STB99/GET_TABLES_W_PERNR'
*   FIELDNAME            = ' '
*   LANGU                = SY-LANGU
*   LFIELDNAME           = ' '
     all_types            = 'X'
*   GROUP_NAMES          = ' '
*   UCLEN                =
* IMPORTING
*   X030L_WA             =
*   DDOBJTYPE            =
*   DFIES_WA             =
*   LINES_DESCR          =
 TABLES
     dfies_tab            = et_dfies
*   FIXED_VALUES         =
* EXCEPTIONS
*   NOT_FOUND            = 1
*   INTERNAL_ERROR       = 2
*   OTHERS               = 3
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT et_dfies INTO wa_dfies
     WHERE datatype NE 'STRU'.
    wa_dfies-fieldname  = wa_dfies-lfieldname.
    MOVE-CORRESPONDING wa_dfies TO wa_fields.
    APPEND wa_fields TO t_fields.
  ENDLOOP.



*Hier wird die Ausgabe der Felder,
*Summierungen, Texte etc. gesetzt
  LOOP AT t_fields INTO wa_fields.
    CASE wa_fields-fieldname.
*Schlüsselfelder
      WHEN 'TABNAME'.
      WHEN 'FIELDNAME'.
      WHEN 'DDTEXT'.

      WHEN OTHERS.
        "andere Felder werden ausgebaut.
        wa_fields-tech = 'X'.
    ENDCASE.

*Numerische Felder ohne Ausgabe bei 0.
    IF wa_fields-datatype EQ 'CURR' OR
        wa_fields-datatype EQ 'NUMC' OR
         wa_fields-datatype EQ 'DEC'.
      wa_fields-no_zero = 'X'.
    ENDIF.


    MODIFY t_fields FROM wa_fields.
  ENDLOOP.
ENDFORM.                    " alv_feldkatalog



*&---------------------------------------------------------------------*
*&      Form  alv_ausgabe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_ausgabe .


  DATA:
        wa_disvariant TYPE disvariant,
        l_report      TYPE sy-repid.

  wa_disvariant-report = l_report = sy-repid.
  wa_disvariant-variant = variant.

  t_layout-zebra                      = 'X'.
  t_layout-totals_only                = 'X'.
  t_layout-colwidth_optimize          = 'X'.
*  t_layout-expand_all                 = ' '.

*  t_layout-totals_before_items        = 'X'.
*  t_layout-subtotals_text             = 'Hallo'.
*  t_layout-no_totalline               = 'X'.

* ALV Grid setzen:
  t_layout-info_fieldname = 'ZFARBE'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = l_report
      i_callback_top_of_page   = 'ALV_TOP_OF_PAGE'
      i_callback_pf_status_set = 'ALV_SET_PF_STATUS'
      i_callback_user_command  = 'ALV_USER_COMMAND'
      it_fieldcat              = t_fields
      it_sort                  = t_criteria
      is_layout                = t_layout
      i_save                   = 'A'
      is_variant               = wa_disvariant
    TABLES
      t_outtab                 = t_data.

ENDFORM.                    " alv_ausgabe



*&---------------------------------------------------------------------*
*&      Form  alv_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_top_of_page .

  DATA: lt_ueberschrift TYPE slis_t_listheader,
        wa_ueberschrift LIKE LINE OF lt_ueberschrift.
  DATA: anzahl(8),
        datum(10).

  CLEAR wa_ueberschrift.
  wa_ueberschrift-typ  = 'H'.
  wa_ueberschrift-info = text-l01.
  APPEND wa_ueberschrift TO lt_ueberschrift.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_ueberschrift.

ENDFORM.                    " alv_top_of_page

*&---------------------------------------------------------------------*
*&      Form  alv_user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_user_command  USING r_ucomm LIKE sy-ucomm
                             rs_selfield TYPE slis_selfield.

  IF r_ucomm = 'REFRESH'.

    CLEAR t_data.
    rs_selfield-refresh    = 'X'.
    rs_selfield-col_stable = 'X'.
    rs_selfield-row_stable = 'X'.

  ENDIF.

ENDFORM.                    " alv_user_command

*&---------------------------------------------------------------------*
*&      Form  alv_set_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_set_pf_status USING rt_extab TYPE slis_t_extab.

* pf-status kopiert vom Programm SAPLSLVC_FULLSCREEN

  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING rt_extab.

ENDFORM.                    " alv_set_pf_status


*&---------------------------------------------------------------------*
*&      Form  alv_criteria
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_criteria .
*
*  CLEAR wa_criteria.
*  wa_criteria-fieldname = 'PERNR'.
*  wa_criteria-tabname = 'T_DATA'.
*  wa_criteria-up = 'X'.
*  wa_criteria-spos = 1.
*  wa_criteria-subtot = 'X'.
*  APPEND wa_criteria TO t_criteria.
**
*  CLEAR wa_criteria.
*  wa_criteria-fieldname = 'SNAME'.
*  wa_criteria-tabname = 'T_DATA'.
*  wa_criteria-up = 'X'.
*  wa_criteria-spos = 2.
*   wa_criteria-subtot = 'X'.
*  APPEND wa_criteria TO t_criteria.

ENDFORM.                    " alv_criteria


*---------------------------------------------------------------------*
*       FORM display_errors                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_errors.
*-----Sind Fehler aufgetreten?
  DESCRIBE TABLE error_tab LINES sy-tfill.
  CHECK sy-tfill GT 0.
*-----Ausgabe einer Fehlerliste
  CALL FUNCTION 'HR_DISPLAY_ERROR_LIST'
    TABLES
      error  = error_tab
    EXCEPTIONS
      OTHERS = 1.
ENDFORM.                    "display_errors

*---------------------------------------------------------------------*
*       FORM error_handling                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM error_handling USING pernr arbgb msgty msgno
                          msgv1 msgv2 msgv3 msgv4.
  CLEAR error_tab.
  error_tab-pernr = pernr.
  error_tab-arbgb = arbgb.
  error_tab-msgty = msgty.
  error_tab-msgno = msgno.
  error_tab-msgv1 = msgv1.
  error_tab-msgv2 = msgv2.
  error_tab-msgv3 = msgv3.
  error_tab-msgv4 = msgv4.
  APPEND error_tab.
ENDFORM.                    "error_handling
