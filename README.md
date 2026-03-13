# Visitor Management System (VMS)

A comprehensive Visitor Management Solution with a Spring Boot backend, a Flutter Web administration dashboard, and a Flutter Mobile application for Guards and Residents.

## Project Structure

- `/backend`: Spring Boot application (Java 17) using Firebase Admin SDK.
- `/lib`: Flutter Web application for Super Admins and Society Secretaries.
- `/mobile_app`: Flutter Mobile application for Security Guards and Residents.
- `/.github/workflows`: CI/CD pipeline for automatic Mobile App builds.

## Features

- **Multi-Role Access**: Super Admin, Society Secretary, Guard, and Resident.
- **QR Code Integration**: Generate society-level QR codes for visitor check-ins.
- **Real-time Monitoring**: Track visitor entry/exit and guard attendance.
- **Resident Preferences**: Residents can set visitor rules (Auto-Allow, Call Before, Deny).
- **CI/CD**: Automatic APK and App Bundle generation via GitHub Actions.

## Setup Instructions

### Backend
1. Navigate to `/backend`.
2. Place your Firebase `serviceAccountKey.json` in `src/main/resources/`.
3. Configure `application.properties` with your database URL.
4. Run with `mvn spring-boot:run`.

### Admin Dashboard (Web)
1. Run `flutter pub get`.
2. Run `flutter run -d chrome --web-port 3000`.

### Mobile App (Guard/Resident)
1. Navigate to `/mobile_app`.
2. Run `flutter pub get`.
3. Build locally with `flutter build apk` or push to GitHub to trigger the Actions workflow.

## Security Note

**DO NOT** commit your `serviceAccountKey.json` or any private keys to the repository. These are already added to `.gitignore`.
