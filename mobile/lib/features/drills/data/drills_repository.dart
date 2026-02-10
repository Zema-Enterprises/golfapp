import '../../../core/api/api_client.dart';
import '../../children/data/child.dart';
import 'drill.dart';

/// Drills repository for API calls
class DrillsRepository {
  final ApiClient _apiClient;

  DrillsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// List drills with optional filters
  Future<DrillsResponse> listDrills({
    AgeBand? ageBand,
    String? skillCategory,
    bool? isPremium,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (ageBand != null) {
      queryParams['ageBand'] = ageBand.name.toUpperCase();
    }
    if (skillCategory != null) {
      queryParams['skillCategory'] = skillCategory;
    }
    if (isPremium != null) {
      queryParams['isPremium'] = isPremium;
    }

    final response = await _apiClient.get(
      '/drills',
      queryParameters: queryParams,
    );

    final data = response.data['data'];
    final drillsList = (data['drills'] as List)
        .map((json) => Drill.fromJson(json))
        .toList();

    return DrillsResponse(
      drills: drillsList,
      total: data['total'] ?? drillsList.length,
      limit: data['limit'] ?? limit,
      offset: data['offset'] ?? offset,
    );
  }

  /// Get a single drill by ID
  Future<Drill> getDrill(String id) async {
    final response = await _apiClient.get('/drills/$id');
    return Drill.fromJson(response.data['data']);
  }

  /// Get skill categories with drill counts
  Future<List<SkillCategory>> getCategories({AgeBand? ageBand}) async {
    final queryParams = <String, dynamic>{};
    if (ageBand != null) {
      queryParams['ageBand'] = ageBand.name.toUpperCase();
    }

    final response = await _apiClient.get(
      '/drills/categories',
      queryParameters: queryParams,
    );

    final list = response.data['data'] as List;
    return list.map((json) => SkillCategory.fromJson(json)).toList();
  }
}
