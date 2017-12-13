CREATE OR REPLACE PROCEDURE BACKUP_BRANCH2_GOODS
AS
  F_CHANGED_AT    TIMESTAMP := SYSDATE;
  CURSOR GOODS_CUR
  IS
    SELECT
      GOOD_ID,
      VENDOR_CODE,
      NAME,
      DESCRIPTION,
      BASE_PRICE
    FROM GOODS@BRANCH_2
    ORDER BY GOOD_ID ASC;

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

  GOOD_REC        GOODS_CUR%ROWTYPE;
  ITEMS_STORE_REC ITEMS_STORE_CUR%ROWTYPE;

  FUNCTION IS_DELETED_GOOD(
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

  FUNCTION IS_EQUAL_GOODS(
    RECORD_C GOODS_CUR%ROWTYPE,
    RECORD_S ITEMS_STORE_CUR%ROWTYPE
  )
    RETURN NUMBER
  AS
    BEGIN
      IF RECORD_C.GOOD_ID = RECORD_S.ITEM_ID
         AND RECORD_C.VENDOR_CODE = RECORD_S.VENDOR_CODE
         AND RECORD_C.NAME = RECORD_S.NAME
         AND RECORD_C.DESCRIPTION = RECORD_S.DESCRIPTION
         AND RECORD_C.BASE_PRICE = RECORD_S.PRICE
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

  PROCEDURE INSERT_GOOD(
    RECORD       GOODS_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO ITEMS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.GOOD_ID,
          2,
          'I',
          RECORD.VENDOR_CODE,
          RECORD.NAME,
          RECORD.DESCRIPTION,
          RECORD.BASE_PRICE
        );
    END;

  PROCEDURE UPDATE_GOOD(
    RECORD       GOODS_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO ITEMS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.GOOD_ID,
          2,
          'U',
          RECORD.VENDOR_CODE,
          RECORD.NAME,
          RECORD.DESCRIPTION,
          RECORD.BASE_PRICE
        );
    END;

  PROCEDURE DELETE_GOOD(
    RECORD       ITEMS_STORE_CUR%ROWTYPE,
    F_CHANGED_AT TIMESTAMP
  ) AS
    BEGIN
      INSERT INTO ITEMS_STORE_TEMP
      VALUES
        (
          F_CHANGED_AT,
          RECORD.ITEM_ID,
          2,
          'D',
          NULL,
          NULL,
          NULL,
          NULL
        );
    END;
  BEGIN
    OPEN GOODS_CUR;
    OPEN ITEMS_STORE_CUR;

    FETCH GOODS_CUR INTO GOOD_REC;
    FETCH ITEMS_STORE_CUR INTO ITEMS_STORE_REC;

    LOOP
      EXIT WHEN GOODS_CUR%NOTFOUND AND ITEMS_STORE_CUR%NOTFOUND;

      IF (GOODS_CUR%NOTFOUND)
      THEN
        GOOD_REC.GOOD_ID := NULL;
      END IF;

      IF (ITEMS_STORE_CUR%NOTFOUND)
      THEN
        ITEMS_STORE_REC.ITEM_ID := NULL;
      END IF;

      DBMS_OUTPUT.PUT_LINE('BRANCH:  ' || RAWTOHEX(GOOD_REC.GOOD_ID));
      DBMS_OUTPUT.PUT_LINE('STORAGE: ' || RAWTOHEX(ITEMS_STORE_REC.ITEM_ID));

      IF (ITEMS_STORE_REC.ITEM_ID IS NULL
          OR GOOD_REC.GOOD_ID IS NOT NULL
             AND ITEMS_STORE_REC.ITEM_ID IS NOT NULL
             AND RAWTOHEX(GOOD_REC.GOOD_ID) < RAWTOHEX(ITEMS_STORE_REC.ITEM_ID))
      THEN
        BEGIN
          DBMS_OUTPUT.PUT_LINE('INSERT ' || GOOD_REC.GOOD_ID);
          INSERT_GOOD(GOOD_REC, F_CHANGED_AT);
          FETCH GOODS_CUR INTO GOOD_REC;
        END;
      ELSIF (GOOD_REC.GOOD_ID IS NULL
             OR GOOD_REC.GOOD_ID IS NOT NULL
                AND ITEMS_STORE_REC.ITEM_ID IS NOT NULL
                AND RAWTOHEX(GOOD_REC.GOOD_ID) > RAWTOHEX(ITEMS_STORE_REC.ITEM_ID))
        THEN
          BEGIN
            IF (IS_DELETED_GOOD(ITEMS_STORE_REC) = 0)
            THEN
              BEGIN
                DBMS_OUTPUT.PUT_LINE('DELETE ' || ITEMS_STORE_REC.ITEM_ID);
                DELETE_GOOD(ITEMS_STORE_REC, F_CHANGED_AT);
              END;
            END IF;
            FETCH ITEMS_STORE_CUR INTO ITEMS_STORE_REC;
          END;
      ELSIF (RAWTOHEX(GOOD_REC.GOOD_ID) = RAWTOHEX(ITEMS_STORE_REC.ITEM_ID))
        THEN
          BEGIN
            IF IS_EQUAL_GOODS(GOOD_REC, ITEMS_STORE_REC) = 0
            THEN
              DBMS_OUTPUT.PUT_LINE('UPDATE ' || GOOD_REC.GOOD_ID);
              UPDATE_GOOD(GOOD_REC, F_CHANGED_AT);
            END IF;
            FETCH GOODS_CUR INTO GOOD_REC;
            FETCH ITEMS_STORE_CUR INTO ITEMS_STORE_REC;
          END;
      END IF;
    END LOOP;

    CLOSE GOODS_CUR;
    CLOSE ITEMS_STORE_CUR;

    INSERT INTO ITEMS_STORE SELECT *
                            FROM ITEMS_STORE_TEMP;
    DELETE FROM ITEMS_STORE_TEMP;
  END;
/
CREATE OR REPLACE PROCEDURE RESTORE_BRANCH2_GOODS(
  F_CHANGED_AT TIMESTAMP)
AS
  BEGIN
    EXECUTE IMMEDIATE ('DELETE FROM GOODS@BRANCH_2');
    EXECUTE IMMEDIATE ('
        INSERT INTO GOODS@BRANCH_2
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
                         AND STORE_NUMBER = 2
                       GROUP BY ITEM_ID
                     ) CS2
            ON CS1.ITEM_ID = CS2.C_ID
               AND CS1.CHANGED_AT = CS2.CHANGED_AT
        WHERE STATUS <> ''D''
      ');
  END;
/