package com.security.visitor.service;

import com.google.cloud.firestore.*;
import com.security.visitor.config.FirebaseConfig;
import com.security.visitor.model.ResidentPreference;
import org.springframework.stereotype.Service;

import java.util.concurrent.ExecutionException;

@Service
public class ResidentService {

    private static final String COLLECTION_NAME = "resident_preferences";

    private Firestore db() {
        Firestore fs = FirebaseConfig.getFirestoreInstance();
        if (fs == null) throw new RuntimeException("Firestore not available. Please add serviceAccountKey.json.");
        return fs;
    }

    public void updatePreference(ResidentPreference preference) throws ExecutionException, InterruptedException {
        String docId = preference.getSocietyId() + "_" + preference.getFlatId();
        db().collection(COLLECTION_NAME).document(docId).set(preference).get();
    }

    public ResidentPreference getPreference(String societyId, String flatId) throws ExecutionException, InterruptedException {
        String docId = societyId + "_" + flatId;
        DocumentSnapshot doc = db().collection(COLLECTION_NAME).document(docId).get().get();
        if (doc.exists()) {
            return doc.toObject(ResidentPreference.class);
        }
        return null;
    }
}
