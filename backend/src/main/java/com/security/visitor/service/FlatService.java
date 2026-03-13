package com.security.visitor.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.security.visitor.config.FirebaseConfig;
import com.security.visitor.exception.InvalidRequestException;
import com.security.visitor.exception.ResourceNotFoundException;
import com.security.visitor.model.Flat;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class FlatService {

    private static final String COLLECTION = "flats";

    @Autowired
    private SocietyService societyService;

    private Firestore db() {
        Firestore fs = FirebaseConfig.getFirestoreInstance();
        if (fs == null) throw new RuntimeException("Firestore not available. Please add serviceAccountKey.json.");
        return fs;
    }

    public Flat createFlat(Flat flat) throws ExecutionException, InterruptedException {
        if (flat.getFlatNumber() == null || flat.getFlatNumber().isBlank()) {
            throw new InvalidRequestException("Flat number is required.");
        }
        if (flat.getSocietyId() == null || flat.getSocietyId().isBlank()) {
            throw new InvalidRequestException("societyId is required when creating a flat.");
        }
        // Validate the society exists before creating the flat
        societyService.validateSocietyExists(flat.getSocietyId());

        // Check for duplicate flat number in this society
        boolean exists = db().collection(COLLECTION)
                .whereEqualTo("societyId", flat.getSocietyId())
                .whereEqualTo("flatNumber", flat.getFlatNumber())
                .get().get().size() > 0;
        if (exists) {
            throw new InvalidRequestException("Flat number " + flat.getFlatNumber() + " already exists in this society.");
        }

        flat.setCreatedAt(System.currentTimeMillis());
        flat.setActive(true);
        ApiFuture<DocumentReference> future = db().collection(COLLECTION).add(flat);
        flat.setId(future.get().getId());
        return flat;
    }

    public Flat getFlatById(String flatId) throws ExecutionException, InterruptedException {
        DocumentSnapshot doc = db().collection(COLLECTION).document(flatId).get().get();
        if (!doc.exists()) {
            throw new ResourceNotFoundException("Flat not found with ID: " + flatId);
        }
        Flat flat = doc.toObject(Flat.class);
        if (flat != null && !flat.isActive()) {
            throw new ResourceNotFoundException("Flat with ID: " + flatId + " is inactive.");
        }
        return flat;
    }

    public List<Flat> getFlatsBySociety(String societyId) throws ExecutionException, InterruptedException {
        societyService.validateSocietyExists(societyId);
        return db().collection(COLLECTION)
                .whereEqualTo("societyId", societyId)
                .whereEqualTo("active", true)
                .get().get().getDocuments().stream()
                .map(doc -> doc.toObject(Flat.class))
                .collect(Collectors.toList());
    }

    public void validateFlatBelongsToSociety(String flatId, String societyId) throws ExecutionException, InterruptedException {
        Flat flat = getFlatById(flatId); // throws if not found
        if (!flat.getSocietyId().equals(societyId)) {
            throw new InvalidRequestException(
                "Flat ID: " + flatId + " does not belong to Society ID: " + societyId
            );
        }
    }
}
