package org.trofiv.ifmo.data.storages.entity.storage;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;
import org.trofiv.ifmo.data.storages.entity.storage.StoredSale.StoredSalePK;

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
@IdClass(StoredSalePK.class)
@Table(name = "sales_store", schema = STORAGE_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class StoredSale {
    @Id
    @Column(name = "changed_at")
    Timestamp changedAt;
    @Id
    @Column(name = "sale_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] saleId;
    @Column(name = "status")
    char status;
    @Column(name = "item_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] itemId;
    @Column(name = "customer_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] customerId;
    @Column(name = "amount")
    BigInteger amount;
    @Column(name = "time")
    Timestamp time;
    @Column(name = "total_price")
    BigDecimal totalPrice;

    @Data
    @SuppressWarnings("PublicInnerClass")
    public static class StoredSalePK implements Serializable {
        protected Timestamp changedAt;
        protected byte[] saleId;
    }
}
