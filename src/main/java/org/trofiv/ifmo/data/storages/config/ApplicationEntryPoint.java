package org.trofiv.ifmo.data.storages.config;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;
import lombok.extern.log4j.Log4j2;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Log4j2
@SpringBootApplication
@EnableTransactionManagement
@ComponentScan(basePackages = "org.trofiv.ifmo.data.storages")
public class ApplicationEntryPoint extends Application {
    @Override
    public void start(final Stage primaryStage) {
        primaryStage.setTitle("Hello World!");
        final Button btn = new Button();
        btn.setText("Say 'Hello World'");
        btn.setOnAction(event -> log.info("Hello World!"));

        final StackPane root = new StackPane();
        root.getChildren().add(btn);
        primaryStage.setScene(new Scene(root, 300, 250));
        primaryStage.show();
    }

    public static void main(final String[] args) {
        SpringApplication.run(ApplicationEntryPoint.class, args);
        Application.launch(args);
    }
}

