package org.trofiv.ifmo.data.storages.entity.storage;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;
import org.trofiv.ifmo.data.storages.entity.storage.StoredItem.StoredItemPK;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import java.io.Serializable;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Timestamp;

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.STORAGE_SCHEMA;

@Data
@Entity
@Builder
@IdClass(StoredItemPK.class)
@Table(name = "items_store", schema = STORAGE_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class StoredItem {
    @Id
    @Column(name = "changed_at")
    Timestamp changedAt;
    @Id
    @Column(name = "item_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] itemId;
    @Id
    @Column(name = "store_number")
    int storeNumber;
    @Column(name = "status")
    char status;
    @Column(name = "vendor_code")
    BigInteger vendorCode;
    @Column(name = "name")
    String name;
    @Column(name = "description")
    String description;
    @Column(name = "price")
    BigDecimal price;

    @Data
    @SuppressWarnings("PublicInnerClass")
    public static class StoredItemPK implements Serializable {
        protected Timestamp changedAt;
        protected byte[] itemId;
        protected String storeNumber;
    }
}
