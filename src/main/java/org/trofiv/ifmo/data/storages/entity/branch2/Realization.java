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

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.BRANCH_2_SCHEMA;

@Data
@Entity
@Builder
@Table(name = "realizations", schema = BRANCH_2_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class Realization {
    @Id
    @Column(name = "realization_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] realizationId;
    @Column(name = "good_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] goodId;
    @Column(name = "promotion_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] promotionId;
    @Column(name = "price")
    BigDecimal price;
}
