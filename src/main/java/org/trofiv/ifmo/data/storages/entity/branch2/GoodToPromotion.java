package org.trofiv.ifmo.data.storages.entity.branch2;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;
import org.trofiv.ifmo.data.storages.entity.branch2.GoodToPromotion.GoodToPromotionPK;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import java.io.Serializable;

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.BRANCH_2_SCHEMA;

@Data
@Entity
@Builder
@IdClass(GoodToPromotionPK.class)
@Table(name = "goods_to_promotions", schema = BRANCH_2_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class GoodToPromotion {
    @Id
    @Column(name = "good_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] goodId;
    @Id
    @Column(name = "promotion_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] promotionId;

    @Data
    @SuppressWarnings("PublicInnerClass")
    public static class GoodToPromotionPK implements Serializable {
        protected byte[] goodId;
        protected byte[] promotionId;
    }
}
