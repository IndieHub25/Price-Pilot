import 'package:flutter_test/flutter_test.dart';
import 'package:price_pilot/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final now = DateTime(2026, 2, 10, 12, 0, 0);

    final sampleJson = {
      'id': 'user_001',
      'name': 'Mantej Singh',
      'email': 'mantej@example.com',
      'phone': '+919876543210',
      'avatar_url': 'https://example.com/avatar.png',
      'saved_locations': <dynamic>[],
      'created_at': now.toIso8601String(),
    };

    test('fromJson creates a valid model', () {
      final user = UserModel.fromJson(sampleJson);

      expect(user.id, 'user_001');
      expect(user.name, 'Mantej Singh');
      expect(user.email, 'mantej@example.com');
      expect(user.phone, '+919876543210');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
      expect(user.savedLocations, isEmpty);
      expect(user.createdAt, now);
    });

    test('toJson produces correct map', () {
      final user = UserModel.fromJson(sampleJson);
      final json = user.toJson();

      expect(json['id'], 'user_001');
      expect(json['name'], 'Mantej Singh');
      expect(json['email'], 'mantej@example.com');
      expect(json['phone'], '+919876543210');
      expect(json['avatar_url'], 'https://example.com/avatar.png');
    });

    test('JSON round-trip preserves data', () {
      final original = UserModel.fromJson(sampleJson);
      final restored = UserModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.phone, original.phone);
    });

    test('fromJson handles null optional fields', () {
      final minimalJson = {
        'id': 'user_002',
        'name': 'Test',
        'email': 'test@test.com',
        'created_at': now.toIso8601String(),
      };

      final user = UserModel.fromJson(minimalJson);

      expect(user.phone, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.savedLocations, isEmpty);
    });

    test('copyWith creates a copy with overridden values', () {
      final user = UserModel.fromJson(sampleJson);
      final updated = user.copyWith(name: 'Updated Name', phone: '+91111');

      expect(updated.name, 'Updated Name');
      expect(updated.phone, '+91111');
      expect(updated.email, user.email);
      expect(updated.id, user.id);
    });

    test('copyWith preserves all values when no args given', () {
      final user = UserModel.fromJson(sampleJson);
      final copy = user.copyWith();

      expect(copy.id, user.id);
      expect(copy.name, user.name);
      expect(copy.email, user.email);
      expect(copy.phone, user.phone);
    });

    test('equality is based on id', () {
      final user1 = UserModel(
        id: 'abc',
        name: 'A',
        email: 'a@a.com',
        createdAt: now,
      );
      final user2 = UserModel(
        id: 'abc',
        name: 'B',
        email: 'b@b.com',
        createdAt: now,
      );

      expect(user1, equals(user2));
    });

    test('inequality when different ids', () {
      final user1 = UserModel(
        id: 'abc',
        name: 'A',
        email: 'a@a.com',
        createdAt: now,
      );
      final user2 = UserModel(
        id: 'def',
        name: 'A',
        email: 'a@a.com',
        createdAt: now,
      );

      expect(user1, isNot(equals(user2)));
    });

    test('toString contains name and email', () {
      final user = UserModel.fromJson(sampleJson);

      expect(user.toString(), contains('Mantej Singh'));
      expect(user.toString(), contains('mantej@example.com'));
    });
  });
}
