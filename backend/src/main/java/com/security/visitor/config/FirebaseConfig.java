package com.security.visitor.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.config.path}")
    private String configPath;

    @Value("${firebase.database.url}")
    private String databaseUrl;

    private final ResourceLoader resourceLoader;
    private static boolean initialized = false;

    public FirebaseConfig(ResourceLoader resourceLoader) {
        this.resourceLoader = resourceLoader;
    }

    @PostConstruct
    public void initialize() {
        try {
            Resource resource = resourceLoader.getResource(configPath);
            if (!resource.exists()) {
                System.err.println(">>> serviceAccountKey.json NOT FOUND. App starts in demo mode (no Firestore).");
                return;
            }
            InputStream serviceAccount = resource.getInputStream();
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .setDatabaseUrl(databaseUrl)
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                initialized = true;
                System.out.println(">>> Firebase initialized successfully!");
            }
        } catch (IOException e) {
            System.err.println(">>> Firebase init failed: " + e.getMessage());
        }
    }

    public static Firestore getFirestoreInstance() {
        if (!initialized || FirebaseApp.getApps().isEmpty()) {
            return null;
        }
        return FirestoreClient.getFirestore();
    }
}
