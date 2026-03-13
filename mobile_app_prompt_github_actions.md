
# Visitor Management Mobile App (Flutter)

## Role
You are a senior Flutter mobile developer and DevOps engineer.

## Goal
Build a Flutter mobile application for Residents and Security Guards for a QR Visitor Management System.

The project must be designed so that the **entire build, testing, and release process runs using GitHub Actions CI/CD**.
The developer should NOT need to build the application locally.

All builds must be triggered automatically through GitHub Actions.

---

# Tech Stack

- Flutter
- Riverpod (state management)
- Firebase Authentication
- REST APIs from Spring Boot backend
- GitHub Actions for CI/CD
- Android build via GitHub Actions
- iOS build via GitHub Actions

---

# CI/CD REQUIREMENT (IMPORTANT)

The project must include a **complete GitHub Actions pipeline** that:

1. Installs Flutter
2. Fetches dependencies
3. Runs lint checks
4. Runs tests
5. Builds Android APK
6. Builds Android App Bundle
7. Builds iOS artifact (if configured)
8. Uploads artifacts

The build must run automatically on:

- push
- pull_request

The workflow must be located at:

.github/workflows/flutter-build.yml

Example steps:

- Checkout repository
- Setup Flutter
- Cache pub dependencies
- Run `flutter pub get`
- Run `flutter analyze`
- Run `flutter test`
- Build APK
- Upload artifact

---

# User Roles

## Security Guard

Features:

- Dashboard
- View visitor requests
- Approve entry
- Create visitor entry manually
- Mark visitor exit
- Guard attendance check-in/check-out
- View shift roster

UI must be **extremely simple** because guards may not be tech savvy.

Use:

- large buttons
- minimal text
- fast navigation

---

## Resident

Residents must be able to:

- View visitor logs
- Approve visitor requests
- Set visitor preferences

Visitor Preference Options:

- AUTO_ALLOW
- CALL_BEFORE_ENTRY
- DENY_UNKNOWN_VISITORS

---

# Visitor Entry Flow

Visitor scans QR code outside society gate.

A web page opens and visitor submits:

- visitorName
- phone
- purpose
- vehicleNumber
- flatId
- societyId

The request is sent to backend API.

Guards see the request in the mobile app.

---

# UI Requirements

The UI must be:

- extremely simple
- optimized for fast usage
- large tap targets
- minimal screens

---

# Project Structure

lib
 ├ core
 ├ models
 ├ services
 ├ providers
 ├ screens
 ├ widgets

---

# Generate

The repository must include:

1. Complete Flutter project
2. Riverpod state management
3. API service layer
4. Guard dashboard
5. Resident dashboard
6. GitHub Actions CI/CD workflow
7. Automatic Android build pipeline
8. Artifact upload

Do NOT assume the developer will run builds locally.

All builds must be runnable via **GitHub Actions only**.
