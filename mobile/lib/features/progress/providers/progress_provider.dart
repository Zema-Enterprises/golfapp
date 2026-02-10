import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../data/progress_data.dart';

/// Progress repository provider
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(apiClient: ref.watch(apiClientProvider));
});

/// Progress stats provider
final progressStatsProvider = FutureProvider.family<ProgressStats, String>(
  (ref, childId) async {
    final repository = ref.watch(progressRepositoryProvider);
    return repository.getStats(childId);
  },
);

/// Streak info provider
final streakInfoProvider = FutureProvider.family<StreakInfo, String>(
  (ref, childId) async {
    final repository = ref.watch(progressRepositoryProvider);
    return repository.getStreak(childId);
  },
);
