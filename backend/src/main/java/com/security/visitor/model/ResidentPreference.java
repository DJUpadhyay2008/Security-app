package com.security.visitor.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResidentPreference {
    private String flatId;
    private String societyId;
    private String preference; // AUTO_ALLOW, CALL_BEFORE_ENTRY, DENY_UNKNOWN_VISITORS
}
