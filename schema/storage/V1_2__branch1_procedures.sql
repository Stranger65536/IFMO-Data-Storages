CREATE OR REPLACE PROCEDURE BACKUP_BRANCH1_CUSTOMERS
AS
  F_CHANGED_AT        TIMESTAMP := SYSDATE;
  CURSOR CUSTOMERS_CUR
  IS
    SELECT
      CUSTOMER_ID,
      FIRST_NAME,
      LAST_NAME,
      MIDDLE_NAME,
      EMAIL,
      PHONE_NUMBER
    FROM CUSTOMERS@BRANCH_1
    ORDER BY CUSTOMER_ID ASC;

  CURSOR CUSTOMERS_STORE_CUR
  IS
    SELECT
      CUSTOMER_ID,
      FIRST_NAME,
      LAST_NAME,
      MIDDLE_NAME,
      EMAIL,
      PHONE_NUMBER,
      STATUS
    FROM CUSTOMERS_STORE CS1
      INNER JOIN (
                   SELECT
                     CUSTOMER_ID     C_ID,
                     MAX(CHANGED_AT) CHANGED_AT
                   FROM CUSTOMERS_STORE
                   GROUP BY CUSTOMER_ID
                 ) CS2
        ON CS1.CUSTOMER_ID = CS2.C_ID
           AND CS1.CHANGED_AT = CS2.CHANGED_AT
    ORDER BY CUSTOMER_ID ASC;

  CUSTOMER_REC        CUSTOMERS_CUR%ROWTYPE;
  CUSTOMERS_STORE_REC CUSTOMERS_STORE_CUR%ROWTYPE;

  FUNCTION IS_DELETED_CUSTOMER(
    RECORD_C CUSTOMERS_STORE_CUR%ROWTYPE)
    RETURN NUMBER
  AS
    REC_EXISTS NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO REC_EXISTS
      FROM CUSTOMERS_STORE CS1
        INNER JOIN (
                     SELECT
                       CUSTOMER_ID     C_ID,
                       MAX(CHANGED_AT) CHANGED_AT
                     FROM CUSTOMERS_STORE
                     WHERE CUSTOMER_ID = RECORD_C.CUSTOMER_ID
                     GROUP BY CUSTOMER_ID
                   ) CS2
          ON CS1.CUSTOMER_ID = CS2.C_ID
             AND CS1.CHANGED_AT = CS2.CHANGED_AT
      WHERE CS1.STATUS = 'D'
            AND ROWNUM = 1;
      IF (REC_EXISTS = 1)
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('ALREADY DELETED');
          RETURN 1;
        END;
      ELSE
        BEGIN
          DBMS_OUTPUT.PUT_LINE('NOT DELETED');
          RETURN 0;
        END;
      END IF;
    END;

  FUNCTION IS_EQUAL_CUSTOMERS(
    RECORD_C CUSTOMERS_CUR%ROWTYPE,
    RECORD_S CUSTOMERS_STORE_CUR%ROWTYPE
  )
    RETURN NUMBER
  AS
    BEGIN
      IF RECORD_C.CUSTOMER_ID = RECORD_S.CUSTOMER_ID
         AND RECORD_C.FIRST_NAME = RECORD_S.FIRST_NAME
         AND RECORD_C.LAST_NAME = RECORD_S.LAST_NAME
         AND RECORD_C.MIDDLE_NAME = RECORD_S.MIDDLE_NAME
         AND RECORD_C.EMAIL = RECORD_S.EMAIL
         AND RECORD_C.PHONE_NUMBER = RECORD_S.PHONE_NUMBER
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('EQUAL');
          RETURN 1;
        END;
      ELSE
        BEGIN
          DBMS_OUTPUT.PUT_LINE('NOT EQUAL');
          RETURN 0;
        END;
      END IF;
    END;

  PROCEDURE INSERT_CUSTOMER(
    RECORD       CUSTOMERS_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO CUSTOMERS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.CUSTOMER_ID,
          'I',
          RECORD.FIRST_NAME,
          RECORD.LAST_NAME,
          RECORD.MIDDLE_NAME,
          RECORD.EMAIL,
          RECORD.PHONE_NUMBER
        );
    END;

  PROCEDURE UPDATE_CUSTOMER(
    RECORD       CUSTOMERS_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO CUSTOMERS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.CUSTOMER_ID,
          'U',
          RECORD.FIRST_NAME,
          RECORD.LAST_NAME,
          RECORD.MIDDLE_NAME,
          RECORD.EMAIL,
          RECORD.PHONE_NUMBER
        );
    END;

  PROCEDURE DELETE_CUSTOMER(
    RECORD       CUSTOMERS_STORE_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO CUSTOMERS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.CUSTOMER_ID,
          'D',
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
        );
    END;
  BEGIN
    OPEN CUSTOMERS_CUR;
    OPEN CUSTOMERS_STORE_CUR;

    FETCH CUSTOMERS_CUR INTO CUSTOMER_REC;
    FETCH CUSTOMERS_STORE_CUR INTO CUSTOMERS_STORE_REC;

    LOOP
      EXIT WHEN CUSTOMERS_CUR%NOTFOUND AND CUSTOMERS_STORE_CUR%NOTFOUND;

      IF (CUSTOMERS_CUR%NOTFOUND)
      THEN
        CUSTOMER_REC.CUSTOMER_ID := NULL;
      END IF;

      IF (CUSTOMERS_STORE_CUR%NOTFOUND)
      THEN
        CUSTOMERS_STORE_REC.CUSTOMER_ID := NULL;
      END IF;

      DBMS_OUTPUT.PUT_LINE('BRANCH:  ' || RAWTOHEX(CUSTOMER_REC.CUSTOMER_ID));
      DBMS_OUTPUT.PUT_LINE('STORAGE: ' || RAWTOHEX(CUSTOMERS_STORE_REC.CUSTOMER_ID));

      IF (CUSTOMERS_STORE_REC.CUSTOMER_ID IS NULL
          OR CUSTOMER_REC.CUSTOMER_ID IS NOT NULL
             AND CUSTOMERS_STORE_REC.CUSTOMER_ID IS NOT NULL
             AND RAWTOHEX(CUSTOMER_REC.CUSTOMER_ID) < RAWTOHEX(CUSTOMERS_STORE_REC.CUSTOMER_ID))
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('INSERT ' || CUSTOMER_REC.CUSTOMER_ID);
          INSERT_CUSTOMER(CUSTOMER_REC, F_CHANGED_AT);
          FETCH CUSTOMERS_CUR INTO CUSTOMER_REC;
        END;
      ELSIF (CUSTOMER_REC.CUSTOMER_ID IS NULL
             OR CUSTOMER_REC.CUSTOMER_ID IS NOT NULL
                AND CUSTOMERS_STORE_REC.CUSTOMER_ID IS NOT NULL
                AND RAWTOHEX(CUSTOMER_REC.CUSTOMER_ID) > RAWTOHEX(CUSTOMERS_STORE_REC.CUSTOMER_ID))
        THEN
          BEGIN
            IF (IS_DELETED_CUSTOMER(CUSTOMERS_STORE_REC) = 0)
            THEN
              BEGIN
                DBMS_OUTPUT.PUT_LINE('DELETE ' || CUSTOMERS_STORE_REC.CUSTOMER_ID);
                DELETE_CUSTOMER(CUSTOMERS_STORE_REC, F_CHANGED_AT);
              END;
            END IF;
            FETCH CUSTOMERS_STORE_CUR INTO CUSTOMERS_STORE_REC;
          END;
      ELSIF (RAWTOHEX(CUSTOMER_REC.CUSTOMER_ID) = RAWTOHEX(CUSTOMERS_STORE_REC.CUSTOMER_ID))
        THEN
          BEGIN
            IF IS_EQUAL_CUSTOMERS(CUSTOMER_REC, CUSTOMERS_STORE_REC) = 0
            THEN
              DBMS_OUTPUT.PUT_LINE('UPDATE ' || CUSTOMER_REC.CUSTOMER_ID);
              UPDATE_CUSTOMER(CUSTOMER_REC, F_CHANGED_AT);
            END IF;
            FETCH CUSTOMERS_CUR INTO CUSTOMER_REC;
            FETCH CUSTOMERS_STORE_CUR INTO CUSTOMERS_STORE_REC;
          END;
      END IF;
    END LOOP;

    CLOSE CUSTOMERS_CUR;
    CLOSE CUSTOMERS_STORE_CUR;

    INSERT INTO CUSTOMERS_STORE SELECT *
                                FROM CUSTOMERS_STORE_TEMP;
    DELETE FROM CUSTOMERS_STORE_TEMP;
  END;
/
CREATE OR REPLACE PROCEDURE RESTORE_BRANCH1_CUSTOMERS(
  F_CHANGED_AT TIMESTAMP)
AS
  BEGIN
    EXECUTE IMMEDIATE ('DELETE FROM CUSTOMERS@BRANCH_1');
    EXECUTE IMMEDIATE ('
        INSERT INTO CUSTOMERS@BRANCH_1
        SELECT
          CUSTOMER_ID,
          FIRST_NAME,
          LAST_NAME,
          MIDDLE_NAME,
          EMAIL,
          PHONE_NUMBER
        FROM CUSTOMERS_STORE CS1
          INNER JOIN (
                       SELECT
                         CUSTOMER_ID     C_ID,
                         MAX(CHANGED_AT) CHANGED_AT
                       FROM CUSTOMERS_STORE
                       WHERE CHANGED_AT <= TO_TIMESTAMP(''' || TO_CHAR(F_CHANGED_AT, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')
                       GROUP BY CUSTOMER_ID
                     ) CS2
            ON CS1.CUSTOMER_ID = CS2.C_ID
               AND CS1.CHANGED_AT = CS2.CHANGED_AT
        WHERE STATUS <> ''D''
      ');
  END;
/
CREATE OR REPLACE PROCEDURE BACKUP_BRANCH1_ITEMS
AS
  F_CHANGED_AT    TIMESTAMP := SYSDATE;
  CURSOR ITEMS_CUR
  IS
    SELECT
      ITEM_ID,
      VENDOR_CODE,
      NAME,
      DESCRIPTION,
      PRICE
    FROM ITEMS@BRANCH_1
    ORDER BY ITEM_ID ASC;

  CURSOR ITEMS_STORE_CUR
  IS
    SELECT
      ITEM_ID,
      VENDOR_CODE,
      NAME,
      DESCRIPTION,
      PRICE,
      STATUS
    FROM ITEMS_STORE CS1
      INNER JOIN (
                   SELECT
                     ITEM_ID         C_ID,
                     MAX(CHANGED_AT) CHANGED_AT
                   FROM ITEMS_STORE
                   GROUP BY ITEM_ID
                 ) CS2
        ON CS1.ITEM_ID = CS2.C_ID
           AND CS1.CHANGED_AT = CS2.CHANGED_AT
    ORDER BY ITEM_ID ASC;

  ITEM_REC        ITEMS_CUR%ROWTYPE;
  ITEMS_STORE_REC ITEMS_STORE_CUR%ROWTYPE;

  FUNCTION IS_DELETED_ITEM(
    RECORD_C ITEMS_STORE_CUR%ROWTYPE)
    RETURN NUMBER
  AS
    REC_EXISTS NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO REC_EXISTS
      FROM ITEMS_STORE CS1
        INNER JOIN (
                     SELECT
                       ITEM_ID         C_ID,
                       MAX(CHANGED_AT) CHANGED_AT
                     FROM ITEMS_STORE
                     WHERE ITEM_ID = RECORD_C.ITEM_ID
                     GROUP BY ITEM_ID
                   ) CS2
          ON CS1.ITEM_ID = CS2.C_ID
             AND CS1.CHANGED_AT = CS2.CHANGED_AT
      WHERE CS1.STATUS = 'D'
            AND ROWNUM = 1;
      IF (REC_EXISTS = 1)
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('ALREADY DELETED');
          RETURN 1;
        END;
      ELSE
        BEGIN
          DBMS_OUTPUT.PUT_LINE('NOT DELETED');
          RETURN 0;
        END;
      END IF;
    END;

  FUNCTION IS_EQUAL_ITEMS(
    RECORD_C ITEMS_CUR%ROWTYPE,
    RECORD_S ITEMS_STORE_CUR%ROWTYPE
  )
    RETURN NUMBER
  AS
    BEGIN
      IF RECORD_C.ITEM_ID = RECORD_S.ITEM_ID
         AND RECORD_C.VENDOR_CODE = RECORD_S.VENDOR_CODE
         AND RECORD_C.NAME = RECORD_S.NAME
         AND RECORD_C.DESCRIPTION = RECORD_S.DESCRIPTION
         AND RECORD_C.PRICE = RECORD_S.PRICE
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('EQUAL');
          RETURN 1;
        END;
      ELSE
        BEGIN
          DBMS_OUTPUT.PUT_LINE('NOT EQUAL');
          RETURN 0;
        END;
      END IF;
    END;

  PROCEDURE INSERT_ITEM(
    RECORD       ITEMS_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO ITEMS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.ITEM_ID,
          1,
          'I',
          RECORD.VENDOR_CODE,
          RECORD.NAME,
          RECORD.DESCRIPTION,
          RECORD.PRICE
        );
    END;

  PROCEDURE UPDATE_ITEM(
    RECORD       ITEMS_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO ITEMS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.ITEM_ID,
          1,
          'U',
          RECORD.VENDOR_CODE,
          RECORD.NAME,
          RECORD.DESCRIPTION,
          RECORD.PRICE
        );
    END;

  PROCEDURE DELETE_ITEM(
    RECORD       ITEMS_STORE_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO ITEMS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.ITEM_ID,
          1,
          'D',
          NULL,
          NULL,
          NULL,
          NULL
        );
    END;
  BEGIN
    OPEN ITEMS_CUR;
    OPEN ITEMS_STORE_CUR;

    FETCH ITEMS_CUR INTO ITEM_REC;
    FETCH ITEMS_STORE_CUR INTO ITEMS_STORE_REC;

    LOOP
      EXIT WHEN ITEMS_CUR%NOTFOUND AND ITEMS_STORE_CUR%NOTFOUND;

      IF (ITEMS_CUR%NOTFOUND)
      THEN
        ITEM_REC.ITEM_ID := NULL;
      END IF;

      IF (ITEMS_STORE_CUR%NOTFOUND)
      THEN
        ITEMS_STORE_REC.ITEM_ID := NULL;
      END IF;

      DBMS_OUTPUT.PUT_LINE('BRANCH:  ' || RAWTOHEX(ITEM_REC.ITEM_ID));
      DBMS_OUTPUT.PUT_LINE('STORAGE: ' || RAWTOHEX(ITEMS_STORE_REC.ITEM_ID));

      IF (ITEMS_STORE_REC.ITEM_ID IS NULL
          OR ITEM_REC.ITEM_ID IS NOT NULL
             AND ITEMS_STORE_REC.ITEM_ID IS NOT NULL
             AND RAWTOHEX(ITEM_REC.ITEM_ID) < RAWTOHEX(ITEMS_STORE_REC.ITEM_ID))
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('INSERT ' || ITEM_REC.ITEM_ID);
          INSERT_ITEM(ITEM_REC, F_CHANGED_AT);
          FETCH ITEMS_CUR INTO ITEM_REC;
        END;
      ELSIF (ITEM_REC.ITEM_ID IS NULL
             OR ITEM_REC.ITEM_ID IS NOT NULL
                AND ITEMS_STORE_REC.ITEM_ID IS NOT NULL
                AND RAWTOHEX(ITEM_REC.ITEM_ID) > RAWTOHEX(ITEMS_STORE_REC.ITEM_ID))
        THEN
          BEGIN
            IF (IS_DELETED_ITEM(ITEMS_STORE_REC) = 0)
            THEN
              BEGIN
                DBMS_OUTPUT.PUT_LINE('DELETE ' || ITEMS_STORE_REC.ITEM_ID);
                DELETE_ITEM(ITEMS_STORE_REC, F_CHANGED_AT);
              END;
            END IF;
            FETCH ITEMS_STORE_CUR INTO ITEMS_STORE_REC;
          END;
      ELSIF (RAWTOHEX(ITEM_REC.ITEM_ID) = RAWTOHEX(ITEMS_STORE_REC.ITEM_ID))
        THEN
          BEGIN
            IF IS_EQUAL_ITEMS(ITEM_REC, ITEMS_STORE_REC) = 0
            THEN
              DBMS_OUTPUT.PUT_LINE('UPDATE ' || ITEM_REC.ITEM_ID);
              UPDATE_ITEM(ITEM_REC, F_CHANGED_AT);
            END IF;
            FETCH ITEMS_CUR INTO ITEM_REC;
            FETCH ITEMS_STORE_CUR INTO ITEMS_STORE_REC;
          END;
      END IF;
    END LOOP;

    CLOSE ITEMS_CUR;
    CLOSE ITEMS_STORE_CUR;

    INSERT INTO ITEMS_STORE SELECT *
                            FROM ITEMS_STORE_TEMP;
    DELETE FROM ITEMS_STORE_TEMP;
  END;
/
CREATE OR REPLACE PROCEDURE RESTORE_BRANCH1_ITEMS(
  F_CHANGED_AT TIMESTAMP)
AS
  BEGIN
    EXECUTE IMMEDIATE ('DELETE FROM ITEMS@BRANCH_1');
    EXECUTE IMMEDIATE ('
        INSERT INTO ITEMS@BRANCH_1
        SELECT
          ITEM_ID,
          VENDOR_CODE,
          NAME,
          DESCRIPTION,
          PRICE
        FROM ITEMS_STORE CS1
          INNER JOIN (
                       SELECT
                         ITEM_ID     C_ID,
                         MAX(CHANGED_AT) CHANGED_AT
                       FROM ITEMS_STORE
                       WHERE CHANGED_AT <= TO_TIMESTAMP(''' || TO_CHAR(F_CHANGED_AT, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')
                         AND STORE_NUMBER = 1
                       GROUP BY ITEM_ID
                     ) CS2
            ON CS1.ITEM_ID = CS2.C_ID
               AND CS1.CHANGED_AT = CS2.CHANGED_AT
        WHERE STATUS <> ''D''
      ');
  END;
/
CREATE OR REPLACE PROCEDURE BACKUP_BRANCH1_PROCUREMENTS
AS
  F_CHANGED_AT           TIMESTAMP := SYSDATE;
  CURSOR PROCUREMENTS_CUR
  IS
    SELECT
      PROCUREMENT_ID,
      ITEM_ID,
      PRICE,
      AMOUNT,
      TIME
    FROM PROCUREMENTS@BRANCH_1
    ORDER BY PROCUREMENT_ID ASC;

  CURSOR PROCUREMENTS_STORE_CUR
  IS
    SELECT
      PROCUREMENT_ID,
      ITEM_ID,
      PRICE,
      AMOUNT,
      TIME,
      STATUS
    FROM PROCUREMENTS_STORE CS1
      INNER JOIN (
                   SELECT
                     PROCUREMENT_ID  C_ID,
                     MAX(CHANGED_AT) CHANGED_AT
                   FROM PROCUREMENTS_STORE
                   GROUP BY PROCUREMENT_ID
                 ) CS2
        ON CS1.PROCUREMENT_ID = CS2.C_ID
           AND CS1.CHANGED_AT = CS2.CHANGED_AT
    ORDER BY PROCUREMENT_ID ASC;

  PROCUREMENT_REC        PROCUREMENTS_CUR%ROWTYPE;
  PROCUREMENTS_STORE_REC PROCUREMENTS_STORE_CUR%ROWTYPE;

  FUNCTION IS_DELETED_PROCUREMENT(
    RECORD_C PROCUREMENTS_STORE_CUR%ROWTYPE)
    RETURN NUMBER
  AS
    REC_EXISTS NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO REC_EXISTS
      FROM PROCUREMENTS_STORE CS1
        INNER JOIN (
                     SELECT
                       PROCUREMENT_ID  C_ID,
                       MAX(CHANGED_AT) CHANGED_AT
                     FROM PROCUREMENTS_STORE
                     WHERE PROCUREMENT_ID = RECORD_C.PROCUREMENT_ID
                     GROUP BY PROCUREMENT_ID
                   ) CS2
          ON CS1.PROCUREMENT_ID = CS2.C_ID
             AND CS1.CHANGED_AT = CS2.CHANGED_AT
      WHERE CS1.STATUS = 'D'
            AND ROWNUM = 1;
      IF (REC_EXISTS = 1)
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('ALREADY DELETED');
          RETURN 1;
        END;
      ELSE
        BEGIN
          DBMS_OUTPUT.PUT_LINE('NOT DELETED');
          RETURN 0;
        END;
      END IF;
    END;

  FUNCTION IS_EQUAL_PROCUREMENTS(
    RECORD_C PROCUREMENTS_CUR%ROWTYPE,
    RECORD_S PROCUREMENTS_STORE_CUR%ROWTYPE
  )
    RETURN NUMBER
  AS
    BEGIN
      IF RECORD_C.PROCUREMENT_ID = RECORD_S.PROCUREMENT_ID
         AND RECORD_C.ITEM_ID = RECORD_S.ITEM_ID
         AND RECORD_C.PRICE = RECORD_S.PRICE
         AND RECORD_C.AMOUNT = RECORD_S.AMOUNT
         AND RECORD_C.TIME = RECORD_S.TIME
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('EQUAL');
          RETURN 1;
        END;
      ELSE
        BEGIN
          DBMS_OUTPUT.PUT_LINE('NOT EQUAL');
          RETURN 0;
        END;
      END IF;
    END;

  PROCEDURE INSERT_PROCUREMENT(
    RECORD       PROCUREMENTS_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO PROCUREMENTS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.PROCUREMENT_ID,
          'I',
          RECORD.ITEM_ID,
          RECORD.PRICE,
          RECORD.AMOUNT,
          RECORD.TIME
        );
    END;

  PROCEDURE UPDATE_PROCUREMENT(
    RECORD       PROCUREMENTS_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO PROCUREMENTS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.PROCUREMENT_ID,
          'U',
          RECORD.ITEM_ID,
          RECORD.PRICE,
          RECORD.AMOUNT,
          RECORD.TIME
        );
    END;

  PROCEDURE DELETE_PROCUREMENT(
    RECORD       PROCUREMENTS_STORE_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO PROCUREMENTS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.PROCUREMENT_ID,
          'D',
          NULL,
          NULL,
          NULL,
          NULL
        );
    END;
  BEGIN
    OPEN PROCUREMENTS_CUR;
    OPEN PROCUREMENTS_STORE_CUR;

    FETCH PROCUREMENTS_CUR INTO PROCUREMENT_REC;
    FETCH PROCUREMENTS_STORE_CUR INTO PROCUREMENTS_STORE_REC;

    LOOP
      EXIT WHEN PROCUREMENTS_CUR%NOTFOUND AND PROCUREMENTS_STORE_CUR%NOTFOUND;

      IF (PROCUREMENTS_CUR%NOTFOUND)
      THEN
        PROCUREMENT_REC.PROCUREMENT_ID := NULL;
      END IF;

      IF (PROCUREMENTS_STORE_CUR%NOTFOUND)
      THEN
        PROCUREMENTS_STORE_REC.PROCUREMENT_ID := NULL;
      END IF;

      DBMS_OUTPUT.PUT_LINE('BRANCH:  ' || RAWTOHEX(PROCUREMENT_REC.PROCUREMENT_ID));
      DBMS_OUTPUT.PUT_LINE('STORAGE: ' || RAWTOHEX(PROCUREMENTS_STORE_REC.PROCUREMENT_ID));

      IF (PROCUREMENTS_STORE_REC.PROCUREMENT_ID IS NULL
          OR PROCUREMENT_REC.PROCUREMENT_ID IS NOT NULL
             AND PROCUREMENTS_STORE_REC.PROCUREMENT_ID IS NOT NULL
             AND RAWTOHEX(PROCUREMENT_REC.PROCUREMENT_ID) < RAWTOHEX(PROCUREMENTS_STORE_REC.PROCUREMENT_ID))
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('INSERT ' || PROCUREMENT_REC.PROCUREMENT_ID);
          INSERT_PROCUREMENT(PROCUREMENT_REC, F_CHANGED_AT);
          FETCH PROCUREMENTS_CUR INTO PROCUREMENT_REC;
        END;
      ELSIF (PROCUREMENT_REC.PROCUREMENT_ID IS NULL
             OR PROCUREMENT_REC.PROCUREMENT_ID IS NOT NULL
                AND PROCUREMENTS_STORE_REC.PROCUREMENT_ID IS NOT NULL
                AND RAWTOHEX(PROCUREMENT_REC.PROCUREMENT_ID) > RAWTOHEX(PROCUREMENTS_STORE_REC.PROCUREMENT_ID))
        THEN
          BEGIN
            IF (IS_DELETED_PROCUREMENT(PROCUREMENTS_STORE_REC) = 0)
            THEN
              BEGIN
                DBMS_OUTPUT.PUT_LINE('DELETE ' || PROCUREMENTS_STORE_REC.PROCUREMENT_ID);
                DELETE_PROCUREMENT(PROCUREMENTS_STORE_REC, F_CHANGED_AT);
              END;
            END IF;
            FETCH PROCUREMENTS_STORE_CUR INTO PROCUREMENTS_STORE_REC;
          END;
      ELSIF (RAWTOHEX(PROCUREMENT_REC.PROCUREMENT_ID) = RAWTOHEX(PROCUREMENTS_STORE_REC.PROCUREMENT_ID))
        THEN
          BEGIN
            IF IS_EQUAL_PROCUREMENTS(PROCUREMENT_REC, PROCUREMENTS_STORE_REC) = 0
            THEN
              DBMS_OUTPUT.PUT_LINE('UPDATE ' || PROCUREMENT_REC.PROCUREMENT_ID);
              UPDATE_PROCUREMENT(PROCUREMENT_REC, F_CHANGED_AT);
            END IF;
            FETCH PROCUREMENTS_CUR INTO PROCUREMENT_REC;
            FETCH PROCUREMENTS_STORE_CUR INTO PROCUREMENTS_STORE_REC;
          END;
      END IF;
    END LOOP;

    CLOSE PROCUREMENTS_CUR;
    CLOSE PROCUREMENTS_STORE_CUR;

    INSERT INTO PROCUREMENTS_STORE SELECT *
                                   FROM PROCUREMENTS_STORE_TEMP;
    DELETE FROM PROCUREMENTS_STORE_TEMP;
  END;
/
CREATE OR REPLACE PROCEDURE RESTORE_BRANCH1_PROCUREMENTS(
  F_CHANGED_AT TIMESTAMP)
AS
  BEGIN
    EXECUTE IMMEDIATE ('DELETE FROM PROCUREMENTS@BRANCH_1');
    EXECUTE IMMEDIATE ('
        INSERT INTO PROCUREMENTS@BRANCH_1
        SELECT
          PROCUREMENT_ID,
          ITEM_ID,
          PRICE,
          AMOUNT,
          TIME
        FROM PROCUREMENTS_STORE CS1
          INNER JOIN (
                       SELECT
                         PROCUREMENT_ID     C_ID,
                         MAX(CHANGED_AT) CHANGED_AT
                       FROM PROCUREMENTS_STORE
                       WHERE CHANGED_AT <= TO_TIMESTAMP(''' || TO_CHAR(F_CHANGED_AT, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')
                       GROUP BY PROCUREMENT_ID
                     ) CS2
            ON CS1.PROCUREMENT_ID = CS2.C_ID
               AND CS1.CHANGED_AT = CS2.CHANGED_AT
        WHERE STATUS <> ''D''
      ');
  END;
/
CREATE OR REPLACE PROCEDURE BACKUP_BRANCH1_SALES
AS
  F_CHANGED_AT    TIMESTAMP := SYSDATE;
  CURSOR SALES_CUR
  IS
    SELECT
      SALE_ID,
      ITEM_ID,
      CUSTOMER_ID,
      AMOUNT,
      TIME,
      TOTAL_PRICE
    FROM SALES@BRANCH_1
    ORDER BY SALE_ID ASC;

  CURSOR SALES_STORE_CUR
  IS
    SELECT
      SALE_ID,
      ITEM_ID,
      CUSTOMER_ID,
      AMOUNT,
      TIME,
      TOTAL_PRICE,
      STATUS
    FROM SALES_STORE CS1
      INNER JOIN (
                   SELECT
                     SALE_ID         C_ID,
                     MAX(CHANGED_AT) CHANGED_AT
                   FROM SALES_STORE
                   GROUP BY SALE_ID
                 ) CS2
        ON CS1.SALE_ID = CS2.C_ID
           AND CS1.CHANGED_AT = CS2.CHANGED_AT
    ORDER BY SALE_ID ASC;

  SALE_REC        SALES_CUR%ROWTYPE;
  SALES_STORE_REC SALES_STORE_CUR%ROWTYPE;

  FUNCTION IS_DELETED_SALE(
    RECORD_C SALES_STORE_CUR%ROWTYPE)
    RETURN NUMBER
  AS
    REC_EXISTS NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO REC_EXISTS
      FROM SALES_STORE CS1
        INNER JOIN (
                     SELECT
                       SALE_ID         C_ID,
                       MAX(CHANGED_AT) CHANGED_AT
                     FROM SALES_STORE
                     WHERE SALE_ID = RECORD_C.SALE_ID
                     GROUP BY SALE_ID
                   ) CS2
          ON CS1.SALE_ID = CS2.C_ID
             AND CS1.CHANGED_AT = CS2.CHANGED_AT
      WHERE CS1.STATUS = 'D'
            AND ROWNUM = 1;
      IF (REC_EXISTS = 1)
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('ALREADY DELETED');
          RETURN 1;
        END;
      ELSE
        BEGIN
          DBMS_OUTPUT.PUT_LINE('NOT DELETED');
          RETURN 0;
        END;
      END IF;
    END;

  FUNCTION IS_EQUAL_SALES(
    RECORD_C SALES_CUR%ROWTYPE,
    RECORD_S SALES_STORE_CUR%ROWTYPE
  )
    RETURN NUMBER
  AS
    BEGIN
      IF RECORD_C.SALE_ID = RECORD_S.SALE_ID
         AND RECORD_C.ITEM_ID = RECORD_S.ITEM_ID
         AND RECORD_C.CUSTOMER_ID = RECORD_S.CUSTOMER_ID
         AND RECORD_C.AMOUNT = RECORD_S.AMOUNT
         AND RECORD_C.TIME = RECORD_S.TIME
         AND RECORD_C.TOTAL_PRICE = RECORD_S.TOTAL_PRICE
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('EQUAL');
          RETURN 1;
        END;
      ELSE
        BEGIN
          DBMS_OUTPUT.PUT_LINE('NOT EQUAL');
          RETURN 0;
        END;
      END IF;
    END;

  PROCEDURE INSERT_SALE(
    RECORD       SALES_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO SALES_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.SALE_ID,
          'I',
          RECORD.ITEM_ID,
          RECORD.CUSTOMER_ID,
          RECORD.AMOUNT,
          RECORD.TIME,
          RECORD.TOTAL_PRICE
        );
    END;

  PROCEDURE UPDATE_SALE(
    RECORD       SALES_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO SALES_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.SALE_ID,
          'U',
          RECORD.ITEM_ID,
          RECORD.CUSTOMER_ID,
          RECORD.AMOUNT,
          RECORD.TIME,
          RECORD.TOTAL_PRICE
        );
    END;

  PROCEDURE DELETE_SALE(
    RECORD       SALES_STORE_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO SALES_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.SALE_ID,
          'D',
          NULL,
          NULL,
          NULL,
          NULL,
          NULL
        );
    END;
  BEGIN
    OPEN SALES_CUR;
    OPEN SALES_STORE_CUR;

    FETCH SALES_CUR INTO SALE_REC;
    FETCH SALES_STORE_CUR INTO SALES_STORE_REC;

    LOOP
      EXIT WHEN SALES_CUR%NOTFOUND AND SALES_STORE_CUR%NOTFOUND;

      IF (SALES_CUR%NOTFOUND)
      THEN
        SALE_REC.SALE_ID := NULL;
      END IF;

      IF (SALES_STORE_CUR%NOTFOUND)
      THEN
        SALES_STORE_REC.SALE_ID := NULL;
      END IF;

      DBMS_OUTPUT.PUT_LINE('BRANCH:  ' || RAWTOHEX(SALE_REC.SALE_ID));
      DBMS_OUTPUT.PUT_LINE('STORAGE: ' || RAWTOHEX(SALES_STORE_REC.SALE_ID));

      IF (SALES_STORE_REC.SALE_ID IS NULL
          OR SALE_REC.SALE_ID IS NOT NULL
             AND SALES_STORE_REC.SALE_ID IS NOT NULL
             AND RAWTOHEX(SALE_REC.SALE_ID) < RAWTOHEX(SALES_STORE_REC.SALE_ID))
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('INSERT ' || SALE_REC.SALE_ID);
          INSERT_SALE(SALE_REC, F_CHANGED_AT);
          FETCH SALES_CUR INTO SALE_REC;
        END;
      ELSIF (SALE_REC.SALE_ID IS NULL
             OR SALE_REC.SALE_ID IS NOT NULL
                AND SALES_STORE_REC.SALE_ID IS NOT NULL
                AND RAWTOHEX(SALE_REC.SALE_ID) > RAWTOHEX(SALES_STORE_REC.SALE_ID))
        THEN
          BEGIN
            IF (IS_DELETED_SALE(SALES_STORE_REC) = 0)
            THEN
              BEGIN
                DBMS_OUTPUT.PUT_LINE('DELETE ' || SALES_STORE_REC.SALE_ID);
                DELETE_SALE(SALES_STORE_REC, F_CHANGED_AT);
              END;
            END IF;
            FETCH SALES_STORE_CUR INTO SALES_STORE_REC;
          END;
      ELSIF (RAWTOHEX(SALE_REC.SALE_ID) = RAWTOHEX(SALES_STORE_REC.SALE_ID))
        THEN
          BEGIN
            IF IS_EQUAL_SALES(SALE_REC, SALES_STORE_REC) = 0
            THEN
              DBMS_OUTPUT.PUT_LINE('UPDATE ' || SALE_REC.SALE_ID);
              UPDATE_SALE(SALE_REC, F_CHANGED_AT);
            END IF;
            FETCH SALES_CUR INTO SALE_REC;
            FETCH SALES_STORE_CUR INTO SALES_STORE_REC;
          END;
      END IF;
    END LOOP;

    CLOSE SALES_CUR;
    CLOSE SALES_STORE_CUR;

    INSERT INTO SALES_STORE SELECT *
                            FROM SALES_STORE_TEMP;
    DELETE FROM SALES_STORE_TEMP;
  END;
/
CREATE OR REPLACE PROCEDURE RESTORE_BRANCH1_SALES(
  F_CHANGED_AT TIMESTAMP)
AS
  BEGIN
    EXECUTE IMMEDIATE ('DELETE FROM SALES@BRANCH_1');
    EXECUTE IMMEDIATE ('
        INSERT INTO SALES@BRANCH_1
        SELECT
          SALE_ID,
          ITEM_ID,
          CUSTOMER_ID,
          AMOUNT,
          TIME,
          TOTAL_PRICE
        FROM SALES_STORE CS1
          INNER JOIN (
                       SELECT
                         SALE_ID     C_ID,
                         MAX(CHANGED_AT) CHANGED_AT
                       FROM SALES_STORE
                       WHERE CHANGED_AT <= TO_TIMESTAMP(''' || TO_CHAR(F_CHANGED_AT, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')
                       GROUP BY SALE_ID
                     ) CS2
            ON CS1.SALE_ID = CS2.C_ID
               AND CS1.CHANGED_AT = CS2.CHANGED_AT
        WHERE STATUS <> ''D''
      ');
  END;
/