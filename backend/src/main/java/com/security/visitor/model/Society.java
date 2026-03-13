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
public class Society {
    @DocumentId
    private String id;
    private String name;
    private String address;
    private String city;
    private String state;
    private String pincode;
    private boolean active;
    private long createdAt;
}
