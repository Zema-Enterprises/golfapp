import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../data/settings_data.dart';

/// Settings repository provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(apiClient: ref.watch(apiClientProvider));
});

/// Settings state
class SettingsState {
  final UserSettings? settings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.settings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    UserSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Settings notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsState());

  /// Load settings
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.getSettings();
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load settings');
    }
  }

  /// Update notifications
  Future<bool> updateNotifications({
    required bool enabled,
    String? reminderTime,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.updateNotifications(
        enabled: enabled,
        reminderTime: reminderTime,
      );
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update settings');
      return false;
    }
  }

  /// Update sound
  Future<bool> updateSound({required bool enabled}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.updateSound(enabled: enabled);
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update settings');
      return false;
    }
  }

  /// Update theme
  Future<bool> updateTheme(AppTheme theme) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.updateTheme(theme);
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update settings');
      return false;
    }
  }

  /// Update language
  Future<bool> updateLanguage(AppLanguage language) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.updateLanguage(language);
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update settings');
      return false;
    }
  }

  /// Update streak goal
  Future<bool> updateStreakGoal(String goal) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.updateStreakGoal(goal);
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update settings');
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Settings provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(repository: ref.watch(settingsRepositoryProvider));
});
