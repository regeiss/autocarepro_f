import 'package:floor/floor.dart';
import '../../../data/models/profile_model.dart';

/// Data Access Object for Profile operations
@dao
abstract class ProfileDao {
  @Query('SELECT * FROM profiles ORDER BY name ASC')
  Future<List<Profile>> getAllProfiles();

  @Query('SELECT * FROM profiles ORDER BY name ASC')
  Stream<List<Profile>> watchAllProfiles();

  @Query('SELECT * FROM profiles WHERE id = :id')
  Future<Profile?> getProfileById(String id);

  @Query('SELECT * FROM profiles WHERE id = :id')
  Stream<Profile?> watchProfileById(String id);

  @Query('SELECT COUNT(*) FROM profiles')
  Future<int?> getProfileCount();

  @insert
  Future<void> insertProfile(Profile profile);

  @update
  Future<void> updateProfile(Profile profile);

  @delete
  Future<void> deleteProfile(Profile profile);

  @Query('DELETE FROM profiles WHERE id = :id')
  Future<void> deleteProfileById(String id);
}
