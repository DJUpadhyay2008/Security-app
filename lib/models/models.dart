class VisitorEntry {
  final String? id;
  final String visitorName;
  final String phoneNumber;
  final String purpose;
  final String? vehicleNumber;
  final String flatId;
  final String societyId;
  final int entryTimestamp;
  final int? exitTimestamp;
  final String status;
  final String? guardId;

  const VisitorEntry({
    this.id,
    required this.visitorName,
    required this.phoneNumber,
    required this.purpose,
    this.vehicleNumber,
    required this.flatId,
    required this.societyId,
    required this.entryTimestamp,
    this.exitTimestamp,
    required this.status,
    this.guardId,
  });

  factory VisitorEntry.fromJson(Map<String, dynamic> j) => VisitorEntry(
        id: j['id'],
        visitorName: j['visitorName'] ?? '',
        phoneNumber: j['phoneNumber'] ?? '',
        purpose: j['purpose'] ?? '',
        vehicleNumber: j['vehicleNumber'],
        flatId: j['flatId'] ?? '',
        societyId: j['societyId'] ?? '',
        entryTimestamp: (j['entryTimestamp'] ?? 0).toInt(),
        exitTimestamp: j['exitTimestamp'] != null ? (j['exitTimestamp'] as num).toInt() : null,
        status: j['status'] ?? 'PENDING',
        guardId: j['guardId'],
      );
}

class Society {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final bool active;

  const Society({required this.id, required this.name, this.address, this.city, this.active = true});

  factory Society.fromJson(Map<String, dynamic> j) => Society(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        address: j['address'],
        city: j['city'],
        active: j['active'] ?? true,
      );
}

class Flat {
  final String id;
  final String flatNumber;
  final String? wing;
  final String societyId;
  final String? ownerName;
  final bool active;

  const Flat({
    required this.id,
    required this.flatNumber,
    this.wing,
    required this.societyId,
    this.ownerName,
    this.active = true,
  });

  factory Flat.fromJson(Map<String, dynamic> j) => Flat(
        id: j['id'] ?? '',
        flatNumber: j['flatNumber'] ?? '',
        wing: j['wing'],
        societyId: j['societyId'] ?? '',
        ownerName: j['ownerName'],
        active: j['active'] ?? true,
      );
}

class GuardAttendance {
  final String? id;
  final String guardId;
  final String societyId;
  final int checkInTime;
  final int? checkOutTime;

  const GuardAttendance({
    this.id,
    required this.guardId,
    required this.societyId,
    required this.checkInTime,
    this.checkOutTime,
  });

  factory GuardAttendance.fromJson(Map<String, dynamic> j) => GuardAttendance(
        id: j['id'],
        guardId: j['guardId'] ?? '',
        societyId: j['societyId'] ?? '',
        checkInTime: (j['checkInTime'] ?? 0).toInt(),
        checkOutTime: j['checkOutTime'] != null ? (j['checkOutTime'] as num).toInt() : null,
      );
}

class GuardRoster {
  final String? id;
  final String guardId;
  final String societyId;
  final String shiftStart;
  final String shiftEnd;
  final String date;

  const GuardRoster({
    this.id,
    required this.guardId,
    required this.societyId,
    required this.shiftStart,
    required this.shiftEnd,
    required this.date,
  });

  factory GuardRoster.fromJson(Map<String, dynamic> j) => GuardRoster(
        id: j['id'],
        guardId: j['guardId'] ?? '',
        societyId: j['societyId'] ?? '',
        shiftStart: j['shiftStart'] ?? '',
        shiftEnd: j['shiftEnd'] ?? '',
        date: j['date'] ?? '',
      );
}
