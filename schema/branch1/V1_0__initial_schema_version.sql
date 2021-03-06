CREATE TABLE ITEMS (
  ITEM_ID     RAW(32) DEFAULT SYS_GUID() NOT NULL,
  VENDOR_CODE NUMERIC(32, 0)             NOT NULL,
  NAME        VARCHAR(255)               NOT NULL,
  DESCRIPTION VARCHAR2(4000)             NOT NULL,
  PRICE       NUMERIC(15, 2)             NOT NULL,
  PRIMARY KEY (ITEM_ID),
  CONSTRAINT ITEM_UNIQ_VENDOR_CODE_IDX UNIQUE (VENDOR_CODE)
);

CREATE TABLE CUSTOMERS (
  CUSTOMER_ID  RAW(32) DEFAULT SYS_GUID() NOT NULL,
  FIRST_NAME   VARCHAR2(35)               NOT NULL,
  LAST_NAME    VARCHAR2(35)               NOT NULL,
  MIDDLE_NAME  VARCHAR2(35)               NOT NULL,
  EMAIL        VARCHAR2(45)               NOT NULL,
  PHONE_NUMBER VARCHAR2(15)               NOT NULL,
  PRIMARY KEY (CUSTOMER_ID)
);

CREATE TABLE PROCUREMENTS (
  PROCUREMENT_ID RAW(32) DEFAULT SYS_GUID() NOT NULL,
  ITEM_ID        RAW(32)                    NOT NULL,
  PRICE          NUMERIC(15, 2)             NOT NULL,
  AMOUNT         NUMERIC(7, 0)              NOT NULL,
  TIME           TIMESTAMP                  NOT NULL,
  PRIMARY KEY (PROCUREMENT_ID),
  CONSTRAINT PROCUREMENT_ITEM_FK FOREIGN KEY (ITEM_ID) REFERENCES ITEMS (ITEM_ID) ON DELETE CASCADE
);

CREATE INDEX PROCUREMENT_TIME_IDX
  ON PROCUREMENTS (TIME);

CREATE TABLE SALES (
  SALE_ID     RAW(32) DEFAULT SYS_GUID() NOT NULL,
  ITEM_ID     RAW(32)                    NOT NULL,
  CUSTOMER_ID RAW(32)                    NOT NULL,
  AMOUNT      NUMERIC(4, 0)              NOT NULL,
  TIME        TIMESTAMP                  NOT NULL,
  TOTAL_PRICE NUMERIC(15, 2)             NOT NULL,
  PRIMARY KEY (SALE_ID),
  CONSTRAINT SALE_ITEM_FK FOREIGN KEY (ITEM_ID) REFERENCES ITEMS (ITEM_ID) ON DELETE CASCADE,
  CONSTRAINT SALE_CUSTOMER_FK FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS (CUSTOMER_ID) ON DELETE CASCADE
);

CREATE INDEX SAME_TIME_IDX
  ON SALES (TIME);