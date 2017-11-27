package org.trofiv.ifmo.data.storages.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.PropertySource;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;

@Configuration
@PropertySource("file:gradle.properties")
public class AppConfig {
    @Bean
    public DataSource branch1DataSource(
            @Value("${branch1.url}") final String url,
            @Value("${branch1.user}") final String user,
            @Value("${branch1.password}") final String password) {
        return new DriverManagerDataSource(url, user, password);
    }

    @Bean
    public DataSource branch2DataSource(
            @Value("${branch2.url}") final String url,
            @Value("${branch2.user}") final String user,
            @Value("${branch2.password}") final String password) {
        return new DriverManagerDataSource(url, user, password);
    }

    @Primary
    @Bean
    public DataSource storageDataSource(
            @Value("${storage.url}") final String url,
            @Value("${storage.user}") final String user,
            @Value("${storage.password}") final String password) {
        return new DriverManagerDataSource(url, user, password);
    }
}
