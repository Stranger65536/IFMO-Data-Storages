CREATE OR REPLACE TYPE ARRAY_T IS TABLE OF RAW(32);
/
CREATE OR REPLACE FUNCTION RANDOM_TIMESTAMP
  RETURN TIMESTAMP
AS
  BEGIN
    RETURN TO_TIMESTAMP(SYSDATE) + (DBMS_RANDOM.VALUE(0, 86400) / 86400);
  END;
/
CREATE OR REPLACE PROCEDURE INSERT_ITEM(
  F_ITEM_ID     RAW,
  F_VENDOR_CODE NUMBER,
  F_NAME        VARCHAR2,
  F_DESCRIPTION VARCHAR2,
  F_PRICE       NUMBER
) AS
  BEGIN
    INSERT INTO ITEMS VALUES
      (
        F_ITEM_ID,
        F_VENDOR_CODE,
        F_NAME,
        F_DESCRIPTION,
        F_PRICE
      );
  END;
/
CREATE OR REPLACE PROCEDURE UPDATE_ITEM(
  F_ITEM_ID     RAW,
  F_VENDOR_CODE NUMBER,
  F_NAME        VARCHAR2,
  F_DESCRIPTION VARCHAR2,
  F_PRICE       NUMBER
) AS
  BEGIN
    UPDATE ITEMS
    SET VENDOR_CODE = F_VENDOR_CODE,
      NAME          = F_NAME,
      DESCRIPTION   = F_DESCRIPTION,
      PRICE         = F_PRICE
    WHERE ITEM_ID = F_ITEM_ID;
  END;
/
CREATE OR REPLACE PROCEDURE DELETE_ITEM(
  ID RAW
) AS
  BEGIN
    DELETE FROM ITEMS
    WHERE ITEM_ID = ID;
  END;
/
CREATE OR REPLACE FUNCTION SELECT_RANDOM_ITEM_IDS(
  RECORDS_NUMBER NUMBER)
  RETURN ARRAY_T
AS
  RESULT ARRAY_T := ARRAY_T();
  BEGIN
    RESULT.EXTEND(RECORDS_NUMBER);

    SELECT ITEM_ID
    BULK COLLECT INTO RESULT
    FROM
      (SELECT
         ITEM_ID,
         DBMS_RANDOM.VALUE
       FROM ITEMS
       ORDER BY 2)
    WHERE ROWNUM <= RECORDS_NUMBER;

    RETURN RESULT;
  END;
/
CREATE OR REPLACE FUNCTION INSERT_RANDOM_ITEMS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  INSERTED_IDS ARRAY_T;
  INSERTED     NUMERIC;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO INSERTED
    FROM DUAL;

    INSERTED_IDS := ARRAY_T();

    FOR I IN 1..INSERTED LOOP
      INSERTED_IDS.EXTEND();
      INSERTED_IDS(I) := SYS_GUID();
      INSERT_ITEM(
          INSERTED_IDS(I),
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000000000000)),
          'NAME_' || DBMS_RANDOM.STRING('A', 30),
          'DESC_' || DBMS_RANDOM.STRING('A', 30),
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000))
      );
    END LOOP;

    RETURN INSERTED_IDS;
  END;
/
CREATE OR REPLACE FUNCTION UPDATE_RANDOM_ITEMS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  UPDATED_IDS ARRAY_T;
  UPDATED     NUMERIC;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO UPDATED
    FROM DUAL;

    UPDATED_IDS := SELECT_RANDOM_ITEM_IDS(UPDATED);

    FOR I IN 1..UPDATED_IDS.COUNT LOOP
      UPDATE_ITEM(
          UPDATED_IDS(I),
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000000000000)),
          'NAME_' || DBMS_RANDOM.STRING('A', 30),
          'DESC_' || DBMS_RANDOM.STRING('A', 30),
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000))
      );
    END LOOP;

    RETURN UPDATED_IDS;
  END;
/
CREATE OR REPLACE FUNCTION DELETE_RANDOM_ITEMS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  DELETED_IDS ARRAY_T;
  DELETED     NUMERIC;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO DELETED
    FROM DUAL;

    DELETED_IDS := SELECT_RANDOM_ITEM_IDS(DELETED);

    FOR I IN 1..DELETED_IDS.COUNT LOOP
      DELETE_ITEM(DELETED_IDS(I));
    END LOOP;

    RETURN DELETED_IDS;
  END;
/
CREATE OR REPLACE PROCEDURE INSERT_CUSTOMER(
  F_CUSTOMER_ID  RAW,
  F_FIRST_NAME   VARCHAR2,
  F_LAST_NAME    VARCHAR2,
  F_MIDDLE_NAME  VARCHAR2,
  F_EMAIL        VARCHAR2,
  F_PHONE_NUMBER VARCHAR2
) AS
  BEGIN
    INSERT INTO CUSTOMERS VALUES
      (
        F_CUSTOMER_ID,
        F_FIRST_NAME,
        F_LAST_NAME,
        F_MIDDLE_NAME,
        F_EMAIL,
        F_PHONE_NUMBER
      );
  END;
/
CREATE OR REPLACE PROCEDURE UPDATE_CUSTOMER(
  F_CUSTOMER_ID  RAW,
  F_FIRST_NAME   VARCHAR2,
  F_LAST_NAME    VARCHAR2,
  F_MIDDLE_NAME  VARCHAR2,
  F_EMAIL        VARCHAR2,
  F_PHONE_NUMBER VARCHAR2
) AS
  BEGIN
    UPDATE CUSTOMERS
    SET FIRST_NAME = F_FIRST_NAME,
      LAST_NAME    = F_LAST_NAME,
      MIDDLE_NAME  = F_MIDDLE_NAME,
      EMAIL        = F_EMAIL,
      PHONE_NUMBER = F_PHONE_NUMBER
    WHERE CUSTOMER_ID = F_CUSTOMER_ID;
  END;
/
CREATE OR REPLACE PROCEDURE DELETE_CUSTOMER(
  ID RAW
) AS
  BEGIN
    DELETE FROM CUSTOMERS
    WHERE CUSTOMER_ID = ID;
  END;
/
CREATE OR REPLACE FUNCTION SELECT_RANDOM_CUSTOMER_IDS(
  RECORDS_NUMBER NUMBER)
  RETURN ARRAY_T
AS
  RESULT ARRAY_T := ARRAY_T();
  BEGIN
    RESULT.EXTEND(RECORDS_NUMBER);

    SELECT CUSTOMER_ID
    BULK COLLECT INTO RESULT
    FROM
      (SELECT
         CUSTOMER_ID,
         DBMS_RANDOM.VALUE
       FROM CUSTOMERS
       ORDER BY 2)
    WHERE ROWNUM <= RECORDS_NUMBER;

    RETURN RESULT;
  END;
/
CREATE OR REPLACE FUNCTION INSERT_RANDOM_CUSTOMERS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  INSERTED_IDS ARRAY_T;
  INSERTED     NUMERIC;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO INSERTED
    FROM DUAL;

    INSERTED_IDS := ARRAY_T();

    FOR I IN 1..INSERTED LOOP
      INSERTED_IDS.EXTEND();
      INSERTED_IDS(I) := SYS_GUID();
      INSERT_CUSTOMER
      (
          INSERTED_IDS(I),
          'FIRST_NAME_' || DBMS_RANDOM.STRING('A', 15),
          'LAST_NAME_' || DBMS_RANDOM.STRING('A', 15),
          'MIDDLE_NAME_' || DBMS_RANDOM.STRING('A', 15),
          'EMAIL_' || DBMS_RANDOM.STRING('A', 35),
          'PHONE_' || DBMS_RANDOM.STRING('A', 9)
      );
    END LOOP;

    RETURN INSERTED_IDS;
  END;
/
CREATE OR REPLACE FUNCTION UPDATE_RANDOM_CUSTOMERS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  UPDATED_IDS ARRAY_T;
  UPDATED     NUMERIC;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO UPDATED
    FROM DUAL;

    UPDATED_IDS := SELECT_RANDOM_CUSTOMER_IDS(UPDATED);

    FOR I IN 1..UPDATED_IDS.COUNT LOOP
      UPDATE_CUSTOMER(
          UPDATED_IDS(I),
          'FIRST_NAME_' || DBMS_RANDOM.STRING('A', 15),
          'LAST_NAME_' || DBMS_RANDOM.STRING('A', 15),
          'MIDDLE_NAME_' || DBMS_RANDOM.STRING('A', 15),
          'EMAIL_' || DBMS_RANDOM.STRING('A', 35),
          'PHONE_' || DBMS_RANDOM.STRING('A', 9)
      );
    END LOOP;

    RETURN UPDATED_IDS;
  END;
/
CREATE OR REPLACE FUNCTION DELETE_RANDOM_CUSTOMERS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  DELETED_IDS ARRAY_T;
  DELETED     NUMERIC;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO DELETED
    FROM DUAL;

    DELETED_IDS := SELECT_RANDOM_CUSTOMER_IDS(DELETED);

    FOR I IN 1..DELETED_IDS.COUNT LOOP
      DELETE_CUSTOMER(DELETED_IDS(I));
    END LOOP;

    RETURN DELETED_IDS;
  END;
/
CREATE OR REPLACE PROCEDURE INSERT_PROCUREMENT(
  F_PROCUREMENT_ID RAW,
  F_ITEM_ID        RAW,
  F_PRICE          NUMBER,
  F_AMOUNT         NUMBER,
  F_TIME           TIMESTAMP
) AS
  BEGIN
    INSERT INTO PROCUREMENTS VALUES
      (
        F_PROCUREMENT_ID,
        F_ITEM_ID,
        F_PRICE,
        F_AMOUNT,
        F_TIME
      );
  END;
/
CREATE OR REPLACE PROCEDURE UPDATE_PROCUREMENT(
  F_PROCUREMENT_ID RAW,
  F_PRICE          NUMBER,
  F_AMOUNT         NUMBER,
  F_TIME           TIMESTAMP
) AS
  BEGIN
    UPDATE PROCUREMENTS
    SET PRICE = F_PRICE,
      AMOUNT  = F_AMOUNT,
      TIME    = F_TIME
    WHERE PROCUREMENT_ID = F_PROCUREMENT_ID;
  END;
/
CREATE OR REPLACE PROCEDURE DELETE_PROCUREMENT(
  ID RAW
) AS
  BEGIN
    DELETE FROM PROCUREMENTS
    WHERE PROCUREMENT_ID = ID;
  END;
/
CREATE OR REPLACE FUNCTION SELECT_RANDOM_PROCUREMENT_IDS(
  RECORDS_NUMBER NUMBER)
  RETURN ARRAY_T
AS
  RESULT ARRAY_T := ARRAY_T();
  BEGIN
    RESULT.EXTEND(RECORDS_NUMBER);

    SELECT PROCUREMENT_ID
    BULK COLLECT INTO RESULT
    FROM
      (SELECT
         PROCUREMENT_ID,
         DBMS_RANDOM.VALUE
       FROM PROCUREMENTS
       ORDER BY 2)
    WHERE ROWNUM <= RECORDS_NUMBER;

    RETURN RESULT;
  END;
/
CREATE OR REPLACE FUNCTION INSERT_RANDOM_PROCUREMENTS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER,
  ITEMS_IDS            IN ARRAY_T)
  RETURN ARRAY_T
AS
  INSERTED_IDS ARRAY_T;
  F_ITEM_ID    RAW(32);
  INSERTED     NUMERIC;
  TIME_TEMP    TIMESTAMP;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO INSERTED
    FROM DUAL;

    INSERTED_IDS := ARRAY_T();

    FOR I IN 1..INSERTED LOOP
      INSERTED_IDS.EXTEND();
      INSERTED_IDS(I) := SYS_GUID();
      F_ITEM_ID := ITEMS_IDS(TRUNC(DBMS_RANDOM.VALUE(1, ITEMS_IDS.COUNT)));
      TIME_TEMP := RANDOM_TIMESTAMP();
      INSERT_PROCUREMENT(
          INSERTED_IDS(I),
          F_ITEM_ID,
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000)),
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000)),
          TIME_TEMP
      );
    END LOOP;

    RETURN INSERTED_IDS;
  END;
/
CREATE OR REPLACE FUNCTION UPDATE_RANDOM_PROCUREMENTS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  UPDATED_IDS ARRAY_T;
  UPDATED     NUMERIC;
  TIME_TEMP   TIMESTAMP;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO UPDATED
    FROM DUAL;

    UPDATED_IDS := SELECT_RANDOM_PROCUREMENT_IDS(UPDATED);

    FOR I IN 1..UPDATED_IDS.COUNT LOOP
      TIME_TEMP := RANDOM_TIMESTAMP();
      UPDATE_PROCUREMENT(
          UPDATED_IDS(I),
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000)),
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000)),
          TIME_TEMP
      );
    END LOOP;

    RETURN UPDATED_IDS;
  END;
/
CREATE OR REPLACE FUNCTION DELETE_RANDOM_PROCUREMENTS(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  DELETED_IDS ARRAY_T;
  DELETED     NUMERIC;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO DELETED
    FROM DUAL;

    DELETED_IDS := SELECT_RANDOM_PROCUREMENT_IDS(DELETED);

    FOR I IN 1..DELETED_IDS.COUNT LOOP
      DELETE_PROCUREMENT(DELETED_IDS(I));
    END LOOP;

    RETURN DELETED_IDS;
  END;
/
CREATE OR REPLACE PROCEDURE INSERT_SALE(
  F_SALE_ID     RAW,
  F_ITEM_ID     RAW,
  F_CUSTOMER_ID RAW,
  F_AMOUNT      NUMBER,
  F_TIME        TIMESTAMP,
  F_TOTAL_PRICE NUMBER
) AS
  BEGIN
    INSERT INTO SALES VALUES
      (
        F_SALE_ID,
        F_ITEM_ID,
        F_CUSTOMER_ID,
        F_AMOUNT,
        F_TIME,
        F_TOTAL_PRICE
      );
  END;
/
CREATE OR REPLACE PROCEDURE UPDATE_SALE(
  F_SALE_ID     RAW,
  F_AMOUNT      NUMBER,
  F_TIME        TIMESTAMP,
  F_TOTAL_PRICE NUMBER
) AS
  BEGIN
    UPDATE SALES
    SET AMOUNT    = F_AMOUNT,
      TIME        = F_TIME,
      TOTAL_PRICE = F_TOTAL_PRICE
    WHERE SALE_ID = F_SALE_ID;
  END;
/
CREATE OR REPLACE PROCEDURE DELETE_SALE(
  ID RAW
) AS
  BEGIN
    DELETE FROM SALES
    WHERE SALE_ID = ID;
  END;
/
CREATE OR REPLACE FUNCTION SELECT_RANDOM_SALE_IDS(
  RECORDS_NUMBER NUMBER)
  RETURN ARRAY_T
AS
  RESULT ARRAY_T := ARRAY_T();
  BEGIN
    RESULT.EXTEND(RECORDS_NUMBER);

    SELECT SALE_ID
    BULK COLLECT INTO RESULT
    FROM
      (SELECT
         SALE_ID,
         DBMS_RANDOM.VALUE
       FROM SALES
       ORDER BY 2)
    WHERE ROWNUM <= RECORDS_NUMBER;

    RETURN RESULT;
  END;
/
CREATE OR REPLACE FUNCTION INSERT_RANDOM_SALES(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER,
  ITEMS_IDS            IN ARRAY_T,
  CUSTOMERS_IDS        IN ARRAY_T)
  RETURN ARRAY_T
AS
  INSERTED_IDS  ARRAY_T;
  F_ITEM_ID     RAW(32);
  F_CUSTOMER_ID RAW(32);
  INSERTED      NUMERIC;
  TIME_TEMP     TIMESTAMP;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO INSERTED
    FROM DUAL;

    INSERTED_IDS := ARRAY_T();

    FOR I IN 1..INSERTED LOOP
      INSERTED_IDS.EXTEND();
      INSERTED_IDS(I) := SYS_GUID();
      F_ITEM_ID := ITEMS_IDS(TRUNC(DBMS_RANDOM.VALUE(1, ITEMS_IDS.COUNT)));
      F_CUSTOMER_ID := CUSTOMERS_IDS(TRUNC(DBMS_RANDOM.VALUE(1, CUSTOMERS_IDS.COUNT)));
      TIME_TEMP := RANDOM_TIMESTAMP();
      INSERT_SALE(
          INSERTED_IDS(I),
          F_ITEM_ID,
          F_CUSTOMER_ID,
          TRUNC(DBMS_RANDOM.VALUE(1, 1000)),
          TIME_TEMP,
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000))
      );
    END LOOP;

    RETURN INSERTED_IDS;
  END;
/
CREATE OR REPLACE FUNCTION UPDATE_RANDOM_SALES(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  UPDATED_IDS ARRAY_T;
  UPDATED     NUMERIC;
  TIME_TEMP   TIMESTAMP;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO UPDATED
    FROM DUAL;

    UPDATED_IDS := SELECT_RANDOM_SALE_IDS(UPDATED);

    FOR I IN 1..UPDATED_IDS.COUNT LOOP
      TIME_TEMP := RANDOM_TIMESTAMP();
      UPDATE_SALE(
          UPDATED_IDS(I),
          TRUNC(DBMS_RANDOM.VALUE(1, 1000)),
          TIME_TEMP,
          TRUNC(DBMS_RANDOM.VALUE(1, 1000000))
      );
    END LOOP;

    RETURN UPDATED_IDS;
  END;
/
CREATE OR REPLACE FUNCTION DELETE_RANDOM_SALES(
  RECORDS_NUMBER_FLOOR IN NUMBER,
  RECORDS_NUMBER_CEIL  IN NUMBER)
  RETURN ARRAY_T
AS
  DELETED_IDS ARRAY_T;
  DELETED     NUMERIC;
  BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL))
    INTO DELETED
    FROM DUAL;

    DELETED_IDS := SELECT_RANDOM_SALE_IDS(DELETED);

    FOR I IN 1..DELETED_IDS.COUNT LOOP
      DELETE_SALE(DELETED_IDS(I));
    END LOOP;

    RETURN DELETED_IDS;
  END;
/
CREATE OR REPLACE PROCEDURE INSERT_RANDOM_DATA(
  RECORDS_NUMBER_FLOOR IN  NUMBER,
  RECORDS_NUMBER_CEIL  IN  NUMBER,
  ITEM_IDS             OUT ARRAY_T,
  CUSTOMER_IDS         OUT ARRAY_T,
  PROCUREMENT_IDS      OUT ARRAY_T,
  SALES_IDS            OUT ARRAY_T)
AS
  BEGIN
    ITEM_IDS := INSERT_RANDOM_ITEMS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
    CUSTOMER_IDS := INSERT_RANDOM_CUSTOMERS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
    PROCUREMENT_IDS := INSERT_RANDOM_PROCUREMENTS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL, ITEM_IDS);
    SALES_IDS := INSERT_RANDOM_SALES(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL, ITEM_IDS, CUSTOMER_IDS);
  END;
/
CREATE OR REPLACE PROCEDURE UPDATE_RANDOM_DATA(
  RECORDS_NUMBER_FLOOR IN  NUMBER,
  RECORDS_NUMBER_CEIL  IN  NUMBER,
  ITEM_IDS             OUT ARRAY_T,
  CUSTOMER_IDS         OUT ARRAY_T,
  PROCUREMENT_IDS      OUT ARRAY_T,
  SALES_IDS            OUT ARRAY_T)
AS
  BEGIN
    ITEM_IDS := UPDATE_RANDOM_ITEMS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
    CUSTOMER_IDS := UPDATE_RANDOM_CUSTOMERS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
    PROCUREMENT_IDS := UPDATE_RANDOM_PROCUREMENTS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
    SALES_IDS := UPDATE_RANDOM_SALES(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
  END;
/
CREATE OR REPLACE PROCEDURE DELETE_RANDOM_DATA(
  RECORDS_NUMBER_FLOOR IN  NUMBER,
  RECORDS_NUMBER_CEIL  IN  NUMBER,
  ITEM_IDS             OUT ARRAY_T,
  CUSTOMER_IDS         OUT ARRAY_T,
  PROCUREMENT_IDS      OUT ARRAY_T,
  SALES_IDS            OUT ARRAY_T)
AS
  BEGIN
    ITEM_IDS := DELETE_RANDOM_ITEMS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
    CUSTOMER_IDS := DELETE_RANDOM_CUSTOMERS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
    PROCUREMENT_IDS := DELETE_RANDOM_PROCUREMENTS(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
    SALES_IDS := DELETE_RANDOM_SALES(RECORDS_NUMBER_FLOOR, RECORDS_NUMBER_CEIL);
  END;
/