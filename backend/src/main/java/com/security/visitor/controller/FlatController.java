package com.security.visitor.controller;

import com.security.visitor.model.Flat;
import com.security.visitor.service.FlatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/admin/flat")
@Tag(name = "flat-controller", description = "Manage flats (Admin only)")
public class FlatController {

    private final FlatService flatService;

    public FlatController(FlatService flatService) {
        this.flatService = flatService;
    }

    @Operation(summary = "Create a new flat (society must exist)")
    @PostMapping
    public ResponseEntity<Flat> createFlat(@RequestBody Flat flat) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(flatService.createFlat(flat));
    }

    @Operation(summary = "Get flat by ID")
    @GetMapping("/{flatId}")
    public ResponseEntity<Flat> getFlat(@PathVariable String flatId) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(flatService.getFlatById(flatId));
    }

    @Operation(summary = "List all active flats in a society")
    @GetMapping("/society/{societyId}")
    public ResponseEntity<List<Flat>> getFlatsBySociety(@PathVariable String societyId) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(flatService.getFlatsBySociety(societyId));
    }
}
