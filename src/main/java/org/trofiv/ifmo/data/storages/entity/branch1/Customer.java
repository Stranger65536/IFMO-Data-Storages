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

import static org.trofiv.ifmo.data.storages.entity.EntityConstants.BRANCH_1_SCHEMA;

@Data
@Entity
@Builder
@Table(name = "CUSTOMERS", schema = BRANCH_1_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class Customer {
    @Id
    @Column(name = "customer_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] customerId;
    @Column(name = "first_name")
    String firstName;
    @Column(name = "last_name")
    String lastName;
    @Column(name = "middle_name")
    String middleName;
    @Column(name = "email")
    String email;
    @Column(name = "phone_number")
    String phoneNumber;
}
