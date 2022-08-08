REPORT zsn_oops_2.

*methods: importing, exporting, changing, returning

CLASS lcl_emp DEFINITION.
PUBLIC SECTION.
METHODS : setemp IMPORTING i_empno type i
                  " i_ename(20) type c OPTIONAL "err, size declaration iss
                    i_ename type c OPTIONAL
                    i_design TYPE c DEFAULT 'Employee',

          getemp.

PROTECTED SECTION.
data : empno TYPE i,
       ename TYPE c LENGTH 20,
       edesign TYPE c LENGTH 20.

ENDCLASS.

CLASS lcl_emp IMPLEMENTATION.
METHOD getemp.
WRITE : / empno, ename, edesign.
ENDMETHOD. "/getemp-method

METHOD setemp.
empno = i_empno.
ename = i_ename.
edesign = i_design.
ENDMETHOD. "/setemp-method
ENDCLASS.

START-OF-SELECTION.

*crate an object
data ob1 TYPE REF TO lcl_emp.
create object ob1.

PARAMETERs : p_empno TYPE i,
             p_ename TYPE c LENGTH 20,
             p_design TYPE c LENGTH 20.
BREAK-POINT.
call method ob1->setemp
EXPORTING
 i_empno = p_empno
 i_ename = p_ename
 i_design = p_design.
call method ob1->getemp.
