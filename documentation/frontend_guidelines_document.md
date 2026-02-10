# Frontend Guidelines Document

# Junior Golf Playbook - Flutter Frontend Guidelines

This document outlines how we build and organize the Flutter mobile app for Junior Golf Playbook. It covers architecture, design principles, styling, components, state management, routing, performance, testing, and more.

---

## 1. Architecture

### Framework: Flutter + Dart

| Aspect | Choice | Rationale |
|--------|--------|-----------|
| **Framework** | Flutter 3.x | Cross-platform, single codebase, native performance |
| **Language** | Dart (null-safe) | Strong typing, async/await, hot reload |
| **State Management** | Riverpod 2.x | Type-safe, testable, compile-time safety |
| **Navigation** | GoRouter | Declarative routing, deep linking |
| **Local Storage** | Drift (SQLite) | Offline-first, reactive queries |

### Architecture Pattern: Feature-First + Clean Architecture

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp configuration
│
├── /core                        # Shared infrastructure
│   ├── /config                  # Environment, constants
│   │   ├── env.dart
│   │   └── constants.dart
│   ├── /network                 # API client, interceptors
│   │   ├── api_client.dart
│   │   ├── api_interceptors.dart
│   │   └── api_exceptions.dart
│   ├── /database                # Drift database
│   │   ├── app_database.dart
│   │   └── /daos
│   ├── /services                # Cross-cutting services
│   │   ├── sync_service.dart
│   │   └── notification_service.dart
│   └── /utils                   # Helpers, extensions
│
├── /features                    # Feature modules
│   ├── /auth
│   │   ├── /data
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_local_source.dart
│   │   ├── /domain
│   │   │   ├── parent.dart
│   │   │   └── auth_state.dart
│   │   └── /presentation
│   │       ├── /screens
│   │       ├── /widgets
│   │       └── /providers
│   ├── /sessions
│   ├── /drills
│   ├── /avatar
│   ├── /progress
│   └── /settings
│
├── /shared                      # Shared UI
│   ├── /widgets                 # Reusable components
│   ├── /theme                   # Theming
│   └── /providers               # Global providers
│
└── /routing
    └── router.dart              # GoRouter setup
```

### Key Principles

1. **Feature Independence**: Each feature is self-contained
2. **Dependency Flow**: Presentation → Domain → Data
3. **Repository Pattern**: Abstract data sources behind repositories
4. **Provider Scope**: Features expose providers, not internal implementation

---

## 2. Design Principles

### Core Principles

| Principle | Implementation |
|-----------|----------------|
| **Usability** | Simple flows, clear CTAs, minimal steps |
| **Accessibility** | Large tap targets (48px+), high contrast, semantic labels |
| **Responsiveness** | Flexible layouts for phones/tablets |
| **Consistency** | Design tokens, reusable components |
| **Engagement** | Micro-animations, rewarding feedback |

### Kid Mode vs Parent Mode

| Aspect | Kid Mode | Parent Mode |
|--------|----------|-------------|
| **Tap Targets** | 64px minimum | 48px minimum |
| **Typography** | 24px+ body text | 16px body text |
| **Navigation** | Single-action screens | Full navigation |
| **Content** | Visual-first, minimal text | Text + controls |
| **Animations** | Playful, rewarding | Subtle, functional |

---

## 3. Styling & Theming

### Design System

```dart
// lib/shared/theme/app_theme.dart

class AppColors {
  // Brand Colors
  static const primary = Color(0xFF3DA35D);      // Golf Green
  static const secondary = Color(0xFF2A73CC);    // Sky Blue
  static const accent = Color(0xFFFFB400);       // Star Gold
  static const coral = Color(0xFFFF6F61);        // Warm Coral
  
  // Neutrals
  static const surface = Color(0xFFF8F9FA);
  static const background = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  
  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const full = 999.0;
}
```

### Typography

```dart
class AppTypography {
  static const fontFamily = 'Poppins';
  
  // Kid Mode - Larger
  static const kidHeadline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static const kidBody = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  // Parent Mode - Standard
  static const headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}
```

---

## 4. Component Structure

### Widget Organization

```
/shared/widgets
├── /buttons
│   ├── primary_button.dart
│   ├── icon_button.dart
│   └── kid_action_button.dart
├── /cards
│   ├── drill_card.dart
│   ├── child_profile_card.dart
│   └── reward_card.dart
├── /inputs
│   ├── text_field.dart
│   ├── pin_input.dart
│   └── dropdown.dart
├── /feedback
│   ├── loading_indicator.dart
│   ├── error_view.dart
│   └── empty_state.dart
└── /layout
    ├── safe_scaffold.dart
    ├── bottom_sheet.dart
    └── modal.dart
```

### Component Guidelines

1. **Single Responsibility**: One widget, one purpose
2. **Props-Driven**: Configure via parameters, not hardcoded
3. **Composition**: Small widgets composed into larger ones
4. **Stateless First**: Prefer StatelessWidget when possible

### Example Component

```dart
// lib/shared/widgets/buttons/kid_action_button.dart

class KidActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;

  const KidActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 32),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Text(label, style: AppTypography.kidHeadline),
                ],
              ),
      ),
    );
  }
}
```

---

## 5. State Management

### Riverpod Architecture

```dart
// Feature-level providers

// 1. State Notifier for complex state
@riverpod
class SessionController extends _$SessionController {
  @override
  AsyncValue<Session> build(String childId) {
    return const AsyncValue.loading();
  }
  
  Future<void> generateSession() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(sessionRepositoryProvider);
      return repo.generateSession(childId);
    });
  }
  
  Future<void> completeDrill(String drillId, String pin) async {
    // ...
  }
}

// 2. Simple providers for derived state
@riverpod
int totalStars(TotalStarsRef ref, String childId) {
  final progress = ref.watch(progressProvider(childId));
  return progress.value?.totalStars ?? 0;
}

// 3. Repository providers
@riverpod
SessionRepository sessionRepository(SessionRepositoryRef ref) {
  return SessionRepository(
    api: ref.read(apiClientProvider),
    db: ref.read(databaseProvider),
  );
}
```

### State Flow

```
UI Widget (Consumer)
       │
       ▼
   Provider (Riverpod)
       │
       ▼
   Repository
       │
   ┌───┴───┐
   ▼       ▼
Remote   Local
 API     Database
```

---

## 6. Navigation

### GoRouter Setup

```dart
// lib/routing/router.dart

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      
      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      
      // Main shell with bottom nav
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/child/:id',
            builder: (_, state) => ChildDetailScreen(
              childId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/session/:id',
            builder: (_, state) => SessionScreen(
              sessionId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
      
      // Kid Mode (separate navigation)
      GoRoute(
        path: '/kid-mode/:sessionId',
        builder: (_, state) => KidModeScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
    ],
  );
});
```

---

## 7. Performance

### Optimization Strategies

| Strategy | Implementation |
|----------|----------------|
| **Lazy Loading** | Deferred widget loading for heavy screens |
| **Image Caching** | `cached_network_image` package |
| **List Performance** | `ListView.builder` with keys |
| **Animations** | 60fps with `flutter_animate` |
| **Build Efficiency** | `const` constructors, minimal rebuilds |
| **Memory** | Dispose controllers, cancel subscriptions |

### Performance Checklist

- [ ] Use `const` widgets where possible
- [ ] Implement pagination for lists
- [ ] Cache network images
- [ ] Profile with Flutter DevTools
- [ ] Test on low-end devices
- [ ] Measure startup time

---

## 8. Testing

### Testing Pyramid

```
        ╱╲
       ╱  ╲      E2E Tests (integration_test/)
      ╱────╲     - Critical user flows
     ╱      ╲    - 5-10 tests
    ╱────────╲
   ╱          ╲   Widget Tests (test/widgets/)
  ╱────────────╲  - UI components
 ╱              ╲ - 50+ tests
╱────────────────╲
        Unit Tests (test/unit/)
        - Business logic
        - Repositories
        - 100+ tests
```

### Test Structure

```
test/
├── /unit
│   ├── /features
│   │   ├── auth_repository_test.dart
│   │   └── session_controller_test.dart
│   └── /core
│       └── sync_service_test.dart
├── /widgets
│   ├── drill_card_test.dart
│   └── pin_input_test.dart
└── /mocks
    └── mock_providers.dart

integration_test/
├── auth_flow_test.dart
├── session_flow_test.dart
└── offline_sync_test.dart
```

### Testing Tools

| Tool | Purpose |
|------|---------|
| `flutter_test` | Widget and unit tests |
| `integration_test` | E2E testing |
| `mocktail` | Mocking dependencies |
| `flutter_riverpod` | Provider testing utilities |

---

## 9. Code Quality

### Linting & Formatting

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
    require_trailing_commas: true

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
```

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - hooks:
      - id: dart-format
      - id: dart-analyze
      - id: flutter-test
```

---

## 10. Summary

| Aspect | Technology |
|--------|------------|
| **Framework** | Flutter 3.x + Dart |
| **State** | Riverpod 2.x |
| **Navigation** | GoRouter |
| **Database** | Drift (SQLite) |
| **HTTP** | Dio |
| **Testing** | flutter_test + mocktail |
| **Linting** | flutter_lints |

This architecture provides a scalable, testable, and maintainable foundation for the Junior Golf Playbook mobile app.

---

**Document Details**
- **Project ID**: bc0ded31-54a9-4f61-91a5-233ceb4d22e3
- **Last Updated**: 2025-12-16
- **Version**: 2.0 (Flutter rewrite)
