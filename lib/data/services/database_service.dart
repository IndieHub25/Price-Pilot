import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/errors/app_exceptions.dart' as errors;

/// Manages data persistence via Supabase and provides CRUD operations
/// for all entities: bookings, saved locations, search history,
/// and user preferences.
class DatabaseService {
  static DatabaseService? _instance;

  DatabaseService._();

  factory DatabaseService() {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// The Supabase client instance.
  SupabaseClient get _client => SupabaseConfig.client;

  // ---------------------------------------------------------------------------
  // Generic CRUD helpers
  // ---------------------------------------------------------------------------

  /// Inserts a row into the given table.
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      throw errors.DatabaseException(
        'Insert into $table failed',
        originalError: e,
      );
    }
  }

  /// Upserts a row (insert or update on conflict) into the given table.
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).upsert(data).select().single();
      return response;
    } catch (e) {
      throw errors.DatabaseException(
        'Upsert into $table failed',
        originalError: e,
      );
    }
  }

  /// Queries rows from a table with optional filters.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
    bool ascending = true,
  }) async {
    try {
      dynamic query = _client.from(table).select();

      // Apply where filters: expects pairs like "column = ?" with whereArgs
      if (where != null && whereArgs != null) {
        final conditions = _parseWhere(where, whereArgs);
        for (final condition in conditions) {
          query = query.eq(condition['column'] as String, condition['value']);
        }
      }

      if (orderBy != null) {
        // Handle "column DESC" or "column ASC" or just "column"
        final parts = orderBy.trim().split(RegExp(r'\s+'));
        final column = parts[0];
        final asc = parts.length > 1
            ? parts[1].toUpperCase() != 'DESC'
            : ascending;
        query = query.order(column, ascending: asc);
      }

      if (limit != null) {
        final start = offset ?? 0;
        final end = start + limit - 1;
        query = query.range(start, end);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw errors.DatabaseException(
        'Query on $table failed',
        originalError: e,
      );
    }
  }

  /// Updates rows matching the filter criteria.
  Future<void> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      dynamic query = _client.from(table).update(data);

      if (where != null && whereArgs != null) {
        final conditions = _parseWhere(where, whereArgs);
        for (final condition in conditions) {
          query = query.eq(condition['column'] as String, condition['value']);
        }
      }

      await query;
    } catch (e) {
      throw errors.DatabaseException(
        'Update on $table failed',
        originalError: e,
      );
    }
  }

  /// Deletes rows matching the filter criteria.
  Future<void> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      dynamic query = _client.from(table).delete();

      if (where != null && whereArgs != null) {
        final conditions = _parseWhere(where, whereArgs);
        for (final condition in conditions) {
          query = query.eq(condition['column'] as String, condition['value']);
        }
      }

      await query;
    } catch (e) {
      throw errors.DatabaseException(
        'Delete on $table failed',
        originalError: e,
      );
    }
  }

  /// Deletes all data from all application tables.
  /// Used for testing and account reset.
  Future<void> clearAll() async {
    // Supabase requires at least one filter for delete.
    // Use neq on id to match all rows.
    await _client.from('preferences').delete().neq('id', '');
    await _client.from('search_history').delete().neq('id', '');
    await _client.from('saved_locations').delete().neq('id', '');
    await _client.from('bookings').delete().neq('id', '');
    await _client.from('users').delete().neq('id', '');
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Parses a simplified SQL-style WHERE clause into column/value pairs.
  ///
  /// Supports: "col1 = ? AND col2 = ?" with positional args.
  /// For simple equality-only filters used throughout this app.
  List<Map<String, dynamic>> _parseWhere(
    String where,
    List<dynamic> whereArgs,
  ) {
    final parts = where.split(RegExp(r'\s+AND\s+', caseSensitive: false));
    final conditions = <Map<String, dynamic>>[];

    for (var i = 0; i < parts.length && i < whereArgs.length; i++) {
      final part = parts[i].trim();
      // Extract column name from "column = ?" or "column < ?"
      final match = RegExp(r'(\w+)\s*=\s*\?').firstMatch(part);
      if (match != null) {
        conditions.add({'column': match.group(1), 'value': whereArgs[i]});
      }
    }

    return conditions;
  }
}
