import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';

enum UserRole { superAdmin, societySecretary, guest }

final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.guest);

// --- Society / Flat ---
final societyIdProvider = StateProvider<String>((ref) => '');

final allSocietiesProvider = FutureProvider<List<Society>>((ref) async {
  final data = await ApiService.get('/api/admin/society') as List;
  return data.map((e) => Society.fromJson(e)).toList();
});

final flatsBySocietyProvider = FutureProvider.family<List<Flat>, String>((ref, societyId) async {
  if (societyId.isEmpty) return [];
  final data = await ApiService.get('/api/admin/flat/society/$societyId') as List;
  return data.map((e) => Flat.fromJson(e)).toList();
});

// --- Visitors ---
final visitorHistoryProvider = FutureProvider.family<List<VisitorEntry>, String>((ref, societyId) async {
  if (societyId.isEmpty) return [];
  final data = await ApiService.get('/api/admin/all-visitors', params: {'societyId': societyId}) as List;
  return data.map((e) => VisitorEntry.fromJson(e)).toList();
});

final pendingVisitorsProvider = FutureProvider.family<List<VisitorEntry>, String>((ref, societyId) async {
  if (societyId.isEmpty) return [];
  final data = await ApiService.get('/api/visitor/pending', params: {'societyId': societyId}) as List;
  return data.map((e) => VisitorEntry.fromJson(e)).toList();
});

// --- Attendance ---
final guardAttendanceProvider = FutureProvider.family<List<GuardAttendance>, String>((ref, societyId) async {
  if (societyId.isEmpty) return [];
  final data = await ApiService.get('/api/admin/attendance', params: {'societyId': societyId}) as List;
  return data.map((e) => GuardAttendance.fromJson(e)).toList();
});

// --- Status Filter ---
final statusFilterProvider = StateProvider<String>((ref) => 'ALL');
final searchQueryProvider = StateProvider<String>((ref) => '');
