import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import 'repository_providers.dart';

const _currentProfileIdKey = 'current_profile_id';

/// Current profile ID (persisted)
final currentProfileIdProvider =
    StateNotifierProvider<CurrentProfileIdNotifier, AsyncValue<String?>>((ref) {
  return CurrentProfileIdNotifier(ref);
});

class CurrentProfileIdNotifier extends StateNotifier<AsyncValue<String?>> {
  CurrentProfileIdNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref _ref;

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_currentProfileIdKey);
      final repo = _ref.read(profileRepositoryProvider);
      final profile = await repo.ensureDefaultProfile();
      state = AsyncValue.data(id ?? profile.id);
      if (id == null) {
        await setCurrentProfileId(profile.id);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setCurrentProfileId(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentProfileIdKey, profileId);
    state = AsyncValue.data(profileId);
  }
}

/// Current profile (resolved from ID)
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final profileId = ref.watch(currentProfileIdProvider);
  return profileId.when(
    data: (id) async {
      if (id == null) return null;
      final repo = ref.read(profileRepositoryProvider);
      return repo.getProfileById(id);
    },
    loading: () async => null,
    error: (_, __) => null,
  );
});

/// All profiles stream
final profilesStreamProvider = StreamProvider<List<Profile>>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.watchAllProfiles();
});
