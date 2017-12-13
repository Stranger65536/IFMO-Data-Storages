BEGIN
  BACKUP_BRANCH1_CUSTOMERS();
  BACKUP_BRANCH1_ITEMS();
  BACKUP_BRANCH1_PROCUREMENTS();
  BACKUP_BRANCH1_SALES();
END;
BEGIN
  RESTORE_BRANCH1_CUSTOMERS(SYSDATE);
  RESTORE_BRANCH1_ITEMS(SYSDATE);
  RESTORE_BRANCH1_PROCUREMENTS(SYSDATE);
  RESTORE_BRANCH1_SALES(SYSDATE);
END;