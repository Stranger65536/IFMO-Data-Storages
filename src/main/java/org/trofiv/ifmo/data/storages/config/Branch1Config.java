package org.trofiv.ifmo.data.storages.config;

import com.google.common.collect.ImmutableMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
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
        basePackages = "org.trofiv.ifmo.data.storages.repository.branch1",
        entityManagerFactoryRef = "branch1EntityManager",
        transactionManagerRef = "branch1TransactionManager")
public class Branch1Config {
    private final String ddlAuto;
    private final String dialect;
    @Resource
    private DataSource branch1DataSource;

    @Autowired
    public Branch1Config(
            @Value("${jpa.branch1.hibernate.ddl-auto}") final String ddlAuto,
            @Value("${jpa.branch1.hibernate.properties.dialect}") final String dialect) {
        this.ddlAuto = ddlAuto;
        this.dialect = dialect;
    }

    @Bean
    @SuppressWarnings("Duplicates")
    public LocalContainerEntityManagerFactoryBean branch1EntityManager() {
        final LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(branch1DataSource);
        em.setPackagesToScan("org.trofiv.ifmo.data.storages.entity.branch1");

        final JpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);
        final Map<String, String> properties = ImmutableMap.<String, String>builder()
                .put("hibernate.hbm2ddl.auto", ddlAuto)
                .put("hibernate.dialect", dialect)
                .build();
        em.setJpaPropertyMap(properties);

        return em;
    }

    @Bean
    public PlatformTransactionManager branch1TransactionManager() {
        final JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(branch1EntityManager().getObject());
        return transactionManager;
    }
}
