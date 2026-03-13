package com.security.visitor.controller;

import com.google.zxing.WriterException;
import com.security.visitor.service.QRCodeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@RequestMapping("/api/utils")
public class QRCodeController {

    private final QRCodeService qrCodeService;

    public QRCodeController(QRCodeService qrCodeService) {
        this.qrCodeService = qrCodeService;
    }

    @GetMapping("/generate-qr")
    public ResponseEntity<String> generateQRCode(@RequestParam String societyId) {
        try {
            String qrBase64 = qrCodeService.generateSocietyQRCode(societyId);
            return ResponseEntity.ok(qrBase64);
        } catch (WriterException | IOException e) {
            return ResponseEntity.status(500).body("Error generating QR code: " + e.getMessage());
        }
    }
}
