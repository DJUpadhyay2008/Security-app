package com.security.visitor.controller;

import com.security.visitor.model.Society;
import com.security.visitor.service.SocietyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/admin/society")
@Tag(name = "society-controller", description = "Manage societies (Admin only)")
public class SocietyController {

    private final SocietyService societyService;

    public SocietyController(SocietyService societyService) {
        this.societyService = societyService;
    }

    @Operation(summary = "Create a new society")
    @PostMapping
    public ResponseEntity<Society> createSociety(@RequestBody Society society) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(societyService.createSociety(society));
    }

    @Operation(summary = "Get society by ID")
    @GetMapping("/{societyId}")
    public ResponseEntity<Society> getSociety(@PathVariable String societyId) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(societyService.getSocietyById(societyId));
    }

    @Operation(summary = "List all active societies")
    @GetMapping
    public ResponseEntity<List<Society>> getAllSocieties() throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(societyService.getAllSocieties());
    }
}
