CREATE OR REPLACE FUNCTION UPLOAD_ERR(
   p_id_load VARCHAR,
   p_file CLOB,
   p_client VARCHAR,
   header VARCHAR,
   ext VARCHAR
) RETURN VARCHAR AS
 mongo VARCHAR(50) := '';
 fileName VARCHAR(60) := '';
BEGIN
   DELETE ITG_DOO_LOAD_ERROR WHERE ID_HEADER = header;
   COMMIT;
   IF p_id_load is null THEN
     mongo := random_uuid();
     fileName := mongo || ext;
     INSERT INTO ITG_DOO_LOAD_ERROR (ID_LOAD,FILE_NAME,CONTENT,ID_HEADER,ID_CLIENT) VALUES (mongo,fileName,p_file,header,p_client);
     COMMIT;
   END IF;
   IF p_id_load is not null THEN
     mongo := p_id_load;
     UPDATE ITG_DOO_LOAD_ERROR SET CONTENT = p_file WHERE ID_LOAD = p_id_load;
     COMMIT;
   END IF;
    RETURN mongo;
END;


CREATE OR REPLACE FUNCTION UPDATE_ORDER(
   p_id_header_erp VARCHAR,
   p_order_num VARCHAR,
   p_header_id VARCHAR,
   status VARCHAR
) RETURN VARCHAR AS
BEGIN
   UPDATE ITG_DOO_HEADER_ALL SET HEADER_ID_ERP = p_id_header_erp, ORDER_NUMBER = p_order_num, STATUS = status WHERE ID_HEADER = p_header_id;
   COMMIT;
   RETURN 'CORRECTO';
END;



CREATE OR REPLACE FUNCTION GET_ORDERS (
   p_client VARCHAR
) RETURN CLOB AS
   v_response CLOB;
   v_temp_line CLOB;
   CURSOR order_state IS SELECT * FROM ITG_DOO_HEADER_ALL WHERE STATUS = 'ON_AWAIT';
   CURSOR orders_client IS  SELECT
                              DHA.ID_HEADER,
                              DHA.ORDER_NUMBER,
                              DHA.HEADER_ID_ERP,
                              DHA.SOURCE_TRANSACTION_NUMBER,
                              DHA.SOURCE_TRANSACTION_SYSTEM,
                              DHA.BUSINESS_UNIT_NAME,
                              DHA.BUYING_PARTY_NAME,
                              DHA.BUYING_PARTY_CONTACT_NAME,
                              DHA.TRANSACTION_TYPE,
                              DHA.REQUESTED_SHIP_DATE,
                              DHA.REQUESTED_FULFILLMENT_ORGANIZATION_NAME,
                              DHA.TRANSACTIONAL_CURRENCY_NAME,
                              DHA.CUSTOMER_PO_NUMBER,
                              DHA.PAYMENT_TERMS,
                              DHA.STATUS,
                              DHA.CLIENT_ID,
                              DHA.LAST_UPDATE_DATE,
                              DLE.ID_LOAD,
                              DLE.FILE_NAME
                           FROM
                               ITG_DOO_HEADER_ALL DHA,
                               ITG_DOO_LOAD_ERROR DLE
                           WHERE
                               1 = 1
                               AND DHA.CLIENT_ID = p_client
                               AND DLE.ID_HEADER(+) = DHA.ID_HEADER
                               AND DLE.ID_CLIENT(+) = DHA.CLIENT_ID;
   CURSOR lines(header IN VARCHAR) IS SELECT * FROM ITG_DOO_LINES WHERE ID_HEADER = header;
BEGIN
    IF p_client is null THEN
       FOR orderLoop IN order_state LOOP
           v_temp_line := null;
           FOR line IN lines(orderLoop.ID_HEADER) LOOP
                v_temp_line := v_temp_line
                            || '<line><ID_LINE>'
                            || line.ID_LINE
                            || '</ID_LINE><LINE_NUMBER>'
                            || line.LINE_NUMBER
                            || '</LINE_NUMBER><ID_HEADER>'
                            || line.ID_HEADER
                            || '</ID_HEADER><HEADER_ID_ERP>'
                            || line.HEADER_ID_ERP
                            || '</HEADER_ID_ERP><LINE_ID_ERP>'
                            || line.LINE_ID_ERP
                            || '</LINE_ID_ERP><PRODUCT_NUMBER>'
                            || line.PRODUCT_NUMBER
                            || '</PRODUCT_NUMBER><UNIT_SELLING_PRICE>'
                            || line.UNIT_SELLING_PRICE
                            ||'</UNIT_SELLING_PRICE><ORDERED_QUANTITY>'
                            || line.ORDERED_QUANTITY
                            || '</ORDERED_QUANTITY><ORDERED_UOM_CODE>'
                            || line.ORDERED_UOM_CODE
                            || '</ORDERED_UOM_CODE><TRANSACTIONAL_LINE_TYPE>'
                            || line.TRANSACTIONAL_LINE_TYPE
                            || '</TRANSACTIONAL_LINE_TYPE><TRANSACTIONAL_CATEGORY_CODE>'
                            || line.TRANSACTIONAL_CATEGORY_CODE
                            || '</TRANSACTIONAL_CATEGORY_CODE></line>';
           END LOOP;
           v_response := v_response
                      || '<order><ID_HEADER>'
                      || orderLoop.ID_HEADER
                      || '</ID_HEADER><ORDER_NUMBER>'
                      || orderLoop.ORDER_NUMBER
                      || '</ORDER_NUMBER><HEADER_ID_ERP>'
                      || orderLoop.HEADER_ID_ERP
                      || '</HEADER_ID_ERP><SOURCE_TRANSACTION_NUMBER>'
                      || orderLoop.SOURCE_TRANSACTION_NUMBER
                      || '</SOURCE_TRANSACTION_NUMBER><SOURCE_TRANSACTION_SYSTEM>'
                      || orderLoop.SOURCE_TRANSACTION_SYSTEM
                      || '</SOURCE_TRANSACTION_SYSTEM><BUSINESS_UNIT_NAME>'
                      || orderLoop.BUSINESS_UNIT_NAME
                      || '</BUSINESS_UNIT_NAME><BUYING_PARTY_NAME>'
                      || orderLoop.BUYING_PARTY_NAME
                      || '</BUYING_PARTY_NAME><BUYING_PARTY_CONTACT_NAME>'
                      || orderLoop.BUYING_PARTY_CONTACT_NAME
                      || '</BUYING_PARTY_CONTACT_NAME><TRANSACTION_TYPE>'
                      || orderLoop.TRANSACTION_TYPE
                      || '</TRANSACTION_TYPE><REQUESTED_SHIP_DATE>'
                      || orderLoop.REQUESTED_SHIP_DATE
                      || '</REQUESTED_SHIP_DATE><TRANSACTIONAL_CURRENCY_NAME>'
                      || orderLoop.TRANSACTIONAL_CURRENCY_NAME
                      || '</TRANSACTIONAL_CURRENCY_NAME><CUSTOMER_PO_NUMBER>'
                      || orderLoop.CUSTOMER_PO_NUMBER
                      || '</CUSTOMER_PO_NUMBER><PAYMENT_TERMS>'
                      || orderLoop.PAYMENT_TERMS
                      || '</PAYMENT_TERMS><STATUS>'
                      || orderLoop.STATUS
                      || '</STATUS><CLIENT_ID>'
                      || orderLoop.CLIENT_ID
                      || '</CLIENT_ID><REQUESTED_FULFILLMENT_ORGANIZATION_NAME>'
                      || orderLoop.REQUESTED_FULFILLMENT_ORGANIZATION_NAME
                      ||'</REQUESTED_FULFILLMENT_ORGANIZATION_NAME><LAST_UPDATE_DATE>'
                      || orderLoop.LAST_UPDATE_DATE
                      || '</LAST_UPDATE_DATE><lines>'
                      || v_temp_line
                      || '</lines></order>';
       END LOOP;
    END IF;
    IF p_client is not null THEN
       FOR orderLoop IN orders_client LOOP
           v_temp_line := null;
           FOR line IN lines(orderLoop.ID_HEADER) LOOP
                v_temp_line := v_temp_line
                            || '<line><ID_LINE>'
                            || line.ID_LINE
                            || '</ID_LINE><LINE_NUMBER>'
                            || line.LINE_NUMBER
                            || '</LINE_NUMBER><ID_HEADER>'
                            || line.ID_HEADER
                            || '</ID_HEADER><HEADER_ID_ERP>'
                            || line.HEADER_ID_ERP
                            || '</HEADER_ID_ERP><LINE_ID_ERP>'
                            || line.LINE_ID_ERP
                            || '</LINE_ID_ERP><PRODUCT_NUMBER>'
                            || line.PRODUCT_NUMBER
                            || '</PRODUCT_NUMBER><UNIT_SELLING_PRICE>'
                            || line.UNIT_SELLING_PRICE
                            ||'</UNIT_SELLING_PRICE><ORDERED_QUANTITY>'
                            || line.ORDERED_QUANTITY
                            || '</ORDERED_QUANTITY><ORDERED_UOM_CODE>'
                            || line.ORDERED_UOM_CODE
                            || '</ORDERED_UOM_CODE><TRANSACTIONAL_LINE_TYPE>'
                            || line.TRANSACTIONAL_LINE_TYPE
                            || '</TRANSACTIONAL_LINE_TYPE><TRANSACTIONAL_CATEGORY_CODE>'
                            || line.TRANSACTIONAL_CATEGORY_CODE
                            || '</TRANSACTIONAL_CATEGORY_CODE></line>';
           END LOOP;
           v_response := v_response
                      || '<order><ID_HEADER>'
                      || orderLoop.ID_HEADER
                      || '</ID_HEADER><ORDER_NUMBER>'
                      || orderLoop.ORDER_NUMBER
                      || '</ORDER_NUMBER><HEADER_ID_ERP>'
                      || orderLoop.HEADER_ID_ERP
                      || '</HEADER_ID_ERP><SOURCE_TRANSACTION_NUMBER>'
                      || orderLoop.SOURCE_TRANSACTION_NUMBER
                      || '</SOURCE_TRANSACTION_NUMBER><SOURCE_TRANSACTION_SYSTEM>'
                      || orderLoop.SOURCE_TRANSACTION_SYSTEM
                      || '</SOURCE_TRANSACTION_SYSTEM><BUSINESS_UNIT_NAME>'
                      || orderLoop.BUSINESS_UNIT_NAME
                      || '</BUSINESS_UNIT_NAME><BUYING_PARTY_NAME>'
                      || orderLoop.BUYING_PARTY_NAME
                      || '</BUYING_PARTY_NAME><BUYING_PARTY_CONTACT_NAME>'
                      || orderLoop.BUYING_PARTY_CONTACT_NAME
                      || '</BUYING_PARTY_CONTACT_NAME><TRANSACTION_TYPE>'
                      || orderLoop.TRANSACTION_TYPE
                      || '</TRANSACTION_TYPE><REQUESTED_SHIP_DATE>'
                      || orderLoop.REQUESTED_SHIP_DATE
                      || '</REQUESTED_SHIP_DATE><TRANSACTIONAL_CURRENCY_NAME>'
                      || orderLoop.TRANSACTIONAL_CURRENCY_NAME
                      || '</TRANSACTIONAL_CURRENCY_NAME><CUSTOMER_PO_NUMBER>'
                      || orderLoop.CUSTOMER_PO_NUMBER
                      || '</CUSTOMER_PO_NUMBER><PAYMENT_TERMS>'
                      || orderLoop.PAYMENT_TERMS
                      || '</PAYMENT_TERMS><STATUS>'
                      || orderLoop.STATUS
                      || '</STATUS><REQUESTED_FULFILLMENT_ORGANIZATION_NAME>'
                      || orderLoop.REQUESTED_FULFILLMENT_ORGANIZATION_NAME
                      ||'</REQUESTED_FULFILLMENT_ORGANIZATION_NAME><CLIENT_ID>'
                      || orderLoop.CLIENT_ID
                      || '</CLIENT_ID><LAST_UPDATE_DATE>'
                      || orderLoop.LAST_UPDATE_DATE
                      || '</LAST_UPDATE_DATE><ID_LOAD>'
                      || orderLoop.ID_LOAD
                      || '</ID_LOAD><FILE_NAME>'
                      || orderLoop.FILE_NAME
                      || '</FILE_NAME><lines>'
                      || v_temp_line
                      || '</lines></order>';
       END LOOP;
    END IF;
    RETURN '<ORDERS>' || v_response || '</ORDERS>';   
END;



CREATE OR REPLACE FUNCTION GETIME RETURN NUMBER is
   v_time NUMBER;
   v_round NUMBER;
BEGIN
    SELECT (TO_DATE(to_char(systimestamp,'DD/MM/YYYY HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS')-TO_DATE('01/01/1970 00:00:00','DD/MM/YYYY HH24:MI:SS'))*60*60*24 INTO v_time FROM DUAL;
    v_round := ROUND(v_time,0);
    RETURN v_round;
END GETIME;

create or replace function getEx RETURN VARCHAR is
   v_result VARCHAR(2);
   v_dms NUMBER;
   v_math NUMBER;
BEGIN
   v_math := DBMS_RANDOM.VALUE;
   v_dms := TRUNC(v_math * 16);
   RETURN TO_CHAR(v_dms ,'x');
END getEx;

create or replace function random_uuid return VARCHAR2 is
   random_hex varchar2(32);
   v_time NUMBER;
   v_time_hex VARCHAR(10);
   v_timestamp VARCHAR2(400);
begin
  v_time := GETIME();
  v_time_hex := TO_CHAR(v_time,'xxxxxxxx');

  v_timestamp := v_time_hex;
  FOR i IN 1..16 LOOP
    v_timestamp := v_timestamp || getEx();
  END LOOP;
  return REPLACE(LOWER(v_timestamp),' ','');
end random_uuid;


CREATE OR REPLACE FUNCTION UPDATE_CLIENTS(
   orders CLOB,
   p_client VARCHAR
) RETURN VARCHAR AS
  l_xml XMLTYPE;
BEGIN
   l_xml := XMLTYPE(orders);
   UPDATE ITG_DOO_HEADER_ALL SET CLIENT_ID = p_client WHERE ID_HEADER IN (SELECT
    IDHEADER
    FROM
    XMLTable(
        '/request-wrapper/topLevelArray' PASSING l_xml columns IDHEADER VARCHAR(70) path '*'
    ) x);

    COMMIT;
    RETURN 'CORRECTO';
END;


