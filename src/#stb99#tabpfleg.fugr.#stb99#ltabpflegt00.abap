*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /STB99/CT2_CUST.................................*
DATA:  BEGIN OF STATUS_/STB99/CT2_CUST               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/STB99/CT2_CUST               .
CONTROLS: TCTRL_/STB99/CT2_CUST
            TYPE TABLEVIEW USING SCREEN '0006'.
*.........table declarations:.................................*
TABLES: */STB99/CT2_CUST               .
TABLES: /STB99/CT2_CUST                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
