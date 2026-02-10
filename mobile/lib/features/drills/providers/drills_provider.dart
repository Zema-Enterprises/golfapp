import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../children/data/child.dart';
import '../data/drills_data.dart';

/// Drills repository provider
final drillsRepositoryProvider = Provider<DrillsRepository>((ref) {
  return DrillsRepository(apiClient: ref.watch(apiClientProvider));
});

/// Drills list provider
final drillsProvider = FutureProvider.family<DrillsResponse, AgeBand?>(
  (ref, ageBand) async {
    final repository = ref.watch(drillsRepositoryProvider);
    return repository.listDrills(ageBand: ageBand);
  },
);

/// Single drill provider
final drillProvider = FutureProvider.family<Drill, String>(
  (ref, id) async {
    final repository = ref.watch(drillsRepositoryProvider);
    return repository.getDrill(id);
  },
);

/// Skill categories provider
final skillCategoriesProvider = FutureProvider.family<List<SkillCategory>, AgeBand?>(
  (ref, ageBand) async {
    final repository = ref.watch(drillsRepositoryProvider);
    return repository.getCategories(ageBand: ageBand);
  },
);
