REPORT zsn_oops_1.

*its a general practice to define the attr under private or protected sectin
*and methods under public section
*attrbutes can be accessed only by the methods in the calss
CLASS lcl_emp DEFINITION.
PUBLIC SECTION.
METHODS : getemp,
          setemp.
PROTECTED SECTION.
data : empno TYPE i,
       ename TYPE c LENGTH 20,
       empdesign(25) type c.

ENDCLASS.

CLASS lcl_emp IMPLEMENTATION.

METHOD getemp.
 empno = 12.
 ename = 'Humayu'.
 empdesign = 'Employee'.
ENDMETHOD. "/getemp

METHOD setemp.
*WRITE : / me->empno, me->ename, me->empdesign. or
WRITE : empno, ename, empdesign.
*me is an implicitly created object
* me refers to the particular object.
ENDMETHOD. "/setemp

ENDCLASS.

START-OF-SELECTION. "define it before defining the object
*problem comes if you don't define start of selection event
DATA ob1 TYPE REF TO lcl_emp.
CREATE OBJECT ob1.
"*CALL METHOD ob1->getemp.
"or
ob1->getemp(  ).
ob1->setemp(  ).

*you can transfer the data from one object to another
uline.
WRITE / 'New object ob2'.
data ob2 TYPE REF TO lcl_emp.
CREATE OBJECT ob2.
ob2 = ob1.
"above the data of ob1 is transfered to ob2.




