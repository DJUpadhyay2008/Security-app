package com.security.visitor.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.security.visitor.config.FirebaseConfig;
import com.security.visitor.model.VisitorEntry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class VisitorService {

    private static final String COLLECTION_NAME = "visitor_entries";

    @Autowired
    private SocietyService societyService;

    @Autowired
    private FlatService flatService;

    private Firestore db() {
        Firestore fs = FirebaseConfig.getFirestoreInstance();
        if (fs == null) throw new RuntimeException("Firestore not available. Please add serviceAccountKey.json.");
        return fs;
    }

    public String createEntry(VisitorEntry entry) throws ExecutionException, InterruptedException {
        // 1. Validate societyId exists in DB (throws 404 if not found)
        societyService.validateSocietyExists(entry.getSocietyId());

        // 2. Validate flatId exists AND belongs to that society (throws 404 / 400 if mismatch)
        flatService.validateFlatBelongsToSociety(entry.getFlatId(), entry.getSocietyId());

        entry.setEntryTimestamp(System.currentTimeMillis());
        entry.setStatus("PENDING");
        ApiFuture<DocumentReference> future = db().collection(COLLECTION_NAME).add(entry);
        return future.get().getId();
    }

    public List<VisitorEntry> getPendingVisitors(String societyId) throws ExecutionException, InterruptedException {
        societyService.validateSocietyExists(societyId);
        Query query = db().collection(COLLECTION_NAME)
                .whereEqualTo("societyId", societyId)
                .whereEqualTo("status", "PENDING");
        ApiFuture<QuerySnapshot> querySnapshot = query.get();
        return querySnapshot.get().getDocuments().stream()
                .map(doc -> doc.toObject(VisitorEntry.class))
                .collect(Collectors.toList());
    }

    public void markExit(String visitorId, String guardId) throws ExecutionException, InterruptedException {
        DocumentReference docRef = db().collection(COLLECTION_NAME).document(visitorId);
        DocumentSnapshot snap = docRef.get().get();
        if (!snap.exists()) {
            throw new com.security.visitor.exception.ResourceNotFoundException("Visitor entry not found: " + visitorId);
        }
        docRef.update("exitTimestamp", System.currentTimeMillis(), "status", "EXITED", "guardId", guardId).get();
    }

    public List<VisitorEntry> getVisitorHistory(String societyId) throws ExecutionException, InterruptedException {
        societyService.validateSocietyExists(societyId);
        Query query = db().collection(COLLECTION_NAME)
                .whereEqualTo("societyId", societyId);
        ApiFuture<QuerySnapshot> querySnapshot = query.get();
        return querySnapshot.get().getDocuments().stream()
                .map(doc -> doc.toObject(VisitorEntry.class))
                .sorted((a, b) -> Long.compare(b.getEntryTimestamp(), a.getEntryTimestamp()))
                .collect(Collectors.toList());
    }
}
