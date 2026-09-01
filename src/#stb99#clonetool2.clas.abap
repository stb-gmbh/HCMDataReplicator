class /STB99/CLONETOOL2 definition
  public
  final
  create public .

public section.

*"* public components of class /STB99/CLONETOOL2
*"* do not include other source files here!!!
  data CUSTOMIZING type /STB99/CT2_CUST .
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
      !XSTRTAB type /STB99/XTAB
    exceptions
      NOTHING_SELECTED .
  methods CONSTRUCTOR .
  methods READ_FIELDS_WITH_PERNR
    importing
      !TABNAME type TABNAME .
  methods READ_TABLES_ADDITIONAL .
  methods READ_TABLES_CLUSTER
    exceptions
      CLUSTER_NOT_IMPLEMENTED .
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
  methods READ_TABLE_GOS .
  methods READ_TABLE_LSTA .
  methods READ_TABLE_RENTENUEBERSICHT .
  methods READ_TABLE_SVZUSATZ .
  methods READ_TABLE_WITH_PERNR
    importing
      !TABNAME type TABNAME .
  methods READ_TABLE_B2A .
  methods READ_TABLE_UVM .
  methods READ_TABLE_RVBEA .
  methods READ_TABLE_BEA .
  PROTECTED SECTION.
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
  methods READ_MELD_DABPV .
  methods READ_MELD_RVBEAFORMS .
ENDCLASS.



CLASS /STB99/CLONETOOL2 IMPLEMENTATION.


  METHOD add_guid_table.
    DATA ls_add_tab TYPE LINE OF iqtrtab.

    CLEAR ls_add_tab.
    ls_add_tab-low = table.
    ls_add_tab-option = 'EQ'.
    ls_add_tab-sign = 'I'.
    APPEND ls_add_tab TO add_guid_tabs.



  ENDMETHOD.


  METHOD clone.

    DATA: ls_pernr LIKE LINE OF at_pernr.

    "Personalnummern ermitteln
    CLEAR at_pernr[].
    SELECT pernr FROM pa0003 INTO ls_pernr-low WHERE pernr IN s_pernr
      ORDER BY pernr ASCENDING.
      ls_pernr-sign = 'I'.
      ls_pernr-option = 'EQ'.
      APPEND ls_pernr TO at_pernr.
    ENDSELECT.

    if at_pernr[] IS INITIAL.
      raise nothing_selected.
    endif.

    "Parameter von Quellsystem (welche Verfahren etc.)
    at_infty[] = gr_infty[].

    CALL METHOD me->read_tables_infotypes.
    CALL METHOD me->read_tables_additional.
    CALL METHOD me->read_tables_cluster.
    CALL METHOD me->read_table_svzusatz.
    CALL METHOD me->read_tables_time.
    CALL METHOD me->read_tables_orgman.
    CALL METHOD me->read_tables_trvl.
    CALL METHOD me->read_tables_numkr.
    CALL METHOD me->read_tables_pcp0.
    CALL METHOD me->read_meld_a1.
    CALL METHOD me->read_meld_elena.
    CALL METHOD me->read_meld_eau.
    CALL METHOD me->read_meld_rbm.
    CALL METHOD me->read_meld_bv.
    CALL METHOD me->read_meld_ea.
    CALL METHOD me->read_meld_ee.
    CALL METHOD me->read_meld_deuev.
    CALL METHOD me->read_meld_lstb. "Meldeverfahren LStB
    CALL METHOD me->read_meld_elstam. ""Meldeverfahren ElStAM
    CALL METHOD me->read_table_beitragsnachweise. "Meldeverfahren Beitragsnachweise
    CALL METHOD me->read_table_lsta. "Meldeverfahren LStA
    CALL METHOD me->read_table_betriebsdatenpfl. "Meldeverfahren Betriebsdaten
    CALL METHOD me->read_table_arbeitgeberkonto. "Meldeverfahren Arbeitgeberkonto
    CALL METHOD me->read_table_rentenuebersicht. ""Meldeverfahren Rentenübersicht
    CALL METHOD me->read_table_eubp.
    CALL METHOD me->read_table_gos.
    CALL METHOD me->READ_MELD_DABPV.
    CALL METHOD me->read_meld_rvbeaforms.

    CALL METHOD me->READ_TABLE_RVBEA.
    CALL METHOD me->READ_TABLE_BEA.
    CALL METHOD me->read_table_b2a.
    CALL METHOD me->read_meld_zs.
    CALL METHOD me->read_table_uvm.

    "versicheurngsnummer vav
    "KEG
    "ESS ABW PTCOR
    "ptquoded



    "PCL1:
*TA	RP-Reisekosten allg. Daten
*TC	RP-Reisekosten Kreditkartendaten
*TE	RP-Reisekosten international
*TS	RP-Reisekosten Shared
*TV	RP-Reisekosten Stammdaten VCF4


    "Rückgabe an FuB
    xstrtab = at_xstrtab.
    cloned_tables = at_cloned_tables.
    s_pernr = at_pernr.

  ENDMETHOD.


  METHOD constructor.


    TYPES:
      tt_clst TYPE STANDARD TABLE OF /stb99/clst
        WITH EMPTY KEY.

    DATA(lt_clst) = VALUE tt_clst(

*   ---------------------------------------------------------------
*   PCL1 - Zeitwirtschaft, BDE und persönliche Kalenderdaten
*   ---------------------------------------------------------------

      ( tabname = 'PCL1'
        relid   = 'B1' ) " BDE-Daten

      ( tabname = 'PCL2'
        relid   = 'B2' ) " BDE-Auswertung / PDC-Evaluation

*      ( tabname = 'PCL1'
*        relid   = 'B3' ) " Puffer für BDE-Sätze
*
*      ( tabname = 'PCL1'
*        relid   = 'B4' ) " Deponie für BDE-Sätze

*      ( tabname = 'PCL1'
*        relid   = 'G1' ) " Gruppen-Leistungslohn
*
*      ( tabname = 'PCL1'
*        relid   = 'G3' ) " BDE-Daten für Gruppen

      ( tabname = 'PCL1'
        relid   = 'PC' ) " Persönlicher Kalender

      ( tabname = 'PCL1'
        relid   = 'TE' ) " Reisekosten


*   ---------------------------------------------------------------
*   PCL2 - Personalabrechnung Deutschland
*   ---------------------------------------------------------------

      ( tabname = 'PCL2'
        relid   = 'CU' ) " Verzeichnis der Abrechnungsergebnisse

*      ( tabname = 'PCL2'
*        relid   = 'CE' ) " Abrechnungsergebnis: Personenergebnis CE

      ( tabname = 'PCL2'
        relid   = 'RD' ) " Abrechnungsergebnis Deutschland

*      ( tabname = 'PCL2'
*        relid   = 'RU' ) " Abrechnungsergebnis international

*      ( tabname = 'PCL2'
*        relid   = 'RX' ) " Internationales Abrechnungsergebnis

*      ( tabname = 'PCL2'
*        relid   = 'BT' ) " Banktransferdaten

*      ( tabname = 'PCL2'
*        relid   = 'CD' ) " Cluster-Verzeichnis

*      ( tabname = 'PCL2'
*        relid   = 'DR' ) " Pfändungen Deutschland, Schattencluster

*      ( tabname = 'PCL2'
*        relid   = 'DS' ) " Directory Pfändung Deutschland, Schattencluster

*      ( tabname = 'PCL2'
*        relid   = 'DT' ) " Pfändungen Deutschland, Schattencluster-Sicherung

*      ( tabname = 'PCL2'
*        relid   = 'DV' ) " Directory Pfändung, Schattencluster-Sicherung


**   ---------------------------------------------------------------
**   PCL3 - Reisekosten
**   ---------------------------------------------------------------
*
*      ( tabname = 'PCL3'
*        relid   = 'LA' ) " Reisekostendaten
*
*      ( tabname = 'PCL3'
*        relid   = 'LB' ) " Reisekostenbelege


**   ---------------------------------------------------------------
**   PCL4 - Zeitwirtschaft
**   ---------------------------------------------------------------
*
*      ( tabname = 'PCL4'
*        relid   = 'TX' ) " Zeitwirtschaftsdaten
*

**   ---------------------------------------------------------------
**   PCL5 - Bewerbermanagement
**   ---------------------------------------------------------------
*
*      ( tabname = 'PCL5'
*        relid   = 'PS' ) " Bewerberdaten
*
    ).

* Alte Definitionen entfernen
    DELETE FROM /stb99/clst
    WHERE tabname = 'PCL1'
       OR tabname = 'PCL2'
       OR tabname = 'PCL3'
       OR tabname = 'PCL4'
       OR tabname = 'PCL5'.

    IF sy-subrc <> 0 AND sy-subrc <> 4.
      ROLLBACK WORK.

      MESSAGE e398(00)
        WITH 'Fehler beim Löschen der Tabelle /STB99/CLST'.
    ENDIF.

* Neue Definitionen einfügen
    INSERT /stb99/clst FROM TABLE @lt_clst.

    IF sy-subrc <> 0.
      ROLLBACK WORK.

      MESSAGE e398(00)
        WITH 'Fehler beim Befüllen der Tabelle /STB99/CLST'.
    ENDIF.

    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD read_fields_with_pernr.
    DATA:
      lx            TYPE xstring,
      ldo_data      TYPE REF TO data,
      lr_flat_data  TYPE REF TO data,
      lo_flat_table TYPE REF TO cl_abap_tabledescr,
      ls_cloned     TYPE /stb99/tables.
    DATA: lt_desc   TYPE /stb99/clonetool2rtts=>tt_components.

    FIELD-SYMBOLS: <lt_itab>    TYPE table,
                   <lt_flat>   TYPE table,
                   <ls_source> TYPE any,
                   <ls_flat>   TYPE any.

    CREATE DATA ldo_data TYPE TABLE OF (tabname).
    ASSIGN ldo_data->* TO <lt_itab>.

    SELECT * FROM (tabname) INTO TABLE <lt_itab>
              WHERE pernr IN at_pernr.

    IF <lt_itab>[] IS NOT INITIAL.




      "------------------------------------------------------------
      "Flache Beschreibung erzeugen
      "------------------------------------------------------------
      lt_desc =
        /stb99/clonetool2rtts=>describe_table(
          it_table = <lt_itab> ).


      "------------------------------------------------------------
      "Flache Tabelle erzeugen
      "------------------------------------------------------------
      lo_flat_table =
        /stb99/clonetool2rtts=>create_table(
          it_desc = lt_desc ).


      CREATE DATA lr_flat_data
        TYPE HANDLE lo_flat_table.

      ASSIGN lr_flat_data->* TO <lt_flat>.


      "------------------------------------------------------------
      "Original -> flache Übertragungsstruktur
      "------------------------------------------------------------
      LOOP AT <lt_itab> ASSIGNING <ls_source>.

        APPEND INITIAL LINE TO <lt_flat>
          ASSIGNING <ls_flat>.

        MOVE-CORRESPONDING <ls_source> TO <ls_flat>.

      ENDLOOP.


      "------------------------------------------------------------
      "Jetzt wird nur noch die flache Struktur serialisiert
      "------------------------------------------------------------
      EXPORT
        p1 = <lt_flat>
        p2 = lt_desc
        TO DATA BUFFER lx.


      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = tabname.
      ls_cloned-mode    = 'M'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.

  ENDMETHOD.


  METHOD read_meld_a1.
    CHECK me->customizing-a1 IS NOT INITIAL.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01A1_STAT'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01A1_EXT_DATA'.

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


  METHOD read_meld_bv.
    CHECK me->customizing-bv IS NOT INITIAL.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'p01bv_stat'.

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


  METHOD READ_MELD_DABPV.
    CONSTANTS: gui_tabname TYPE tabname VALUE 'P01_DBP_STAT'.

    CHECK me->customizing-DaBPV IS NOT INITIAL.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = gui_tabname.

    CLEAR add_guid_tabs[].
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_DBP_HINWCODE'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_DBP_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_DBP_KINDER'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_DBP_NOTIFDAT'.

    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = gui_tabname
        add_tab  = add_guid_tabs.

  ENDMETHOD.


  METHOD read_meld_deuev.
    CHECK me->customizing-deuv IS NOT INITIAL.

    CONSTANTS: gui_tabname TYPE tabname VALUE 'P01ZS_STAT'.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBAN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBEU'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBGB'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBKS'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBKV'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBME'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBNA'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBSO'.
* CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBS'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DSAP'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DSME'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3FLAG'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3HIST'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PD3DBUV'.



  ENDMETHOD.


  METHOD read_meld_ea.
    CHECK me->customizing-ea IS NOT INITIAL.

    CONSTANTS: gui_tabname TYPE tabname VALUE 'P01EA_STAT'.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = gui_tabname.

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

    CHECK me->customizing-eau IS NOT INITIAL.

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


  METHOD read_meld_ee.
    CHECK me->customizing-ee IS NOT INITIAL.

    CONSTANTS: gui_tabname TYPE tabname VALUE 'p01EE_stat'.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = gui_tabname.

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


  METHOD read_meld_elena.
    CHECK me->customizing-elena IS NOT INITIAL.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01EL_STAT'.

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

    CHECK me->customizing-elsta IS NOT INITIAL.

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
*    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_LIST_ST'.
*    CALL METHOD me->add_guid_table EXPORTING table = 'P01E2_LISTMTL_ST'.
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
    CHECK me->customizing-lstb IS NOT INITIAL.

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







  ENDMETHOD.


  METHOD read_meld_rbm.
    CHECK me->customizing-rbm IS NOT INITIAL.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'P01RBM_STAT'.

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


  METHOD READ_MELD_RVBEAFORMS.
    CONSTANTS: gui_tabname TYPE tabname VALUE 'P01_RVF_STAT'.

    CHECK me->customizing-rvbf IS NOT INITIAL.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = gui_tabname.

    CLEAR add_guid_tabs[].

    CALL METHOD me->add_guid_table EXPORTING table = 'P01_RVF_DXAR_MON'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_RVF_DXAR_VAL'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_RVF_DXEB_MON'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_RVF_DXWL'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_RVF_FEHLER'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_RVF_HIST'.
    CALL METHOD me->add_guid_table EXPORTING table = 'P01_RVF_INFO'.

    CALL METHOD me->read_tables_meld_with_guid
      EXPORTING
        tab_guid = gui_tabname
        add_tab  = add_guid_tabs.


  ENDMETHOD.


  METHOD read_meld_zs.
    CHECK me->customizing-zs IS NOT INITIAL.

    SELECT tabname
        FROM dd02l
        INTO @DATA(l_table)
        WHERE tabname LIKE 'P01ZS%'
          AND as4local = 'A'
          AND tabclass = 'TRANSP'.

      CALL METHOD me->read_table_complete
        EXPORTING
          tabname = l_table.
      ENDSELECT.

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

    CHECK me->customizing-calc IS NOT INITIAL.

    DATA:
      lx        TYPE xstring,
      ldo_data  TYPE REF TO data,
      ls_cloned TYPE /stb99/tables.

    FIELD-SYMBOLS: <lt_itab>    TYPE table.

    DATA: s_srtfd  TYPE /stb99/range_srtfd_t,
          s_srtfd2 TYPE /stb99/range_srtfd_t,
          l_srtfd  TYPE /stb99/range_srtfd.

    DATA: s_relid TYPE /stb99/copy_relid_range,
          l_relid TYPE /stb99/copy_relid_range_line.

    DATA: rgdir    TYPE TABLE OF pc261,
          ls_rgdir TYPE pc261.

    DATA: BEGIN OF cdkey,
            pernr TYPE pernr_d,             "key to cluster directory
          END OF cdkey.

    DATA: s_abkrs TYPE /stb99/range_abkrs_t,
          l_abkrs TYPE /stb99/range_abkrs.

    FIELD-SYMBOLS: <line>  TYPE any,
                   <field> TYPE any.

    DATA: ls_pernr LIKE LINE OF at_pernr.


    SELECT * FROM /stb99/clst INTO @DATA(ls_clst).
      CASE ls_clst-tabname.
        WHEN 'PCL1'.
          CASE ls_clst-relid.
            WHEN 'B1' OR 'PC' OR 'TE'.
              "Personalnummer*
              CLEAR l_srtfd.
              l_srtfd-option = 'CP'.
              l_srtfd-sign = 'I'.
              LOOP AT at_pernr INTO ls_pernr.
                l_srtfd-low(8) = ls_pernr-low.
                l_srtfd-low+8(1) = '*'.
                APPEND l_srtfd TO s_srtfd.
              ENDLOOP.
            WHEN OTHERS.
              RAISE cluster_not_implemented.
          ENDCASE.
        WHEN 'PCL2'.
          CASE ls_clst-relid.
            WHEN 'CU' OR 'RD' OR 'B2'.
              "Personalnummer*
              CLEAR l_srtfd.
              l_srtfd-option = 'CP'.
              l_srtfd-sign = 'I'.
              LOOP AT at_pernr INTO ls_pernr.
                l_srtfd-low(8) = ls_pernr-low.
                l_srtfd-low+8(1) = '*'.
                APPEND l_srtfd TO s_srtfd.
              ENDLOOP.
            WHEN OTHERS.
              RAISE cluster_not_implemented.

          ENDCASE.
      ENDCASE.

      "Tabelle mit tabname und relid und srtfd lesen
      CREATE DATA ldo_data TYPE TABLE OF (ls_clst-tabname).
      ASSIGN ldo_data->* TO <lt_itab>.
      " Daten selektieren
      SELECT * FROM (ls_clst-tabname) INTO TABLE <lt_itab>
        WHERE relid EQ ls_clst-relid
          AND srtfd IN s_srtfd.

      IF <lt_itab>[] IS NOT INITIAL.
        EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
        APPEND lx TO at_xstrtab.
        ls_cloned-index = sy-tabix.
        ls_cloned-tabname = ls_clst-tabname.
        APPEND ls_cloned TO at_cloned_tables.
      ENDIF.

*          IF me->customizing-pa03 IS NOT INITIAL AND ls_clst-relid EQ 'CU'.
      "Abrechnungskreise für PA03 sammeln
      CLEAR l_abkrs.
      REFRESH s_abkrs.
      l_abkrs-sign = 'I'.
      l_abkrs-option = 'EQ'.
      LOOP AT <lt_itab> ASSIGNING <line>.
        ASSIGN COMPONENT 'SRTFD' OF STRUCTURE <line> TO <field>.
        IF sy-subrc EQ 0.
          cdkey = <field>.

          REFRESH rgdir.
          IMPORT rgdir TO rgdir
          FROM DATABASE pcl2(cu)
          ID cdkey.
          LOOP AT rgdir INTO ls_rgdir.
            l_abkrs-low = ls_rgdir-abkrs.
            COLLECT l_abkrs INTO s_abkrs.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
*          ENDIF.

    ENDSELECT.

    "Zentrale Personen
    CREATE DATA ldo_data TYPE TABLE OF hrp1000.
    ASSIGN ldo_data->* TO <lt_itab>.

    SELECT * FROM hrp1000 INTO TABLE <lt_itab>
      WHERE plvar EQ '01'
        AND otype EQ 'P'
        AND objid IN s_srtfd.

    IF <lt_itab>[] IS NOT INITIAL.
      EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = 'HRP1000'.
      ls_cloned-mode = 'Z'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.

    CREATE DATA ldo_data TYPE TABLE OF hrp1001.
    ASSIGN ldo_data->* TO <lt_itab>.

    SELECT * FROM hrp1001 INTO TABLE <lt_itab>
      WHERE plvar EQ '01' AND ( ( otype EQ 'P'  AND sclas EQ 'CP' AND objid IN s_srtfd ) OR
                                ( otype EQ 'CP' AND sclas EQ 'P'  AND sobid IN s_srtfd )
                              ).

    "Zentrale Personen sammeln
    REFRESH s_srtfd2.
    LOOP AT <lt_itab> ASSIGNING <line>.
      ASSIGN COMPONENT 'OTYPE' OF STRUCTURE <line> TO <field>.
      IF sy-subrc EQ 0.
        CHECK <field> EQ 'CP'.
        ASSIGN COMPONENT 'OBJID' OF STRUCTURE <line> TO <field>.
        CLEAR l_srtfd.
        l_srtfd-option = 'EQ'.
        l_srtfd-sign = 'I'.
        LOOP AT at_pernr INTO ls_pernr.
          l_srtfd-low = <field>.
          APPEND l_srtfd TO s_srtfd2.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

    IF <lt_itab>[] IS NOT INITIAL.
      EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = 'HRP1001'.
      ls_cloned-mode = 'Z'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.

    CREATE DATA ldo_data TYPE TABLE OF hrp1000.
    ASSIGN ldo_data->* TO <lt_itab>.

    SELECT * FROM hrp1000 INTO TABLE <lt_itab>
      WHERE plvar EQ '01'
        AND otype EQ 'CP'
        AND objid IN s_srtfd2.

    IF <lt_itab>[] IS NOT INITIAL.
      EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = 'HRP1000'.
      ls_cloned-mode = 'Z'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.


































    "Abrechnungskreise
    IF me->customizing-numkr IS NOT INITIAL
      AND s_abkrs IS NOT INITIAL.
      CREATE DATA ldo_data TYPE TABLE OF t569v.
      ASSIGN ldo_data->* TO <lt_itab>.

* Daten selektieren
      SELECT * FROM t569v INTO TABLE <lt_itab>
        WHERE abkrs IN s_abkrs.

      CHECK <lt_itab>[] IS NOT INITIAL.
      EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = 'T569V'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.


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
      lx                TYPE xstring,
      ldo_data          TYPE REF TO data,
      ls_cloned         TYPE /stb99/tables,
      ls_table_to_clone TYPE /stb99/tables_to_clone.

    DATA: l_srtfd_tx TYPE /stb99/range_srtfd.

    FIELD-SYMBOLS: <lt_itab> TYPE table,
                   <pernr>   TYPE pernr_d,
                   <line>    TYPE any,
                   <field>   TYPE any.



    SELECT * FROM dd03l INTO CORRESPONDING FIELDS OF ls_table_to_clone
       WHERE tabname BETWEEN 'PA0000' AND 'PA9999'
         AND fieldname EQ 'PERNR'
         ORDER BY tabname ASCENDING.

      CHECK ls_table_to_clone-tabname NE 'PA2001_UGR'
        AND ls_table_to_clone-tabname NE 'PA2002_UGR'
        AND ls_table_to_clone-tabname NE 'PA2006_UGR'
        AND ls_table_to_clone-tabname NE 'PA2007_UGR'.


      "Infotyp Selektion
      CHECK ls_table_to_clone-tabname+2(4) IN at_infty.


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


  METHOD read_tables_meld_with_guid.
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


  METHOD read_tables_numkr.
    CHECK me->customizing-numkr IS NOT INITIAL.

    DATA:
      lx                 TYPE xstring,
      ldo_data           TYPE REF TO data,
      ls_cloned          TYPE /stb99/tables,
      ls_tables_to_clone TYPE /stb99/tables_to_clone.

    FIELD-SYMBOLS: <lt_itab> TYPE table,
                   <line>    TYPE any,
                   <field>   TYPE any.


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

    CHECK me->customizing-org IS NOT INITIAL.

    DATA:
      lx                 TYPE xstring,
      ldo_data           TYPE REF TO data,
      ls_cloned          TYPE /stb99/tables,
      ls_tables_to_clone TYPE /stb99/tables_to_clone,
      ls_pernr           TYPE /stb99/pernr_table.

    FIELD-SYMBOLS: <lt_itab> TYPE table,
                   <pernr>   TYPE any.

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

    DATA: pernr_table TYPE TABLE OF /stb99/pernr_table.

    CHECK me->customizing-org IS NOT INITIAL.

    IF me->customizing-wegid IS NOT INITIAL.

      LOOP AT at_pernr INTO ls_pernr.
        CALL FUNCTION 'RH_STRUC_GET'
          EXPORTING
            act_otype      = 'P'
            act_objid      = ls_pernr-pernr
            act_wegid      = me->customizing-wegid
*           ACT_INT_FLAG   =
            act_plvar      = me->customizing-plvar
            act_begda      = '19000101'
            act_endda      = '99991231'
            act_tdepth     = me->customizing-depth
*           ACT_TFLAG      = 'X'
*           ACT_VFLAG      = 'X'
*           AUTHORITY_CHECK        = 'X'
*           TEXT_BUFFER_FILL       =
*           BUFFER_MODE    =
*       IMPORTING
*           ACT_PLVAR      =
          TABLES
            result_tab     = lt_result_tab
*           result_objec   =
            result_struc   = lt_result_struc
          EXCEPTIONS
            no_plvar_found = 1
            no_entry_found = 2
            OTHERS         = 3.
        IF sy-subrc EQ 0.
          LOOP AT lt_result_tab INTO ls_result_tab WHERE otype IN s_otype.
            l_objid-low = ls_result_tab-objid.
            l_objid-sign = 'I'.
            l_objid-option = 'EQ'.
            COLLECT l_objid INTO s_objid.

            l_otype-low = ls_result_tab-otype.
            l_otype-sign = 'I'.
            l_otype-option = 'EQ'.
            COLLECT l_otype INTO s_otype.
          ENDLOOP.
        ENDIF.
      ENDLOOP. "pernr
    ELSE. "ohne wegid alles kopieren
      REFRESH s_otype[].
      REFRESH s_objid[].
    ENDIF.

    SELECT * FROM dd03l INTO CORRESPONDING FIELDS OF ls_tables_to_clone
          WHERE tabname BETWEEN 'HRP1000' AND 'HRP9999'
            AND fieldname EQ 'OBJID'
            ORDER BY tabname ASCENDING.

      CREATE DATA ldo_data TYPE TABLE OF (ls_tables_to_clone-tabname).
      ASSIGN ldo_data->* TO <lt_itab>.

      SELECT * FROM (ls_tables_to_clone-tabname) INTO TABLE <lt_itab>
        WHERE otype IN s_otype
          AND objid IN s_objid.


      CHECK <lt_itab>[] IS NOT INITIAL.
      EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = ls_tables_to_clone-tabname.
      APPEND ls_cloned TO at_cloned_tables.

    ENDSELECT.





*    IF ls_tables_to_clone-tabname EQ 'HRP1001'.
*      SELECT * FROM (ls_tables_to_clone-tabname) APPENDING TABLE <lt_itab>
*        WHERE sclas EQ 'P'
*          AND sobid IN at_pernr.

*
*      SELECT DISTINCT pernr INTO CORRESPONDING FIELDS OF ls_pernr
*        FROM pa0003
*        WHERE pernr IN at_pernr.
*      ENDSELECT.
*
*      LOOP AT pernr_table INTO ls_pernr.
*        CALL FUNCTION 'RH_STRUC_GET'
*          EXPORTING
*            act_otype      = 'P'
*            act_objid      = ls_pernr-pernr
*            act_wegid      = me->customizing-wegid
**           ACT_INT_FLAG   =
*            act_plvar      = me->customizing-plvar
*            act_begda      = '19000101'
*            act_endda      = '99991231'
*            act_tdepth     = me->customizing-depth
**           ACT_TFLAG      = 'X'
**           ACT_VFLAG      = 'X'
**           AUTHORITY_CHECK        = 'X'
**           TEXT_BUFFER_FILL       =
**           BUFFER_MODE    =
**       IMPORTING
**           ACT_PLVAR      =
*          TABLES
*            result_tab     = lt_result_tab
**           result_objec   =
*            result_struc   = lt_result_struc
*          EXCEPTIONS
*            no_plvar_found = 1
*            no_entry_found = 2
*            OTHERS         = 3.
*        IF sy-subrc EQ 0.
*          LOOP AT lt_result_tab INTO ls_result_tab WHERE otype IN s_otype.
*            l_objid-low = ls_result_tab-objid.
*            l_objid-sign = 'I'.
*            l_objid-option = 'EQ'.
*            COLLECT l_objid INTO s_objid.
*          ENDLOOP.

*          lt_result_struc[] = it_result_struc[].
*
*          LOOP AT it_result_struc INTO is_result_struc.
*            IF is_result_struc-pup GT 0.
*
*              LOOP AT lt_result_struc INTO ls_result_struc
*                WHERE level EQ is_result_struc-pup.
*                EXIT.
*              ENDLOOP.
*
*              SELECT * FROM hrp1001 APPENDING TABLE <lt_itab>
*                WHERE otype EQ ls_result_struc-otype
*                  AND objid EQ ls_result_struc-objid
*                  AND sclas EQ is_result_struc-otype
*                  AND sobid EQ is_result_struc-objid
*                  AND begda EQ is_result_struc-vbegda
*                  AND endda EQ is_result_struc-vendda.
*
*              SELECT * FROM hrp1001 APPENDING TABLE <lt_itab>
*                WHERE otype EQ is_result_struc-otype
*                  AND objid EQ is_result_struc-objid
*                  AND sclas EQ ls_result_struc-otype
*                  AND sobid EQ ls_result_struc-objid
*                  AND begda EQ is_result_struc-vbegda
*                  AND endda EQ is_result_struc-vendda.
*
*            ENDIF.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.


*      "weitere Objekte
*      CREATE DATA ldo_data TYPE TABLE OF hrp1000.
*      ASSIGN ldo_data->* TO <lt_itab>.
*
*      SELECT * FROM hrp1000 INTO TABLE <lt_itab>
*        WHERE plvar EQ me->customizing-plvar
*          AND objid IN s_objid.
*
*      DELETE ADJACENT DUPLICATES FROM <lt_itab>.
*
*      IF <lt_itab>[] IS NOT INITIAL.
*        EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
*        APPEND lx TO at_xstrtab.
*        ls_cloned-index = sy-tabix.
*        ls_cloned-tabname = 'HRP1000'.
*        APPEND ls_cloned TO at_cloned_tables.
*      ENDIF.
*      CREATE DATA ldo_data TYPE TABLE OF plogi.
*      ASSIGN ldo_data->* TO <lt_itab>.
*
*      SELECT * FROM plogi INTO TABLE <lt_itab>
*        WHERE plvar EQ me->customizing-plvar
*          AND objid IN s_objid.
*
*      IF <lt_itab>[] IS NOT INITIAL.
*        EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
*        APPEND lx TO at_xstrtab.
*        ls_cloned-index = sy-tabix.
*        ls_cloned-tabname = 'HRP1000'.
*        APPEND ls_cloned TO at_cloned_tables.
*      ENDIF.




  ENDMETHOD.


  METHOD read_tables_pcp0.
    CHECK me->customizing-pcp0 IS NOT INITIAL.

    DATA:
      lx                 TYPE xstring,
      ldo_data           TYPE REF TO data,
      ls_cloned          TYPE /stb99/tables,
      ls_tables_to_clone TYPE /stb99/tables_to_clone.

    DATA: l_srtfd_tx TYPE /stb99/range_srtfd.

    FIELD-SYMBOLS: <lt_itab> TYPE table,
                   <pernr>   TYPE pernr_d,
                   <line>    TYPE any,
                   <field>   TYPE any.


    "weitere Objekte
    CREATE DATA ldo_data TYPE TABLE OF pcalac.
    ASSIGN ldo_data->* TO <lt_itab>.

    SELECT * FROM pcalac INTO TABLE <lt_itab>.
*      WHERE pernr IN at_pernr.

    IF <lt_itab>[] IS NOT INITIAL.
      EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = 'PCALAC'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.

    CREATE DATA ldo_data TYPE TABLE OF ppoix.
    ASSIGN ldo_data->* TO <lt_itab>.

    SELECT * FROM ppoix INTO TABLE <lt_itab>.
*      WHERE pernr IN at_pernr.

    IF <lt_itab>[] IS NOT INITIAL.
      EXPORT p1 = <lt_itab> TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-tabname = 'PPOIX'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.

    CREATE DATA ldo_data TYPE TABLE OF ppopx.
    ASSIGN ldo_data->* TO <lt_itab>.

    SELECT * FROM ppopx INTO TABLE <lt_itab>.
*      WHERE pernr IN at_pernr.

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
      WHERE evtyp EQ 'PP' OR evtyp EQ 'TR'.

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
      WHERE type EQ 'PP' OR type EQ 'TR'.

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
      WHERE type EQ 'PP' OR type EQ 'TR'.

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
      WHERE type EQ 'PP' OR type EQ 'TR'.

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
      WHERE evtyp EQ 'PP' OR evtyp EQ 'TR'.

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

    CHECK me->customizing-time IS NOT INITIAL.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'TEVEN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'TEVEN_MORE'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTQUODED'.

  ENDMETHOD.


  METHOD read_tables_trvl.
    CHECK me->customizing-trvl IS NOT INITIAL.

    CALL METHOD me->read_fields_with_pernr EXPORTING tabname = 'PTRV_HEAD'.
    CALL METHOD me->read_fields_with_pernr EXPORTING tabname = 'PTRV_PERIO'.

    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'FITV_HINZ_WERB_B'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'FITV_HINZ_WERB_S'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'FITV_NOT_CH_TR'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_ADMIN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_ARCHIVE'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_ARCH_HEAD'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_ARCH_PERIO'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_CHAIN_MPD'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_CHANGE'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_KMSUM'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_NOT_CH_TR'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_RECDETAIL'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SADD'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SBACKLOG'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SCOS'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SHDR'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_SREC'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_TRIP_CHAIN'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_VATDETAIL'.
    CALL METHOD me->read_table_with_pernr EXPORTING tabname = 'PTRV_WAF_CONFLCT'.

    CALL METHOD me->read_table_complete EXPORTING  tabname = 'PTRV_DOC_HD'.
    CALL METHOD me->read_table_complete EXPORTING  tabname = 'PTRV_DOC_IT'.
    CALL METHOD me->read_table_complete EXPORTING  tabname = 'PTRV_DOC_MESS'.
    CALL METHOD me->read_table_complete EXPORTING  tabname = 'PTRV_DOC_TAX'.

  ENDMETHOD.


  METHOD read_table_arbeitgeberkonto.
    CHECK me->customizing-agkto IS NOT INITIAL.

    DATA: l_table TYPE tabname.

    SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01AK%' AND as4local EQ 'A' AND tabclass EQ 'TRANSP'.
      CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
    ENDSELECT.






  ENDMETHOD.


  METHOD read_table_b2a.
    CHECK me->customizing-b2a IS NOT INITIAL.

    SELECT tabname
      FROM dd02l
      INTO @DATA(l_table)
      WHERE tabname LIKE 'PB2A%'
        AND as4local = 'A'
        AND tabclass = 'TRANSP'.

      CALL METHOD me->read_table_complete
        EXPORTING
          tabname = l_table.

    ENDSELECT.

    "Werma
    l_table = 'T5D1I'.
    CALL METHOD me->read_table_complete
      EXPORTING
        tabname = l_table.



  ENDMETHOD.


  METHOD READ_TABLE_BEA.
    CHECK me->customizing-bea IS NOT INITIAL.

    SELECT tabname
      FROM dd02l
      INTO @DATA(l_table)
      WHERE ( tabname LIKE 'P01SV%')
        AND as4local = 'A'
        AND tabclass = 'TRANSP'.

      CALL METHOD me->read_table_complete
        EXPORTING
          tabname = l_table.

    ENDSELECT.

  ENDMETHOD.


  METHOD read_table_beitragsnachweise.
    CHECK me->customizing-beitr IS NOT INITIAL.

    DATA: l_table TYPE tabname.

    SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01BN%' AND as4local EQ 'A' AND tabclass EQ 'TRANSP'.
      CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
    ENDSELECT.






  ENDMETHOD.


  METHOD read_table_betriebsdatenpfl.
    CHECK me->customizing-betri IS NOT INITIAL.

    DATA: l_table TYPE tabname.

    SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01BD%' AND as4local EQ 'A' AND tabclass EQ 'TRANSP'.
      CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
    ENDSELECT.






  ENDMETHOD.


  METHOD read_table_complete.

    DATA:
      lx        TYPE xstring,
      ldo_data  TYPE REF TO data,
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


  METHOD read_table_eubp.
    CHECK me->customizing-eubp IS NOT INITIAL.

    DATA: l_table TYPE tabname.

    SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01EBP%' AND as4local EQ 'A' AND tabclass EQ 'TRANSP'.
      CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
    ENDSELECT.






  ENDMETHOD.


  METHOD read_table_gos.
    CHECK me->customizing-gos IS NOT INITIAL.

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
      lt_relations     TYPE STANDARD TABLE OF srgbtbrel,
      ls_relation      TYPE srgbtbrel,

      ls_attachment    TYPE ty_attachment,

      ls_sood          TYPE sood,

      lv_len           TYPE i,
      lv_offset        TYPE i,

      lv_folder_key    TYPE c LENGTH 17,
      lv_doc_key       TYPE c LENGTH 17,

      lv_objtp         TYPE sood-objtp,
      lv_objyr         TYPE sood-objyr,
      lv_objno         TYPE sood-objno,

      lv_folder_id     TYPE soodk,
      lv_object_id     TYPE soodk,

      ls_object_hd     TYPE sood2,

      lt_objcont       TYPE STANDARD TABLE OF soli,

      lt_solix         TYPE solix_tab,

      lv_xstring       TYPE xstring,
      lv_filename      TYPE string,
      lv_ext           TYPE string,

      lv_output_length TYPE i.

    DATA:
      ls_document_data  TYPE sofolenti1,
      lt_object_header  TYPE STANDARD TABLE OF solisti1,
      ls_object_header  TYPE solisti1,
      lt_object_content TYPE STANDARD TABLE OF solisti1,
      lt_contents_hex   TYPE STANDARD TABLE OF solix,
      lv_document_id    TYPE sofolenti1-doc_id,
      lv_size           TYPE i.


    LOOP AT at_pernr ASSIGNING FIELD-SYMBOL(<ls_pernr>).

*---------------------------------------------------------------------*
* GOS-Verknüpfungen lesen
*---------------------------------------------------------------------*
      SELECT *
        FROM srgbtbrel
        INTO TABLE lt_relations
        WHERE typeid_a = 'BUS1065'
          AND instid_a = <ls_pernr>-low
          AND catid_a  = 'BO'
          AND reltype  = 'ATTA'
          AND typeid_b = 'MESSAGE'.

      LOOP AT lt_relations INTO ls_relation.

        CLEAR:
          ls_attachment,
          ls_sood,
          lv_len,
          lv_offset,
          lv_folder_key,
          lv_doc_key,
          lv_objtp,
          lv_objyr,
          lv_objno,
          lv_folder_id,
          lv_object_id,
          ls_object_hd,
          lt_objcont,
          lt_object_header,
          lt_solix,
          lv_xstring,
          lv_filename,
          lv_ext,
          lv_output_length.

*---------------------------------------------------------------------*
* Grunddaten übernehmen
*---------------------------------------------------------------------*
        ls_attachment-pernr    = <ls_pernr>-low.
        ls_attachment-instid_a = ls_relation-instid_a.
        ls_attachment-typeid_a = ls_relation-typeid_a.
        ls_attachment-instid_b = ls_relation-instid_b.
        ls_attachment-typeid_b = ls_relation-typeid_b.
        ls_attachment-reltype  = ls_relation-reltype.

*---------------------------------------------------------------------*
* INSTID_B zerlegen
*
* Beispiel:
*
* FOL2600000000024EXT5100000000033
*
* FOL2600000000024 = Folder
* EXT5100000000033 = Dokument
*---------------------------------------------------------------------*
        lv_len = strlen( ls_relation-instid_b ).

        IF lv_len < 34.
          CONTINUE.
        ENDIF.

*---------------------------------------------------------------------*
* letzte 17 Zeichen = Dokument-ID
*---------------------------------------------------------------------*
        lv_offset = lv_len - 17.

        lv_doc_key = ls_relation-instid_b+lv_offset(17).

*---------------------------------------------------------------------*
* davor liegende 17 Zeichen = Folder-ID
*---------------------------------------------------------------------*
        lv_offset = lv_offset - 17.

        lv_folder_key = ls_relation-instid_b+lv_offset(17).

*---------------------------------------------------------------------*
* Dokument-Key zerlegen
*---------------------------------------------------------------------*
        lv_objtp = lv_doc_key+0(3).
        lv_objyr = lv_doc_key+3(2).
        lv_objno = lv_doc_key+5(12).

*---------------------------------------------------------------------*
* SOOD lesen
*---------------------------------------------------------------------*
        SELECT SINGLE *
          FROM sood
          INTO ls_sood
          WHERE objtp = lv_objtp
            AND objyr = lv_objyr
            AND objno = lv_objno.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        ls_attachment-objtp  = ls_sood-objtp.
        ls_attachment-objyr  = ls_sood-objyr.
        ls_attachment-objno  = ls_sood-objno.
        ls_attachment-objdes = ls_sood-objdes.

*---------------------------------------------------------------------*
* SOODK Folder
*---------------------------------------------------------------------*
        lv_folder_id-objtp = lv_folder_key+0(3).
        lv_folder_id-objyr = lv_folder_key+3(2).
        lv_folder_id-objno = lv_folder_key+5(12).

*---------------------------------------------------------------------*
* SOODK Dokument
*---------------------------------------------------------------------*
        lv_object_id-objtp = lv_doc_key+0(3).
        lv_object_id-objyr = lv_doc_key+3(2).
        lv_object_id-objno = lv_doc_key+5(12).

        CLEAR:
          ls_document_data,
          lt_object_header,
          lt_object_content,
          lt_contents_hex,
          lv_document_id,
          lv_xstring,
          lv_size.

*---------------------------------------------------------------------*
* INSTID_B ist bereits die komplette SAPoffice-Dokument-ID
*
* Beispiel:
* FOL2600000000024EXT5100000000033
*---------------------------------------------------------------------*
        lv_document_id = ls_relation-instid_b.

*---------------------------------------------------------------------*
* SAPoffice-Dokument BINÄR lesen
*---------------------------------------------------------------------*
        CALL FUNCTION 'SO_DOCUMENT_READ_API1'
          EXPORTING
            document_id                = lv_document_id
          IMPORTING
            document_data              = ls_document_data
          TABLES
            object_header              = lt_object_header
            object_content             = lt_object_content
            contents_hex               = lt_contents_hex
          EXCEPTIONS
            document_id_not_exist      = 1
            operation_no_authorization = 2
            x_error                    = 3
            OTHERS                     = 4.

        IF sy-subrc <> 0.
          WRITE: / 'SO_DOCUMENT_READ_API1 Fehler:',
                   sy-subrc,
                   ls_relation-instid_b.
          CONTINUE.
        ENDIF.





*---------------------------------------------------------------------*
* Dateiname aus OBJHEAD bestimmen
*---------------------------------------------------------------------*
        LOOP AT lt_object_header INTO ls_object_header.

          IF ls_object_header-line CS '&SO_FILENAME='.

            lv_filename = ls_object_header-line.

            REPLACE FIRST OCCURRENCE OF '&SO_FILENAME='
              IN lv_filename
              WITH space.

            CONDENSE lv_filename.

            ls_attachment-filename = lv_filename.

            FIND REGEX '\.([^.]+)$'
              IN lv_filename
              SUBMATCHES lv_ext.

            IF sy-subrc = 0.
              ls_attachment-file_ext = lv_ext.
            ENDIF.

          ENDIF.

        ENDLOOP.

*---------------------------------------------------------------------*
* Fallback Dateiname
*---------------------------------------------------------------------*
        IF ls_attachment-filename IS INITIAL.

          ls_attachment-filename = ls_sood-objdes.

        ENDIF.
*---------------------------------------------------------------------*
* SOLIX -> XSTRING
*---------------------------------------------------------------------*
        CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
          EXPORTING
            input_length = lv_size
          IMPORTING
            buffer       = lv_xstring
          TABLES
            binary_tab   = lt_contents_hex
          EXCEPTIONS
            failed       = 1
            OTHERS       = 2.

        IF sy-subrc <> 0.
          WRITE: / 'SCMS_BINARY_TO_XSTRING Fehler:',
                   sy-subrc,
                   ls_relation-instid_b.
          CONTINUE.
        ENDIF.
*---------------------------------------------------------------------*
* Ergebnis
*---------------------------------------------------------------------*
        ls_attachment-file_size    = lv_output_length.
        ls_attachment-content_hex  = lt_contents_hex.
        ls_attachment-content_xstr = lv_xstring.

        APPEND ls_attachment TO gt_attachments.

      ENDLOOP.
    ENDLOOP.


    DATA:
      lx        TYPE xstring,
      ldo_data  TYPE REF TO data,
      ls_cloned TYPE /stb99/tables.


    IF gt_attachments IS NOT INITIAL.
      EXPORT p1 = gt_attachments TO DATA BUFFER lx.
      APPEND lx TO at_xstrtab.
      ls_cloned-index = sy-tabix.
      ls_cloned-mode = 'G'.
      ls_cloned-tabname = 'GOS Dokumente'.
      APPEND ls_cloned TO at_cloned_tables.
    ENDIF.



  ENDMETHOD.


  METHOD read_table_lsta.
    CHECK me->customizing-lsta IS NOT INITIAL.

    DATA: l_table TYPE tabname.

    SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01T\_A\_%' AND as4local EQ 'A' AND tabclass EQ 'TRANSP'.
      CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
    ENDSELECT.






  ENDMETHOD.


  METHOD read_table_rentenuebersicht.
    CHECK me->customizing-rent IS NOT INITIAL.

    DATA: l_table TYPE tabname.

    SELECT tabname FROM dd02l INTO l_table WHERE tabname LIKE 'P01RUE%' AND as4local EQ 'A' AND tabclass EQ 'TRANSP'.
      CALL METHOD me->read_table_complete EXPORTING tabname = l_table.
    ENDSELECT.






  ENDMETHOD.


  METHOD read_table_rvbea.
    CHECK me->customizing-rvbea IS NOT INITIAL.

    SELECT tabname
      FROM dd02l
      INTO @DATA(l_table)
      WHERE ( tabname LIKE 'P01RB%')
        AND as4local = 'A'
        AND tabclass = 'TRANSP'.

      CALL METHOD me->read_table_complete
        EXPORTING
          tabname = l_table.

    ENDSELECT.

  ENDMETHOD.


  METHOD read_table_svzusatz.

    CHECK me->customizing-sv IS NOT INITIAL.

    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_B2A_GLBID'.
    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_B2A_STATUS'.
    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_B2ATRNS'.
    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_DSID'.
    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_IT700_A'.
    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_IT700_B'.
    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_KINDER'.
    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_MLDAUFR'.
    CALL METHOD me->read_table_complete EXPORTING tabname = 'P01SV_MLDTRNS'.

  ENDMETHOD.


  METHOD read_table_uvm.
    CHECK me->customizing-uvm IS NOT INITIAL.

    SELECT tabname
      FROM dd02l
      INTO @data(l_table)
      WHERE ( tabname LIKE 'P01UV%'
           OR tabname LIKE 'P01SV%'
           OR tabname LIKE 'PB2A%'
           OR tabname LIKE 'PD3DBUV%'
           OR tabname LIKE 'PD3DS%'
           OR tabname LIKE 'HRD3%'
           OR tabname LIKE 'PC01B2A%' )
        AND as4local = 'A'
        AND tabclass = 'TRANSP'.

      me->read_table_complete( EXPORTING tabname = l_table ).

    ENDSELECT.

  ENDMETHOD.


  METHOD read_table_with_pernr.
    DATA:
      lx        TYPE xstring,
      ldo_data  TYPE REF TO data,
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
