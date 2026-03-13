package com.security.visitor.controller;

import com.security.visitor.model.ResidentPreference;
import com.security.visitor.service.ResidentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/resident")
public class ResidentController {

    private final ResidentService residentService;

    public ResidentController(ResidentService residentService) {
        this.residentService = residentService;
    }

    @PutMapping("/preference")
    public ResponseEntity<Void> updatePreference(@RequestBody ResidentPreference preference) throws ExecutionException, InterruptedException {
        residentService.updatePreference(preference);
        return ResponseEntity.ok().build();
    }
}
