import '../../../core/api/api_client.dart';
import 'session.dart';

/// Sessions repository for API calls
class SessionsRepository {
  final ApiClient _apiClient;

  SessionsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Generate a new practice session
  Future<Session> generateSession(GenerateSessionRequest request) async {
    final response = await _apiClient.post(
      '/sessions',
      data: request.toJson(),
    );
    return Session.fromJson(response.data['data']['session']);
  }

  /// List sessions with optional filters
  Future<SessionsResponse> listSessions({
    String? childId,
    SessionStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (childId != null) {
      queryParams['childId'] = childId;
    }
    if (status != null) {
      queryParams['status'] = status.name.toUpperCase();
    }

    final response = await _apiClient.get(
      '/sessions',
      queryParameters: queryParams,
    );

    final data = response.data['data'];
    final sessionsList = (data['sessions'] as List)
        .map((json) => Session.fromJson(json))
        .toList();

    return SessionsResponse(
      sessions: sessionsList,
      total: data['total'] ?? sessionsList.length,
      limit: data['limit'] ?? limit,
      offset: data['offset'] ?? offset,
    );
  }

  /// Get a single session by ID
  Future<Session> getSession(String id) async {
    final response = await _apiClient.get('/sessions/$id');
    return Session.fromJson(response.data['data']['session']);
  }

  /// Complete a drill in session (returns updated session)
  Future<Session> completeDrill({
    required String sessionId,
    required String drillId,
    int starsEarned = 2,
  }) async {
    final response = await _apiClient.patch(
      '/sessions/$sessionId/drills/$drillId',
      data: {'starsEarned': starsEarned},
    );
    return Session.fromJson(response.data['data']['session']);
  }

  /// Complete entire session
  Future<Session> completeSession(String id) async {
    final response = await _apiClient.post(
      '/sessions/$id/complete',
      data: {},
    );
    return Session.fromJson(response.data['data']['session']);
  }

  /// Get in-progress session for child (if any)
  Future<Session?> getInProgressSession(String childId) async {
    final response = await listSessions(
      childId: childId,
      status: SessionStatus.inProgress,
      limit: 1,
    );
    return response.sessions.isNotEmpty ? response.sessions.first : null;
  }
}
