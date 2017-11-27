package org.trofiv.ifmo.data.storages.config;

import com.google.common.collect.ImmutableMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.JpaVendorAdapter;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;

import javax.annotation.Resource;
import javax.sql.DataSource;
import java.util.Map;

@Configuration
@EnableJpaRepositories(
        basePackages = "org.trofiv.ifmo.data.storages.repository.storage",
        entityManagerFactoryRef = "storageEntityManager",
        transactionManagerRef = "storageTransactionManager")
public class StorageConfig {
    private final String ddlAuto;
    private final String dialect;
    @Resource
    private DataSource storageDataSource;

    @Autowired
    public StorageConfig(
            @Value("${jpa.storage.hibernate.ddl-auto}") final String ddlAuto,
            @Value("${jpa.storage.hibernate.properties.dialect}") final String dialect) {
        this.ddlAuto = ddlAuto;
        this.dialect = dialect;
    }

    @Bean
    @Primary
    public LocalContainerEntityManagerFactoryBean storageEntityManager() {
        final LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(storageDataSource);
        em.setPackagesToScan("org.trofiv.ifmo.data.storages.entity.storage");

        final JpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);
        final Map<String, String> properties = ImmutableMap.<String, String>builder()
                .put("hibernate.hbm2ddl.auto", ddlAuto)
                .put("hibernate.dialect", dialect)
                .build();
        em.setJpaPropertyMap(properties);

        return em;
    }

    @Primary
    @Bean
    public PlatformTransactionManager userTransactionManager() {
        final JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(storageEntityManager().getObject());
        return transactionManager;
    }
}
