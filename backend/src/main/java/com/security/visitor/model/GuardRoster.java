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
public class GuardRoster {
    @DocumentId
    private String id;
    private String guardId;
    private String societyId;
    private String shiftStart; // e.g., "08:00"
    private String shiftEnd;   // e.g., "20:00"
    private String date;       // e.g., "2024-03-20"
}
