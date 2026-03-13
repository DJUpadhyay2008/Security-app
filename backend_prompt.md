
# Visitor Management Backend (Spring Boot)

## Role
You are a senior Java Spring Boot backend architect.

## Goal
Build a scalable, multitenant backend for a QR-based Visitor Management System for residential societies.

## Tech Stack
- Java Spring Boot
- Firebase Firestore
- Firebase Authentication
- Google Cloud Run

## Core Requirement
The backend must support multiple societies (multitenant). Every record must include `societyId` and queries must always filter by `societyId`.

## Main Features

### Visitor Entry System
Visitors scan a QR code containing `societyId` and `flatId` and submit a form:

- visitorName  
- phoneNumber  
- purpose  
- vehicleNumber (optional)  
- photo (optional)  
- flatId  
- societyId  
- timestamp  

System checks resident preference:

- AUTO_ALLOW
- CALL_BEFORE_ENTRY
- DENY_UNKNOWN_VISITORS

### Exit System
Only guards can mark visitor exit.

Store:

- exitTime
- guardId

### Guard Attendance

Guards check-in and check-out:

- guardId
- societyId
- checkInTime
- checkOutTime

### Guard Roster

Admin assigns shifts:

- guardId
- societyId
- shiftStart
- shiftEnd
- date

## Firestore Collections

- societies
- flats
- residents
- guards
- visitor_entries
- guard_attendance
- guard_roster

## Required APIs

### Visitor APIs

POST /api/visitor/entry  
GET /api/visitor/pending  
POST /api/visitor/exit  
GET /api/visitor/history  

### Guard APIs

POST /api/guard/checkin  
POST /api/guard/checkout  
GET /api/guard/attendance  

### Resident APIs

GET /api/resident/visitors  
PUT /api/resident/preference  

### Admin APIs

GET /api/admin/all-visitors  
GET /api/admin/attendance  
POST /api/admin/assign-roster  

## Project Structure

```
src
 ├ controller
 ├ service
 ├ repository
 ├ model
 ├ dto
 ├ config
 ├ security
```

## Generate

- Complete Spring Boot project
- REST APIs
- Firestore integration
- QR code generation service
- Multitenant filtering
