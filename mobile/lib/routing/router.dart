import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/pin_setup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/children/presentation/screens/add_child_screen.dart';
import '../features/sessions/presentation/screens/session_preview_screen.dart';
import '../features/sessions/presentation/screens/kid_ready_screen.dart';
import '../features/sessions/presentation/screens/kid_drill_screen.dart';
import '../features/sessions/presentation/screens/session_complete_screen.dart';
import '../features/sessions/presentation/screens/session_summary_screen.dart';
import '../features/avatar/presentation/screens/avatar_preview_screen.dart';
import '../features/avatar/presentation/screens/avatar_shop_screen.dart';
import '../features/avatar/presentation/screens/avatar_shop_tab_screen.dart';
import '../features/progress/presentation/screens/progress_screen.dart';
import '../features/progress/presentation/screens/progress_tab_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/change_pin_screen.dart';
import '../features/settings/presentation/screens/change_password_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import 'main_shell.dart';

/// Bridges Riverpod auth state to GoRouter's refreshListenable
class _RouterAuthNotifier extends ChangeNotifier {
  _RouterAuthNotifier(this._authState);

  AuthState _authState;

  AuthState get authState => _authState;

  set authState(AuthState value) {
    _authState = value;
    notifyListeners();
  }
}

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _RouterAuthNotifier(ref.read(authProvider));

  ref.listen(authProvider, (_, next) {
    authNotifier.authState = next;
  });

  return GoRouter(
    initialLocation: '/auth/welcome',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.authState;
      final isAuthenticated = authState.isAuthenticated;
      final needsPinSetup = authState.needsPinSetup;
      final location = state.uri.path;
      final isAuthRoute = location.startsWith('/auth');
      final isDevRoute = location.startsWith('/dev');
      final isPinSetupRoute = location == '/auth/pin-setup';

      // Dev routes bypass auth
      if (isDevRoute) return null;

      // If authenticated but needs PIN setup, redirect to PIN setup
      if (isAuthenticated && needsPinSetup && !isPinSetupRoute) {
        return '/auth/pin-setup';
      }

      // If authenticated with PIN and trying to access auth routes, go to home
      if (isAuthenticated && !needsPinSetup && isAuthRoute) {
        return '/';
      }

      // If not authenticated and not on auth route, go to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      return null;
    },
    routes: [
      // Main app shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                name: 'progress-tab',
                builder: (context, state) => const ProgressTabScreen(),
              ),
            ],
          ),

          // Tab 2: Avatar Shop
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/avatar-shop',
                name: 'avatar-shop-tab',
                builder: (context, state) => const AvatarShopTabScreen(),
              ),
            ],
          ),

          // Tab 3: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Auth routes (outside shell - no bottom nav)
      GoRoute(
        path: '/auth/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/pin-setup',
        name: 'pin-setup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Child routes (outside shell - pushed on top)
      GoRoute(
        path: '/child/add',
        name: 'add-child',
        builder: (context, state) => const AddChildScreen(),
      ),

      // Settings sub-routes (outside shell - pushed on top)
      GoRoute(
        path: '/settings/change-pin',
        name: 'change-pin',
        builder: (context, state) => const ChangePinScreen(),
      ),
      GoRoute(
        path: '/settings/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Session routes (outside shell - full screen flow)
      GoRoute(
        path: '/session/preview',
        name: 'session-preview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SessionPreviewScreen(
            childId: extra?['childId'] ?? '',
            duration: extra?['duration'] ?? '15',
          );
        },
      ),

      // Kid mode session flow (outside shell - full screen)
      GoRoute(
        path: '/session/:id/play',
        name: 'session-play',
        builder: (context, state) => KidReadyScreen(
          sessionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/session/:id/drill',
        name: 'session-drill',
        builder: (context, state) => KidDrillScreen(
          sessionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/session/:id/complete',
        name: 'session-complete',
        builder: (context, state) => SessionCompleteScreen(
          sessionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/session/:id/summary',
        name: 'session-summary',
        builder: (context, state) => SessionSummaryScreen(
          sessionId: state.pathParameters['id']!,
        ),
      ),

      // Direct access routes (outside shell - pushed from specific links)
      GoRoute(
        path: '/avatar-shop/:childId',
        name: 'avatar-shop-direct',
        builder: (context, state) => AvatarShopScreen(
          childId: state.pathParameters['childId']!,
        ),
      ),
      GoRoute(
        path: '/progress/:childId',
        name: 'progress-direct',
        builder: (context, state) => ProgressScreen(
          childId: state.pathParameters['childId']!,
        ),
      ),

      // Dev: Avatar preview page
      GoRoute(
        path: '/dev/avatar-preview',
        name: 'avatar-preview',
        builder: (context, state) => const AvatarPreviewScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
