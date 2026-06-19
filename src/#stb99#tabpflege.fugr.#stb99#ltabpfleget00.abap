*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /STB99/CT2_CUST.................................*
DATA:  BEGIN OF STATUS_/STB99/CT2_CUST               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/STB99/CT2_CUST               .
CONTROLS: TCTRL_/STB99/CT2_CUST
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /STB99/CT2_RELID................................*
DATA:  BEGIN OF STATUS_/STB99/CT2_RELID              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/STB99/CT2_RELID              .
CONTROLS: TCTRL_/STB99/CT2_RELID
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: */STB99/CT2_CUST               .
TABLES: */STB99/CT2_RELID              .
TABLES: /STB99/CT2_CUST                .
TABLES: /STB99/CT2_RELID               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
