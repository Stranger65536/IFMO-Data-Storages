package org.trofiv.ifmo.data.storages.entity.storage;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;
import org.trofiv.ifmo.data.storages.entity.storage.StoredProcurement.StoredProcurementPK;

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
@IdClass(StoredProcurementPK.class)
@Table(name = "procurements_store", schema = STORAGE_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class StoredProcurement {
    @Id
    @Column(name = "changed_at")
    Timestamp changedAt;
    @Id
    @Column(name = "procurement_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] procurementId;
    @Column(name = "status")
    char status;
    @Column(name = "item_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] itemId;
    @Column(name = "price")
    BigDecimal price;
    @Column(name = "amount")
    BigInteger amount;
    @Column(name = "time")
    Timestamp time;

    @Data
    @SuppressWarnings("PublicInnerClass")
    public static class StoredProcurementPK implements Serializable {
        protected Timestamp changedAt;
        protected byte[] procurementId;
    }
}
