DECLARE
  GOOD_IDS        BRANCH_2.ARRAY_T := BRANCH_2.ARRAY_T();
  PROMOTION_IDS   BRANCH_2.ARRAY_T := BRANCH_2.ARRAY_T();
  REALIZATION_IDS BRANCH_2.ARRAY_T := BRANCH_2.ARRAY_T();
  CAT_IDS         BRANCH_2.WIDE_ARRAY_T := BRANCH_2.WIDE_ARRAY_T();
BEGIN
  BRANCH_2.INSERT_RANDOM_DATA(20, 20, GOOD_IDS, PROMOTION_IDS, REALIZATION_IDS, CAT_IDS);
  BRANCH_2.DELETE_RANDOM_DATA(3, 3, GOOD_IDS, PROMOTION_IDS, REALIZATION_IDS, CAT_IDS);
  BRANCH_2.UPDATE_RANDOM_DATA(4, 4, GOOD_IDS, PROMOTION_IDS, REALIZATION_IDS);
END;