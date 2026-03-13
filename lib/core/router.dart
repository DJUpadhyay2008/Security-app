import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/dashboard_shell.dart';
import '../pages/visitors_page.dart';
import '../pages/flats_page.dart';
import '../pages/guards_page.dart';
import '../pages/attendance_page.dart';
import '../pages/roster_page.dart';
import '../pages/analytics_page.dart';
import '../pages/residents_page.dart';
import '../pages/societies_page.dart';
import '../pages/login_page.dart';
import '../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final role = ref.read(userRoleProvider);
      final isLogin = state.uri.toString() == '/login';
      if (role == UserRole.guest && !isLogin) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(path: '/societies', builder: (c, s) => const SocietiesPage()),
          GoRoute(path: '/visitors', builder: (c, s) => const VisitorsPage()),
          GoRoute(path: '/residents', builder: (c, s) => const ResidentsPage()),
          GoRoute(path: '/flats', builder: (c, s) => const FlatsPage()),
          GoRoute(path: '/guards', builder: (c, s) => const GuardsPage()),
          GoRoute(path: '/attendance', builder: (c, s) => const AttendancePage()),
          GoRoute(path: '/roster', builder: (c, s) => const RosterPage()),
          GoRoute(path: '/analytics', builder: (c, s) => const AnalyticsPage()),
        ],
      ),
    ],
  );
});
