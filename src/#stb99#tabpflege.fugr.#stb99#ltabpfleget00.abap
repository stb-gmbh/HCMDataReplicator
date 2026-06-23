*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /STB99/CT2_CUST.................................*
DATA:  BEGIN OF STATUS_/STB99/CT2_CUST               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/STB99/CT2_CUST               .
CONTROLS: TCTRL_/STB99/CT2_CUST
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /STB99/CT2_OBJ..................................*
DATA:  BEGIN OF STATUS_/STB99/CT2_OBJ                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/STB99/CT2_OBJ                .
CONTROLS: TCTRL_/STB99/CT2_OBJ
            TYPE TABLEVIEW USING SCREEN '0004'.
*.........table declarations:.................................*
TABLES: */STB99/CT2_CUST               .
TABLES: */STB99/CT2_OBJ                .
TABLES: /STB99/CT2_CUST                .
TABLES: /STB99/CT2_OBJ                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
