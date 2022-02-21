import 'package:database_repository/database_repository.dart';
import 'package:supabase/supabase.dart';
import '../../supabase_repository.dart';

/// The Database Adapter for supabase
///
/// WARNING: Supabase uses PostgreSQL which like MySQL relies on predefined
/// tables.
class SupabaseDatabaseAdapter extends DatabaseAdapter with QueryExecutor {
  @override
  final String name;

  /// The URL where supabase is running on
  final String supabaseInstallationUrl;

  /// The api key that is used to comunicate with supabase
  final String supabaseApiKey;

  /// On which schema the adapter should operate.
  final String? supabaseSchema;

  late SupabaseClient _client;

  /// The Database Adapter for supabase
  ///
  /// WARNING: Supabase uses PostgreSQL which like MySQL relies on predefined
  /// tables.
  SupabaseDatabaseAdapter({
    required this.supabaseInstallationUrl,
    required this.supabaseApiKey,
    this.name = 'supabase',
    this.supabaseSchema,
  }) {
    _client = SupabaseClient(
      supabaseInstallationUrl,
      supabaseApiKey,
      schema: supabaseSchema,
    );
  }

  @override
  Future<QueryResult> executeQuery(Query query) {
    switch (query.action) {
      case QueryAction.create:
        return create(query, _client);
      case QueryAction.delete:
        return delete(query, _client);
      case QueryAction.read:
        return read(query, _client);
      case QueryAction.update:
        return update(query, _client);
    }
  }
}
