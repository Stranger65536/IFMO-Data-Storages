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
        basePackages = "org.trofiv.ifmo.data.storages.repository.branch2",
        entityManagerFactoryRef = "branch2EntityManager",
        transactionManagerRef = "branch2TransactionManager")
public class Branch2Config {
    private final String ddlAuto;
    private final String dialect;
    @Resource
    private DataSource branch2DataSource;

    @Autowired
    public Branch2Config(
            @Value("${jpa.branch2.hibernate.ddl-auto}") final String ddlAuto,
            @Value("${jpa.branch2.hibernate.properties.dialect}") final String dialect) {
        this.ddlAuto = ddlAuto;
        this.dialect = dialect;
    }

    @Bean
    @SuppressWarnings("Duplicates")
    public LocalContainerEntityManagerFactoryBean branch2EntityManager() {
        final LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(branch2DataSource);
        em.setPackagesToScan("org.trofiv.ifmo.data.storages.entity.branch2");

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
        transactionManager.setEntityManagerFactory(branch2EntityManager().getObject());
        return transactionManager;
    }
}
