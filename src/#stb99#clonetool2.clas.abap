class /STB99/CLONETOOL2 definition
  public
  final
  create public .

public section.

*"* public components of class /STB99/CLONETOOL2
*"* do not include other source files here!!!
  data CUSTOMIZING type /STB99/CT2_CUST .
  data TABLES_TO_CLONE type /STB99/TABLES_TO_CLONE_T .
  data TX_SRTFD type /STB99/RANGE_SRTFD_T .
  data ADD_GUID_TABS type IQTRTAB .

  methods ADD_GUID_TABLE
    importing
      !TABLE type TABNAME .
  methods CLONE
    importing
      !GR_INFTY type /STB99/STB_INFTY_RANGE_T
    changing
      !S_PERNR type /STB99/RANGE_PERNR_T
      !CLONED_TABLES type /STB99/TABLES_T
      !XSTRTAB type /STB99/XTAB .
  methods CONSTRUCTOR .
  methods GET_TABLES_TO_CLONE .
  methods READ_TABLES_ADDITIONAL .
  methods READ_TABLES_CLUSTER .
  methods READ_TABLES_INFOTYPES .
  methods READ_TABLES_MELD_WITH_GUID
    importing
      !TAB_GUID type TABNAME
      !ADD_TAB type IQTRTAB .
  methods READ_TABLES_NUMKR .
  methods READ_TABLES_ORGMAN .
  methods READ_TABLES_PCP0 .
  methods READ_TABLES_TIME .
  methods READ_TABLES_TRVL .
  methods READ_TABLE_ARBEITGEBERKONTO .
  methods READ_TABLE_BEITRAGSNACHWEISE .
  methods READ_TABLE_BETRIEBSDATENPFL .
  methods READ_TABLE_COMPLETE
    importing
      !TABNAME type TABNAME .
  methods READ_TABLE_EUBP .
  methods READ_TABLE_LSTA .
  methods READ_TABLE_RENTENUEBERSICHT .
  methods READ_TABLE_WITH_PERNR
    importing
      !TABNAME type TABNAME .
protected section.
*"* protected components of class /STB99/CLONETOOL2
*"* do not include other source files here!!!
private section.

  data AT_PERNR type /STB99/RANGE_PERNR_T .
  data AT_CLONED_TABLES type /STB99/TABLES_T .
  data AT_XSTRTAB type /STB99/XTAB .
  data AT_INFTY type /STB99/STB_INFTY_RANGE_T .

  methods READ_MELD_A1 .
  methods READ_MELD_BV .
  methods READ_MELD_DEUEV .
  methods READ_MELD_EA .
  methods READ_MELD_EAU .
  methods READ_MELD_EE .
  methods READ_MELD_ELENA .
  methods READ_MELD_ELSTAM .
  methods READ_MELD_KRANKENKASSEN .
  methods READ_MELD_LSTB .
  methods READ_MELD_RBM .
  methods READ_MELD_ZS .
ENDCLASS.



CLASS /STB99/CLONETOOL2 IMPLEMENTATION.


  METHOD ADD_GUID_TABLE.
    DATA ls_add_tab TYPE LINE OF iqtrtab.

    CLEAR ls_add_tab.
    ls_add_tab-low = table.
    ls_add_tab-option = 'EQ'.
    ls_add_tab-sign = 'I'.
    APPEND ls_add_tab TO add_guid_tabs.



  ENDMETHOD.


METHOD CLONE.

  DATA: ls_pernr LIKE LINE OF at_pernr.

  "Personalnummern ermitteln
  CLEAR at_pernr[].
  SELECT pernr FROM pa0003 INTO ls_pernr-low WHERE pernr IN s_pernr
    ORDER BY pernr ASCENDING.
    ls_pernr-sign = 'I'.
    ls_pernr-option = 'EQ'.
    APPEND ls_pernr TO at_pernr.
  ENDSELECT.

  "Parameter von Quellsystem (welche Verfahren etc.)
  at_infty[] = gr_infty[].

*NEUNEUENENU
  CALL METHOD me->read_tables_infotypes.
  CALL METHOD me->read_tables_additional.
  CALL METHOD me->read_tables_cluster.

  "Zeitereignisse
  IF customizing-time  IS NOT INITIAL. CALL METHOD me->read_tables_time.   ENDIF.     "TEVEN
  IF customizing-org   IS NOT INITIAL. CALL METHOD me->read_tables_orgman. ENDIF.     "Orgmanagement
  IF customizing-trvl  IS NOT INITIAL. CALL METHOD me->read_tables_trvl.   ENDIF.     "Reisekosten      "todo
  IF customizing-numkr IS NOT INITIAL. CALL METHOD me->read_tables_numkr.  ENDIF.     "Nummernkreise
  IF customizing-pcp0  IS NOT INITIAL. CALL METHOD me->read_tables_pcp0.   ENDIF.     "Buchungsbelege
  IF customizing-a1    IS NOT INITIAL. CALL METHOD me->read_meld_a1.       ENDIF.     "Meldeverfahren A1
  IF customizing-elena IS NOT INITIAL. CALL METHOD me->read_meld_elena.    ENDIF.     "Meldeverfahren ELENA
  IF customizing-rbm   IS NOT INITIAL. CALL METHOD me->read_meld_rbm.      ENDIF.     "Meldeverfahren RBM
  IF customizing-bv    IS NOT INITIAL. CALL METHOD me->read_meld_bv.       ENDIF.     "Meldeverfahren BV
  IF customizing-ea    IS NOT INITIAL. CALL METHOD me->read_meld_ea.       ENDIF.     "Meldeverfahren EA
  IF customizing-ee    IS NOT INITIAL. CALL METHOD me->read_meld_ee.       ENDIF.     "Meldeverfahren EE
  IF customizing-deuv  IS NOT INITIAL. CALL METHOD me->read_meld_DEUEV.    ENDIF.     "Meldeverfahren deüv

  "ab hier noch Parameter anlegen
  CALL METHOD me->read_meld_lstb.     "Meldeverfahren LStB
  CALL METHOD me->read_meld_elstam.   ""Meldeverfahren ElStAM


  "keine Personalnummer oder nicht sinnvoll->komplett
  CALL METHOD me->read_table_beitragsnachweise. "Meldeverfahren Beitragsnachweise
  CALL METHOD me->read_table_lsta.              "Meldeverfahren LStA
  CALL METHOD me->read_table_betriebsdatenpfl.  "Meldeverfahren Betriebsdaten
  CALL METHOD me->READ_TABLE_ARBEITGEBERKONTO.  "Meldeverfahren Arbeitgeberkonto
  CALL METHOD me->READ_TABLE_RENTENUEBERSICHT.  ""Meldeverfahren Rentenübersicht
  CALL METHOD me->READ_TABLE_eubp.



  "Rückgabe an FuB
  xstrtab = at_xstrtab.
  cloned_tables = at_cloned_tables.
  s_pernr = at_pernr.

ENDMETHOD.


method CONSTRUCTOR.

"Tabellen zum Klonen auswählen
call METHOD me->get_tables_to_clone.


endmethod.


METHOD get_tables_to_clone.
  "Alle PA Tabellen mit Pernr
  DATA: ls_tables_to_clone  LIKE LINE OF tables_to_clone .
  REFRESH tables_to_clone.
  SELECT * FROM dd03l INTO CORRESPONDING FIELDS OF ls_tables_to_clone
    WHERE tabname BETWEEN 'PA0000' AND 'PA9999'
      AND fieldname EQ 'PERNR'.

    CHECK ls_tables_to_clone-tabname ne 'PA2001_UGR'
      AND ls_tables_to_clone-tabname ne 'PA2002_UGR'
      AND ls_tables_to_clone-tabname ne 'PA2006_UGR'
      AND ls_tables_to_clone-tabname ne 'PA2007_UGR'.

    ls_tables_to_clone-field = 'PERNR'.
    APPEND ls_tables_to_clone TO tables_to_clone.
  ENDSELECT.

  IF me->customizing-org IS NOT INITIAL.
    SELECT * FROM dd03l INTO CORRESPONDING FIELDS OF ls_tables_to_clone
      WHERE tabname BETWEEN 'HRP0000' AND 'HRP9999'
        AND fieldname EQ 'OBJID'.
      ls_tables_to_clone-field = 'OBJID'.
      APPEND ls_tables_to_clone TO tables_to_clone.
    ENDSELECT.
  ENDIF.


  IF me->customizing-sv IS NOT INITIAL.
    ls_tables_to_clone-tabname = 'p01sv_mldaufr'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
    ls_tables_to_clone-tabname = 'p01sv_dsid'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ENDIF.

if me->customizing-bav IS NOT INITIAL.
  "BAV
  ls_tables_to_clone-tabname = 'p01cabr'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cad'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cbe'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cbf'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cbt'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01ccv'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cee'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cef'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cet'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cgp'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cix'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cka'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01crp'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01csl'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cso'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cst'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cua'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01cvu'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01pf_rt_ep'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01pf_tilg'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_auft'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_be'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_bf'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_cbe'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_cbf'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_cka'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_clst'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_ka'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_lstv'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ls_tables_to_clone-tabname = 'p01va_stat'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
endif.

  IF me->customizing-zs IS NOT INITIAL.
    "Zahlstellenmeldungen
    ls_tables_to_clone-tabname = 'p01zs_azvu'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
    ls_tables_to_clone-tabname = 'p01zs_stat'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ENDIF.

  IF me->customizing-rbm IS NOT INITIAL.
    "Rentenbezugsmitteilung
    ls_tables_to_clone-tabname = 'p01rbm_stat'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
    ls_tables_to_clone-tabname = 'p01rbm_stat_r'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
    ls_tables_to_clone-tabname = 'p01rbm_mz01_kolb'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
    ls_tables_to_clone-tabname = 'p01rbm_mz01_korg'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
    ls_tables_to_clone-tabname = 'p01rbm_mz01_kosv'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ENDIF.

  IF me->customizing-zs IS NOT INITIAL.
    "Entgeltersatzlesitungen
    ls_tables_to_clone-tabname = 'p01ee_stat'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ENDIF.

  IF me->customizing-ea IS NOT INITIAL.
    "Erstattungsverfahren
    ls_tables_to_clone-tabname = 'p01ea_stat'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ENDIF.

  IF me->customizing-bv IS NOT INITIAL.
    "Zahlstellenmeldungen
    ls_tables_to_clone-tabname = 'p01bv_stat'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
    ls_tables_to_clone-tabname = 'p01bv_kean'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ENDIF.


  IF me->customizing-elena IS NOT INITIAL.
    "ELENA-Meldeverfahren
    ls_tables_to_clone-tabname = 'p01el_prot'.ls_tables_to_clone-field = 'PERNR'.APPEND ls_tables_to_clone TO tables_to_clone.
  ENDIF.

ENDMETHOD.


  METHOD read_meld_a1.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'P01A1_STAT'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'P01A1_EXT_DATA'.

    CLEAR add_guid_tabs[].
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBAG'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBAG_DXGM'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBAN'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBBA'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBBA_EO'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBBA_VB'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBBE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBBE_AV'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBEA'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBES'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBES_BS'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBES_BS_GM'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBES_SHIP'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBFE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DBZS'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXA1'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXAA'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXAA_HWT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXAB'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXAV'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXBB'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXFK'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXGG'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXGM'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXMM'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_DXWL'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01A1_RAWDATA'.

    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = 'P01A1_STAT'
        add_tab  = add_guid_tabs.




  ENDMETHOD.


  METHOD READ_MELD_BV.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'p01bv_stat'.

    CLEAR add_guid_tabs[].

    CALL METHOD me->add_guid_table EXPORTING table = 'P01BV_DBBF'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01BV_DBFE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01BV_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01BV_KEAN'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01BV_MELD'.


    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = 'p01bv_stat'
        add_tab  = add_guid_tabs.




  ENDMETHOD.


  METHOD READ_MELD_DEUEV.
    CONSTANTS: gui_tabname TYPE tabname VALUE 'P01ZS_STAT'.

    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dban'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbeu'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbgb'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbks'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbkv'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbme'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbna'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbso'.
*    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbs'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dsap'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dsme'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3flag'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3hist'.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'pd3dbuv'.





  ENDMETHOD.


  METHOD READ_MELD_EA.
    CONSTANTS: gui_tabname TYPE tabname VALUE 'P01EA_STAT'.

    CALL METHOD me->read_table_with_pernr exporting tabname = gui_tabname.

    CLEAR add_guid_tabs[].
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EA_DBBF'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EA_DBFE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EA_DSRA'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EA_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EA_MELD'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EA_VRBN'.


    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = gui_tabname
        add_tab  = add_guid_tabs.




  ENDMETHOD.


  METHOD read_meld_eau.
    CONSTANTS: gui_tabname TYPE tabname VALUE 'P01_EAU_STAT'.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = gui_tabname.

    CLEAR add_guid_tabs[].
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_ANSPRPAR'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_ARBNEHM'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_AU_DATEN'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_FEHLER'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_IT2001'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_MELD_AU'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_NOTIFDAT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_PRES_PNR'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_STAT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_EAU_STRGDAT'.

    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = gui_tabname
        add_tab  = add_guid_tabs.




  ENDMETHOD.


  METHOD READ_MELD_EE.
    CONSTANTS: gui_tabname TYPE tabname VALUE 'p01EE_stat'.

    CALL METHOD me->read_table_with_pernr exporting tabname = gui_tabname.

    CLEAR add_guid_tabs[].
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBAE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBAL'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBAN'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBAP'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBAV'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBAW'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBBE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBEE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBFE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBFR'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBFR_W'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBHE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBID'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBLT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBMU'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBNA'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBSD'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBTK'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBUN'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBVO'.
    CALL METHOD me->add_guid_table EXPORTING table = 'p01EE_stat'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBZA'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DBZE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_DSLW'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EE_IT2001'.


    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = gui_tabname
        add_tab  = add_guid_tabs.




  ENDMETHOD.


  METHOD READ_MELD_ELENA.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'P01EL_STAT'.

    CLEAR add_guid_tabs[].

    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBAB'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBAG'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBAN'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBAS'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBEN'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBFE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBFZ'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBGB'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBHA'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBKE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBNA'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBSB'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBSE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DBZD'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_DSVV'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_MVDS'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01EL_PROT'.


    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = 'P01EL_STAT'
        add_tab  = add_guid_tabs.




  ENDMETHOD.


  METHOD read_meld_elstam.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01E2_ADM'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01E2_MELD'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01E2_PKV_ADMIN'.


    DATA:
      lr_data TYPE REF TO data,
      lx      TYPE xstring.
    DATA: s_guid    TYPE /stb99/range_guid_t,
          l_guid    TYPE /stb99/range_guid,
          ls_cloned TYPE /stb99/tables.
    FIELD-SYMBOLS:
      <lt_stat> TYPE STANDARD TABLE,
      <ls_stat> TYPE any,
      <lt_itab> TYPE STANDARD TABLE,
      <lv_guid> TYPE any.

    REFRESH s_guid.


    " Erste Tabelle dynamisch lesen
    CREATE DATA lr_data TYPE STANDARD TABLE OF ('P01E2_ADM').
    ASSIGN lr_data->* TO <lt_stat>.

    SELECT *
      FROM ('P01E2_ADM')
      INTO TABLE <lt_stat>
      WHERE pernr IN at_pernr.

    l_guid-sign   = 'I'.
    l_guid-option = 'EQ'.
    CLEAR l_guid.

    LOOP AT <lt_stat> ASSIGNING <ls_stat>.
      ASSIGN COMPONENT 'GUID' OF STRUCTURE <ls_stat> TO <lv_guid>.
      IF sy-subrc = 0 AND <lv_guid> IS NOT INITIAL.
        l_guid-low    = <lv_guid>.
        COLLECT l_guid INTO s_guid.
      ENDIF.
      ASSIGN COMPONENT 'GUID_CNECT' OF STRUCTURE <ls_stat> TO <lv_guid>.
      IF sy-subrc = 0 AND <lv_guid> IS NOT INITIAL.
        l_guid-low    = <lv_guid>.
        COLLECT l_guid INTO s_guid.
      ENDIF.
      ASSIGN COMPONENT 'GUID_REF_AN_AB' OF STRUCTURE <ls_stat> TO <lv_guid>.
      IF sy-subrc = 0 AND <lv_guid> IS NOT INITIAL.
        l_guid-low    = <lv_guid>.
        COLLECT l_guid INTO s_guid.
      ENDIF.
      ASSIGN COMPONENT 'GUID_CANCEL' OF STRUCTURE <ls_stat> TO <lv_guid>.
      IF sy-subrc = 0 AND <lv_guid> IS NOT INITIAL.
        l_guid-low    = <lv_guid>.
        COLLECT l_guid INTO s_guid.
      ENDIF.
    ENDLOOP.

    CREATE DATA lr_data TYPE STANDARD TABLE OF ('P01E2_PKV_ADMIN').
    ASSIGN lr_data->* TO <lt_stat>.

    SELECT *
      FROM ('P01E2_PKV_ADMIN')
      INTO TABLE <lt_stat>
      WHERE pernr IN at_pernr.

    l_guid-sign   = 'I'.
    l_guid-option = 'EQ'.
    CLEAR l_guid.

    LOOP AT <lt_stat> ASSIGNING <ls_stat>.
      ASSIGN COMPONENT 'GUID' OF STRUCTURE <ls_stat> TO <lv_guid>.
      IF sy-subrc = 0 AND <lv_guid> IS NOT INITIAL.
        l_guid-low    = <lv_guid>.
        COLLECT l_guid INTO s_guid.
      ENDIF.
    ENDLOOP.

    CHECK s_guid[] IS NOT INITIAL.

    CLEAR add_guid_tabs[].

    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_ABMELDUNG'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_ANMELDUNG'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_ELSTAM'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_INFT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_LIST_ST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_LISTMTL_ST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_MELD_ST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_PKV'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_PKV_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_PKV_INFT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_PKV_STATUS'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_STATUS'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_TRANS'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_TRANS_ST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_UMMELDUNG'.

    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = 'P01E2_ADM'
        add_tab  = add_guid_tabs.




  ENDMETHOD.


  METHOD read_meld_krankenkassen.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_ADMIN_01'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBAE'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBAL'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBAN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBEK'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBFR'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBFZ'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBKR'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBMU'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBNA'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBUN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBZE'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DBZK'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01W_DSLW'.
  ENDMETHOD.


  METHOD read_meld_lstb.

    DATA:
      lr_data TYPE REF TO data,
      lx      TYPE xstring.
    DATA: s_ndtic   TYPE /stb99/range_ndtic_t,
          l_ndtic   TYPE /stb99/range_ndtic,
          ls_cloned TYPE /stb99/tables.
    FIELD-SYMBOLS:
      <lt_stat>  TYPE STANDARD TABLE,
      <ls_stat>  TYPE any,
      <lt_itab>  TYPE STANDARD TABLE,
      <lv_ndtic> TYPE any.

    REFRESH s_ndtic.


    " Erste Tabelle dynamisch lesen
    CREATE DATA lr_data TYPE STANDARD TABLE OF ('P01T_ADMIN').
    ASSIGN lr_data->* TO <lt_stat>.

    SELECT *
      FROM ('P01T_ADMIN')
      INTO TABLE <lt_stat>
      WHERE pernr IN at_pernr.

    IF <lt_stat>[] IS NOT INITIAL.
      EXPORT p1 = <lt_stat> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = 'P01T_ADMIN'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.

    LOOP AT <lt_stat> ASSIGNING <ls_stat>.
      ASSIGN COMPONENT 'ndtic' OF STRUCTURE <ls_stat> TO <lv_ndtic>.
      CHECK sy-subrc = 0 AND <lv_ndtic> IS NOT INITIAL.

      CLEAR l_ndtic.
      l_ndtic-low    = <lv_ndtic>.
      l_ndtic-sign   = 'I'.
      l_ndtic-option = 'EQ'.
      COLLECT l_ndtic INTO s_ndtic.
    ENDLOOP.

    CREATE DATA lr_data TYPE STANDARD TABLE OF ('P01T_TRANS').
    ASSIGN lr_data->* TO <lt_stat>.

    SELECT *
      FROM ('P01T_TRANS')
      INTO TABLE <lt_stat>
      WHERE ndtic IN s_ndtic.

    IF <lt_stat>[] IS NOT INITIAL.
      EXPORT p1 = <lt_stat> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = 'P01T_TRANS'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.





    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_ADMIN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_ADMIN_STAT'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_ADMST'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_BPKV'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_ELSTAM'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_FRBJ'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_HINZ'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_KIFB'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_KIST'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_KVPV'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_LST'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_LST1'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_LST2'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_STKL'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_SVBEZ'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01T_VBEZ'.

*    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01T_AGS'.







      endmethod.


  METHOD READ_MELD_RBM.
    CALL METHOD me->read_table_with_pernr exporting tabname = 'P01RBM_STAT'.

    CLEAR add_guid_tabs[].

    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_EMLJ'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_HEADER'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_IM01'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MI01'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MI01R'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01_BTGD'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01_FEDT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01_GRNT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01_KOLB'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01_KORG'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01_KOSV'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01_LBTG'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01_VZTR'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01R'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01RBTGD'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01RFEDT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01RLBTG'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_MZ01RVZTR'.
*    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_STAT_R'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_TRANS'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01RBM_TRIN'.


    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = 'P01RBM_STAT'
        add_tab  = add_guid_tabs.




  ENDMETHOD.


  METHOD READ_MELD_ZS.
    CONSTANTS: gui_tabname TYPE tabname VALUE 'P01ZS_STAT'.

    CALL METHOD me->read_table_with_pernr exporting tabname = gui_tabname.

    CLEAR add_guid_tabs[].
    CALL METHOD me->add_guid_table EXPORTING table = 'P01ZS_0700'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01ZS_AZKK'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01ZS_AZVU'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01ZS_DBBF'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01ZS_DBFE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01ZS_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01ZS_INFT'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01ZS_MELD'.


    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = gui_tabname
        add_tab  = add_guid_tabs.




  ENDMETHOD.


METHOD read_tables_additional.
  DATA:
    lx                 TYPE xstring,
    ldo_data           TYPE REF TO data,
    ls_cloned          TYPE /stb99/tables,
    ls_tables_to_clone TYPE /stb99/tables_to_clone.

  FIELD-SYMBOLS: <lt_itab> TYPE table,
                 <pernr>   TYPE pernr_d,
                 <line>    TYPE any,
                 <field>   TYPE any.
  DATA: lt_asshr TYPE TABLE OF asshr,
        ls_asshr TYPE asshr.

  DATA: s_pdsnr TYPE /stb99/range_pdsnr_t,
        l_pdsnr TYPE /stb99/range_pdsnr.


  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'ASSHR'.

  "pdsnr sammeln
  REFRESH s_pdsnr.
  SELECT * FROM asshr INTO TABLE lt_asshr
        WHERE pernr IN at_pernr.
  LOOP AT lt_asshr INTO ls_asshr.
    l_pdsnr-low = ls_asshr-pdsnr.
    l_pdsnr-sign = 'I'.
    l_pdsnr-option = 'EQ'.
    COLLECT l_pdsnr INTO s_pdsnr.
  ENDLOOP.

  CHECK s_pdsnr IS NOT INITIAL.

  CREATE DATA ldo_data TYPE TABLE OF assob.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM assob INTO TABLE <lt_itab>
            WHERE pdsnr IN s_pdsnr.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'assob'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF pdsnr.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM pdsnr INTO TABLE <lt_itab>
    WHERE pdsnr IN s_pdsnr.
  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'pdsnr'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.


  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'COIFT'.

  "Abrechnungstabellen
  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 't52mcw'.
  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 't5d46'.
  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 't5d48'.
  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 't5d2m'.
*  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 't5d2_prot'.



ENDMETHOD.


METHOD read_tables_cluster.

*PCL1 Leistlohn
*Fehler Zeitwirtschaft B1
*
*PCL2 RD
*PCL2 B2
*
*AE	Abrechnungs-Ergebnisse Pfändung
*AF	Directory Pfändung
*DP	Pfändungen (DE)
*DQ	Directory Pfändung
*
*
*
*
*PCL4 SA
*PCL4 LA nur das mit Personalnummer

*
*PCL5
*PY	Personalkostenplanung - Abrechnungsdaten
*PC	Personalkostenplanung
*PS	Personalkostenplanung Originalwerte
*CB	Personalkostenplanung: Datenbasis aus Abrechnungsergebnissen
*CC	Personalkostenplanung: Originalbeleg für CO-Buchung
*CP	Personalkostenplanung: Daten des Planungslaufs



*  DATA:
*   lx TYPE xstring,
*   ldo_data   TYPE REF TO data,
*   ls_cloned TYPE /stb99/tables.
*
*  FIELD-SYMBOLS: <lt_itab>    TYPE table.
*
*  DATA: ls_pernr TYPE /stb99/range_pernr.
*
*  DATA: s_srtfd TYPE /stb99/range_srtfd_t,
*        s_srtfd2 TYPE /stb99/range_srtfd_t,
*        l_srtfd TYPE /stb99/range_srtfd.
*
*  CLEAR l_srtfd.
*  l_srtfd-sign = 'I'.
*  l_srtfd-option = 'CP'.
*
*  DATA: s_relid TYPE /stb99/copy_relid_range,
*        l_relid TYPE /stb99/copy_relid_range_line.
*
*  DATA: lt_relid TYPE TABLE OF /stb99/ct2_relid,
*        ls_relid TYPE /stb99/ct2_relid.
*
*  DATA: s_abkrs TYPE /stb99/range_abkrs_t,
*        l_abkrs TYPE /stb99/range_abkrs.
*
*  DATA: rgdir TYPE TABLE OF pc261,
*        ls_rgdir TYPE pc261.
*
*  DATA: BEGIN OF cdkey,
*            pernr TYPE pernr_d,             "key to cluster directory
*          END OF cdkey.
*
*  FIELD-SYMBOLS: <line> TYPE any,
*                 <field> TYPE any.
*
*  DATA l1key TYPE pll00.
*  DATA g1key TYPE pll10.
*  DATA: gt TYPE TABLE OF pll04,
*        ls_gt TYPE pll04.
*
*
*
*
*  CLEAR l_relid.
*  l_relid-sign    = 'I'.
*  l_relid-option  = 'EQ'.
*  SELECT * FROM /stb99/ct2_relid INTO TABLE lt_relid.
*  LOOP AT lt_relid INTO ls_relid.
*    CASE ls_relid-grp_relid.
*      WHEN '1'.                  "Abrechnung
*        IF me->customizing-calc IS NOT INITIAL.
*          l_relid-low = ls_relid-relid.
*          APPEND l_relid TO s_relid.
*        ENDIF.
*      WHEN '2'.                  "Zeitwirtschaft
*        IF me->customizing-time IS NOT INITIAL.
*          l_relid-low = ls_relid-relid.
*          APPEND l_relid TO s_relid.
*        ENDIF.
*      WHEN '3'.                  "Leistungslohn
*        IF me->customizing-lohn IS NOT INITIAL.
*          l_relid-low = ls_relid-relid.
*          APPEND l_relid TO s_relid.
*        ENDIF.
*      WHEN '4'.                  "Reisekosten
*        IF me->customizing-trvl IS NOT INITIAL.
*          l_relid-low = ls_relid-relid.
*          APPEND l_relid TO s_relid.
*        ENDIF.
*      WHEN '9'.                  "Sonderverarbeitung
*    ENDCASE.
*  ENDLOOP.
*
*  "Urlaubsdaten
*  l_relid-low = 'PC'.APPEND l_relid TO s_relid.
*  "Sonderverrbeitung
*  l_relid-low = 'TX'. l_relid-sign = 'E'. l_relid-option = 'EQ'.APPEND l_relid TO s_relid.
*  "Sonderverrbeitung
*  l_relid-low = 'G1'. l_relid-sign = 'E'. l_relid-option = 'EQ'.APPEND l_relid TO s_relid.
*
*  "Personalnummernselektion
*  LOOP AT at_pernr INTO ls_pernr.
*    l_srtfd-low(8) = ls_pernr-low.
*    l_srtfd-low+8(1) = '*'.
*    APPEND l_srtfd TO s_srtfd.
*  ENDLOOP.
*
*  CREATE DATA ldo_data TYPE TABLE OF pcl2.
*  ASSIGN ldo_data->* TO <lt_itab>.
*
** Daten selektieren
*  SELECT * FROM pcl2 INTO TABLE <lt_itab>
*    WHERE relid IN s_relid
*      AND srtfd IN s_srtfd.
*
*  IF me->customizing-pa03 IS NOT INITIAL.
*    "Abrechnungskreise für PA03 sammeln
*    CLEAR l_abkrs.
*    REFRESH s_abkrs.
*    l_abkrs-sign = 'I'.
*    l_abkrs-option = 'EQ'.
*    LOOP AT <lt_itab> ASSIGNING <line>.
*      ASSIGN COMPONENT 'SRTFD' OF STRUCTURE <line> TO <field>.
*      IF sy-subrc EQ 0.
*        cdkey = <field>.
*
*        REFRESH rgdir.
*        IMPORT rgdir TO rgdir
*        FROM DATABASE pcl2(cu)
*        ID cdkey.
*        LOOP AT rgdir INTO ls_rgdir.
*          l_abkrs-low = ls_rgdir-abkrs.
*          COLLECT l_abkrs INTO s_abkrs.
*        ENDLOOP.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
*
*  IF <lt_itab>[] IS NOT INITIAL.
*    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
*    APPEND lx TO at_xstrtab.
*    ls_cloned-index = sy-tabix.
*    ls_cloned-tabname = 'PCL2'.
*    APPEND ls_cloned TO at_cloned_tables.
*  ENDIF.
*  IF me->customizing-pa03 IS NOT INITIAL
*    AND s_abkrs IS NOT INITIAL.
*    CREATE DATA ldo_data TYPE TABLE OF t569v.
*    ASSIGN ldo_data->* TO <lt_itab>.
*
** Daten selektieren
*    SELECT * FROM t569v INTO TABLE <lt_itab>
*      WHERE abkrs IN s_abkrs.
*
*    CHECK <lt_itab>[] IS NOT INITIAL.
*    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
*    APPEND lx TO at_xstrtab.
*    ls_cloned-index = sy-tabix.
*    ls_cloned-tabname = 'T569V'.
*    APPEND ls_cloned TO at_cloned_tables.
*  ENDIF.
*
*  "PCL1
*  CREATE DATA ldo_data TYPE TABLE OF pcl1.
*  ASSIGN ldo_data->* TO <lt_itab>.
*
** Daten selektieren
*  SELECT * FROM pcl1 INTO TABLE <lt_itab>
*    WHERE relid IN s_relid
*      AND srtfd IN s_srtfd.
*
*  CHECK <lt_itab>[] IS NOT INITIAL.
*
*  IF me->customizing-lohn IS NOT INITIAL.
*    LOOP AT <lt_itab> ASSIGNING <line>.
*      ASSIGN COMPONENT 'RELID' OF STRUCTURE <line> TO <field>.
*      CHECK <field> EQ 'L1'.
*      ASSIGN COMPONENT 'SRTFD' OF STRUCTURE <line> TO <field>.
*      IF sy-subrc EQ 0.
*        l1key = <field>.
*
*        REFRESH gt.
*        IMPORT gt TO gt
*        FROM DATABASE pcl1(l1)
*        ID l1key.
*
*        CLEAR l_srtfd.
*        l_srtfd-sign = 'I'.
*        l_srtfd-option = 'EQ'.
*
*
*        LOOP AT gt INTO ls_gt.
*          MOVE-CORRESPONDING l1key TO g1key.
*          MOVE  ls_gt-grunr TO g1key-grunr.
*          l_srtfd-low = g1key.
*          COLLECT l_srtfd INTO s_srtfd2.
*        ENDLOOP.
*      ENDIF.
*    ENDLOOP.
*
*
** Daten selektieren
*    SELECT * FROM pcl1 APPENDING TABLE <lt_itab>
*      WHERE relid EQ 'G1' AND srtfd IN s_srtfd2.
*  ENDIF.
*
*
*  EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
*  APPEND lx TO at_xstrtab.
*  ls_cloned-index = sy-tabix.
*  ls_cloned-tabname = 'PCL1'.
*  APPEND ls_cloned TO at_cloned_tables.


ENDMETHOD.


METHOD read_tables_infotypes.

  DATA:
   lx TYPE xstring,
   ldo_data   TYPE REF TO data,
   ls_cloned TYPE /stb99/tables,
   ls_table_to_clone TYPE /stb99/tables_to_clone.

  DATA: l_srtfd_tx TYPE /stb99/range_srtfd.

  FIELD-SYMBOLS: <lt_itab>    TYPE table,
                 <pernr> TYPE pernr_d,
                 <line> TYPE any,
                 <field> TYPE any.



 SELECT * FROM dd03l INTO CORRESPONDING FIELDS OF ls_table_to_clone
    WHERE tabname BETWEEN 'PA0000' AND 'PA9999'
      AND fieldname EQ 'PERNR'
      ORDER BY tabname ASCENDING.

    CHECK ls_table_to_clone-tabname ne 'PA2001_UGR'
      AND ls_table_to_clone-tabname ne 'PA2002_UGR'
      AND ls_table_to_clone-tabname ne 'PA2006_UGR'
      AND ls_table_to_clone-tabname ne 'PA2007_UGR'.


    "Infotyp Selektion
    CHECK ls_table_to_clone-tabname+2(4) in at_infty.


  CREATE DATA ldo_data TYPE TABLE OF (ls_table_to_clone-tabname).
    ASSIGN ldo_data->* TO <lt_itab>.

    "Alle Tabellen mit Personalnummernfeld (PA)
    SELECT * FROM (ls_table_to_clone-tabname) INTO TABLE <lt_itab>
      WHERE pernr IN at_pernr.

    CHECK <lt_itab>[] IS NOT INITIAL.

    "Sammeln Keys für Cluster PCL1-TX
    IF ls_table_to_clone-tabname(2) EQ 'PA'.
      LOOP AT <lt_itab> ASSIGNING <line>.
        ASSIGN COMPONENT 'ITXEX' OF STRUCTURE <line> TO <field>.
        IF sy-subrc EQ 0.
          IF <field> IS NOT INITIAL.
            "Cluster TX
            CLEAR l_srtfd_tx.
            l_srtfd_tx-sign = 'I'.
            l_srtfd_tx-option = 'CP'.
            ASSIGN COMPONENT 'PERNR' OF STRUCTURE <line> TO <pernr>.
            l_srtfd_tx-low(8) = <pernr>.
            l_srtfd_tx-low+8(4) = ls_table_to_clone-tabname+2(4).
            l_srtfd_tx-low+12(1) = '*'.
            COLLECT l_srtfd_tx INTO me->tx_srtfd.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = ls_table_to_clone-tabname.
    APPEND ls_cloned TO at_cloned_tables.


  ENDSELECT.

  CHECK me->tx_srtfd IS NOT INITIAL.

  "Cluster TX dazulesen
  CREATE DATA ldo_data TYPE TABLE OF pcl1.
  ASSIGN ldo_data->* TO <lt_itab>.

  "Alle Tabellen mit Personalnummernfeld (PA)
  SELECT * FROM pcl1 INTO TABLE <lt_itab>
    WHERE relid EQ 'TX' AND srtfd IN me->tx_srtfd.

  CHECK <lt_itab>[] IS NOT INITIAL.

  EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
  APPEND lx TO at_xstrtab.
  ls_cloned-index = sy-tabix.
  ls_cloned-tabname = 'PCL1'.
  APPEND ls_cloned TO at_cloned_tables.

ENDMETHOD.


METHOD READ_TABLES_MELD_WITH_GUID.
  DATA:
    lr_data TYPE REF TO data,
    lx      TYPE xstring.
  DATA: s_guid    TYPE /stb99/range_guid_t,
        l_guid    TYPE /stb99/range_guid,
        ls_cloned TYPE /stb99/tables.
  FIELD-SYMBOLS:
    <lt_stat> TYPE STANDARD TABLE,
    <ls_stat> TYPE any,
    <lt_itab> TYPE STANDARD TABLE,
    <lv_guid> TYPE any.

  REFRESH s_guid.


  " Erste Tabelle dynamisch lesen
  CREATE DATA lr_data TYPE STANDARD TABLE OF (tab_guid).
  ASSIGN lr_data->* TO <lt_stat>.

  SELECT *
    FROM (tab_guid)
    INTO TABLE <lt_stat>
    WHERE pernr IN at_pernr.

  LOOP AT <lt_stat> ASSIGNING <ls_stat>.
    ASSIGN COMPONENT 'GUID' OF STRUCTURE <ls_stat> TO <lv_guid>.
    CHECK sy-subrc = 0 AND <lv_guid> IS NOT INITIAL.

    CLEAR l_guid.
    l_guid-low    = <lv_guid>.
    l_guid-sign   = 'I'.
    l_guid-option = 'EQ'.
    COLLECT l_guid INTO s_guid.
  ENDLOOP.

  CHECK s_guid[] IS NOT INITIAL.

  " Folgetabellen dynamisch lesen
  FIELD-SYMBOLS: <ls_tab> TYPE LINE OF iqtrtab.
  LOOP AT add_guid_tabs ASSIGNING <ls_tab>.

    CHECK <ls_tab>-sign = 'I'
      AND <ls_tab>-option = 'EQ'
      AND <ls_tab>-low IS NOT INITIAL.

    DATA lv_tabname TYPE LINE OF iqtrtab.
    lv_tabname = <ls_tab>-low.
    TRANSLATE lv_tabname TO UPPER CASE.

    " Optional, aber sehr empfohlen: prüfen ob Tabelle existiert
    DATA lv_ddic_tab TYPE string.
    SELECT SINGLE tabname
      FROM dd02l INTO lv_ddic_tab
      WHERE tabname = lv_tabname
        AND as4local = 'A'.


    CHECK sy-subrc = 0.

    CREATE DATA lr_data TYPE STANDARD TABLE OF (lv_tabname).
    ASSIGN lr_data->* TO <lt_itab>.

    SELECT *
      FROM (lv_tabname)
      INTO TABLE <lt_itab>
      WHERE guid IN s_guid.

    IF <lt_itab> IS NOT INITIAL.
      EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.

      CLEAR ls_cloned.
      ls_cloned-index   = lines( at_xstrtab ).
      ls_cloned-tabname = lv_tabname.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.

  ENDLOOP.


  CLEAR add_guid_tabs[].


ENDMETHOD.


METHOD READ_TABLES_NUMKR.

  DATA:
   lx TYPE xstring,
   ldo_data   TYPE REF TO data,
   ls_cloned TYPE /stb99/tables,
   ls_tables_to_clone TYPE /stb99/tables_to_clone.

  FIELD-SYMBOLS: <lt_itab>    TYPE table,
                 <line> TYPE any,
                 <field> TYPE any.


  "weitere Objekte
  CREATE DATA ldo_data TYPE TABLE OF nriv.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM nriv INTO TABLE <lt_itab>.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'NRIV'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.



ENDMETHOD.


METHOD read_tables_orgman.
  DATA:
    lx TYPE xstring,
    ldo_data   TYPE REF TO data,
    ls_cloned TYPE /stb99/tables,
    ls_tables_to_clone TYPE /stb99/tables_to_clone,
    ls_pernr TYPE /stb99/pernr_table.

  FIELD-SYMBOLS: <lt_itab>    TYPE table,
                 <pernr> TYPE any.


  DATA: lt_result_tab TYPE TABLE OF swhactor,
        ls_result_tab TYPE swhactor.

  DATA: lt_result_struc TYPE TABLE OF struc,
        ls_result_struc TYPE struc,
        it_result_struc TYPE TABLE OF struc,
        is_result_struc TYPE struc.

  DATA: s_otype TYPE /stb99/range_otype_t,
          l_otype TYPE /stb99/range_otype,
          s_objid TYPE /stb99/range_objid_t,
          l_objid TYPE /stb99/range_objid.


* Vorbereitungen Org. Management
  DATA: lt_t777i TYPE TABLE OF t777i,
        ls_t777i TYPE t777i.

  IF me->customizing-wegid IS NOT   INITIAL.
    SELECT otype FROM t777i INTO TABLE lt_t777i
      WHERE infty EQ '1000'.

    l_otype-sign ='I'.
    l_otype-option = 'EQ'.

    LOOP AT lt_t777i INTO ls_t777i.
      l_otype-low = ls_t777i-otype.
      APPEND l_otype TO s_otype.
    ENDLOOP.
  ENDIF.




  LOOP AT me->tables_to_clone INTO ls_tables_to_clone WHERE field EQ 'OBJID'.
    CREATE DATA ldo_data TYPE TABLE OF (ls_tables_to_clone-tabname).
    ASSIGN ldo_data->* TO <lt_itab>.

    SELECT * FROM (ls_tables_to_clone-tabname) INTO TABLE <lt_itab>
      WHERE otype EQ 'P'
        AND objid IN at_pernr.

    IF ls_tables_to_clone-tabname EQ 'HRP1001'.
      SELECT * FROM (ls_tables_to_clone-tabname) APPENDING TABLE <lt_itab>
        WHERE sclas EQ 'P'
          AND sobid IN at_pernr.

      DATA: pernr_table TYPE TABLE OF /stb99/pernr_table.

      SELECT DISTINCT pernr INTO CORRESPONDING FIELDS OF ls_pernr
        FROM pa0003
        WHERE pernr in at_pernr.
      ENDSELECT.

      LOOP AT pernr_table INTO ls_pernr.
        CALL FUNCTION 'RH_STRUC_GET'
                 EXPORTING
                   act_otype              = 'P'
                   act_objid              = ls_pernr-pernr
                   act_wegid              = me->customizing-wegid
*         ACT_INT_FLAG           =
                   act_plvar              = me->customizing-plvar
                   act_begda              = '19000101'
                   act_endda              = '99991231'
                   act_tdepth             = me->customizing-depth
*         ACT_TFLAG              = 'X'
*         ACT_VFLAG              = 'X'
*         AUTHORITY_CHECK        = 'X'
*         TEXT_BUFFER_FILL       =
*         BUFFER_MODE            =
*       IMPORTING
*         ACT_PLVAR              =
                 TABLES
                   result_tab             = lt_result_tab
*       result_objec           =
                   result_struc           = lt_result_struc
                 EXCEPTIONS
                   no_plvar_found         = 1
                   no_entry_found         = 2
                   OTHERS                 = 3
                         .
        IF sy-subrc EQ 0.
          LOOP AT lt_result_tab INTO ls_result_tab WHERE otype IN s_otype.
            l_objid-low = ls_result_tab-objid.
            l_objid-sign = 'I'.
            l_objid-option = 'EQ'.
            collect l_objid inTO s_objid.
          ENDLOOP.

          lt_result_struc[] = it_result_struc[].

          LOOP AT it_result_struc INTO is_result_struc.
            IF is_result_struc-pup GT 0.

              LOOP AT lt_result_struc INTO ls_result_struc
                WHERE level EQ is_result_struc-pup.
                EXIT.
              ENDLOOP.

              SELECT * FROM hrp1001 APPENDING TABLE <lt_itab>
                WHERE otype EQ ls_result_struc-otype
                  AND objid EQ ls_result_struc-objid
                  AND sclas EQ is_result_struc-otype
                  AND sobid EQ is_result_struc-objid
                  AND begda EQ is_result_struc-vbegda
                  AND endda EQ is_result_struc-vendda.

              SELECT * FROM hrp1001 APPENDING TABLE <lt_itab>
                WHERE otype EQ is_result_struc-otype
                  AND objid EQ is_result_struc-objid
                  AND sclas EQ ls_result_struc-otype
                  AND sobid EQ ls_result_struc-objid
                  AND begda EQ is_result_struc-vbegda
                  AND endda EQ is_result_struc-vendda.

            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDIF.


    CHECK <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = ls_tables_to_clone-tabname.
    APPEND ls_cloned TO at_cloned_tables.
  ENDLOOP.

  "weitere Objekte
  CREATE DATA ldo_data TYPE TABLE OF hrp1000.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM hrp1000 INTO TABLE <lt_itab>
    WHERE plvar EQ me->customizing-plvar
      AND objid IN s_objid.

  DELETE ADJACENT DUPLICATES FROM <lt_itab>.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'HRP1000'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.
  CREATE DATA ldo_data TYPE TABLE OF plogi.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM plogi INTO TABLE <lt_itab>
    WHERE plvar EQ me->customizing-plvar
      AND objid IN s_objid.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'HRP1000'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.




ENDMETHOD.


METHOD READ_TABLES_PCP0.

  DATA:
   lx TYPE xstring,
   ldo_data   TYPE REF TO data,
   ls_cloned TYPE /stb99/tables,
   ls_tables_to_clone TYPE /stb99/tables_to_clone.

  DATA: l_srtfd_tx TYPE /stb99/range_srtfd.

  FIELD-SYMBOLS: <lt_itab>    TYPE table,
                 <pernr> TYPE pernr_d,
                 <line> TYPE any,
                 <field> TYPE any.


  "weitere Objekte
  CREATE DATA ldo_data TYPE TABLE OF pcalac.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM pcalac INTO TABLE <lt_itab>
    WHERE pernr iN at_pernr.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PCALAC'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF ppoix.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM ppoix INTO TABLE <lt_itab>
    WHERE pernr IN at_pernr.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PPOIX'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF ppopx.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM ppopx INTO TABLE <lt_itab>
    WHERE pernr IN at_pernr.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PPOPX'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  "global übernehmen

  CREATE DATA ldo_data TYPE TABLE OF ppdhd.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM ppdhd INTO TABLE <lt_itab>
    WHERE evtyp eq 'PP' or evtyp eq 'TR'.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PPDHD'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF pevat.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM pevat INTO TABLE <lt_itab>
    WHERE type eq 'PP' or type eq 'TR'.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PEVAT'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF pevsh.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM pevsh INTO TABLE <lt_itab>
    WHERE type eq 'PP' or type eq 'TR'.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PEVSH'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF pevst.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM pevst INTO TABLE <lt_itab>
    WHERE type eq 'PP' or type eq 'TR'.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PEVST'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF ppdit.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM ppdit INTO TABLE <lt_itab>.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PPDIT'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF ppdix.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM ppdix INTO TABLE <lt_itab>
    WHERE evtyp eq 'PP' or evtyp eq 'TR'.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PPDIX'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF ppdmsg.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM ppdmsg INTO TABLE <lt_itab>.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PPDMSG'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF ppdsh.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM ppdsh INTO TABLE <lt_itab>.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PPDSH'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.

  CREATE DATA ldo_data TYPE TABLE OF ppdst.
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM ppdst INTO TABLE <lt_itab>.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = 'PPDST'.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.




ENDMETHOD.


METHOD read_tables_time.

  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'TEVEN'.
  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'TEVEN_MORE'.
  CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTQUODED'.

ENDMETHOD.


METHOD read_tables_trvl.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'FITV_HINZ_WERB_B'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'FITV_HINZ_WERB_S'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'FITV_NOT_CH_TR'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_ADMIN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_ARCHIVE'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_ARCH_HEAD'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_ARCH_PERIO'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_CHAIN_MPD'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_CHANGE'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_HEAD'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_KMSUM'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_NOT_CH_TR'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_PERIO'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_RECDETAIL'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SADD'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SBACKLOG'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SCOS'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SHDR'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SREC'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_TRIP_CHAIN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_VATDETAIL'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_WAF_CONFLCT'.

ENDMETHOD.


METHOD READ_TABLE_ARBEITGEBERKONTO.


  DATA: l_table TYPE tabname.

  SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01AK%' AND as4local eq 'A' AND tabclass eq 'TRANSP'.
    CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
  ENDSELECT.






ENDMETHOD.


METHOD READ_TABLE_BEITRAGSNACHWEISE.


  DATA: l_table TYPE tabname.

  SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01BN%' AND as4local eq 'A' AND tabclass eq 'TRANSP'.
    CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
  ENDSELECT.






ENDMETHOD.


METHOD READ_TABLE_BETRIEBSDATENPFL.


  DATA: l_table TYPE tabname.

  SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01BD%' AND as4local eq 'A' AND tabclass eq 'TRANSP'.
    CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
  ENDSELECT.






ENDMETHOD.


METHOD READ_TABLE_COMPLETE.

  DATA:
   lx TYPE xstring,
   ldo_data   TYPE REF TO data,
   ls_cloned TYPE /stb99/tables.

  FIELD-SYMBOLS: <lt_itab>    TYPE table.

  CREATE DATA ldo_data TYPE TABLE OF (tabname).
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM (tabname) INTO TABLE <lt_itab>.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = tabname.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.


ENDMETHOD.


METHOD READ_TABLE_EUBP.


  DATA: l_table TYPE tabname.

  SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01EBP%' AND as4local eq 'A' AND tabclass eq 'TRANSP'.
    CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
  ENDSELECT.






ENDMETHOD.


METHOD READ_TABLE_LSTA.


  DATA: l_table TYPE tabname.

  SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01T\_A\_%' AND as4local eq 'A' AND tabclass eq 'TRANSP'.
    CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
  ENDSELECT.






ENDMETHOD.


METHOD READ_TABLE_RENTENUEBERSICHT.


  DATA: l_table TYPE tabname.

  SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01RUE%' AND as4local eq 'A' AND tabclass eq 'TRANSP'.
    CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
  ENDSELECT.






ENDMETHOD.


METHOD READ_TABLE_WITH_PERNR.
  DATA:
   lx TYPE xstring,
   ldo_data   TYPE REF TO data,
   ls_cloned TYPE /stb99/tables.

  FIELD-SYMBOLS: <lt_itab>    TYPE table.

  CREATE DATA ldo_data TYPE TABLE OF (tabname).
  ASSIGN ldo_data->* TO <lt_itab>.

  SELECT * FROM (tabname) INTO TABLE <lt_itab>
            WHERE pernr IN at_pernr.

  IF <lt_itab>[] IS NOT INITIAL.
    EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
    APPEND lx TO at_xstrtab.
    ls_cloned-index = sy-tabix.
    ls_cloned-tabname = tabname.
    APPEND ls_cloned TO at_cloned_tables.
  ENDIF.


ENDMETHOD.
ENDCLASS.
