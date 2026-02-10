import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../data/children_data.dart';

/// Children repository provider
final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  return ChildrenRepository(apiClient: ref.watch(apiClientProvider));
});

/// Children state
class ChildrenState {
  final List<Child> children;
  final bool isLoading;
  final String? error;
  final Child? selectedChild;

  const ChildrenState({
    this.children = const [],
    this.isLoading = false,
    this.error,
    this.selectedChild,
  });

  ChildrenState copyWith({
    List<Child>? children,
    bool? isLoading,
    String? error,
    Child? selectedChild,
  }) {
    return ChildrenState(
      children: children ?? this.children,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedChild: selectedChild ?? this.selectedChild,
    );
  }
}

/// Children state notifier
class ChildrenNotifier extends StateNotifier<ChildrenState> {
  final ChildrenRepository _repository;

  ChildrenNotifier({required ChildrenRepository repository})
      : _repository = repository,
        super(const ChildrenState());

  /// Load all children
  Future<void> loadChildren() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final children = await _repository.listChildren();
      state = state.copyWith(
        children: children,
        isLoading: false,
        selectedChild: children.isNotEmpty ? children.first : null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load children');
    }
  }

  /// Create a new child
  Future<Child?> createChild(CreateChildRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final child = await _repository.createChild(request);
      state = state.copyWith(
        children: [...state.children, child],
        isLoading: false,
        selectedChild: state.selectedChild ?? child,
      );
      return child;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create child');
      return null;
    }
  }

  /// Update a child
  Future<Child?> updateChild(String id, UpdateChildRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final child = await _repository.updateChild(id, request);
      final updatedList = state.children.map((c) {
        return c.id == id ? child : c;
      }).toList();

      state = state.copyWith(
        children: updatedList,
        isLoading: false,
        selectedChild: state.selectedChild?.id == id ? child : state.selectedChild,
      );
      return child;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update child');
      return null;
    }
  }

  /// Delete a child
  Future<bool> deleteChild(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteChild(id);
      final updatedList = state.children.where((c) => c.id != id).toList();
      state = state.copyWith(
        children: updatedList,
        isLoading: false,
        selectedChild: state.selectedChild?.id == id
            ? (updatedList.isNotEmpty ? updatedList.first : null)
            : state.selectedChild,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to delete child');
      return false;
    }
  }

  /// Select a child
  void selectChild(Child child) {
    state = state.copyWith(selectedChild: child);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Children state provider
final childrenProvider =
    StateNotifierProvider<ChildrenNotifier, ChildrenState>((ref) {
  return ChildrenNotifier(repository: ref.watch(childrenRepositoryProvider));
});

/// Selected child provider (convenience)
final selectedChildProvider = Provider<Child?>((ref) {
  return ref.watch(childrenProvider).selectedChild;
});
