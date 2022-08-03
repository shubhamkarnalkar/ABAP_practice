REPORT zsn_intro_to_oops.
* -> arrow operator : for instance attr
* => implies operator : for static attr

class lcl_abc DEFINITION.
PUBLIC SECTION.
data x type i. " instance attribute
class-data y type i. "static attribute
constants z type i value 10. "constant attr

ENDCLASS.

class lcl_abc IMPLEMENTATION.


ENDCLASS.

*WRITE / x. "err due to not refered
*WRITE / y. "Field "Y" is unknown. It is neither in one of the specified tables nor defined by a "DATA" statement. "DATA" statement.
*WRITE / z. "Field "Z" is unknown. It is neither in one of the specified tables nor defined by a "DATA" statement. "DATA" statement.

*WRITE : / lcl_abc->x. "Field "LCL_ABC" is unknown. It is neither in one of the specified tables nor defined by a "DATA" statement. "DATA" statement.
*WRITE : lcl_abc->y. "Field "LCL_ABC" is unknown. It is neither in one of the specified tables nor defined by a "DATA" statement. "DATA" statement.
*WRITE : lcl_abc->z. "Field "LCL_ABC" is unknown. It is neither in one of the specified tables nor defined by a "DATA" statement. "DATA" statement.
"you can not access the instance attr using arrow operator



*WRITE : lcl_abc=>x. "You can only use "class=>attr" with static attributes.
WRITE : / lcl_abc=>y. "runs, 0
WRITE : / lcl_abc=>z. "runs, 10
" always use implies operator in case of referring to the class
" protected components are not allowed to access outside the class

write : / 'Creation of object first'.

DATA ob1 TYPE REF TO lcl_abc.
"object is a reference alias for a class, like structure
"it doesn't occupy any memory

*write : ob1->x. "runtime error due to not created a object first

CREATE OBJECT ob1. " now it allocates memory
WRITE : / ob1->x. "runs, 0 -because instance attr starts from zero
"every time due to instance property to initialize with every object
WRITE : / ob1->y. "runs
WRITE / ob1->z. "runs

ob1->y = 1. " assigning the value to the static attr
" the value of the static attr is changes if you change it and
"stays the same throughout

*ob1->z = 2. " error, you can not change the constants value, The field "OB1->Z" cannot be changed. -

"instance atr are specific to the object




