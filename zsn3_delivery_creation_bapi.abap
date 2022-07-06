*&---------------------------------------------------------------------*
*& Report ZSN_SALES_ORDER_BAPI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsn3_delivery_creation_bapi.
TYPE-POOLS: truxs.
 ******* Added the Error fuctionality here************
TYPES : BEGIN OF ty_delivery,
          ship_point_st(4),
          due_date_st      TYPE bapidlvcreateheader-due_date,
          ref_doc_st       TYPE vbeln_vla,
          ref_item_st      TYPE n LENGTH 6,
          del_qty_st(15),
          sales_unit_st    TYPE vbap-vrkme,
        END OF ty_delivery.
DATA this_doc TYPE vbeln_vla.
DATA: it_delivery_excel TYPE STANDARD TABLE OF ty_delivery,
      wa_delivery_excel LIKE LINE OF it_delivery_excel.

DATA : lv_count_index TYPE i. "Local variable for index of the internal table.
lv_count_index = 1.

DATA: it_raw TYPE truxs_t_text_data. "Internal table for raw data type defined from predefined structure.


"""""""""""""""""defining the variables to get the data into the BAPI FM '"""""""""""
DATA : ship_point            TYPE  bapidlvcreateheader-ship_point,
       due_date              TYPE bapidlvcreateheader-due_date,
       ref_doc               TYPE rfbel_vl,
       ref_item              TYPE rfpos_vl,
       dlv_qty               TYPE   lfimg,
       sales_unit            TYPE vrkme,
       delivery              TYPE  bapishpdelivnumb-deliv_numb,
       returns_deliv_item_st TYPE  posnr_vl,
       num_deliveries        TYPE  bapidlvcreateheader-num_deliveries,
       return                TYPE TABLE OF bapiret2. ""


DATA : wa_return LIKE LINE OF return.

DATA : it_delivery_fm TYPE TABLE OF bapidlvreftosalesorder,
       wa_delivery_fm LIKE LINE OF it_delivery_fm.

DATA : type       TYPE  bapi_mtype,
       id         TYPE symsgid,
       number     TYPE symsgno,
       message    TYPE bapi_msg,
       log_no     TYPE balognr,
       log_msg_no TYPE balmnr,
       message_v1 TYPE symsgv,
       message_v2 TYPE symsgv,
       message_v3 TYPE symsgv,
       message_v4 TYPE symsgv,
       parameter  TYPE bapi_param,
       row        TYPE bapi_line,
       field      TYPE bapi_fld,
       system     TYPE bapilogsys.

PARAMETERS: p_file TYPE  rlgrap-filename.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME' " function used for file selection
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_FILE'
    IMPORTING
      file_name     = p_file.

START-OF-SELECTION.

  IF p_file IS NOT INITIAL.
    PERFORM read_excel. "read the excel file using FM ''
    IF it_delivery_excel IS NOT INITIAL.
      SORT it_delivery_excel BY ref_doc_st.
      LOOP AT it_delivery_excel INTO wa_delivery_excel
         FROM lv_count_index.
        CLEAR this_doc.
        AT NEW ref_doc_st. ""Getting a new ref doc number from at new

          PERFORM data_bapi. ""line item data is filled up here in the internal table for FM

          PERFORM fm_delivery. "" Functional Module
        ENDAT.
        IF delivery IS NOT INITIAL.
          PERFORM commit_bapi. ""Commit BAPI from the FM
          SKIP 1.
          CLEAR it_delivery_fm[]. ""clearing the internal table for new sales order data
        ELSE.
          PERFORM error_display.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

end-of-SELECTION.


*&---------------------------------------------------------------------*
*& Form read_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_excel .

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
      i_line_header        = 'X'
      i_tab_raw_data       = it_raw       " WORK TABLE
      i_filename           = p_file
    TABLES
      i_tab_converted_data = it_delivery_excel[]  "ACTUAL DATA
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.


ENDFORM.




*&---------------------------------------------------------------------*
*& Form data_bapi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_bapi .
  this_doc = wa_delivery_excel-ref_doc_st. " assigning the value of the sales doc to the this_doc variable
  LOOP AT it_delivery_excel INTO wa_delivery_excel WHERE ref_doc_st NE 0.
    IF wa_delivery_excel-ref_doc_st = this_doc.
      ship_point = wa_delivery_excel-ship_point_st.
      due_date = wa_delivery_excel-due_date_st.
***************** convert the sales doc num to internal format **********
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_delivery_excel-ref_doc_st
        IMPORTING
          output = wa_delivery_excel-ref_doc_st.

      wa_delivery_fm-ref_doc = wa_delivery_excel-ref_doc_st.""Passing the sales doc num to the  work area of the FM""""""""""


      wa_delivery_fm-ref_item = wa_delivery_excel-ref_item_st.
      CONDENSE wa_delivery_excel-del_qty_st.

      wa_delivery_fm-dlv_qty = wa_delivery_excel-del_qty_st.

************** fn to convert the unit into the internal format*************
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = wa_delivery_excel-sales_unit_st
          language       = sy-langu
        IMPORTING
          output         = wa_delivery_excel-sales_unit_st
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      wa_delivery_fm-sales_unit = wa_delivery_excel-sales_unit_st.
      APPEND wa_delivery_fm TO it_delivery_fm.
      CLEAR wa_delivery_fm.
      lv_count_index = lv_count_index + 1.
    ENDIF.
  ENDLOOP.
ENDFORM.




*&---------------------------------------------------------------------*
*& Form commit_bapi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM commit_bapi .

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'
* IMPORTING
*     RETURN        =
    .
  WRITE : delivery.
ENDFORM.


FORM fm_delivery.
  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_SLS'
    EXPORTING
      ship_point        = ship_point
      due_date          = due_date
*     DEBUG_FLG         =
*     NO_DEQUEUE        = ' '
    IMPORTING
      delivery          = delivery
      num_deliveries    = num_deliveries
    TABLES
      sales_order_items = it_delivery_fm
      return            = return.
ENDFORM.





"
*&---------------------------------------------------------------------*
*& Form error_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM error_display .
  LOOP AT return INTO wa_return.
    WRITE : / 'Message type: S Success, E Error, W Warning, I Info, A Abort = ',  wa_return-type,
            /  'Message Class =  ',         wa_return-id,
            /  'Message Number = ',     wa_return-number,
            / ,
            /  'Message Text = ',     wa_return-message,
            / ,
            /  'Application Log: Log Number = ',     wa_return-log_no,
            /  'Application Log: Internal Message Serial Number =  ',     wa_return-log_msg_no,
            /  'Message Variable = ',     wa_return-message_v1,
            /  'Message Variable = ',     wa_return-message_v2,
            /  'Message Variable = ',     wa_return-message_v3,
            /  'Message Variable = ',     wa_return-message_v4,
            /  'Parameter Name = ',     wa_return-parameter,
            /  'Lines in parameter =',     wa_return-row,
            /  'Field in parameter = ',     wa_return-field,
            /  'Logical system from which message originates = ',     wa_return-system.
    SKIP 2.
  ENDLOOP.
ENDFORM.



"""""" Notes
"1. Use BAPI FM to get the mandatory fields."
"2. Always convert the variables into the internal format i.e. sales doc num, unit, material num etc.
"3. In order to work with the item lines, first loop the header data which is common for the item lines'
"     and then loop the line items
"4.