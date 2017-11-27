package org.trofiv.ifmo.data.storages.entity.storage;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;
import org.trofiv.ifmo.data.storages.entity.storage.StoredGoodToPromotion.StoredGoodToPromotionPK;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import java.io.Serializable;
import java.sql.Timestamp;

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.STORAGE_SCHEMA;

@Data
@Entity
@Builder
@IdClass(StoredGoodToPromotionPK.class)
@Table(name = "goods_to_promotions_store", schema = STORAGE_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class StoredGoodToPromotion {
    @Id
    @Column(name = "changed_at")
    Timestamp changedAt;
    @Id
    @Column(name = "good_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] goodId;
    @Id
    @Column(name = "promotion_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] promotionId;
    @Column(name = "status")
    char status;

    @Data
    @SuppressWarnings("PublicInnerClass")
    public static class StoredGoodToPromotionPK implements Serializable {
        protected Timestamp changedAt;
        protected byte[] goodId;
        protected byte[] promotionId;
    }
}
