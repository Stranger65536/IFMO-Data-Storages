CREATE VIEW BRANCH_1_SHOWCASE
  AS
    SELECT
      STORE.ITEM_ID,
      VENDOR_CODE,
      NAME,
      DESCRIPTION,
      PRICE
    FROM
      ITEMS_STORE STORE
      JOIN (
             SELECT
               ITEM_ID,
               MAX(CHANGED_AT) CHANGED_AT
             FROM ITEMS_STORE
             WHERE STORE_NUMBER = 1
             GROUP BY ITEM_ID) KEYS
        ON STORE.ITEM_ID = KEYS.ITEM_ID
           AND STORE.CHANGED_AT = KEYS.CHANGED_AT
    WHERE STATUS <> 'D' AND STORE_NUMBER = 1;

CREATE VIEW BRANCH_2_SHOWCASE
  AS
    SELECT
      STORE.ITEM_ID,
      VENDOR_CODE,
      NAME,
      DESCRIPTION,
      PRICE
    FROM
      ITEMS_STORE STORE
      JOIN (
             SELECT
               ITEM_ID,
               MAX(CHANGED_AT) CHANGED_AT
             FROM ITEMS_STORE
             WHERE STORE_NUMBER = 1
             GROUP BY ITEM_ID) KEYS
        ON STORE.ITEM_ID = KEYS.ITEM_ID
           AND STORE.CHANGED_AT = KEYS.CHANGED_AT
    WHERE STATUS <> 'D' AND STORE_NUMBER = 2;
