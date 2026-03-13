package com.security.visitor.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.security.visitor.config.FirebaseConfig;
import com.security.visitor.model.GuardAttendance;
import com.security.visitor.model.GuardRoster;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class GuardService {

    private static final String ATTENDANCE_COLLECTION = "guard_attendance";
    private static final String ROSTER_COLLECTION = "guard_roster";

    private Firestore db() {
        Firestore fs = FirebaseConfig.getFirestoreInstance();
        if (fs == null) throw new RuntimeException("Firestore not available. Please add serviceAccountKey.json.");
        return fs;
    }

    public String checkIn(String guardId, String societyId) throws ExecutionException, InterruptedException {
        GuardAttendance attendance = GuardAttendance.builder()
                .guardId(guardId)
                .societyId(societyId)
                .checkInTime(System.currentTimeMillis())
                .build();
        ApiFuture<DocumentReference> future = db().collection(ATTENDANCE_COLLECTION).add(attendance);
        return future.get().getId();
    }

    public void checkOut(String attendanceId) throws ExecutionException, InterruptedException {
        DocumentReference docRef = db().collection(ATTENDANCE_COLLECTION).document(attendanceId);
        docRef.update("checkOutTime", System.currentTimeMillis()).get();
    }

    public List<GuardAttendance> getAttendance(String societyId) throws ExecutionException, InterruptedException {
        Query query = db().collection(ATTENDANCE_COLLECTION)
                .whereEqualTo("societyId", societyId);
        ApiFuture<QuerySnapshot> querySnapshot = query.get();
        return querySnapshot.get().getDocuments().stream()
                .map(doc -> doc.toObject(GuardAttendance.class))
                .collect(Collectors.toList());
    }

    public String assignRoster(GuardRoster roster) throws ExecutionException, InterruptedException {
        ApiFuture<DocumentReference> future = db().collection(ROSTER_COLLECTION).add(roster);
        return future.get().getId();
    }
}
