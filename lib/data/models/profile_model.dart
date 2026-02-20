import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';

/// Represents a user profile - each profile has its own vehicles, maintenance, etc.
@Entity(tableName: 'profiles')
class Profile {
  @PrimaryKey()
  final String id;

  final String name;
  final String? avatarPath;
  final int createdAt;
  final int updatedAt;

  Profile({
    required this.id,
    required this.name,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.create({
    required String name,
    String? avatarPath,
  }) {
    final now = DateTime.now();
    return Profile(
      id: const Uuid().v4(),
      name: name,
      avatarPath: avatarPath,
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );
  }

  Profile copyWith({
    String? name,
    String? avatarPath,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  String? validate() {
    if (name.trim().isEmpty) return 'Name is required';
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Profile && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
