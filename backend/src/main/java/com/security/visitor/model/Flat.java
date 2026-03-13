package com.security.visitor.model;

import com.google.cloud.firestore.annotation.DocumentId;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Flat {
    @DocumentId
    private String id;
    private String flatNumber;   // e.g., "A-101"
    private String wing;         // e.g., "A"
    private String floor;        // e.g., "1"
    private String societyId;    // must reference a valid society
    private String ownerName;
    private String ownerPhone;
    private boolean active;
    private long createdAt;
}
