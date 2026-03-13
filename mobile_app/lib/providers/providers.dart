import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../core/api.dart';

enum UserRole { guard, resident, none }

final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.none);
final userIdProvider = StateProvider<String>((ref) => '');
final societyIdProvider = StateProvider<String>((ref) => 'test'); // Mock society ID for demo

final pendingVisitorsProvider = FutureProvider<List<VisitorEntry>>((ref) async {
  final societyId = ref.watch(societyIdProvider);
  if (societyId.isEmpty) return [];
  
  final data = await ApiService.get('/api/visitor/pending', params: {'societyId': societyId}) as List;
  return data.map((e) => VisitorEntry.fromJson(e)).toList();
});

final allVisitorsProvider = FutureProvider<List<VisitorEntry>>((ref) async {
  final societyId = ref.watch(societyIdProvider);
  if (societyId.isEmpty) return [];
  
  final data = await ApiService.get('/api/admin/all-visitors', params: {'societyId': societyId}) as List;
  return data.map((e) => VisitorEntry.fromJson(e)).toList();
});
