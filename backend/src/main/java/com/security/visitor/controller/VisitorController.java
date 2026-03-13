package com.security.visitor.controller;

import com.security.visitor.model.VisitorEntry;
import com.security.visitor.service.VisitorService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/visitor")
public class VisitorController {

    private final VisitorService visitorService;

    public VisitorController(VisitorService visitorService) {
        this.visitorService = visitorService;
    }

    @PostMapping("/entry")
    public ResponseEntity<String> createEntry(@RequestBody VisitorEntry entry) throws ExecutionException, InterruptedException {
        String id = visitorService.createEntry(entry);
        return ResponseEntity.ok(id);
    }

    @GetMapping("/pending")
    public ResponseEntity<List<VisitorEntry>> getPending(@RequestParam String societyId) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(visitorService.getPendingVisitors(societyId));
    }

    @PostMapping("/exit")
    public ResponseEntity<Void> markExit(@RequestBody Map<String, String> payload) throws ExecutionException, InterruptedException {
        visitorService.markExit(payload.get("visitorId"), payload.get("guardId"));
        return ResponseEntity.ok().build();
    }

    @GetMapping("/history")
    public ResponseEntity<List<VisitorEntry>> getHistory(@RequestParam String societyId) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(visitorService.getVisitorHistory(societyId));
    }
}
