package com.security.visitor.controller;

import com.security.visitor.model.GuardAttendance;
import com.security.visitor.model.GuardRoster;
import com.security.visitor.model.VisitorEntry;
import com.security.visitor.service.GuardService;
import com.security.visitor.service.VisitorService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final VisitorService visitorService;
    private final GuardService guardService;

    public AdminController(VisitorService visitorService, GuardService guardService) {
        this.visitorService = visitorService;
        this.guardService = guardService;
    }

    @GetMapping("/all-visitors")
    public ResponseEntity<List<VisitorEntry>> getAllVisitors(@RequestParam String societyId) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(visitorService.getVisitorHistory(societyId));
    }

    @GetMapping("/attendance")
    public ResponseEntity<List<GuardAttendance>> getAttendance(@RequestParam String societyId) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(guardService.getAttendance(societyId));
    }

    @PostMapping("/assign-roster")
    public ResponseEntity<String> assignRoster(@RequestBody GuardRoster roster) throws ExecutionException, InterruptedException {
        String id = guardService.assignRoster(roster);
        return ResponseEntity.ok(id);
    }
}
