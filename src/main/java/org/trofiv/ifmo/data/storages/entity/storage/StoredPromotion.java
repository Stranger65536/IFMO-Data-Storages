package org.trofiv.ifmo.data.storages.entity.storage;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;
import org.trofiv.ifmo.data.storages.entity.storage.StoredPromotion.StoredPromotionPK;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import java.io.Serializable;
import java.math.BigInteger;
import java.sql.Timestamp;

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.STORAGE_SCHEMA;

@Data
@Entity
@Builder
@IdClass(StoredPromotionPK.class)
@Table(name = "promotions_store", schema = STORAGE_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class StoredPromotion {
    @Id
    @Column(name = "changed_at")
    Timestamp changedAt;
    @Id
    @Column(name = "promotion_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] promotionId;
    @Column(name = "status")
    char status;
    @Column(name = "valid_from")
    Timestamp validFrom;
    @Column(name = "valid_to")
    Timestamp validTo;
    @Column(name = "discount_pct")
    BigInteger discountPct;

    @Data
    @SuppressWarnings("PublicInnerClass")
    public static class StoredPromotionPK implements Serializable {
        protected Timestamp changedAt;
        protected byte[] promotionId;
    }
}
