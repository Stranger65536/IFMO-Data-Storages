package org.trofiv.ifmo.data.storages.entity.storage;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.Type;
import org.trofiv.ifmo.data.storages.entity.storage.StoredCustomer.StoredCustomerPK;

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
@IdClass(StoredCustomerPK.class)
@Table(name = "customers_store", schema = STORAGE_SCHEMA)
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class StoredCustomer {
    @Id
    @Column(name = "changed_at")
    Timestamp changedAt;
    @Id
    @Column(name = "customer_id")
    @Type(type = "org.hibernate.type.UUIDBinaryType")
    byte[] customerId;
    @Column(name = "status")
    char status;
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

    @Data
    @SuppressWarnings("PublicInnerClass")
    public static class StoredCustomerPK implements Serializable {
        protected Timestamp changedAt;
        protected byte[] customerId;
    }
}
