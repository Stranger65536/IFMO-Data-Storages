package org.trofiv.ifmo.data.storages.entity.branch1;

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
import java.math.BigInteger;

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.BRANCH_1_SCHEMA;

@Data
@Entity
@Builder
@Table(name = "items", schema = BRANCH_1_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class Item {
    @Id
    @Column(name = "item_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] itemId;
    @Column(name = "vendor_code")
    BigInteger vendorCode;
    @Column(name = "name")
    String name;
    @Column(name = "description")
    String description;
    @Column(name = "price")
    BigDecimal price;
}
