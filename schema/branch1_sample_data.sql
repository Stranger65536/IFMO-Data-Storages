DECLARE
  ITEM_IDS        ARRAY_T := ARRAY_T();
  CUSTOMER_IDS    ARRAY_T := ARRAY_T();
  PROCUREMENT_IDS ARRAY_T := ARRAY_T();
  SALES_IDS       ARRAY_T := ARRAY_T();
BEGIN
  INSERT_RANDOM_DATA(20, 20, ITEM_IDS, CUSTOMER_IDS, PROCUREMENT_IDS, SALES_IDS);
  DELETE_RANDOM_DATA(3, 3, ITEM_IDS, CUSTOMER_IDS, PROCUREMENT_IDS, SALES_IDS);
  UPDATE_RANDOM_DATA(4, 4, ITEM_IDS, CUSTOMER_IDS, PROCUREMENT_IDS, SALES_IDS);
END;