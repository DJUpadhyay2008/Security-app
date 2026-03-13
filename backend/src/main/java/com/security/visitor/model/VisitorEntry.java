package com.security.visitor.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.google.cloud.firestore.annotation.DocumentId;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VisitorEntry {
    @DocumentId
    private String id;
    private String visitorName;
    private String phoneNumber;
    private String purpose;
    private String vehicleNumber;
    private String photoUrl;
    private String flatId;
    private String societyId;
    private long entryTimestamp;
    private long exitTimestamp;
    private String status; // PENDING, APPROVED, DENIED, EXITED
    private String guardId;
}
