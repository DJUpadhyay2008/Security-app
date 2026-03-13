package com.security.visitor.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.security.visitor.config.FirebaseConfig;
import com.security.visitor.exception.InvalidRequestException;
import com.security.visitor.exception.ResourceNotFoundException;
import com.security.visitor.model.Society;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class SocietyService {

    private static final String COLLECTION = "societies";

    private Firestore db() {
        Firestore fs = FirebaseConfig.getFirestoreInstance();
        if (fs == null) throw new RuntimeException("Firestore not available. Please add serviceAccountKey.json.");
        return fs;
    }

    public Society createSociety(Society society) throws ExecutionException, InterruptedException {
        if (society.getName() == null || society.getName().isBlank()) {
            throw new InvalidRequestException("Society name is required.");
        }
        // Check for duplicate name
        boolean exists = db().collection(COLLECTION)
                .whereEqualTo("name", society.getName())
                .get().get().size() > 0;
        if (exists) {
            throw new InvalidRequestException("Society with this name already exists.");
        }
        society.setCreatedAt(System.currentTimeMillis());
        society.setActive(true);
        ApiFuture<DocumentReference> future = db().collection(COLLECTION).add(society);
        society.setId(future.get().getId());
        return society;
    }

    public Society getSocietyById(String societyId) throws ExecutionException, InterruptedException {
        DocumentSnapshot doc = db().collection(COLLECTION).document(societyId).get().get();
        if (!doc.exists()) {
            throw new ResourceNotFoundException("Society not found with ID: " + societyId);
        }
        Society society = doc.toObject(Society.class);
        if (society != null && !society.isActive()) {
            throw new ResourceNotFoundException("Society with ID: " + societyId + " is inactive.");
        }
        return society;
    }

    public List<Society> getAllSocieties() throws ExecutionException, InterruptedException {
        return db().collection(COLLECTION)
                .whereEqualTo("active", true)
                .get().get().getDocuments().stream()
                .map(doc -> doc.toObject(Society.class))
                .collect(Collectors.toList());
    }

    public void validateSocietyExists(String societyId) throws ExecutionException, InterruptedException {
        getSocietyById(societyId); // throws ResourceNotFoundException if not found/inactive
    }
}
