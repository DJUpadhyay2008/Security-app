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
public class GuardAttendance {
    @DocumentId
    private String id;
    private String guardId;
    private String societyId;
    private long checkInTime;
    private long checkOutTime;
}
