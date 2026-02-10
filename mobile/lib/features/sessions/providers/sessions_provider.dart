import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../data/sessions_data.dart';

/// Sessions repository provider
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepository(apiClient: ref.watch(apiClientProvider));
});

/// Active session state
class ActiveSessionState {
  final Session? session;
  final bool isLoading;
  final String? error;
  final int currentDrillIndex;

  const ActiveSessionState({
    this.session,
    this.isLoading = false,
    this.error,
    this.currentDrillIndex = 0,
  });

  ActiveSessionState copyWith({
    Session? session,
    bool? isLoading,
    String? error,
    int? currentDrillIndex,
  }) {
    return ActiveSessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentDrillIndex: currentDrillIndex ?? this.currentDrillIndex,
    );
  }

  SessionDrill? get currentDrill {
    if (session == null) return null;
    if (currentDrillIndex >= session!.drills.length) return null;
    return session!.drills[currentDrillIndex];
  }

  bool get isComplete => session?.status == SessionStatus.completed;
  bool get hasMoreDrills =>
      session != null && currentDrillIndex < session!.drills.length;
}

/// Active session notifier
class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  final SessionsRepository _repository;

  ActiveSessionNotifier({required SessionsRepository repository})
      : _repository = repository,
        super(const ActiveSessionState());

  /// Generate a new session
  Future<bool> generateSession({
    required String childId,
    String durationMinutes = '15',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final session = await _repository.generateSession(
        GenerateSessionRequest(
          childId: childId,
          durationMinutes: durationMinutes,
        ),
      );
      state = state.copyWith(
        session: session,
        isLoading: false,
        currentDrillIndex: 0,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to generate session');
      return false;
    }
  }

  /// Load existing session
  Future<void> loadSession(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final session = await _repository.getSession(sessionId);

      // Find current drill index (first incomplete)
      int currentIndex = 0;
      for (int i = 0; i < session.drills.length; i++) {
        if (!session.drills[i].isCompleted) {
          currentIndex = i;
          break;
        }
      }

      state = state.copyWith(
        session: session,
        isLoading: false,
        currentDrillIndex: currentIndex,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load session');
    }
  }

  /// Complete current drill
  Future<bool> completeDrill() async {
    if (state.session == null || state.currentDrill == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.completeDrill(
        sessionId: state.session!.id,
        drillId: state.currentDrill!.id,
      );

      // Reload session to get updated state
      final session = await _repository.getSession(state.session!.id);

      final nextIndex = state.currentDrillIndex + 1;
      state = state.copyWith(
        session: session,
        isLoading: false,
        currentDrillIndex: nextIndex < session.drills.length ? nextIndex : state.currentDrillIndex,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to complete drill');
      return false;
    }
  }

  /// Complete entire session
  Future<bool> completeSession() async {
    if (state.session == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final session = await _repository.completeSession(state.session!.id);
      state = state.copyWith(
        session: session,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to complete session');
      return false;
    }
  }

  /// Clear active session
  void clearSession() {
    state = const ActiveSessionState();
  }

  /// Move to next drill
  void nextDrill() {
    if (state.session != null &&
        state.currentDrillIndex < state.session!.drills.length - 1) {
      state = state.copyWith(currentDrillIndex: state.currentDrillIndex + 1);
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Active session provider
final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState>((ref) {
  return ActiveSessionNotifier(
    repository: ref.watch(sessionsRepositoryProvider),
  );
});

/// Session history provider
final sessionHistoryProvider = FutureProvider.family<SessionsResponse, String>(
  (ref, childId) async {
    final repository = ref.watch(sessionsRepositoryProvider);
    return repository.listSessions(childId: childId);
  },
);

/// In-progress session provider
final inProgressSessionProvider = FutureProvider.family<Session?, String>(
  (ref, childId) async {
    final repository = ref.watch(sessionsRepositoryProvider);
    return repository.getInProgressSession(childId);
  },
);
