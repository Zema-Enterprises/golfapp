import '../../../core/api/api_client.dart';
import 'child.dart';

/// Children repository for API calls
class ChildrenRepository {
  final ApiClient _apiClient;

  ChildrenRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Create a new child
  Future<Child> createChild(CreateChildRequest request) async {
    final response = await _apiClient.post(
      '/children',
      data: request.toJson(),
    );
    return Child.fromJson(response.data['data']['child']);
  }

  /// Get all children for current parent
  Future<List<Child>> listChildren() async {
    final response = await _apiClient.get('/children');
    final list = response.data['data']['children'] as List;
    return list.map((json) => Child.fromJson(json)).toList();
  }

  /// Get a single child by ID
  Future<Child> getChild(String id) async {
    final response = await _apiClient.get('/children/$id');
    return Child.fromJson(response.data['data']['child']);
  }

  /// Update a child
  Future<Child> updateChild(String id, UpdateChildRequest request) async {
    final response = await _apiClient.patch(
      '/children/$id',
      data: request.toJson(),
    );
    return Child.fromJson(response.data['data']['child']);
  }

  /// Delete a child
  Future<void> deleteChild(String id) async {
    await _apiClient.delete('/children/$id');
  }
}
