class VisitorEntry {
  final String? id;
  final String visitorName;
  final String phoneNumber;
  final String purpose;
  final String vehicleNumber;
  final String flatId;
  final String societyId;
  final int entryTimestamp;
  final int? exitTimestamp;
  final String status;
  final String? guardId;

  VisitorEntry({
    this.id,
    required this.visitorName,
    required this.phoneNumber,
    required this.purpose,
    required this.vehicleNumber,
    required this.flatId,
    required this.societyId,
    required this.entryTimestamp,
    this.exitTimestamp,
    required this.status,
    this.guardId,
  });

  factory VisitorEntry.fromJson(Map<String, dynamic> json) {
    return VisitorEntry(
      id: json['id'],
      visitorName: json['visitorName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      purpose: json['purpose'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      flatId: json['flatId'] ?? '',
      societyId: json['societyId'] ?? '',
      entryTimestamp: json['entryTimestamp'] ?? 0,
      exitTimestamp: json['exitTimestamp'],
      status: json['status'] ?? 'PENDING',
      guardId: json['guardId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'visitorName': visitorName,
    'phoneNumber': phoneNumber,
    'purpose': purpose,
    'vehicleNumber': vehicleNumber,
    'flatId': flatId,
    'societyId': societyId,
    'entryTimestamp': entryTimestamp,
    'exitTimestamp': exitTimestamp,
    'status': status,
    'guardId': guardId,
  };
}

class ResidentPreference {
  final String? id;
  final String residentId;
  final String visitorType;
  final String preferenceOverride; // AUTO_ALLOW, CALL_BEFORE_ENTRY, DENY_UNKNOWN_VISITORS

  ResidentPreference({
    this.id,
    required this.residentId,
    required this.visitorType,
    required this.preferenceOverride,
  });

  factory ResidentPreference.fromJson(Map<String, dynamic> json) {
    return ResidentPreference(
      id: json['id'],
      residentId: json['residentId'] ?? '',
      visitorType: json['visitorType'] ?? '',
      preferenceOverride: json['preferenceOverride'] ?? 'CALL_BEFORE_ENTRY',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'residentId': residentId,
    'visitorType': visitorType,
    'preferenceOverride': preferenceOverride,
  };
}
