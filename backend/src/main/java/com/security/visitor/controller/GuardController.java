package com.security.visitor.controller;

import com.security.visitor.model.GuardAttendance;
import com.security.visitor.service.GuardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/guard")
public class GuardController {

    private final GuardService guardService;

    public GuardController(GuardService guardService) {
        this.guardService = guardService;
    }

    @PostMapping("/checkin")
    public ResponseEntity<String> checkIn(@RequestBody Map<String, String> payload) throws ExecutionException, InterruptedException {
        String id = guardService.checkIn(payload.get("guardId"), payload.get("societyId"));
        return ResponseEntity.ok(id);
    }

    @PostMapping("/checkout")
    public ResponseEntity<Void> checkOut(@RequestBody Map<String, String> payload) throws ExecutionException, InterruptedException {
        guardService.checkOut(payload.get("attendanceId"));
        return ResponseEntity.ok().build();
    }

    @GetMapping("/attendance")
    public ResponseEntity<List<GuardAttendance>> getAttendance(@RequestParam String societyId) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok(guardService.getAttendance(societyId));
    }
}
