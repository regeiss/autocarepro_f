import '../models/profile_model.dart';
import '../../services/local_database/app_database.dart';
import 'vehicle_repository.dart';

/// Repository for profile data operations
class ProfileRepository {
  final AppDatabase _database;

  ProfileRepository(this._database);

  Future<List<Profile>> getAllProfiles() async {
    try {
      return await _database.profileDao.getAllProfiles();
    } catch (e) {
      throw RepositoryException('Failed to get profiles: $e');
    }
  }

  Stream<List<Profile>> watchAllProfiles() {
    return _database.profileDao.watchAllProfiles();
  }

  Future<Profile?> getProfileById(String id) async {
    try {
      return await _database.profileDao.getProfileById(id);
    } catch (e) {
      throw RepositoryException('Failed to get profile: $e');
    }
  }

  Future<void> addProfile(Profile profile) async {
    try {
      final error = profile.validate();
      if (error != null) throw RepositoryException('Invalid profile: $error');
      await _database.profileDao.insertProfile(profile);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add profile: $e');
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      final error = profile.validate();
      if (error != null) throw RepositoryException('Invalid profile: $error');
      await _database.profileDao.updateProfile(profile);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to update profile: $e');
    }
  }

  Future<void> deleteProfile(Profile profile) async {
    try {
      await _database.serviceProviderDao.deleteByProfileId(profile.id);
      await _database.profileDao.deleteProfile(profile);
    } catch (e) {
      throw RepositoryException('Failed to delete profile: $e');
    }
  }

  Future<int> getProfileCount() async {
    return await _database.profileDao.getProfileCount() ?? 0;
  }

  /// Ensure at least one profile exists; create default if empty
  Future<Profile> ensureDefaultProfile() async {
    final profiles = await getAllProfiles();
    if (profiles.isNotEmpty) return profiles.first;
    final defaultProfile = Profile.create(name: 'Default');
    await addProfile(defaultProfile);
    return defaultProfile;
  }
}
