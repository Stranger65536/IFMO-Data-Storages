package org.trofiv.ifmo.data.storages.entity.branch2;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.math.BigDecimal;
import java.sql.Timestamp;

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.BRANCH_2_SCHEMA;

@Data
@Entity
@Builder
@Table(name = "promotions", schema = BRANCH_2_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class Promotion {
    @Id
    @Column(name = "promotion_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] promotionId;
    @Column(name = "valid_from")
    Timestamp validFrom;
    @Column(name = "valid_to")
    Timestamp validTo;
    @Column(name = "discount_pct")
    BigDecimal discountPct;
}
