package org.trofiv.ifmo.data.storages.entity.storage;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;
import org.trofiv.ifmo.data.storages.entity.storage.StoredRealization.StoredRealizationPK;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.STORAGE_SCHEMA;

@Data
@Entity
@Builder
@IdClass(StoredRealizationPK.class)
@Table(name = "realizations_store", schema = STORAGE_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class StoredRealization {
    @Id
    @Column(name = "changed_at")
    Timestamp changedAt;
    @Id
    @Column(name = "realization_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] realizationId;
    @Column(name = "status")
    char status;
    @Column(name = "good_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] goodId;
    @Column(name = "promotion_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] promotionId;
    @Column(name = "price")
    BigDecimal price;

    @Data
    @SuppressWarnings("PublicInnerClass")
    public static class StoredRealizationPK implements Serializable {
        protected Timestamp changedAt;
        protected byte[] realizationId;
    }
}
